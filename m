Return-Path: linux-nfs-owner@vger.kernel.org
Received: from kawka.in.waw.pl ([178.63.212.103]:35410 "EHLO kawka.in.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751189AbaKWDEU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Nov 2014 22:04:20 -0500
Date: Sun, 23 Nov 2014 03:24:38 +0100
From: Zbigniew =?utf-8?Q?J=C4=99drzejewski-Szmek?= <zbyszek@in.waw.pl>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        systemd-devel@lists.freedesktop.org
Subject: Re: [systemd-devel] [PATCH] rpcbind: add support for systemd
 socket activation
Message-ID: <20141123022438.GK18247@in.waw.pl>
References: <1416588227-17245-1-git-send-email-steved@redhat.com>
 <1416588227-17245-2-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1416588227-17245-2-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 21, 2014 at 11:43:47AM -0500, Steve Dickson wrote:
> From: Tom Gundersen <teg@jklm.no>
> 
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
> Systemd now provides a shared library, and it is (or very soon will
> be) the default init system on all the major Linux distributions.
> 
> This version of the patch has three changes from the original:
> 
>  * It uses the shared library.
>  * It comes with unit files.
>  * It is rebased on top of master.
> 
> Please review the patch with "git show -b" or otherwise ignoring the
> whitespace changes, or it will be extremely difficult to read.

Thanks for working on this... Looks fine to me. Two suggestions
below.

> v4: reorganized the changes to make the diff easier to read
>     remove systemd scripts.
> 
> v3: rebase
>     fix typos
>     listen on /run/rpcbind.sock, rather than /var/run/rpcbind.sock (the
>     latter is a symlink to the former, but this means the socket can be
>     created before /var is mounted)
>     NB: this version has been compile-tested only as I no longer use
>     rpcbind myself
> v2: correctly enable systemd code at compile time
>     handle the case where not all the required sockets were supplied
>     listen on udp/tcp port 111 in addition to /var/run/rpcbind.sock
>     do not daemonize
> 
> Original-patch-by: Lennart Poettering <lennart@poettering.net>
> Cc: Steve Dickson <steved@redhat.com>
> Cc: systemd-devel@lists.freedesktop.org
> Acked-by: Cristian Rodríguez<crrodriguez@opensuse.org>
> Signed-off-by: Tom Gundersen <teg@jklm.no>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  Makefile.am   |  6 +++++
>  configure.ac  | 10 ++++++++
>  src/rpcbind.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
>  3 files changed, 91 insertions(+), 6 deletions(-)
> 
> diff --git a/Makefile.am b/Makefile.am
> index 8715082..c99566d 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -41,6 +41,12 @@ rpcbind_SOURCES = \
>  	src/warmstart.c
>  rpcbind_LDADD = $(TIRPC_LIBS)
>  
> +if SYSTEMD
> +AM_CPPFLAGS += $(SYSTEMD_CFLAGS) -DSYSTEMD
> +
> +rpcbind_LDADD += $(SYSTEMD_LIBS)
> +endif
> +
>  rpcinfo_SOURCES =       src/rpcinfo.c
>  rpcinfo_LDADD   =       $(TIRPC_LIBS)
>  
> diff --git a/configure.ac b/configure.ac
> index 5a88cc7..fdad639 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -36,6 +36,16 @@ AC_SUBST([nss_modules], [$with_nss_modules])
>  
>  PKG_CHECK_MODULES([TIRPC], [libtirpc])
>  
> +PKG_PROG_PKG_CONFIG
> +AC_ARG_WITH([systemdsystemunitdir],
> +  AS_HELP_STRING([--with-systemdsystemunitdir=DIR], [Directory for systemd service files]),
> +  [], [with_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd)])
> +  if test "x$with_systemdsystemunitdir" != xno; then
> +    AC_SUBST([systemdsystemunitdir], [$with_systemdsystemunitdir])
> +    PKG_CHECK_MODULES([SYSTEMD], [libsystemd-daemon])
libsystemd-daemon got subsummed by libsystemd. So you should use something
like

   PKG_CHECK_MODULES([SYSTEMD], [libsystemd], [],
      [PKG_CHECK_MODULES([SYSTEMD], [libsystemd-daemon], [],
       AC_MSG_ERROR([libsystemd support requested but found]))])

to get the new libary in preference to the old one.

