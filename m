From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/6] nfs-utils: break up nfssvc.c into more individually
 callable functions
Date: Tue, 2 Jun 2009 14:40:57 -0400
Message-ID: <20090602144057.1786c0d4@tlielax.poochiereds.net>
References: <1243943029-6400-1-git-send-email-jlayton@redhat.com>
	<1243943029-6400-4-git-send-email-jlayton@redhat.com>
	<8B504E30-ECF0-45E2-BA30-2DC8A4128F82@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54143 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750776AbZFBSlD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2009 14:41:03 -0400
In-Reply-To: <8B504E30-ECF0-45E2-BA30-2DC8A4128F82@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2 Jun 2009 11:32:01 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> Some cursory comments.  I think Steve should take the first two in  
> this series now, as they are simple and reasonable clean-ups.
> 
> On Jun 2, 2009, at 7:43 AM, Jeff Layton wrote:
> 
> > nfssvc.c contains functions for starting up knfsd. Currently, the only
> > non-static function in that file is nfssvc(). In order to add IPv6
> > support, we'll need to be able to call some of these functions in a  
> > more
> > granular fashion.
> >
> > Reorganize these functions and add prototypes to the header so that  
> > they
> > can be called individually, and change the nfsd program to call those
> > routines individually.
> >
> > Change nfssvc_setfds to take a different set of args and change it to
> > use getaddrinfo to look up addresses. This simplifies the code in the
> > core nfsd program significantly and should make adding IPv6 support
> > easier.
> >
> > Finally, change nfsd to use xlog routines for logging and add a -- 
> > debug
> > switch to enable sending output to stderr rather than syslog.
> >
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > support/include/nfslib.h |    7 ++-
> > support/nfs/nfssvc.c     |  226 +++++++++++++++++++++++++++++ 
> > +----------------
> > utils/nfsd/nfsd.c        |  109 ++++++++++++++---------
> > 3 files changed, 219 insertions(+), 123 deletions(-)
> >
> > diff --git a/support/include/nfslib.h b/support/include/nfslib.h
> > index ae98650..fe24fe3 100644
> > --- a/support/include/nfslib.h
> > +++ b/support/include/nfslib.h
> > @@ -20,6 +20,7 @@
> > #include <paths.h>
> > #include <rpcsvc/nfs_prot.h>
> > #include <nfs/nfs.h>
> > +#include <netdb.h>
> > #include "xlog.h"
> >
> > #ifndef _PATH_EXPORTS
> > @@ -130,7 +131,11 @@ int			wildmat(char *text, char *pattern);
> >  * nfsd library functions.
> >  */
> > int			nfsctl(int, struct nfsctl_arg *, union nfsctl_res *);
> > -int			nfssvc(int port, int nrservs, unsigned int versbits, int  
> > minorvers4, unsigned int portbits, char *haddr);
> > +int			nfssvc_inuse(void);
> > +int			nfssvc_setfds(const struct addrinfo *hints, const char *node,
> > +					const char *port);
> > +void			nfssvc_setvers(unsigned int ctlbits, int minorvers4);
> > +int			nfssvc_threads(unsigned short port, int nrservs);
> > int			nfsaddclient(struct nfsctl_client *clp);
> > int			nfsdelclient(struct nfsctl_client *clp);
> > int			nfsexport(struct nfsctl_export *exp);
> > diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
> > index 33c15a7..e7f3262 100644
> > --- a/support/nfs/nfssvc.c
> > +++ b/support/nfs/nfssvc.c
> > @@ -10,113 +10,179 @@
> > #include <config.h>
> > #endif
> >
> > +#include <sys/types.h>
> > #include <sys/socket.h>
> > +#include <netdb.h>
> > #include <netinet/in.h>
> > #include <arpa/inet.h>
> > #include <unistd.h>
> > #include <fcntl.h>
> > #include <errno.h>
> > -#include <syslog.h>
> > -
> >
> > #include "nfslib.h"
> > +#include "xlog.h"
> >
> > #define NFSD_PORTS_FILE     "/proc/fs/nfsd/portlist"
> > #define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
> > #define NFSD_THREAD_FILE  "/proc/fs/nfsd/threads"
> >
> > -static void
> > -nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
> > +/*
> > + * Are there already sockets configured? If not, then it is safe to  
> > try to
> > + * open some and pass them through.
> > + *
> > + * Note: If the user explicitly asked for 'udp', then we should  
> > probably check
> > + * if that is open, and should open it if not. However we don't  
> > yet. All
> > + * sockets have to be opened when the first daemon is started.
> > + */
> > +int
> > +nfssvc_inuse(void)
> > {
> > -	int fd, n, on=1;
> > +	int fd, n;
> > 	char buf[BUFSIZ];
> > -	int udpfd = -1, tcpfd = -1;
> > -	struct sockaddr_in sin;
> >
> > 	fd = open(NFSD_PORTS_FILE, O_RDONLY);
> > +
> > +	/* problem opening file, assume that nothing is configured */
> > 	if (fd < 0)
> > -		return;
> > +		return 0;
> > +
> > 	n = read(fd, buf, BUFSIZ);
> > 	close(fd);
> > +
> > 	if (n != 0)
> > -		return;
> > -	/* there are no ports currently open, so it is safe to
> > -	 * try to open some and pass them through.
> > -	 * Note: If the user explicitly asked for 'udp', then
> > -	 * we should probably check if that is open, and should
> > -	 * open it if not.  However we don't yet.  All sockets
> > -	 * have to be opened when the first daemon is started.
> > +		return 1;
> > +
> > +	return 0;
> > +}
> > +
> > +int
> > +nfssvc_setfds(const struct addrinfo *hints, const char *node, const  
> > char *port)
> > +{
> > +	int fd, on = 1, fac = L_ERROR;
> > +	int sockfd = -1, rc = 0;
> > +	char buf[BUFSIZ];
> > +	struct addrinfo *addrhead = NULL, *addr;
> > +	char *proto, *family;
> > +
> > +	/*
> > +	 * if file can't be opened, then assume that it's not available and
> > +	 * that the caller should just fall back to the old nfsctl interface
> > 	 */
> > 	fd = open(NFSD_PORTS_FILE, O_WRONLY);
> > 	if (fd < 0)
> > -		return;
> > -	sin.sin_family = AF_INET;
> > -	sin.sin_port   = htons(port);
> > -	sin.sin_addr.s_addr =  inet_addr(haddr);
> > -
> > -	if (NFSCTL_UDPISSET(ctlbits)) {
> > -		udpfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
> > -		if (udpfd < 0) {
> > -			syslog(LOG_ERR, "nfssvc: unable to create UPD socket: "
> > -				"errno %d (%s)\n", errno, strerror(errno));
> > -			exit(1);
> > -		}
> > -		if (bind(udpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
> > -			syslog(LOG_ERR, "nfssvc: unable to bind UPD socket: "
> > -				"errno %d (%s)\n", errno, strerror(errno));
> > -			exit(1);
> > -		}
> > +		return 0;
> > +
> > +	switch(hints->ai_family) {
> > +	case AF_INET:
> > +		family = "inet";
> > +		break;
> > +	case AF_INET6:
> > +		family = "inet6";
> > +		break;
> > +	default:
> > +		/* FIXME: should never happen -- return error here? */
> > +		family = "unknown family";
> > +	}
> > +
> > +	rc = getaddrinfo(node, port, hints, &addrhead);
> > +	if (rc == EAI_NONAME && !strcmp(port, "nfs"))
> > +		rc = getaddrinfo(node, "2049", hints, &addrhead);
> 
> Here (and in the getservbyname(3) call below) perhaps you could use  
> NFS_PORT or something similar.
> 
> I recommend breaking this patch up.  It's a lot to change at once, and  
> we might benefit from being able to bisect over these changes.
> 

Fair enough. It's sort of hard to break this up since a lot of the
changes depend on each other. I can probably do a better job than this
though. Let me see what I can do.

> > +
> > +	if (rc != 0) {
> > +		xlog(L_ERROR, "unable to resolve %s:%s to %s address: "
> > +				"%s", node ? node : "ANYADDR", port, family,
> > +				rc == EAI_SYSTEM ? strerror(errno) :
> > +					gai_strerror(rc));
> > +		goto error;
> > 	}
> >
> > -	if (NFSCTL_TCPISSET(ctlbits)) {
> > -		tcpfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
> > -		if (tcpfd < 0) {
> > -			syslog(LOG_ERR, "nfssvc: unable to createt tcp socket: "
> > -				"errno %d (%s)\n", errno, strerror(errno));
> > -			exit(1);
> > +	addr = addrhead;
> > +	while(addr) {
> > +		/* skip non-TCP / non-UDP sockets */
> > +		switch(addr->ai_protocol) {
> > +		case IPPROTO_UDP:
> > +			proto = "UDP";
> > +			break;
> > +		case IPPROTO_TCP:
> > +			proto = "TCP";
> > +			break;
> > +		default:
> > +			addr = addr->ai_next;
> > +			continue;
> > 		}
> > -		if (setsockopt(tcpfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on))  
> > < 0) {
> > -			syslog(LOG_ERR, "nfssvc: unable to set SO_REUSEADDR: "
> > -				"errno %d (%s)\n", errno, strerror(errno));
> > -			exit(1);
> > +
> > +		xlog(D_GENERAL, "Creating %s %s socket.", family, proto);
> > +
> > +		/* open socket and prepare to hand it off to kernel */
> > +		sockfd = socket(addr->ai_family, addr->ai_socktype,
> > +				addr->ai_protocol);
> > +		if (sockfd < 0) {
> > +			xlog(L_ERROR, "unable to create %s %s socket: "
> > +				"errno %d (%s)", family, proto, errno,
> > +				strerror(errno));
> > +			rc = errno;
> > +			goto error;
> > 		}
> > -		if (bind(tcpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
> > -			syslog(LOG_ERR, "nfssvc: unable to bind TCP socket: "
> > -				"errno %d (%s)\n", errno, strerror(errno));
> > -			exit(1);
> > +		if (addr->ai_protocol == IPPROTO_TCP &&
> > +		    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &on,  
> > sizeof(on))) {
> > +			xlog(L_ERROR, "unable to set SO_REUSEADDR on %s "
> > +				"socket: errno %d (%s)", family, errno,
> > +				strerror(errno));
> > +			rc = errno;
> > +			goto error;
> > 		}
> > -		if (listen(tcpfd, 64) < 0){
> > -			syslog(LOG_ERR, "nfssvc: unable to create listening socket: "
> > -				"errno %d (%s)\n", errno, strerror(errno));
> > -			exit(1);
> > +		if (bind(sockfd, addr->ai_addr, addr->ai_addrlen)) {
> > +			xlog(L_ERROR, "unable to bind %s %s socket: "
> > +				"errno %d (%s)", family, proto, errno,
> > +				strerror(errno));
> > +			rc = errno;
> > +			goto error;
> > 		}
> > -	}
> > -	if (udpfd >= 0) {
> > -		snprintf(buf, BUFSIZ,"%d\n", udpfd);
> > -		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
> > -			syslog(LOG_ERR,
> > -			       "nfssvc: writing fds to kernel failed: errno %d (%s)",
> > -			       errno, strerror(errno));
> > +		if (addr->ai_protocol == IPPROTO_TCP && listen(sockfd, 64)) {
> > +			xlog(L_ERROR, "unable to create listening socket: "
> > +				"errno %d (%s)", errno, strerror(errno));
> > +			rc = errno;
> > +			goto error;
> > 		}
> > -		close(fd);
> > -		fd = -1;
> > -	}
> > -	if (tcpfd >= 0) {
> > +
> > 		if (fd < 0)
> > 			fd = open(NFSD_PORTS_FILE, O_WRONLY);
> > -		snprintf(buf, BUFSIZ,"%d\n", tcpfd);
> > +
> > +		if (fd < 0) {
> > +			xlog(L_ERROR, "couldn't open ports file: errno "
> > +				      "%d (%s)", errno, strerror(errno));
> > +			goto error;
> > +		}
> > +
> > +		snprintf(buf, BUFSIZ, "%d\n", sockfd);
> > 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
> > -			syslog(LOG_ERR,
> > -			       "nfssvc: writing fds to kernel failed: errno %d (%s)",
> > -			       errno, strerror(errno));
> > +			/*
> > +			 * this error may be common on older kernels that don't
> > +			 * support IPv6, so turn into a debug message.
> > +			 */
> > +			if (errno == EAFNOSUPPORT)
> > +				fac = D_ALL;
> > +			xlog(fac, "writing fd to kernel failed: errno %d (%s)",
> > +				  errno, strerror(errno));
> > +			rc = errno;
> > +			goto error;
> > 		}
> > +		close(fd);
> > +		fd = -1;
> > +		addr = addr->ai_next;
> > 	}
> > -	close(fd);
> >
> > -	return;
> > +error:
> > +	if (fd >= 0)
> > +		close(fd);
> > +	if (addrhead)
> > +		freeaddrinfo(addrhead);
> > +
> > +	return rc;
> > }
> > -static void
> > -nfssvc_versbits(unsigned int ctlbits, int minorvers4)
> > +
> > +void
> > +nfssvc_setvers(unsigned int ctlbits, int minorvers4)
> > {
> > 	int fd, n, off;
> > 	char buf[BUFSIZ], *ptr;
> > @@ -140,27 +206,21 @@ nfssvc_versbits(unsigned int ctlbits, int  
> > minorvers4)
> > 				    n);
> > 	snprintf(ptr+off, BUFSIZ - off, "\n");
> > 	if (write(fd, buf, strlen(buf)) != strlen(buf)) {
> > -		syslog(LOG_ERR, "nfssvc: Setting version failed: errno %d (%s)",
> > +		xlog(L_ERROR, "Setting version failed: errno %d (%s)",
> > 			errno, strerror(errno));
> > 	}
> > 	close(fd);
> >
> > 	return;
> > }
> > +
> > int
> > -nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4,
> > -	unsigned protobits, char *haddr)
> > +nfssvc_threads(unsigned short port, const int nrservs)
> > {
> > 	struct nfsctl_arg	arg;
> > +	struct servent *ent;
> > 	int fd;
> >
> > -	/* Note: must set versions before fds so that
> > -	 * the ports get registered with portmap against correct
> > -	 * versions
> > -	 */
> > -	nfssvc_versbits(versbits, minorvers4);
> > -	nfssvc_setfds(port, protobits, haddr);
> > -
> > 	fd = open(NFSD_THREAD_FILE, O_WRONLY);
> > 	if (fd < 0)
> > 		fd = open("/proc/fs/nfs/threads", O_WRONLY);
> > @@ -180,6 +240,14 @@ nfssvc(int port, int nrservs, unsigned int  
> > versbits, int minorvers4,
> > 			return 0;
> > 	}
> >
> > +	if (!port) {
> > +		ent = getservbyname ("nfs", "udp");
> > +		if (ent != NULL)
> > +			port = ntohs (ent->s_port);
> > +		else
> > +			port = 2049;
> > +	}
> > +
> 
> In addition to using NFS_PORT (or something similar), you should  
> remove the blank before the "(" to match the same style used elsewhere  
> in this file.
> 

Ahh, didn't realize we had a #define for this (the original nfsd code
didn't use it). I'll switch it to use that (always preferred over
"magic numbers"). Good catch on the parens -- leftover from cut and
paste job...

> >
> > 	arg.ca_version = NFSCTL_VERSION;
> > 	arg.ca_svc.svc_nthreads = nrservs;
> > 	arg.ca_svc.svc_port = port;
> > diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> > index c7bd003..bdc71db 100644
> > --- a/utils/nfsd/nfsd.c
> > +++ b/utils/nfsd/nfsd.c
> > @@ -18,13 +18,13 @@
> > #include <string.h>
> > #include <errno.h>
> > #include <getopt.h>
> > -#include <syslog.h>
> > #include <netdb.h>
> > #include <sys/socket.h>
> > #include <netinet/in.h>
> > #include <arpa/inet.h>
> >
> > #include "nfslib.h"
> > +#include "xlog.h"
> >
> > static void	usage(const char *);
> >
> > @@ -37,48 +37,48 @@ static struct option longopts[] =
> > 	{ "no-udp", 0, 0, 'U' },
> > 	{ "port", 1, 0, 'P' },
> > 	{ "port", 1, 0, 'p' },
> > +	{ "debug", 0, 0, 'd' },
> > 	{ NULL, 0, 0, 0 }
> > };
> > unsigned int protobits = NFSCTL_ALLBITS;
> > unsigned int versbits = NFSCTL_ALLBITS;
> > int minorvers4 = NFSD_MAXMINORVERS4;		/* nfsv4 minor version */
> > -char *haddr = NULL;
> >
> > int
> > main(int argc, char **argv)
> > {
> > -	int	count = 1, c, error, port, fd, found_one;
> > -	struct servent *ent;
> > -	struct hostent *hp;
> > -	char *p;
> > -
> > -	ent = getservbyname ("nfs", "udp");
> > -	if (ent != NULL)
> > -		port = ntohs (ent->s_port);
> > -	else
> > -		port = 2049;
> > -
> > -	while ((c = getopt_long(argc, argv, "H:hN:p:P:TU", longopts,  
> > NULL)) != EOF) {
> > +	int	count = 1, c, error, portnum = 0, fd, found_one;
> > +	char *p, *port = "nfs";
> > +	char *haddr = NULL;
> > +	struct addrinfo hints = { .ai_flags = AI_PASSIVE | AI_ADDRCONFIG };
> > +
> > +	xlog_syslog(1);
> > +	xlog_stderr(0);
> > +
> > +	while ((c = getopt_long(argc, argv, "dH:hN:p:P:TU", longopts,  
> > NULL)) != EOF) {
> > 		switch(c) {
> > +		case 'd':
> > +			xlog_config(D_ALL, 1);
> > +			xlog_syslog(0);
> > +			xlog_stderr(1);
> > +			break;
> > 		case 'H':
> > -			if (inet_addr(optarg) != INADDR_NONE) {
> > +			/*
> > +			 * for now, this only handles one -H option. Use the
> > +			 * first one specified.
> > +			 */
> 
> Interesting comment.  Did the old version allow you to specify more  
> than one?  Can you run rpc.nfsd more than once, specifying a different  
> "-H" on each?
> 
> >
> > +			if (!haddr)
> > 				haddr = strdup(optarg);
> > -			} else if ((hp = gethostbyname(optarg)) != NULL) {
> > -				haddr = inet_ntoa((*(struct in_addr*)(hp->h_addr_list[0])));
> > -			} else {
> > -				fprintf(stderr, "%s: Unknown hostname: %s\n",
> > -					argv[0], optarg);
> > -				usage(argv [0]);
> > -			}
> > 			break;
> > 		case 'P':	/* XXX for nfs-server compatibility */
> > 		case 'p':
> > -			port = atoi(optarg);
> > -			if (port <= 0 || port > 65535) {
> > +			portnum = atoi(optarg);
> > +			if (portnum <= 0 || portnum > 65535) {
> > 				fprintf(stderr, "%s: bad port number: %s\n",
> > 					argv[0], optarg);
> > -				usage(argv [0]);
> > +				usage(argv[0]);
> > 			}
> > +			port = strdup(optarg);
> > 			break;
> > 		case 'N':
> > 			switch((c = strtol(optarg, &p, 0))) {
> > @@ -108,25 +108,21 @@ main(int argc, char **argv)
> > 			usage(argv[0]);
> > 		}
> > 	}
> > -	/*
> > -	 * Do some sanity checking, if the ctlbits are set
> > -	 */
> > -	if (!NFSCTL_UDPISSET(protobits) && !NFSCTL_TCPISSET(protobits)) {
> > -		fprintf(stderr, "invalid protocol specified\n");
> > -		exit(1);
> > -	}
> > +
> > +	xlog_open("nfsd");
> 
> How about "rpc.nfsd" or even argv[0] ?
> 
> >
> > +
> > 	found_one = 0;
> > 	for (c = NFSD_MINVERS; c <= NFSD_MAXVERS; c++) {
> > 		if (NFSCTL_VERISSET(versbits, c))
> > 			found_one = 1;
> > 	}
> > 	if (!found_one) {
> > -		fprintf(stderr, "no version specified\n");
> > +		xlog(L_ERROR, "no version specified");
> > 		exit(1);
> > 	}			
> >
> > 	if (NFSCTL_VERISSET(versbits, 4) && !NFSCTL_TCPISSET(protobits)) {
> > -		fprintf(stderr, "version 4 requires the TCP protocol\n");
> > +		xlog(L_ERROR, "version 4 requires the TCP protocol");
> > 		exit(1);
> > 	}
> > 	if (haddr == NULL) {
> > @@ -135,24 +131,51 @@ main(int argc, char **argv)
> > 	}
> >
> > 	if (chdir(NFS_STATEDIR)) {
> > -		fprintf(stderr, "%s: chdir(%s) failed: %s\n",
> > -			argv [0], NFS_STATEDIR, strerror(errno));
> > +		xlog(L_ERROR, "chdir(%s) failed: %s",
> > +			NFS_STATEDIR, strerror(errno));
> > 		exit(1);
> > 	}
> >
> > 	if (optind < argc) {
> > 		if ((count = atoi(argv[optind])) < 0) {
> > 			/* insane # of servers */
> > -			fprintf(stderr,
> > -				"%s: invalid server count (%d), using 1\n",
> > +			xlog(L_ERROR,
> > +				"invalid server count (%d), using 1",
> > 				argv[0], count);
> > 			count = 1;
> > 		}
> > 	}
> > +
> > +	if (!NFSCTL_UDPISSET(protobits) && !NFSCTL_TCPISSET(protobits)) {
> > +		xlog(L_ERROR, "invalid protocol specified");
> > +		exit(1);
> > +	}
> > +
> > +	if (!NFSCTL_UDPISSET(protobits))
> > +		hints.ai_protocol = IPPROTO_TCP;
> > +	else if (!NFSCTL_TCPISSET(protobits))
> > +		hints.ai_protocol = IPPROTO_UDP;
> > +
> > +	hints.ai_family = AF_INET;
> > +
> > +	/*
> > +	 * must set versions before the fd's so that the right versions get
> > +	 * registered with rpcbind. Note that on older kernels w/o the right
> > +	 * interfaces, these are a no-op.
> > +	 */
> > +	if (!nfssvc_inuse()) {
> > +		nfssvc_setvers(versbits, minorvers4);
> > +		error = nfssvc_setfds(&hints, haddr, port);
> > +		if (error)
> > +			goto out;
> > +	}
> > +
> > 	/* KLUDGE ALERT:
> > 	   Some kernels let nfsd kernel threads inherit open files
> > 	   from the program that spawns them (i.e. us).  So close
> > 	   everything before spawning kernel threads.  --Chip */
> > +	xlog_syslog(1);
> > +	xlog_stderr(0);
> > 	fd = open("/dev/null", O_RDWR);
> > 	if (fd == -1)
> > 		perror("/dev/null");
> > @@ -163,13 +186,13 @@ main(int argc, char **argv)
> > 	}
> > 	closeall(3);
> >
> > -	openlog("nfsd", LOG_PID, LOG_DAEMON);
> > -	if ((error = nfssvc(port, count, versbits, minorvers4, protobits,  
> > haddr)) < 0) {
> > +	if ((error = nfssvc_threads(portnum, count)) < 0) {
> > 		int e = errno;
> > -		syslog(LOG_ERR, "nfssvc: %s", strerror(e));
> > -		closelog();
> > +		xlog(L_ERROR, "error starting threads: %s", strerror(e));
> > 	}
> >
> > +out:
> > +	free(haddr);
> > 	return (error != 0);
> > }
> >
> > @@ -177,7 +200,7 @@ static void
> > usage(const char *prog)
> > {
> > 	fprintf(stderr, "Usage:\n"
> > -		"%s [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version  
> > version ] [-T|--no-tcp] [-U|--no-udp] nrservs\n",
> > +		"%s [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version  
> > version ] [-T|--no-tcp] [-U|--no-udp] [-d|--debug] nrservs\n",
> > 		prog);
> > 	exit(2);
> > }
> > -- 
> > 1.6.0.6
> >
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 


-- 
Jeff Layton <jlayton@redhat.com>
