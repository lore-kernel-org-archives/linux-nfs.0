Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:24925 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755326Ab0GUR5L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jul 2010 13:57:11 -0400
Message-ID: <4C4734DC.9010106@oracle.com>
Date: Wed, 21 Jul 2010 13:56:44 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Lennart Poettering <lennart@poettering.net>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpcbind: add support for systemd socket activation
References: <20100719021906.GA16939@tango.0pointer.de>
In-Reply-To: <20100719021906.GA16939@tango.0pointer.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/18/10 10:19 PM, Lennart Poettering wrote:
> Heya!
>
> (I sent this patch to Steve Dickson earlier, he asked me to post this
> here.)
>
> This patch allows us to spawn rpcbind automatically on first use in a
> systemd environment, the same way it is done on MacOS X with launchd.
>
> This makes use of socket-based activation as provided by systemd (in
> case you are wondering, systemd is a Fedora 14 feature, described in all
> detail here: http://0pointer.de/blog/projects/systemd.html). It uses the
> reference implementation of the fd passing code, as supplied by systemd
> upstream. I hope that's acceptable. It's liberally licensed, so I hope
> this is OK. If not, it isn't difficult to reimplement this without the
> reference implementation.
>
> The algorithms implemented are described here:
>
>      http://0pointer.de/public/systemd-man/sd_listen_fds.html
>      http://0pointer.de/public/systemd-man/sd-daemon.html
>      http://0pointer.de/public/systemd-man/daemon.html
>
> Any comments welcome.
>
> If this patch is OK then I can provide systemd unit files as well.
>
> (This patch is generated with --ignore-space-change, to make it more
> readable. A version generated without this switch you find here under
> http://0pointer.de/public/0001-systemd-add-support-for-system-bus-activation.patch
> That's actually the patch you might want to merge. This patch here in
> the mail is the one you want to review. Since the rpcbind sources are a
> bit chaotic when it comes to indenting and whitespace, this patch
> ended up as messy as it is without the switch applied. Sorry for
> that. I'd recommend adopting a stricter whitespace regime for the
> package, following how they do it for the kernel. Would make it a lot
> ncier to prepare patches, and all the git warning madness about weird
> whitespace changes in your commits would go away. But anyway, this is
> just me nitpicking.)
>
> Lennart
>
> Signed-off-by: Lennart Poettering<lennart@poettering.net>
> ---
>   src/Makefile.am |    6 +-
>   src/rpcbind.c   |   75 +++++++++-
>   src/sd-daemon.c |  452 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>   src/sd-daemon.h |  257 +++++++++++++++++++++++++++++++
>   4 files changed, 783 insertions(+), 7 deletions(-)
>   create mode 100644 src/sd-daemon.c
>   create mode 100644 src/sd-daemon.h

Why aren't sd-daemon.[ch] part of a systemd related library?  They seem 
pretty generic to me, and could be useful for other daemons.

Plus, the newly introduced update-systemd Makefile target seems to 
suggest these won't be stable over time.  Wouldn't it be better to have 
a versioned library, external to rpcbind, with this code in it?

> diff --git a/src/Makefile.am b/src/Makefile.am
> index cc0a85b..6340fe9 100644
> --- a/src/Makefile.am
> +++ b/src/Makefile.am
> @@ -20,7 +20,8 @@ rpcbind_SOURCES =       check_bound.c rpcbind.c \
>                           rpcb_svc_4.c rpcb_svc_com.c \
>                           util.c pmap_svc.c rpcb_stat.c \
>                           rpcb_svc.c security.c warmstart.c \
> -                        rpcbind.h
> +                        rpcbind.h \
> +			sd-daemon.c sd-daemon.h
>
>   rpcinfo_SOURCES =       rpcinfo.c
>   rpcinfo_LDFLAGS =       -lpthread -ltirpc
> @@ -32,3 +33,6 @@ rpcbind_LDADD = $(LIB_TIRPC)
>   AM_CPPFLAGS = -I/usr/include/tirpc -DCHECK_LOCAL -DPORTMAP \
>                          -DFACILITY=LOG_MAIL -DSEVERITY=LOG_INFO
>
> +update-systemd:
> +	curl http://cgit.freedesktop.org/systemd/plain/src/sd-daemon.c>  sd-daemon.c
> +	curl http://cgit.freedesktop.org/systemd/plain/src/sd-daemon.h>  sd-daemon.h
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index 63023e1..0368eaf 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -70,6 +70,7 @@
>   #include<nss.h>
>   #include "config.h"
>   #include "rpcbind.h"
> +#include "sd-daemon.h"
>
>   /*#define RPCBIND_DEBUG*/
>
> @@ -282,6 +283,7 @@ init_transport(struct netconfig *nconf)
>   	u_int32_t host_addr[4];  /* IPv4 or IPv6 */
>   	struct sockaddr_un sun;
>   	mode_t oldmask;
> +	int n;
>           res = NULL;
>
>   	if ((nconf->nc_semantics != NC_TPI_CLTS)&&
> @@ -301,6 +303,72 @@ init_transport(struct netconfig *nconf)
>   	}
>   #endif
>
> +	if (!__rpc_nconf2sockinfo(nconf,&si)) {
> +		syslog(LOG_ERR, "cannot get information for %s",
> +		    nconf->nc_netid);
> +		return (1);
> +	}
> +
> +	n = sd_listen_fds(0);
> +	if (n<  0) {
> +		syslog(LOG_ERR, "failed to acquire systemd scokets: %s", strerror(-n));
> +		return 1;
> +	}
> +
> +	if (n>  0) {
> +		int fd;
> +
> +		/* We have systemd sockets, now find those that match
> +		 * our netconfig structure. */
> +
> +		for (fd = SD_LISTEN_FDS_START; fd<  SD_LISTEN_FDS_START + n; fd++) {
> +			struct __rpc_sockinfo si_other;
> +			union {
> +				struct sockaddr sa;
> +				struct sockaddr_un un;
> +				struct sockaddr_in in4;
> +				struct sockaddr_in6 in6;
> +				struct sockaddr_storage storage;
> +			} sa;
> +			socklen_t addrlen = sizeof(sa);
> +
> +			if (!__rpc_fd2sockinfo(fd,&si_other)) {
> +				syslog(LOG_ERR, "cannog get information for fd %i", fd);
> +				return 1;
> +			}
> +
> +			if (si.si_af != si_other.si_af ||
> +			    si.si_socktype != si_other.si_socktype ||
> +			    si.si_proto != si_other.si_proto)
> +				continue;
> +
> +			if (getsockname(fd,&sa.sa,&addrlen)<  0) {
> +				syslog(LOG_ERR, "failed to query socket name: %s",
> +				       strerror(errno));
> +				goto error;
> +			}
> +
> +			/* Copy the address */
> +			taddr.addr.maxlen = taddr.addr.len = addrlen;
> +			taddr.addr.buf = malloc(addrlen);
> +			if (taddr.addr.buf == NULL) {
> +				syslog(LOG_ERR,
> +				       "cannot allocate memory for %s address",
> +				       nconf->nc_netid);
> +				goto error;
> +			}
> +			memcpy(taddr.addr.buf,&sa, addrlen);
> +
> +			my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf,&taddr,
> +                                RPC_MAXDATASIZE, RPC_MAXDATASIZE);
> +			if (my_xprt == (SVCXPRT *)NULL) {
> +				syslog(LOG_ERR, "%s: could not create service",
> +                                        nconf->nc_netid);
> +				goto error;
> +			}
> +		}
> +	} else {
> +
>   	/*
>   	 * XXX - using RPC library internal functions. For NC_TPI_CLTS
>   	 * we call this later, for each socket we like to bind.
> @@ -313,12 +381,6 @@ init_transport(struct netconfig *nconf)
>   		}
>   	}
>
> -	if (!__rpc_nconf2sockinfo(nconf,&si)) {
> -		syslog(LOG_ERR, "cannot get information for %s",
> -		    nconf->nc_netid);
> -		return (1);
> -	}
> -
>   	if ((strcmp(nconf->nc_netid, "local") == 0) ||
>   	    (strcmp(nconf->nc_netid, "unix") == 0)) {
>   		memset(&sun, 0, sizeof sun);
> @@ -555,6 +617,7 @@ init_transport(struct netconfig *nconf)
>   			goto error;
>   		}
>   	}
> +	}
>
>   #ifdef PORTMAP
>   	/*
> diff --git a/src/sd-daemon.c b/src/sd-daemon.c
> new file mode 100644
> index 0000000..3bb258d
> --- /dev/null
> +++ b/src/sd-daemon.c
> @@ -0,0 +1,452 @@
> +/*-*- Mode: C; c-basic-offset: 8 -*-*/
> +
> +/***
> +  Copyright 2010 Lennart Poettering
> +
> +  Permission is hereby granted, free of charge, to any person
> +  obtaining a copy of this software and associated documentation files
> +  (the "Software"), to deal in the Software without restriction,
> +  including without limitation the rights to use, copy, modify, merge,
> +  publish, distribute, sublicense, and/or sell copies of the Software,
> +  and to permit persons to whom the Software is furnished to do so,
> +  subject to the following conditions:
> +
> +  The above copyright notice and this permission notice shall be
> +  included in all copies or substantial portions of the Software.
> +
> +  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> +  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> +  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> +  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> +  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> +  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> +  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> +  SOFTWARE.
> +***/
> +
> +#ifndef _GNU_SOURCE
> +#define _GNU_SOURCE
> +#endif
> +
> +#include<sys/types.h>
> +#include<sys/stat.h>
> +#include<sys/socket.h>
> +#include<sys/un.h>
> +#include<sys/fcntl.h>
> +#include<netinet/in.h>
> +#include<stdlib.h>
> +#include<errno.h>
> +#include<unistd.h>
> +#include<string.h>
> +#include<stdarg.h>
> +#include<stdio.h>
> +
> +#include "sd-daemon.h"
> +
> +int sd_listen_fds(int unset_environment) {
> +
> +#if defined(DISABLE_SYSTEMD) || !defined(__linux__)
> +        return 0;
> +#else
> +        int r, fd;
> +        const char *e;
> +        char *p = NULL;
> +        unsigned long l;
> +
> +        if (!(e = getenv("LISTEN_PID"))) {
> +                r = 0;
> +                goto finish;
> +        }
> +
> +        errno = 0;
> +        l = strtoul(e,&p, 10);
> +
> +        if (errno != 0) {
> +                r = -errno;
> +                goto finish;
> +        }
> +
> +        if (!p || *p || l<= 0) {
> +                r = -EINVAL;
> +                goto finish;
> +        }
> +
> +        /* Is this for us? */
> +        if (getpid() != (pid_t) l) {
> +                r = 0;
> +                goto finish;
> +        }
> +
> +        if (!(e = getenv("LISTEN_FDS"))) {
> +                r = 0;
> +                goto finish;
> +        }
> +
> +        errno = 0;
> +        l = strtoul(e,&p, 10);
> +
> +        if (errno != 0) {
> +                r = -errno;
> +                goto finish;
> +        }
> +
> +        if (!p || *p) {
> +                r = -EINVAL;
> +                goto finish;
> +        }
> +
> +        for (fd = SD_LISTEN_FDS_START; fd<  SD_LISTEN_FDS_START + (int) l; fd ++) {
> +                int flags;
> +
> +                if ((flags = fcntl(fd, F_GETFD))<  0) {
> +                        r = -errno;
> +                        goto finish;
> +                }
> +
> +                if (flags&  FD_CLOEXEC)
> +                        continue;
> +
> +                if (fcntl(fd, F_SETFD, flags | FD_CLOEXEC)<  0) {
> +                        r = -errno;
> +                        goto finish;
> +                }
> +        }
> +
> +        r = (int) l;
> +
> +finish:
> +        if (unset_environment) {
> +                unsetenv("LISTEN_PID");
> +                unsetenv("LISTEN_FDS");
> +        }
> +
> +        return r;
> +#endif
> +}
> +
> +int sd_is_fifo(int fd, const char *path) {
> +        struct stat st_fd;
> +
> +        if (fd<  0)
> +                return -EINVAL;
> +
> +        memset(&st_fd, 0, sizeof(st_fd));
> +        if (fstat(fd,&st_fd)<  0)
> +                return -errno;
> +
> +        if (!S_ISFIFO(st_fd.st_mode))
> +                return 0;
> +
> +        if (path) {
> +                struct stat st_path;
> +
> +                memset(&st_path, 0, sizeof(st_path));
> +                if (stat(path,&st_path)<  0) {
> +
> +                        if (errno == ENOENT || errno == ENOTDIR)
> +                                return 0;
> +
> +                        return -errno;
> +                }
> +
> +                return
> +                        st_path.st_dev == st_fd.st_dev&&
> +                        st_path.st_ino == st_fd.st_ino;
> +        }
> +
> +        return 1;
> +}
> +
> +static int sd_is_socket_internal(int fd, int type, int listening) {
> +        struct stat st_fd;
> +
> +        if (fd<  0 || type<  0)
> +                return -EINVAL;
> +
> +        if (fstat(fd,&st_fd)<  0)
> +                return -errno;
> +
> +        if (!S_ISSOCK(st_fd.st_mode))
> +                return 0;
> +
> +        if (type != 0) {
> +                int other_type = 0;
> +                socklen_t l = sizeof(other_type);
> +
> +                if (getsockopt(fd, SOL_SOCKET, SO_TYPE,&other_type,&l)<  0)
> +                        return -errno;
> +
> +                if (l != sizeof(other_type))
> +                        return -EINVAL;
> +
> +                if (other_type != type)
> +                        return 0;
> +        }
> +
> +        if (listening>= 0) {
> +                int accepting = 0;
> +                socklen_t l = sizeof(accepting);
> +
> +                if (getsockopt(fd, SOL_SOCKET, SO_ACCEPTCONN,&accepting,&l)<  0)
> +                        return -errno;
> +
> +                if (l != sizeof(accepting))
> +                        return -EINVAL;
> +
> +                if (!accepting != !listening)
> +                        return 0;
> +        }
> +
> +        return 1;
> +}
> +
> +union sockaddr_union {
> +        struct sockaddr sa;
> +        struct sockaddr_in in4;
> +        struct sockaddr_in6 in6;
> +        struct sockaddr_un un;
> +        struct sockaddr_storage storage;
> +};
> +
> +int sd_is_socket(int fd, int family, int type, int listening) {
> +        int r;
> +
> +        if (family<  0)
> +                return -EINVAL;
> +
> +        if ((r = sd_is_socket_internal(fd, type, listening))<= 0)
> +                return r;
> +
> +        if (family>  0) {
> +                union sockaddr_union sockaddr;
> +                socklen_t l;
> +
> +                memset(&sockaddr, 0, sizeof(sockaddr));
> +                l = sizeof(sockaddr);
> +
> +                if (getsockname(fd,&sockaddr.sa,&l)<  0)
> +                        return -errno;
> +
> +                if (l<  sizeof(sa_family_t))
> +                        return -EINVAL;
> +
> +                return sockaddr.sa.sa_family == family;
> +        }
> +
> +        return 1;
> +}
> +
> +int sd_is_socket_inet(int fd, int family, int type, int listening, uint16_t port) {
> +        union sockaddr_union sockaddr;
> +        socklen_t l;
> +        int r;
> +
> +        if (family != 0&&  family != AF_INET&&  family != AF_INET6)
> +                return -EINVAL;
> +
> +        if ((r = sd_is_socket_internal(fd, type, listening))<= 0)
> +                return r;
> +
> +        memset(&sockaddr, 0, sizeof(sockaddr));
> +        l = sizeof(sockaddr);
> +
> +        if (getsockname(fd,&sockaddr.sa,&l)<  0)
> +                return -errno;
> +
> +        if (l<  sizeof(sa_family_t))
> +                return -EINVAL;
> +
> +        if (sockaddr.sa.sa_family != AF_INET&&
> +            sockaddr.sa.sa_family != AF_INET6)
> +                return 0;
> +
> +        if (family>  0)
> +                if (sockaddr.sa.sa_family != family)
> +                        return 0;
> +
> +        if (port>  0) {
> +                if (sockaddr.sa.sa_family == AF_INET) {
> +                        if (l<  sizeof(struct sockaddr_in))
> +                                return -EINVAL;
> +
> +                        return htons(port) == sockaddr.in4.sin_port;
> +                } else {
> +                        if (l<  sizeof(struct sockaddr_in6))
> +                                return -EINVAL;
> +
> +                        return htons(port) == sockaddr.in6.sin6_port;
> +                }
> +        }
> +
> +        return 1;
> +}
> +
> +int sd_is_socket_unix(int fd, int type, int listening, const char *path, size_t length) {
> +        union sockaddr_union sockaddr;
> +        socklen_t l;
> +        int r;
> +
> +        if ((r = sd_is_socket_internal(fd, type, listening))<= 0)
> +                return r;
> +
> +        memset(&sockaddr, 0, sizeof(sockaddr));
> +        l = sizeof(sockaddr);
> +
> +        if (getsockname(fd,&sockaddr.sa,&l)<  0)
> +                return -errno;
> +
> +        if (l<  sizeof(sa_family_t))
> +                return -EINVAL;
> +
> +        if (sockaddr.sa.sa_family != AF_UNIX)
> +                return 0;
> +
> +        if (path) {
> +                if (length<= 0)
> +                        length = strlen(path);
> +
> +                if (length<= 0)
> +                        /* Unnamed socket */
> +                        return l == sizeof(sa_family_t);
> +
> +                if (path[0])
> +                        /* Normal path socket */
> +                        return
> +                                (l>= sizeof(sa_family_t) + length + 1)&&
> +                                memcmp(path, sockaddr.un.sun_path, length+1) == 0;
> +                else
> +                        /* Abstract namespace socket */
> +                        return
> +                                (l == sizeof(sa_family_t) + length)&&
> +                                memcmp(path, sockaddr.un.sun_path, length) == 0;
> +        }
> +
> +        return 1;
> +}
> +
> +int sd_notify(int unset_environment, const char *state) {
> +#if defined(DISABLE_SYSTEMD) || !defined(__linux__)
> +        return 0;
> +#else
> +        int fd = -1, r;
> +        struct msghdr msghdr;
> +        struct iovec iovec;
> +        union sockaddr_union sockaddr;
> +        struct ucred *ucred;
> +        union {
> +                struct cmsghdr cmsghdr;
> +                uint8_t buf[CMSG_SPACE(sizeof(struct ucred))];
> +        } control;
> +        const char *e;
> +
> +        if (!state) {
> +                r = -EINVAL;
> +                goto finish;
> +        }
> +
> +        if (!(e = getenv("NOTIFY_SOCKET")))
> +                return 0;
> +
> +        /* Must be an abstract socket, or an absolute path */
> +        if ((e[0] != '@'&&  e[0] != '/') || e[1] == 0) {
> +                r = -EINVAL;
> +                goto finish;
> +        }
> +
> +        if ((fd = socket(AF_UNIX, SOCK_DGRAM|SOCK_CLOEXEC, 0))<  0) {
> +                r = -errno;
> +                goto finish;
> +        }
> +
> +        memset(&sockaddr, 0, sizeof(sockaddr));
> +        sockaddr.sa.sa_family = AF_UNIX;
> +        strncpy(sockaddr.un.sun_path, e, sizeof(sockaddr.un.sun_path));
> +
> +        if (sockaddr.un.sun_path[0] == '@')
> +                sockaddr.un.sun_path[0] = 0;
> +
> +        memset(&iovec, 0, sizeof(iovec));
> +        iovec.iov_base = (char*) state;
> +        iovec.iov_len = strlen(state);
> +
> +        memset(&control, 0, sizeof(control));
> +        control.cmsghdr.cmsg_level = SOL_SOCKET;
> +        control.cmsghdr.cmsg_type = SCM_CREDENTIALS;
> +        control.cmsghdr.cmsg_len = CMSG_LEN(sizeof(struct ucred));
> +
> +        ucred = (struct ucred*) CMSG_DATA(&control.cmsghdr);
> +        ucred->pid = getpid();
> +        ucred->uid = getuid();
> +        ucred->gid = getgid();
> +
> +        memset(&msghdr, 0, sizeof(msghdr));
> +        msghdr.msg_name =&sockaddr;
> +        msghdr.msg_namelen = sizeof(sa_family_t) + strlen(e);
> +
> +        if (msghdr.msg_namelen>  sizeof(struct sockaddr_un))
> +                msghdr.msg_namelen = sizeof(struct sockaddr_un);
> +
> +        msghdr.msg_iov =&iovec;
> +        msghdr.msg_iovlen = 1;
> +        msghdr.msg_control =&control;
> +        msghdr.msg_controllen = control.cmsghdr.cmsg_len;
> +
> +        if (sendmsg(fd,&msghdr, MSG_NOSIGNAL)<  0) {
> +                r = -errno;
> +                goto finish;
> +        }
> +
> +        r = 1;
> +
> +finish:
> +        if (unset_environment)
> +                unsetenv("NOTIFY_SOCKET");
> +
> +        if (fd>= 0)
> +                close(fd);
> +
> +        return r;
> +#endif
> +}
> +
> +int sd_notifyf(int unset_environment, const char *format, ...) {
> +#if defined(DISABLE_SYSTEMD) || !defined(__linux__)
> +        return 0;
> +#else
> +        va_list ap;
> +        char *p = NULL;
> +        int r;
> +
> +        va_start(ap, format);
> +        r = vasprintf(&p, format, ap);
> +        va_end(ap);
> +
> +        if (r<  0 || !p)
> +                return -ENOMEM;
> +
> +        r = sd_notify(unset_environment, p);
> +        free(p);
> +
> +        return r;
> +#endif
> +}
> +
> +int sd_booted(void) {
> +#if defined(DISABLE_SYSTEMD) || !defined(__linux__)
> +        return 0;
> +#else
> +
> +        struct stat a, b;
> +
> +        /* We simply test whether the systemd cgroup hierarchy is
> +         * mounted */
> +
> +        if (lstat("/cgroup",&a)<  0)
> +                return 0;
> +
> +        if (lstat("/cgroup/systemd",&b)<  0)
> +                return 0;
> +
> +        return a.st_dev != b.st_dev;
> +#endif
> +}
> diff --git a/src/sd-daemon.h b/src/sd-daemon.h
> new file mode 100644
> index 0000000..fd6221f
> --- /dev/null
> +++ b/src/sd-daemon.h
> @@ -0,0 +1,257 @@
> +/*-*- Mode: C; c-basic-offset: 8 -*-*/
> +
> +#ifndef foosddaemonhfoo
> +#define foosddaemonhfoo
> +
> +/***
> +  Copyright 2010 Lennart Poettering
> +
> +  Permission is hereby granted, free of charge, to any person
> +  obtaining a copy of this software and associated documentation files
> +  (the "Software"), to deal in the Software without restriction,
> +  including without limitation the rights to use, copy, modify, merge,
> +  publish, distribute, sublicense, and/or sell copies of the Software,
> +  and to permit persons to whom the Software is furnished to do so,
> +  subject to the following conditions:
> +
> +  The above copyright notice and this permission notice shall be
> +  included in all copies or substantial portions of the Software.
> +
> +  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> +  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> +  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> +  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> +  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> +  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> +  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> +  SOFTWARE.
> +***/
> +
> +#include<sys/types.h>
> +#include<inttypes.h>
> +
> +#ifdef __cplusplus
> +extern "C" {
> +#endif
> +
> +/*
> +  Reference implementation of a few systemd related interfaces for
> +  writing daemons. These interfaces are trivial to implement. To
> +  simplify porting we provide this reference implementation.
> +  Applications are welcome to reimplement the algorithms described
> +  here if they do not want to include these two source files.
> +
> +  The following functionality is provided:
> +
> +  - Support for logging with log levels on stderr
> +  - File descriptor passing for socket-based activation
> +  - Daemon startup and status notification
> +  - Detection of systemd boots
> +
> +  You may compile this with -DDISABLE_SYSTEMD to disable systemd
> +  support. This makes all those calls NOPs that are directly related to
> +  systemd (i.e. only sd_is_xxx() will stay useful).
> +
> +  Since this is drop-in code we don't want any of our symbols to be
> +  exported in any case. Hence we declare hidden visibility for all of
> +  them.
> +
> +  You may find an up-to-date version of these source files online:
> +
> +  http://cgit.freedesktop.org/systemd/plain/src/sd-daemon.h
> +  http://cgit.freedesktop.org/systemd/plain/src/sd-daemon.c
> +
> +  This should compile on non-Linux systems, too, but with the
> +  exception of the sd_is_xxx() calls all functions will become NOPs.
> +
> +  See sd-daemon(7) for more information.
> +*/
> +
> +#if __GNUC__>= 4
> +#define _sd_printf_attr_(a,b) __attribute__ ((format (printf, a, b)))
> +#define _sd_hidden_ __attribute__ ((visibility("hidden")))
> +#else
> +#define _sd_printf_attr_(a,b)
> +#define _sd_hidden_
> +#endif
> +
> +/*
> +  Log levels for usage on stderr:
> +
> +          fprintf(stderr, SD_NOTICE "Hello World!\n");
> +
> +  This is similar to printk() usage in the kernel.
> +*/
> +#define SD_EMERG   "<0>"  /* system is unusable */
> +#define SD_ALERT   "<1>"  /* action must be taken immediately */
> +#define SD_CRIT    "<2>"  /* critical conditions */
> +#define SD_ERR     "<3>"  /* error conditions */
> +#define SD_WARNING "<4>"  /* warning conditions */
> +#define SD_NOTICE  "<5>"  /* normal but significant condition */
> +#define SD_INFO    "<6>"  /* informational */
> +#define SD_DEBUG   "<7>"  /* debug-level messages */
> +
> +/* The first passed file descriptor is fd 3 */
> +#define SD_LISTEN_FDS_START 3
> +
> +/*
> +  Returns how many file descriptors have been passed, or a negative
> +  errno code on failure. Optionally, removes the $LISTEN_FDS and
> +  $LISTEN_PID file descriptors from the environment (recommended, but
> +  problematic in threaded environments). If r is the return value of
> +  this function you'll find the file descriptors passed as fds
> +  SD_LISTEN_FDS_START to SD_LISTEN_FDS_START+r-1. Returns a negative
> +  errno style error code on failure. This function call ensures that
> +  the FD_CLOEXEC flag is set for the passed file descriptors, to make
> +  sure they are not passed on to child processes. If FD_CLOEXEC shall
> +  not be set, the caller needs to unset it after this call for all file
> +  descriptors that are used.
> +
> +  See sd_listen_fds(3) for more information.
> +*/
> +int sd_listen_fds(int unset_environment) _sd_hidden_;
> +
> +/*
> +  Helper call for identifying a passed file descriptor. Returns 1 if
> +  the file descriptor is a FIFO in the file system stored under the
> +  specified path, 0 otherwise. If path is NULL a path name check will
> +  not be done and the call only verifies if the file descriptor
> +  refers to a FIFO. Returns a negative errno style error code on
> +  failure.
> +
> +  See sd_is_fifo(3) for more information.
> +*/
> +int sd_is_fifo(int fd, const char *path) _sd_hidden_;
> +
> +/*
> +  Helper call for identifying a passed file descriptor. Returns 1 if
> +  the file descriptor is a socket of the specified family (AF_INET,
> +  ...) and type (SOCK_DGRAM, SOCK_STREAM, ...), 0 otherwise. If
> +  family is 0 a socket family check will not be done. If type is 0 a
> +  socket type check will not be done and the call only verifies if
> +  the file descriptor refers to a socket. If listening is>  0 it is
> +  verified that the socket is in listening mode. (i.e. listen() has
> +  been called) If listening is == 0 it is verified that the socket is
> +  not in listening mode. If listening is<  0 no listening mode check
> +  is done. Returns a negative errno style error code on failure.
> +
> +  See sd_is_socket(3) for more information.
> +*/
> +int sd_is_socket(int fd, int family, int type, int listening) _sd_hidden_;
> +
> +/*
> +  Helper call for identifying a passed file descriptor. Returns 1 if
> +  the file descriptor is an Internet socket, of the specified family
> +  (either AF_INET or AF_INET6) and the specified type (SOCK_DGRAM,
> +  SOCK_STREAM, ...), 0 otherwise. If version is 0 a protocol version
> +  check is not done. If type is 0 a socket type check will not be
> +  done. If port is 0 a socket port check will not be done. The
> +  listening flag is used the same way as in sd_is_socket(). Returns a
> +  negative errno style error code on failure.
> +
> +  See sd_is_socket_inet(3) for more information.
> +*/
> +int sd_is_socket_inet(int fd, int family, int type, int listening, uint16_t port) _sd_hidden_;
> +
> +/*
> +  Helper call for identifying a passed file descriptor. Returns 1 if
> +  the file descriptor is an AF_UNIX socket of the specified type
> +  (SOCK_DGRAM, SOCK_STREAM, ...) and path, 0 otherwise. If type is 0
> +  a socket type check will not be done. If path is NULL a socket path
> +  check will not be done. For normal AF_UNIX sockets set length to
> +  0. For abstract namespace sockets set length to the length of the
> +  socket name (including the initial 0 byte), and pass the full
> +  socket path in path (including the initial 0 byte). The listening
> +  flag is used the same way as in sd_is_socket(). Returns a negative
> +  errno style error code on failure.
> +
> +  See sd_is_socket_unix(3) for more information.
> +*/
> +int sd_is_socket_unix(int fd, int type, int listening, const char *path, size_t length) _sd_hidden_;
> +
> +/*
> +  Informs systemd about changed daemon state. This takes a number of
> +  newline seperated environment-style variable assignments in a
> +  string. The following variables are known:
> +
> +     READY=1      Tells systemd that daemon startup is finished (only
> +                  relevant for services of Type=notify). The passed
> +                  argument is a boolean "1" or "0". Since there is
> +                  little value in signalling non-readiness the only
> +                  value daemons should send is "READY=1".
> +
> +     STATUS=...   Passes a single-line status string back to systemd
> +                  that describes the daemon state. This is free-from
> +                  and can be used for various purposes: general state
> +                  feedback, fsck-like programs could pass completion
> +                  percentages and failing programs could pass a human
> +                  readable error message. Example: "STATUS=Completed
> +                  66% of file system check..."
> +
> +     ERRNO=...    If a daemon fails, the errno-style error code,
> +                  formatted as string. Example: "ERRNO=2" for ENOENT.
> +
> +     BUSERROR=... If a daemon fails, the D-Bus error-style error
> +                  code. Example: "BUSERROR=org.freedesktop.DBus.Error.TimedOut"
> +
> +     MAINPID=...  The main pid of a daemon, in case systemd did not
> +                  fork off the process itself. Example: "MAINPID=4711"
> +
> +  Daemons can choose to send additional variables. However, it is
> +  recommened to prefix variable names not listed above with X_.
> +
> +  Returns a negative errno-style error code on failure. Returns>  0
> +  if systemd could be notified, 0 if it couldn't possibly because
> +  systemd is not running.
> +
> +  Example: When a daemon finished starting up, it could issue this
> +  call to notify systemd about it:
> +
> +     sd_notify(0, "READY=1");
> +
> +  See sd_notifyf() for more complete examples.
> +
> +  See sd_notify(3) for more information.
> +*/
> +int sd_notify(int unset_environment, const char *state) _sd_hidden_;
> +
> +/*
> +  Similar to sd_notify() but takes a format string.
> +
> +  Example 1: A daemon could send the following after initialization:
> +
> +     sd_notifyf(0, "READY=1\n"
> +                   "STATUS=Processing requests...\n"
> +                   "MAINPID=%lu",
> +                   (unsigned long) getpid());
> +
> +  Example 2: A daemon could send the following shortly before
> +  exiting, on failure:
> +
> +     sd_notifyf(0, "STATUS=Failed to start up: %s\n"
> +                   "ERRNO=%i",
> +                   strerror(errno),
> +                   errno);
> +
> +  See sd_notifyf(3) for more information.
> +*/
> +int sd_notifyf(int unset_environment, const char *format, ...) _sd_printf_attr_(2,3) _sd_hidden_;
> +
> +/*
> +  Returns>  0 if the system was booted with systemd. Returns<  0 on
> +  error. Returns 0 if the system was not booted with systemd. Note
> +  that all of the functions above handle non-systemd boots just
> +  fine. You should NOT protect them with a call to this function. Also
> +  note that this function checks whether the system, not the user
> +  session is controlled by systemd. However the functions above work
> +  for both session and system services.
> +
> +  See sd_booted(3) for more information.
> +*/
> +int sd_booted(void) _sd_hidden_;
> +
> +#ifdef __cplusplus
> +}
> +#endif
> +
> +#endif

