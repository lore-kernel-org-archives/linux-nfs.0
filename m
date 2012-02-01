Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:50641 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155Ab2BAPdM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 10:33:12 -0500
Subject: Re: [PATCH] rpcbind: add support for systemd socket activation
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=iso-8859-1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1328096830-1383-1-git-send-email-teg@jklm.no>
Date: Wed, 1 Feb 2012 10:32:45 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Michal Schmidt <mschmidt@redhat.com>,
        Steve Dickson <steved@redhat.com>, systemd-devel@lists.freedesktop.org,
        libtirpc <libtirpc-devel@lists.sourceforge.net>
Message-Id: <22B77A95-49D5-4855-A230-A86C57372B28@oracle.com>
References: <1324602327-1789-1-git-send-email-teg@jklm.no> <1328096830-1383-1-git-send-email-teg@jklm.no>
To: Tom Gundersen <teg@jklm.no>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adding libtirpc developers mailing list...

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

Typically this is done by breaking the proposed change into smaller atomic patches.  Is that not possible in this case?

I can play with this more later today or tomorrow.

> Added Michal to cc as this patch should go a long way to sort out
> <https://bugzilla.redhat.com/show_bug.cgi?id=747363>.

Wouldn't comment 3 also work around problems long enough to give us an opportunity to adequately vet the proposed changes?

What additions to our test matrix are needed?

