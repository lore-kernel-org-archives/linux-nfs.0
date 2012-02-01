Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:26739 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932246Ab2BAUAH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 15:00:07 -0500
Subject: Re: [PATCH] rpcbind: add support for systemd socket activation
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=iso-8859-1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1328096830-1383-1-git-send-email-teg@jklm.no>
Date: Wed, 1 Feb 2012 14:59:53 -0500
Cc: linux-nfs@vger.kernel.org, Michal Schmidt <mschmidt@redhat.com>,
        Steve Dickson <steved@redhat.com>, systemd-devel@lists.freedesktop.org
Message-Id: <387B63A5-88EC-45CE-AB20-48DEAEE0D786@oracle.com>
References: <1324602327-1789-1-git-send-email-teg@jklm.no> <1328096830-1383-1-git-send-email-teg@jklm.no>
To: Tom Gundersen <teg@jklm.no>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

On Feb 1, 2012, at 6:47 AM, Tom Gundersen wrote:

> Making rpcbind sockect activated will greatly simplify
> its integration in systemd systems. In essence, other services
> may now assume that rpcbind is always available, even during very
> early boot. This means that we no longer need to worry about any
> ordering dependencies.
> 
> This is based on a patch originally posted by Lennart Poettering:
> <http://permalink.gmane.org/gmane.linux.nfs/33774>.
> 
> That patch was not merged due to the lack of a shared library and
> as systemd was seen to be too Fedora specific.
> 
> Systemd now provides a shared library, and it is shipped by defalt in
> OpenSUSE in addition to Fedora, and it is available in Debain, Gentoo,
> Arch, and others.
> 
> This version of the patch has three changes from the original:
> 
> * It uses the shared library.
> * It comes with unit files.
> * It is rebased on top of master.
> 
> Please review the patch with "git show -b" or otherwise ignoring the
> whitespace changes, or it will be extremely difficult to read.
> 
> Comments welcome.
> 
> v2: correctly enable systemd code at compile time
>    handle the case where not all the required sockets were supplied
>    listen on udp/tcp port 111 in addition to /var/run/rpcbind.sock
>    do not daemonize
> 
> Original-patch-by: Lennart Poettering <lennart@poettering.net>
> Cc: Michal Schmidt <mschmidt@redhat.com>
> Cc: Steve Dickson <steved@redhat.com>
> Cc: systemd-devel@lists.freedesktop.org
> Acked-by: Cristian Rodríguez<crrodriguez@opensuse.org>
> Signed-off-by: Tom Gundersen <teg@jklm.no>
> ---
> 
> What's the status on this?
> 
> Lennart, does your ack still appl after my changes?
> 
> Steve, any chance of applying this?
> 
> If this is applied I have a couple of follow ups. In particular, I'd like to
> do the cleanup of init_transport that Jim suggested as a separate patch,
> as leaving the line-wraps alone makes this patch easier to read I think.
> 
> Added Michal to cc as this patch should go a long way to sort out
> <https://bugzilla.redhat.com/show_bug.cgi?id=747363>.
> 
> Cheers,
> 
> Tom
> 
> Makefile.am                |   15 ++
> configure.in               |   11 +
> src/rpcbind.c              |  467 +++++++++++++++++++++++++-------------------
> systemd/.gitignore         |    1 +
> systemd/rpcbind.service.in |    9 +
> systemd/rpcbind.socket     |   12 ++
> 6 files changed, 316 insertions(+), 199 deletions(-)
> create mode 100644 systemd/.gitignore
> create mode 100644 systemd/rpcbind.service.in
> create mode 100644 systemd/rpcbind.socket
> 
> diff --git a/Makefile.am b/Makefile.am
> index 9fa608e..194b467 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -38,6 +38,21 @@ rpcbind_SOURCES = \
> 	src/warmstart.c
> rpcbind_LDADD = $(TIRPC_LIBS)
> 
> +if SYSTEMD
> +AM_CPPFLAGS += $(SYSTEMD_CFLAGS) -DSYSTEMD
> +
> +rpcbind_LDADD += $(SYSTEMD_LIBS)
> +
> +systemd/rpcbind.service: systemd/rpcbind.service.in Makefile
> +	sed -e 's,@bindir\@,$(bindir),g' \
> +		< $< > $@ || rm $@
> +
> +systemdsystemunit_DATA = \
> +	systemd/rpcbind.service \
> +	systemd/rpcbind.socket
> +
> +endif
> +
> rpcinfo_SOURCES =       src/rpcinfo.c
> rpcinfo_LDADD   =       $(TIRPC_LIBS)
> 
> diff --git a/configure.in b/configure.in
> index 2b67720..397d52d 100644
> --- a/configure.in
> +++ b/configure.in

If I do a "make distclean" I don't have a configure.in.  Should you be patching configure.ac instead?

> @@ -29,6 +29,17 @@ AC_SUBST([rpcuser], [$with_rpcuser])
> 
> PKG_CHECK_MODULES([TIRPC], [libtirpc])
> 
> +PKG_PROG_PKG_CONFIG
> +AC_ARG_WITH([systemdsystemunitdir],
> +  AS_HELP_STRING([--with-systemdsystemunitdir=DIR], [Directory for systemd service files]),
> +  [], [with_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd)])
> +  if test "x$with_systemdsystemunitdir" != xno; then
> +    AC_SUBST([systemdsystemunitdir], [$with_systemdsystemunitdir])
> +    PKG_CHECK_MODULES([SYSTEMD], [libsystemd-daemon])
> +  fi
> +AM_CONDITIONAL(SYSTEMD, [test -n "$with_systemdsystemunitdir" -a "x$with_systemdsystemunitdir" != xno ])
> +
> +
> AS_IF([test x$enable_libwrap = xyes], [
> 	AC_CHECK_LIB([wrap], [hosts_access], ,
> 		AC_MSG_ERROR([libwrap support requested but unable to find libwrap]))
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