> +  fi
> +AM_CONDITIONAL(SYSTEMD, [test -n "$with_systemdsystemunitdir" -a "x$with_systemdsystemunitdir" != xno ])
> +
>  AS_IF([test x$enable_libwrap = xyes], [
>  	AC_CHECK_LIB([wrap], [hosts_access], ,
>  		AC_MSG_ERROR([libwrap support requested but unable to find libwrap]))
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index e3462e3..f7c71ee 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -56,6 +56,9 @@
>  #include <netinet/in.h>
>  #endif
>  #include <arpa/inet.h>
> +#ifdef SYSTEMD
> +#include <systemd/sd-daemon.h>
> +#endif
>  #include <fcntl.h>
>  #include <netdb.h>
>  #include <stdio.h>
> @@ -296,6 +299,7 @@ init_transport(struct netconfig *nconf)
>  	u_int32_t host_addr[4];  /* IPv4 or IPv6 */
>  	struct sockaddr_un sun;
>  	mode_t oldmask;
> +	int n;
>          res = NULL;
>  
>  	if ((nconf->nc_semantics != NC_TPI_CLTS) &&
> @@ -314,6 +318,76 @@ init_transport(struct netconfig *nconf)
>  			fprintf(stderr, "[%d] - %s\n", i, *s);
>  	}
>  #endif
> +	if (!__rpc_nconf2sockinfo(nconf, &si)) {
> +		syslog(LOG_ERR, "cannot get information for %s",
> +		    nconf->nc_netid);
> +		return (1);
> +	}
> +
> +#ifdef SYSTEMD
> +	n = sd_listen_fds(0);
> +	if (n < 0) {
> +		syslog(LOG_ERR, "failed to acquire systemd sockets: %s", strerror(-n));
> +		return 1;
> +	}
> +
> +	/* Try to find if one of the systemd sockets we were given match
> +	 * our netconfig structure. */
> +
> +	for (fd = SD_LISTEN_FDS_START; fd < SD_LISTEN_FDS_START + n; fd++) {
> +		struct __rpc_sockinfo si_other;
> +		union {
> +			struct sockaddr sa;
> +			struct sockaddr_un un;
> +			struct sockaddr_in in4;
> +			struct sockaddr_in6 in6;
> +			struct sockaddr_storage storage;
> +		} sa;
> +		socklen_t addrlen = sizeof(sa);
> +
> +		if (!__rpc_fd2sockinfo(fd, &si_other)) {
> +			syslog(LOG_ERR, "cannot get information for fd %i", fd);
> +			return 1;
> +		}
> +
> +		if (si.si_af != si_other.si_af ||
> +                    si.si_socktype != si_other.si_socktype ||
> +                    si.si_proto != si_other.si_proto)
> +			continue;
If I understand correctly, this ignores the socket if it is 
different than expected. Shouldn't this result in an error instead?

> +
> +		if (getsockname(fd, &sa.sa, &addrlen) < 0) {
> +			syslog(LOG_ERR, "failed to query socket name: %s",
> +                               strerror(errno));
> +			goto error;
> +		}
> +
> +		/* Copy the address */
> +		taddr.addr.maxlen = taddr.addr.len = addrlen;
> +		taddr.addr.buf = malloc(addrlen);
> +		if (taddr.addr.buf == NULL) {
> +			syslog(LOG_ERR,
> +                               "cannot allocate memory for %s address",
> +                               nconf->nc_netid);
> +			goto error;
> +		}
> +		memcpy(taddr.addr.buf, &sa, addrlen);
> +
> +		my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf, &taddr,
> +                          RPC_MAXDATASIZE, RPC_MAXDATASIZE);
> +		if (my_xprt == (SVCXPRT *)NULL) {
> +			syslog(LOG_ERR, "%s: could not create service",
> +                               nconf->nc_netid);
> +			goto error;
> +		}
> +	}
> +
> +	/*
> +	 * If none of the systemd sockets matched, we set up the socket in
> +	 * the normal way:
> +	 */
> +#endif
> +	if (my_xprt != NULL)
> +		goto got_socket;
>  
>  	/*
>  	 * XXX - using RPC library internal functions. For NC_TPI_CLTS
> @@ -327,12 +401,6 @@ init_transport(struct netconfig *nconf)
>  		}
>  	}
>  
> -	if (!__rpc_nconf2sockinfo(nconf, &si)) {
> -		syslog(LOG_ERR, "cannot get information for %s",
> -		    nconf->nc_netid);
> -		return (1);
> -	}
> -
>  	if ((strcmp(nconf->nc_netid, "local") == 0) ||
>  	    (strcmp(nconf->nc_netid, "unix") == 0)) {
>  		memset(&sun, 0, sizeof sun);
> @@ -569,6 +637,7 @@ init_transport(struct netconfig *nconf)
>  			goto error;
>  		}
>  	}
> +got_socket:
>  
>  #ifdef PORTMAP
>  	/*

Zbyszek