One more immediate comment below.

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
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index 24e069b..a87ce05 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -56,6 +56,9 @@
> #include <netinet/in.h>
> #endif
> #include <arpa/inet.h>
> +#ifdef SYSTEMD
> +#include <systemd/sd-daemon.h>
> +#endif
> #include <fcntl.h>
> #include <netdb.h>
> #include <stdio.h>
> @@ -281,6 +284,7 @@ init_transport(struct netconfig *nconf)
> 	u_int32_t host_addr[4];  /* IPv4 or IPv6 */
> 	struct sockaddr_un sun;
> 	mode_t oldmask;
> +	int n = 0;
>         res = NULL;
> 
> 	if ((nconf->nc_semantics != NC_TPI_CLTS) &&
> @@ -300,141 +304,285 @@ init_transport(struct netconfig *nconf)
> 	}
> #endif
> 
> -	/*
> -	 * XXX - using RPC library internal functions. For NC_TPI_CLTS
> -	 * we call this later, for each socket we like to bind.
> -	 */
> -	if (nconf->nc_semantics != NC_TPI_CLTS) {
> -		if ((fd = __rpc_nconf2fd(nconf)) < 0) {
> -			syslog(LOG_ERR, "cannot create socket for %s",
> -			    nconf->nc_netid);
> -			return (1);
> -		}
> -	}
> -
> 	if (!__rpc_nconf2sockinfo(nconf, &si)) {
> 		syslog(LOG_ERR, "cannot get information for %s",
> 		    nconf->nc_netid);
> 		return (1);
> 	}
> 
> -	if ((strcmp(nconf->nc_netid, "local") == 0) ||
> -	    (strcmp(nconf->nc_netid, "unix") == 0)) {
> -		memset(&sun, 0, sizeof sun);
> -		sun.sun_family = AF_LOCAL;
> -		unlink(_PATH_RPCBINDSOCK);
> -		strcpy(sun.sun_path, _PATH_RPCBINDSOCK);
> -		addrlen = SUN_LEN(&sun);
> -		sa = (struct sockaddr *)&sun;
> -	} else {
> -		/* Get rpcbind's address on this transport */
> -
> -		memset(&hints, 0, sizeof hints);
> -		hints.ai_flags = AI_PASSIVE;
> -		hints.ai_family = si.si_af;
> -		hints.ai_socktype = si.si_socktype;
> -		hints.ai_protocol = si.si_proto;
> +#ifdef SYSTEMD
> +	n = sd_listen_fds(0);
> +	if (n < 0) {
> +		syslog(LOG_ERR, "failed to acquire systemd scokets: %s", strerror(-n));
> +		return 1;
> 	}
> -	if (nconf->nc_semantics == NC_TPI_CLTS) {
> -		/*
> -		 * If no hosts were specified, just bind to INADDR_ANY.  Otherwise
> -		 * make sure 127.0.0.1 is added to the list.
> -		 */
> -		nhostsbak = nhosts;
> -		nhostsbak++;
> -		hosts = realloc(hosts, nhostsbak * sizeof(char *));
> -		if (nhostsbak == 1)
> -			hosts[0] = "*";
> -		else {
> -			if (hints.ai_family == AF_INET) {
> -				hosts[nhostsbak - 1] = "127.0.0.1";
> -			} else if (hints.ai_family == AF_INET6) {
> -				hosts[nhostsbak - 1] = "::1";
> -			} else
> -				return 1;
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

Why is sockaddr_storage included in this union?

> +		socklen_t addrlen = sizeof(sa);
> +
> +		if (!__rpc_fd2sockinfo(fd, &si_other)) {
> +			syslog(LOG_ERR, "cannot get information for fd %i", fd);
> +			return 1;
> 		}
> 
> -	       /*
> -		* Bind to specific IPs if asked to
> -		*/
> -		checkbind = 0;
> -		while (nhostsbak > 0) {
> -			--nhostsbak;
> -			/*
> -			 * XXX - using RPC library internal functions.
> -			 */
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
> +		/*
> +		 * XXX - using RPC library internal functions. For NC_TPI_CLTS
> +		 * we call this later, for each socket we like to bind.
> +		 */
> +		if (nconf->nc_semantics != NC_TPI_CLTS) {
> 			if ((fd = __rpc_nconf2fd(nconf)) < 0) {
> 				syslog(LOG_ERR, "cannot create socket for %s",
> 				    nconf->nc_netid);
> 				return (1);
> 			}
> -			switch (hints.ai_family) {
> -			case AF_INET:
> -				if (inet_pton(AF_INET, hosts[nhostsbak],
> -				    host_addr) == 1) {
> -					hints.ai_flags &= AI_NUMERICHOST;
> -				} else {
> -					/*
> -					 * Skip if we have an AF_INET6 adress.
> -					 */
> -					if (inet_pton(AF_INET6,
> -					    hosts[nhostsbak], host_addr) == 1)
> -						continue;
> +		}
> +
> +		if ((strcmp(nconf->nc_netid, "local") == 0) ||
> +		    (strcmp(nconf->nc_netid, "unix") == 0)) {
> +			memset(&sun, 0, sizeof sun);
> +			sun.sun_family = AF_LOCAL;
> +			unlink(_PATH_RPCBINDSOCK);
> +			strcpy(sun.sun_path, _PATH_RPCBINDSOCK);
> +			addrlen = SUN_LEN(&sun);
> +			sa = (struct sockaddr *)&sun;
> +		} else {
> +			/* Get rpcbind's address on this transport */
> +
> +			memset(&hints, 0, sizeof hints);
> +			hints.ai_flags = AI_PASSIVE;
> +			hints.ai_family = si.si_af;
> +			hints.ai_socktype = si.si_socktype;
> +			hints.ai_protocol = si.si_proto;
> +		}
> +		if (nconf->nc_semantics == NC_TPI_CLTS) {
> +			/*
> +			 * If no hosts were specified, just bind to INADDR_ANY.  Otherwise
> +			 * make sure 127.0.0.1 is added to the list.
> +			 */
> +			nhostsbak = nhosts;
> +			nhostsbak++;
> +			hosts = realloc(hosts, nhostsbak * sizeof(char *));
> +			if (nhostsbak == 1)
> +				hosts[0] = "*";
> +			else {
> +				if (hints.ai_family == AF_INET) {
> +					hosts[nhostsbak - 1] = "127.0.0.1";
> +				} else if (hints.ai_family == AF_INET6) {
> +					hosts[nhostsbak - 1] = "::1";
> +				} else
> +					return 1;
> +			}
> +
> +		       /*
> +			* Bind to specific IPs if asked to
> +			*/
> +			checkbind = 0;
> +			while (nhostsbak > 0) {
> +				--nhostsbak;
> +				/*
> +				 * XXX - using RPC library internal functions.
> +				 */
> +				if ((fd = __rpc_nconf2fd(nconf)) < 0) {
> +					syslog(LOG_ERR, "cannot create socket for %s",
> +					    nconf->nc_netid);
> +					return (1);
> +				}
> +				switch (hints.ai_family) {
> +				case AF_INET:
> +					if (inet_pton(AF_INET, hosts[nhostsbak],
> +					    host_addr) == 1) {
> +						hints.ai_flags &= AI_NUMERICHOST;
> +					} else {
> +						/*
> +						 * Skip if we have an AF_INET6 adress.
> +						 */
> +						if (inet_pton(AF_INET6,
> +						    hosts[nhostsbak], host_addr) == 1)
> +							continue;
> +					}
> +					break;
> +				case AF_INET6:
> +					if (inet_pton(AF_INET6, hosts[nhostsbak],
> +					    host_addr) == 1) {
> +						hints.ai_flags &= AI_NUMERICHOST;
> +					} else {
> +						/*
> +						 * Skip if we have an AF_INET adress.
> +						 */
> +						if (inet_pton(AF_INET, hosts[nhostsbak],
> +						    host_addr) == 1)
> +							continue;
> +					}
> +					break;
> +				default:
> +					break;
> 				}
> -				break;
> -			case AF_INET6:
> -				if (inet_pton(AF_INET6, hosts[nhostsbak],
> -				    host_addr) == 1) {
> -					hints.ai_flags &= AI_NUMERICHOST;
> -				} else {
> +
> +				/*
> +				 * If no hosts were specified, just bind to INADDR_ANY
> +				 */
> +				if (strcmp("*", hosts[nhostsbak]) == 0)
> +					hosts[nhostsbak] = NULL;
> +
> +				if ((aicode = getaddrinfo(hosts[nhostsbak],
> +				    servname, &hints, &res)) != 0) {
> +				  if ((aicode = getaddrinfo(hosts[nhostsbak],
> +							    "portmapper", &hints, &res)) != 0) {
> +					syslog(LOG_ERR,
> +					    "cannot get local address for %s: %s",
> +					    nconf->nc_netid, gai_strerror(aicode));
> +					continue;
> +				  }
> +				}
> +				addrlen = res->ai_addrlen;
> +				sa = (struct sockaddr *)res->ai_addr;
> +				oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
> +				if (bind(fd, sa, addrlen) != 0) {
> +					syslog(LOG_ERR, "cannot bind %s on %s: %m",
> +						(hosts[nhostsbak] == NULL) ? "*" :
> +						hosts[nhostsbak], nconf->nc_netid);
> +					if (res != NULL)
> +						freeaddrinfo(res);
> +					continue;
> +				} else
> +					checkbind++;
> +				(void) umask(oldmask);
> +
> +				/* Copy the address */
> +				taddr.addr.maxlen = taddr.addr.len = addrlen;
> +				taddr.addr.buf = malloc(addrlen);
> +				if (taddr.addr.buf == NULL) {
> +					syslog(LOG_ERR,
> +					    "cannot allocate memory for %s address",
> +					    nconf->nc_netid);
> +					if (res != NULL)
> +						freeaddrinfo(res);
> +					return 1;
> +				}
> +				memcpy(taddr.addr.buf, sa, addrlen);
> +#ifdef RPCBIND_DEBUG
> +				if (debugging) {
> 					/*
> -					 * Skip if we have an AF_INET adress.
> +					 * for debugging print out our universal
> +					 * address
> 					 */
> -					if (inet_pton(AF_INET, hosts[nhostsbak],
> -					    host_addr) == 1)
> -						continue;
> +					char *uaddr;
> +					struct netbuf nb;
> +					int sa_size = 0;
> +
> +					nb.buf = sa;
> +					switch( sa->sa_family){
> +					case AF_INET:
> +					  sa_size = sizeof (struct sockaddr_in);
> +					  break;
> +					case AF_INET6:
> +					  sa_size = sizeof (struct sockaddr_in6);
> +					  break;
> +					}
> +					nb.len = nb.maxlen = sa_size;
> +					uaddr = taddr2uaddr(nconf, &nb);
> +					(void) fprintf(stderr,
> +					    "rpcbind : my address is %s\n", uaddr);
> +					(void) free(uaddr);
> +				}
> +#endif
> +				my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf, &taddr,
> +                                          RPC_MAXDATASIZE, RPC_MAXDATASIZE);
> +				if (my_xprt == (SVCXPRT *)NULL) {
> +					syslog(LOG_ERR, "%s: could not create service",
> +                                               nconf->nc_netid);
> +					goto error;
> 				}
> -	        		break;
> -			default:
> -				break;
> 			}
> -
> -			/*
> -			 * If no hosts were specified, just bind to INADDR_ANY
> -			 */
> -			if (strcmp("*", hosts[nhostsbak]) == 0)
> -				hosts[nhostsbak] = NULL;
> -
> -			if ((aicode = getaddrinfo(hosts[nhostsbak],
> -			    servname, &hints, &res)) != 0) {
> -			  if ((aicode = getaddrinfo(hosts[nhostsbak],
> -						    "portmapper", &hints, &res)) != 0) {
> -				syslog(LOG_ERR,
> -				    "cannot get local address for %s: %s",
> -				    nconf->nc_netid, gai_strerror(aicode));
> -				continue;
> -			  }
> +			if (!checkbind)
> +				return 1;
> +		} else {	/* NC_TPI_COTS */
> +			if ((strcmp(nconf->nc_netid, "local") != 0) &&
> +			    (strcmp(nconf->nc_netid, "unix") != 0)) {
> +				if ((aicode = getaddrinfo(NULL, servname, &hints, &res))!= 0) {
> +				  if ((aicode = getaddrinfo(NULL, "portmapper", &hints, &res))!= 0) {
> +				  printf("cannot get local address for %s: %s",  nconf->nc_netid, gai_strerror(aicode));
> +				  syslog(LOG_ERR,
> +					    "cannot get local address for %s: %s",
> +					    nconf->nc_netid, gai_strerror(aicode));
> +					return 1;
> +				  }
> +				}
> +				addrlen = res->ai_addrlen;
> +				sa = (struct sockaddr *)res->ai_addr;
> 			}
> -			addrlen = res->ai_addrlen;
> -			sa = (struct sockaddr *)res->ai_addr;
> 			oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
> -                        if (bind(fd, sa, addrlen) != 0) {
> -				syslog(LOG_ERR, "cannot bind %s on %s: %m",
> -					(hosts[nhostsbak] == NULL) ? "*" :
> -					hosts[nhostsbak], nconf->nc_netid);
> +			__rpc_fd2sockinfo(fd, &si);
> +			if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on,
> +					sizeof(on)) != 0) {
> +				syslog(LOG_ERR, "cannot set SO_REUSEADDR on %s",
> +					nconf->nc_netid);
> 				if (res != NULL)
> 					freeaddrinfo(res);
> -				continue;
> -			} else
> -				checkbind++;
> +				return 1;
> +			}
> +			if (bind(fd, sa, addrlen) < 0) {
> +				syslog(LOG_ERR, "cannot bind %s: %m", nconf->nc_netid);
> +				if (res != NULL)
> +					freeaddrinfo(res);
> +				return 1;
> +			}
> 			(void) umask(oldmask);
> 
> 			/* Copy the address */
> -			taddr.addr.maxlen = taddr.addr.len = addrlen;
> +			taddr.addr.len = taddr.addr.maxlen = addrlen;
> 			taddr.addr.buf = malloc(addrlen);
> 			if (taddr.addr.buf == NULL) {
> -				syslog(LOG_ERR,
> -				    "cannot allocate memory for %s address",
> +				syslog(LOG_ERR, "cannot allocate memory for %s address",
> 				    nconf->nc_netid);
> 				if (res != NULL)
> 					freeaddrinfo(res);
> @@ -443,116 +591,37 @@ init_transport(struct netconfig *nconf)
> 			memcpy(taddr.addr.buf, sa, addrlen);
> #ifdef RPCBIND_DEBUG
> 			if (debugging) {
> -				/*
> -				 * for debugging print out our universal
> -				 * address
> -				 */
> +				/* for debugging print out our universal address */
> 				char *uaddr;
> 				struct netbuf nb;
> -				int sa_size = 0;
> +			        int sa_size2 = 0;
> 
> 				nb.buf = sa;
> 				switch( sa->sa_family){
> 				case AF_INET:
> -				  sa_size = sizeof (struct sockaddr_in);
> +				  sa_size2 = sizeof (struct sockaddr_in);
> 				  break;
> 				case AF_INET6:
> -				  sa_size = sizeof (struct sockaddr_in6);				 
> +				  sa_size2 = sizeof (struct sockaddr_in6);
> 				  break;
> 				}
> -				nb.len = nb.maxlen = sa_size;
> +				nb.len = nb.maxlen = sa_size2;
> 				uaddr = taddr2uaddr(nconf, &nb);
> -				(void) fprintf(stderr,
> -				    "rpcbind : my address is %s\n", uaddr);
> +				(void) fprintf(stderr, "rpcbind : my address is %s\n",
> +				    uaddr);
> 				(void) free(uaddr);
> 			}
> #endif
> -			my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf, &taddr, 
> -                                RPC_MAXDATASIZE, RPC_MAXDATASIZE);
> +
> +			listen(fd, SOMAXCONN);
> +
> +			my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf, &taddr, RPC_MAXDATASIZE, RPC_MAXDATASIZE);
> 			if (my_xprt == (SVCXPRT *)NULL) {
> -				syslog(LOG_ERR, "%s: could not create service", 
> -                                        nconf->nc_netid);
> +				syslog(LOG_ERR, "%s: could not create service",
> +						nconf->nc_netid);
> 				goto error;
> 			}
> 		}
> -		if (!checkbind)
> -			return 1;
> -	} else {	/* NC_TPI_COTS */
> -		if ((strcmp(nconf->nc_netid, "local") != 0) &&
> -		    (strcmp(nconf->nc_netid, "unix") != 0)) {
> -			if ((aicode = getaddrinfo(NULL, servname, &hints, &res))!= 0) {
> -			  if ((aicode = getaddrinfo(NULL, "portmapper", &hints, &res))!= 0) {
> -			  printf("cannot get local address for %s: %s",  nconf->nc_netid, gai_strerror(aicode));
> -			  syslog(LOG_ERR,
> -				    "cannot get local address for %s: %s",
> -				    nconf->nc_netid, gai_strerror(aicode));
> -				return 1;
> -			  }
> -			}
> -			addrlen = res->ai_addrlen;
> -			sa = (struct sockaddr *)res->ai_addr;
> -		}
> -		oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
> -		__rpc_fd2sockinfo(fd, &si);
> -		if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on,
> -				sizeof(on)) != 0) {
> -			syslog(LOG_ERR, "cannot set SO_REUSEADDR on %s",
> -				nconf->nc_netid);
> -			if (res != NULL)
> -				freeaddrinfo(res);
> -			return 1;
> -		}
> -		if (bind(fd, sa, addrlen) < 0) {
> -			syslog(LOG_ERR, "cannot bind %s: %m", nconf->nc_netid);
> -			if (res != NULL)
> -				freeaddrinfo(res);
> -			return 1;
> -		}
> -		(void) umask(oldmask);
> -
> -		/* Copy the address */
> -		taddr.addr.len = taddr.addr.maxlen = addrlen;
> -		taddr.addr.buf = malloc(addrlen);
> -		if (taddr.addr.buf == NULL) {
> -			syslog(LOG_ERR, "cannot allocate memory for %s address",
> -			    nconf->nc_netid);
> -			if (res != NULL)
> -				freeaddrinfo(res);
> -			return 1;
> -		}
> -		memcpy(taddr.addr.buf, sa, addrlen);
> -#ifdef RPCBIND_DEBUG
> -		if (debugging) {
> -			/* for debugging print out our universal address */
> -			char *uaddr;
> -			struct netbuf nb;
> -		        int sa_size2 = 0;
> -
> -			nb.buf = sa;
> -			switch( sa->sa_family){
> -			case AF_INET:
> -			  sa_size2 = sizeof (struct sockaddr_in);
> -			  break;
> -			case AF_INET6:
> -			  sa_size2 = sizeof (struct sockaddr_in6);				 
> -			  break;
> -			}
> -			nb.len = nb.maxlen = sa_size2;
> -			uaddr = taddr2uaddr(nconf, &nb);
> -			(void) fprintf(stderr, "rpcbind : my address is %s\n",
> -			    uaddr);
> -			(void) free(uaddr);
> -		}
> -#endif
> -
> -		listen(fd, SOMAXCONN);
> -
> -		my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf, &taddr, RPC_MAXDATASIZE, RPC_MAXDATASIZE);
> -		if (my_xprt == (SVCXPRT *)NULL) {
> -			syslog(LOG_ERR, "%s: could not create service",
> -					nconf->nc_netid);
> -			goto error;
> -		}
> 	}
> 
> #ifdef PORTMAP
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
> -- 
> 1.7.9
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




