# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Note: This ebuild was written 05-Jul-12 for wxlauncher-0.9.0
# The wxWidgets and Python restrictions might not apply in
# future versions.

# wxLauncher only works with Python 2.6+ but not 3.x
PYTHON_DEPEND="2:2.6"
PYTHON_USE_WITH="sqlite"

EAPI=2
inherit cmake-utils
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

DESCRIPTION="Cross-Platform Launcher for the FreeSpace 2 Open engine"
SRC_URI="http://wxlauncher.googlecode.com/files/wxlauncher-${V}-source.tbz2"
HOMEPAGE="http://code.google.com/p/wxlauncher/"
LICENSE="GPL-2"

SLOT=0
IUSE="+openal"

# Because package name is fs2-wxlauncher, we have to set the source directory manually
S=${WORKDIR}/wxlauncher-${V}

# wxLauncher isn't compatible with wxWidgets 2.9
RDEPEND=">=x11-libs/wxGTK-2.8.10:2.8[X,sdl]
		 >=media-libs/libsdl-1.2
		 dev-python/markdown
		 openal? ( media-libs/openal )"

# We also need CMake for building
DEPEND="${RDEPEND}
		 >=dev-util/cmake-2.8"


src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr/local
		$(cmake-utils_use_use openal OPENAL)
	)
	cmake-utils_src_configure
}

# Not sure if required...
src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
