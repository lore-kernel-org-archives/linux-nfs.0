Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47607 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755406Ab2BCK6x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Feb 2012 05:58:53 -0500
Message-ID: <1328266709.2233.12.camel@perseus.themaw.net>
Subject: Re: [Libtirpc-devel] [PATCH] rpcbind: add support for systemd
 socket activation
From: Ian Kent <ikent@redhat.com>
To: Tom Gundersen <teg@jklm.no>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Lennart Poettering <lennart@poettering.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Michal Schmidt <mschmidt@redhat.com>,
        systemd-devel@lists.freedesktop.org,
        libtirpc <libtirpc-devel@lists.sourceforge.net>
Date: Fri, 03 Feb 2012 18:58:29 +0800
In-Reply-To: <CAG-2HqVC3k+vmO2ieARqrKFEuP1RWZmBZ63J088DvBzSh2EdMA@mail.gmail.com>
References: <1324602327-1789-1-git-send-email-teg@jklm.no>
	 <1328096830-1383-1-git-send-email-teg@jklm.no>
	 <22B77A95-49D5-4855-A230-A86C57372B28@oracle.com>
	 <CAG-2HqVC3k+vmO2ieARqrKFEuP1RWZmBZ63J088DvBzSh2EdMA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-02-01 at 17:37 +0100, Tom Gundersen wrote:
> Hi Chuck,
> 
> Thanks for the feedback.
> 
> On Wed, Feb 1, 2012 at 4:32 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > Typically this is done by breaking the proposed change into smaller atomic patches.  Is that not possible in this case?
> 
> Not entirely sure what you have in mind, I don't immediately see how
> to split this up. Any suggestions welcome.

You could pull out just the socket handling code.

SYSTEMD then is not defined so you can test that things still work the
same without configure changes. Then add the configure changes and
introduce the unit file.

I know the bulk of the change is in fact the socket handling and that
seems somewhat more significant than in the original patch that was
referred to. I can't tell why, perhaps because I never saw the first
post, since it wasn't sent to the libtirpc mailing list.

This division might then show other opportunities to divide the socket
handling code.

It may seem excessive but I have "never" had a patch(es) (that hasn't
been broken down into bits that were easier to review) that didn't cause
me pain later down the track. It's true that doing this doesn't mean any
bugs will always be caught but there is a better chance.

