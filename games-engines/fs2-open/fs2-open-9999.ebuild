# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit games subversion

DESCRIPTION="FreeSpace Open - The FreeSpace engine improved by the SCP"
HOMEPAGE="http://scp.indiegames.us"
ESVN_REPO_URI="svn://svn.icculus.org/fs2open/trunk/fs2_open/"

LICENSE="fs2_open"
SLOT="9999"
KEYWORDS="~x86 ~amd64"
IUSE="+inferno static-libs speech gprof debug"


# Note: as far as i know, SDL in FSO is only used for events handling so we dont
# need to check for X/opengl/audio/alsa useflags
# Didn't put all the X11 libs here, they should be catched by everything else...
RDEPEND="
	>=media-libs/openal-1.1
	>=media-libs/libsdl-1.2
	media-libs/mesa
	media-libs/alsa-lib
	virtual/opengl

	dev-lang/lua
	
	!static-libs? (
					media-libs/libogg
					media-libs/libvorbis 
					media-libs/libtheora
					media-libs/libpng
					media-libs/jpeg:62
				  )
"

DEPEND="${RDEPEND}"

src_configure() {
	# Make sure the bootstrapping script is executable
	chmod u+x ${S}/autogen.sh
	# Remove possible previous binaries in case we're using portage's KEEPWORK
	rm -f ${S}/code/fs2_open_*
	# Generate configure (This should use subversion eclass bootstrapping)
	env NOCONFIGURE=1 ./autogen.sh || die "Bootstrapping failed !" 
	# Actually configure the source
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

	# Finds the generated binary and rename it to something more fitting for
	# bleeding edge version. Anyone who knows how to use sed fix this.
	subversion_wc_info
	fs2bin_old=`find -name "fs2_open_*"`
	fs2bin_new=`echo $fs2bin_old | sed "s/\(fs2_open.*_\).*$/\1r${ESVN_WC_REVISION}/"`
	
	# Generate directory structure
	# REMEMBER, we are only instaling in the sandbox for now, so use ${D} !
	gameroot="${GAMES_PREFIX_OPT}/fs2_open"
	mkdir -p "${D}/${gameroot}/bin"

	# Copies the binary in game folder
	cp "$fs2bin_old" "${D}/${gameroot}/bin/${fs2bin_new}"

	# Correct permissions: make everything owned by the games group
	chown -R games:games "${D}"
	chmod g+x "${D}/{$gameroot}/bin/${fs2bin_new}"
}

pkg_postinst() {
	# User warning concerning the game engine
	elog \
"Revision ${ESVN_WC_REVISION} of FreeSpace Open's trunk was built in 
${gameroot}/bin. Please note that this is only the binary portion of 
the engine, you also need data files from the original game, 
or total conversions !"

	# Now that we're out of the sandbox,
	# and portage merged the binary, we can update the SVN symlink
	if [[ -L "${gameroot}/bin/fs2_open_SVN" ]]; then
		rm -f "${gameroot}/bin/fs2_open_SVN";
	fi
	ln -s "${gameroot}/bin/${fs2bin_new}" "${gameroot}/bin/fs2_open_SVN"
	chmod g+x "${gameroot}/bin/fs2_open_SVN"
}
