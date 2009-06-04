From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 06/10] nfs-utils: convert nfssvc_setfds to use getaddrinfo
Date: Thu, 4 Jun 2009 16:17:25 -0400
Message-ID: <8CBDF84A-D188-4D25-8211-A18AD5EC65A7@oracle.com>
References: <1244058763-10352-1-git-send-email-jlayton@redhat.com> <1244058763-10352-7-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:57061 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbZFDUSh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2009 16:18:37 -0400
In-Reply-To: <1244058763-10352-7-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 3, 2009, at 3:52 PM, Jeff Layton wrote:

> Convert nfssvc_setfds to use getaddrinfo. Change the args that it  
> takes
> and fix up nfssvc function to pass in the proper args. The things that
> nfssvc has to do to call the new nfssvc_setfds is a little cumbersome
> for now, but that will eventually be cleaned up in a later patch.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> support/nfs/nfssvc.c |  191 +++++++++++++++++++++++++++++++++ 
> +----------------
> utils/nfsd/nfsd.c    |   18 +++--
> 2 files changed, 140 insertions(+), 69 deletions(-)
>
> diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
> index 8b15c4d..168414c 100644
> --- a/support/nfs/nfssvc.c
> +++ b/support/nfs/nfssvc.c
> @@ -10,7 +10,9 @@
> #include <config.h>
> #endif
>
> +#include <sys/types.h>
> #include <sys/socket.h>
> +#include <netdb.h>
> #include <netinet/in.h>
> #include <arpa/inet.h>
> #include <unistd.h>
> @@ -53,85 +55,148 @@ nfssvc_inuse(void)
> 	return 0;
> }
>
> -static void
> -nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
> +static int
> +nfssvc_setfds(const struct addrinfo *hints, const char *node, const  
> char *port)
> {
> -	int fd, n, on=1;
> +	int fd, on = 1, fac = L_ERROR;
> +	int sockfd = -1, rc = 0;
> 	char buf[BUFSIZ];

Same comment as earlier; BUFSIZ is probably unnecessarily large.

> -	int udpfd = -1, tcpfd = -1;
> -	struct sockaddr_in sin;
> -
> -	if (nfssvc_inuse())
> -		return;
> +	struct addrinfo *addrhead = NULL, *addr;
> +	char *proto, *family;
>
> +	/*
> +	 * if file can't be opened, then assume that it's not available and
> +	 * that the caller should just fall back to the old nfsctl interface
> + 	 */
> 	fd = open(NFSD_PORTS_FILE, O_WRONLY);
> 	if (fd < 0)
> -		return;
> -	sin.sin_family = AF_INET;
> -	sin.sin_port   = htons(port);
> -	sin.sin_addr.s_addr =  inet_addr(haddr);
> -
> -	if (NFSCTL_UDPISSET(ctlbits)) {
> -		udpfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
> -		if (udpfd < 0) {
> -			xlog(L_ERROR, "unable to create UDP socket: "
> -				"errno %d (%m)", errno);
> -			exit(1);
> -		}
> -		if (bind(udpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
> -			xlog(L_ERROR, "unable to bind UDP socket: "
> -				"errno %d (%m)", errno);
> -			exit(1);
> -		}
> +		return 0;
> +
> +	switch(hints->ai_family) {
> +	case AF_INET:
> +		family = "inet";
> +		break;
> +	default:
> +		xlog(L_ERROR, "Unknown address family specified: %d\n",
> +				hints->ai_family);
> +		rc = EAFNOSUPPORT;
> +		goto error;
> 	}
>
> -	if (NFSCTL_TCPISSET(ctlbits)) {
> -		tcpfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
> -		if (tcpfd < 0) {
> -			xlog(L_ERROR, "unable to createt tcp socket: "
> -				"errno %d (%m)", errno);
> -			exit(1);
> +	rc = getaddrinfo(node, port, hints, &addrhead);
> +	if (rc == EAI_NONAME && !strcmp(port, "nfs")) {
> +		snprintf(buf, BUFSIZ, "%d", NFS_PORT);
> +		rc = getaddrinfo(node, buf, hints, &addrhead);
> +	}

So, I wonder about this semantic.  Should rpc.nfsd fail outright if  
the specified port isn't usable?  If it succeeds, but silently creates  
a listener on a port that wasn't specified, that might be a little  
surprising to some administrators.

Also, passing sizeof(buf) instead of BUFSIZ might be more maintainable.

> +
> +	if (rc != 0) {
> +		xlog(L_ERROR, "unable to resolve %s:%s to %s address: "
> +				"%s", node ? node : "ANYADDR", port, family,
> +				rc == EAI_SYSTEM ? strerror(errno) :
> +					gai_strerror(rc));
> +		goto error;
> +	}
> +
> +	addr = addrhead;
> +	while(addr) {
> +		/* skip non-TCP / non-UDP sockets */
> +		switch(addr->ai_protocol) {
> +		case IPPROTO_UDP:
> +			proto = "UDP";
> +			break;
> +		case IPPROTO_TCP:
> +			proto = "TCP";
> +			break;
> +		default:
> +			addr = addr->ai_next;
> +			continue;
> 		}
> -		if (setsockopt(tcpfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on))  
> < 0) {
> -			xlog(L_ERROR, "unable to set SO_REUSEADDR: "
> -				"errno %d (%m)", errno);
> -			exit(1);
> +
> +		xlog(D_GENERAL, "Creating %s %s socket.", family, proto);
> +
> +		/* open socket and prepare to hand it off to kernel */
> +		sockfd = socket(addr->ai_family, addr->ai_socktype,
> +				addr->ai_protocol);
> +		if (sockfd < 0) {
> +			xlog(L_ERROR, "unable to create %s %s socket: "
> +				"errno %d (%m)", family, proto, errno);
> +			rc = errno;
> +			goto error;
> 		}
> -		if (bind(tcpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
> -			xlog(L_ERROR, "unable to bind TCP socket: "
> -				"errno %d (%m)", errno);
> -			exit(1);
> +		if (addr->ai_protocol == IPPROTO_TCP &&
> +		    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &on,  
> sizeof(on))) {
> +			xlog(L_ERROR, "unable to set SO_REUSEADDR on %s "
> +				"socket: errno %d (%m)", family, errno);
> +			rc = errno;
> +			goto error;
> +		}
> +		if (bind(sockfd, addr->ai_addr, addr->ai_addrlen)) {
> +			xlog(L_ERROR, "unable to bind %s %s socket: "
> +				"errno %d (%m)", family, proto, errno);
> +			rc = errno;
> +			goto error;
> 		}
> -		if (listen(tcpfd, 64) < 0){
> +		if (addr->ai_protocol == IPPROTO_TCP && listen(sockfd, 64)) {
> 			xlog(L_ERROR, "unable to create listening socket: "
> 				"errno %d (%m)", errno);
> -			exit(1);
> +			rc = errno;
> +			goto error;
> 		}
> -	}
> -	if (udpfd >= 0) {
> -		snprintf(buf, BUFSIZ,"%d\n", udpfd);
> -		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
> -			xlog(L_ERROR,
> -			       "writing fds to kernel failed: errno %d (%m)",
> -			       errno);
> -		}
> -		close(fd);
> -		fd = -1;
> -	}
> -	if (tcpfd >= 0) {
> +
> 		if (fd < 0)
> 			fd = open(NFSD_PORTS_FILE, O_WRONLY);
> -		snprintf(buf, BUFSIZ,"%d\n", tcpfd);
> +
> +		if (fd < 0) {
> +			xlog(L_ERROR, "couldn't open ports file: errno "
> +				      "%d (%m)", errno);
> +			goto error;
> +		}
> +		snprintf(buf, BUFSIZ, "%d\n", sockfd);
> 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
> -			xlog(L_ERROR,
> -			       "writing fds to kernel failed: errno %d (%m)",
> -			       errno);
> +			/*
> +			 * this error may be common on older kernels that don't
> +			 * support IPv6, so turn into a debug message.
> +			 */
> +			if (errno == EAFNOSUPPORT)
> +				fac = D_ALL;
> +			xlog(fac, "writing fd to kernel failed: errno %d (%m)",
> +				  errno);
> +			rc = errno;
> +			goto error;
> 		}
> +		close(fd);
> +		close(sockfd);
> +		sockfd = fd = -1;
> +		addr = addr->ai_next;
> 	}
> -	close(fd);
> +error:
> +	if (fd >= 0)
> +		close(fd);
> +	if (sockfd >= 0)
> +		close(sockfd);
> +	if (addrhead)
> +		freeaddrinfo(addrhead);
> +	return rc;
> +}
>
> -	return;
> +static int
> +nfssvc_set_sockets(const int family, const unsigned int protobits,
> +		   const char *host, const char *port)
> +{
> +	struct addrinfo hints = { .ai_flags = AI_PASSIVE | AI_ADDRCONFIG };
> +
> +	hints.ai_family = family;
> +
> +	if (!NFSCTL_ANYPROTO(protobits))
> +		return EPROTOTYPE;
> +	else if (!NFSCTL_UDPISSET(protobits))
> +		hints.ai_protocol = IPPROTO_TCP;
> +	else if (!NFSCTL_TCPISSET(protobits))
> +		hints.ai_protocol = IPPROTO_UDP;
> +
> +	return nfssvc_setfds(&hints, host, port);
> }
> +
> static void
> nfssvc_versbits(unsigned int ctlbits, int minorvers4)
> {
> @@ -169,13 +234,17 @@ nfssvc(int port, int nrservs, unsigned int  
> versbits, int minorvers4,
> {
> 	struct nfsctl_arg	arg;
> 	int fd;
> +	char portstr[BUFSIZ];

Ditto.

> 	/* Note: must set versions before fds so that
> 	 * the ports get registered with portmap against correct
> 	 * versions
> 	 */
> -	nfssvc_versbits(versbits, minorvers4);
> -	nfssvc_setfds(port, protobits, haddr);
> +	if (!nfssvc_inuse()) {
> +		nfssvc_versbits(versbits, minorvers4);
> +		snprintf(portstr, BUFSIZ, "%d", port);
> +		nfssvc_set_sockets(AF_INET, protobits, haddr, portstr);
> +	}
>
> 	fd = open(NFSD_THREAD_FILE, O_WRONLY);
> 	if (fd < 0)
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 6dfea67..e9d0bf9 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -76,14 +76,16 @@ main(int argc, char **argv)
> 			xlog_stderr(1);
> 			break;
> 		case 'H':
> -			if (inet_addr(optarg) != INADDR_NONE) {
> -				haddr = strdup(optarg);
> -			} else if ((hp = gethostbyname(optarg)) != NULL) {
> -				haddr = inet_ntoa((*(struct in_addr*)(hp->h_addr_list[0])));
> -			} else {
> -				fprintf(stderr, "%s: Unknown hostname: %s\n",
> -					progname, optarg);
> -				usage(progname);
> +			/*
> +			 * for now, this only handles one -H option. Use the
> +			 * last one specified.
> +			 */
> +			free(haddr);
> +			haddr = strdup(optarg);
> +			if (!haddr) {
> +				fprintf(stderr, "%s: unable to allocate "
> +					"memory.\n", progname);
> +				exit(1);

Aside: I've been trying to stick with EXIT_SUCCESS and EXIT_FAILURE  
when calling exit(3).

> 			}
> 			break;
> 		case 'P':	/* XXX for nfs-server compatibility */
> -- 
> 1.6.2.2
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
