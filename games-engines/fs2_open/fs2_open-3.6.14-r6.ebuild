# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit games

DESCRIPTION="FreeSpace Open - The FreeSpace engine improved by the SCP"
HOMEPAGE="http://scp.indiegames.us"
SRC_URI="http://swc.fs2downloads.com/builds/fs2_open_3_6_14_RC6_src.tgz"
S="${WORKDIR}/fs2_open_3_6_14_RC6"

LICENSE="fs2_open"
# All ebuilds sharing the same non-release version share the same slot
SLOT="${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="+inferno speech gprof debug"


# Note: as far as i know, SDL in FSO is only used for events handling so we dont
# need to check for X/opengl/audio/alsa useflags
# Didn't put all the X11 libs here, they should be catched by everything else...
RDEPEND="
	>=media-libs/openal-1.1
	>=media-libs/libsdl-1.2
	media-libs/mesa
	media-libs/alsa-lib
	media-libs/libpng
	virtual/opengl

	dev-lang/lua
"	

	# Source for those are included along the engine source,
	# and they can be statically linked using configure options
	#!static-libs? (
	#				media-libs/libogg
	#				media-libs/libvorbis 
	#				media-libs/libtheora
	#				media-libs/jpeg:62
	#			  )


DEPEND="${RDEPEND}"

src_configure() {
	# Remove possible previous binaries in case we're using portage's KEEPWORK
	rm -f ${S}/code/fs2_open_*
	# Bootstrap the source
	chmod u+x ${S}/autogen.sh
	env NOCONFIGURE=1 ./autogen.sh || die "Bootstrapping failed !"
							
	# Configure the source
	econf --disable-option-checking --enable-silent-rules --enable-wxfred2=no \
	--disable-dependency-tracking `use_enable inferno` `use_enable debug` \
	`use_enable speech` `use_enable gprof` || die "Econf failed !"
}

src_compile() {
	# Run the Makefile
	emake || die "Emake failed !"
}

src_install() {
	# We'll generally avoid using Portage's wrappers because what we want here
	# Is a custom installation into /opt rather than a generic software install

	cd code

	# Finds the generated binary (use a wildcard because name change with build)
	fs2bin=`find -name "fs2_open_*"`
	
	# Generate directory structure
	# REMEMBER, we are only instaling in the sandbox for now, so use ${D} !
	gameroot="${GAMES_PREFIX_OPT}/fs2_open"
	mkdir -p "${D}/${gameroot}/bin"

	# Copies the binary in game folder
	cp "$fs2bin" "${D}/${gameroot}/bin/${fs2bin}"

	# Correct permissions: make everything owned by the games group
	chown -R games:games "${D}"
	chmod g+x "${D}/{$gameroot}/bin/${fs2bin}"
}

pkg_postinst() {
	# User warning concerning the game engine
	elog \
"Version ${PV} of FreeSpace Open's trunk was built in 
${gameroot}/bin. Please note that this is only the binary portion of 
the engine, you also need data files from the original game, 
or total conversions !"
}