> 
> >> Added Michal to cc as this patch should go a long way to sort out
> >> <https://bugzilla.redhat.com/show_bug.cgi?id=747363>.
> >
> > Wouldn't comment 3 also work around problems long enough to give us an opportunity to adequately vet the proposed changes?
> 
> Sure, that's another option.
> 
> > What additions to our test matrix are needed?
> 
> I could not find any tests in the rpcbind git repo. Could you point me
> at your test matrix?
> 
> >> +     /* Try to find if one of the systemd sockets we were given match
> >> +      * our netconfig structure. */
> >> +
> >> +     for (fd = SD_LISTEN_FDS_START; fd < SD_LISTEN_FDS_START + n; fd++) {
> >> +             struct __rpc_sockinfo si_other;
> >> +             union {
> >> +                     struct sockaddr sa;
> >> +                     struct sockaddr_un un;
> >> +                     struct sockaddr_in in4;
> >> +                     struct sockaddr_in6 in6;
> >> +                     struct sockaddr_storage storage;
> >> +             } sa;
> >
> > Why is sockaddr_storage included in this union?
> 
> This is from Lennart's original patch. Lennart, care to comment?
> 
> For what it's worth, here is the patch with whitespace ignored, which
> should make it simpler to review:
> 
> 
> diff --git a/Makefile.am b/Makefile.am
> index 9fa608e..194b467 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -38,6 +38,21 @@ rpcbind_SOURCES = \
>  	src/warmstart.c
>  rpcbind_LDADD = $(TIRPC_LIBS)
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
>  rpcinfo_SOURCES =       src/rpcinfo.c
>  rpcinfo_LDADD   =       $(TIRPC_LIBS)
> 
> diff --git a/configure.in b/configure.in
> index 2b67720..397d52d 100644
> --- a/configure.in
> +++ b/configure.in
> @@ -29,6 +29,17 @@ AC_SUBST([rpcuser], [$with_rpcuser])
> 
>  PKG_CHECK_MODULES([TIRPC], [libtirpc])
> 
> +PKG_PROG_PKG_CONFIG
> +AC_ARG_WITH([systemdsystemunitdir],
> +  AS_HELP_STRING([--with-systemdsystemunitdir=DIR], [Directory for
> systemd service files]),
> +  [], [with_systemdsystemunitdir=$($PKG_CONFIG
> --variable=systemdsystemunitdir systemd)])
> +  if test "x$with_systemdsystemunitdir" != xno; then
> +    AC_SUBST([systemdsystemunitdir], [$with_systemdsystemunitdir])
> +    PKG_CHECK_MODULES([SYSTEMD], [libsystemd-daemon])
> +  fi
> +AM_CONDITIONAL(SYSTEMD, [test -n "$with_systemdsystemunitdir" -a
> "x$with_systemdsystemunitdir" != xno ])
> +
> +
>  AS_IF([test x$enable_libwrap = xyes], [
>  	AC_CHECK_LIB([wrap], [hosts_access], ,
>  		AC_MSG_ERROR([libwrap support requested but unable to find libwrap]))
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index 24e069b..a87ce05 100644
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
> @@ -281,6 +284,7 @@ init_transport(struct netconfig *nconf)
>  	u_int32_t host_addr[4];  /* IPv4 or IPv6 */
>  	struct sockaddr_un sun;
>  	mode_t oldmask;
> +	int n = 0;
>          res = NULL;
> 
>  	if ((nconf->nc_semantics != NC_TPI_CLTS) &&
> @@ -300,6 +304,76 @@ init_transport(struct netconfig *nconf)
>  	}
>  #endif
> 
> +	if (!__rpc_nconf2sockinfo(nconf, &si)) {
> +		syslog(LOG_ERR, "cannot get information for %s",
> +		    nconf->nc_netid);
> +		return (1);
> +	}
> +
> +#ifdef SYSTEMD
> +	n = sd_listen_fds(0);
> +	if (n < 0) {
> +		syslog(LOG_ERR, "failed to acquire systemd scokets: %s", strerror(-n));
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
> +	/* if none of the systemd sockets matched, we set up the socket in
> +	 * the normal way:
> +	 */
> +#endif
> +
> +	if(my_xprt == (SVCXPRT *)NULL) {
> +
>  	/*
>  	 * XXX - using RPC library internal functions. For NC_TPI_CLTS
>  	 * we call this later, for each socket we like to bind.
> @@ -312,12 +386,6 @@ init_transport(struct netconfig *nconf)
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
> @@ -554,6 +622,7 @@ init_transport(struct netconfig *nconf)
>  			goto error;
>  		}
>  	}
> +	}
> 
>  #ifdef PORTMAP
>  	/*
> diff --git a/systemd/.gitignore b/systemd/.gitignore
> new file mode 100644
> index 0000000..b7b4561
> --- /dev/null
> +++ b/systemd/.gitignore
> @@ -0,0 +1 @@
> +rpcbind.service
> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
> new file mode 100644
> index 0000000..58ae5de
> --- /dev/null
> +++ b/systemd/rpcbind.service.in
> @@ -0,0 +1,9 @@
> +[Unit]
> +Description=RPC Bind
> +
> +[Service]
> +ExecStart=@bindir@/rpcbind -w -f
> +
> +[Install]
> +WantedBy=multi-user.target
> +Also=rpcbind.socket
> diff --git a/systemd/rpcbind.socket b/systemd/rpcbind.socket
> new file mode 100644
> index 0000000..ad5fd62
> --- /dev/null
> +++ b/systemd/rpcbind.socket
> @@ -0,0 +1,12 @@
> +[Unit]
> +Description=RPCbind Server Activation Socket
> +Wants=rpcbind.target
> +Before=rpcbind.target
> +
> +[Socket]
> +ListenStream=/var/run/rpcbind.sock
> +ListenStream=111
> +ListenDatagram=111
> +
> +[Install]
> +WantedBy=sockets.target
> 
> ------------------------------------------------------------------------------
> Keep Your Developer Skills Current with LearnDevNow!
> The most comprehensive online learning library for Microsoft developers
> is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
> Metro Style Apps, more. Free future releases when you subscribe now!
> http://p.sf.net/sfu/learndevnow-d2d
> _______________________________________________
> Libtirpc-devel mailing list
> Libtirpc-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel


