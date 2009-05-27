From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 4/5] nfs-utils: add IPv6 support to nfsd
Date: Wed, 27 May 2009 12:22:57 -0400
Message-ID: <08EFB0AF-CE3B-4B21-9D6D-33EEBFCDC39E@oracle.com>
References: <1243425275-6284-1-git-send-email-jlayton@redhat.com> <1243425275-6284-5-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:29382 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901AbZE0QXS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 May 2009 12:23:18 -0400
In-Reply-To: <1243425275-6284-5-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 27, 2009, at 7:54 AM, Jeff Layton wrote:

> Add support for handing off IPv6 sockets to the kernel for nfsd. One  
> of
> the main goals here is to not change the behavior of options and not  
> to
> add any new ones, so this patch attempts to do that.
>
> We also don't want to break anything in the event that someone has an
> rpc.nfsd program built with IPv6 capability, but the knfsd doesn't
> support IPv6. Ditto for the cases where IPv6 is either not compiled in
> or is compiled in and blacklisted.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> utils/nfsd/nfsd.c |  158 +++++++++++++++++++++++++++++++++++++++++ 
> +-----------
> 1 files changed, 125 insertions(+), 33 deletions(-)
>
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 2a3cd0a..77c7e1b 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -41,17 +41,24 @@ static struct option longopts[] =
> };
> unsigned int protobits = NFSCTL_ALLBITS;
> unsigned int versbits = NFSCTL_ALLBITS;
> -int minorvers4 = NFSD_MAXMINORVERS4;		/* nfsv4 minor version */
> -char *haddr = NULL;
>
> int
> main(int argc, char **argv)
> {
> -	int	count = 1, c, error, port, fd, found_one;
> +	int	count = 1, c, error = 0, port, fd, found_one;
> 	struct servent *ent;
> 	struct hostent *hp;
> 	char *p;
> -	struct sockaddr_in sin;
> +	struct sockaddr_in sin = { };
> +	struct sockaddr_in6 sin6 = { };
> +	int minorvers4 = NFSD_MAXMINORVERS4;	/* nfsv4 minor version */
> +	char	*haddr = NULL;
> +	int	ipv4 = 1;
> +#ifdef IPV6_SUPPORTED
> +	int	ipv6 = 1;
> +#else  /* IPV6_SUPPORTED */
> +	int	ipv6 = 0;
> +#endif /* IPV6_SUPPORTED */
>
> 	ent = getservbyname ("nfs", "udp");
> 	if (ent != NULL)
> @@ -62,15 +69,9 @@ main(int argc, char **argv)
> 	while ((c = getopt_long(argc, argv, "H:hN:p:P:TU", longopts,  
> NULL)) != EOF) {
> 		switch(c) {
> 		case 'H':
> -			if (inet_addr(optarg) != INADDR_NONE) {
> -				haddr = strdup(optarg);
> -			} else if ((hp = gethostbyname(optarg)) != NULL) {
> -				haddr = inet_ntoa((*(struct in_addr*)(hp->h_addr_list[0])));
> -			} else {
> -				fprintf(stderr, "%s: Unknown hostname: %s\n",
> -					argv[0], optarg);
> -				usage(argv [0]);
> -			}
> +			/* we only deal with one host addr at the moment */
> +			free(haddr);
> +			haddr = strdup(optarg);
> 			break;
> 		case 'P':	/* XXX for nfs-server compatibility */
> 		case 'p':
> @@ -98,24 +99,79 @@ main(int argc, char **argv)
> 			}
> 			break;
> 		case 'T':
> -				NFSCTL_TCPUNSET(protobits);
> -				break;
> +			NFSCTL_TCPUNSET(protobits);
> +			break;
> 		case 'U':
> -				NFSCTL_UDPUNSET(protobits);
> -				break;
> +			NFSCTL_UDPUNSET(protobits);
> +			break;

Clean up: separate patch?

> 		default:
> 			fprintf(stderr, "Invalid argument: '%c'\n", c);
> 		case 'h':
> 			usage(argv[0]);
> 		}
> 	}
> -	/*
> -	 * Do some sanity checking, if the ctlbits are set
> -	 */
> +
> +	/* sanity checks */
> +
> +	/* if an address was specified, check it first */
> +	if (haddr) {
> +		/* does it look like an addr of some sort? */
> +		if (inet_pton(AF_INET, haddr, &sin.sin_addr)) {
> +			ipv6 = 0;
> +			goto family_check;
> +		} else if (inet_pton(AF_INET6, haddr, &sin6.sin6_addr)) {
> +			ipv4 = 0;
> +			goto family_check;
> +		}

Using getaddrinfo(3) with AI_NUMERICHOST might allow a lot of  
simplification here.  See utils/new-statd/hostname.c in my repo for  
some possibilities.

You could also easily pass the text version of the -p option into  
getaddrinfo() to have it plant the port number into the bind address.

This logic is complex enough that you may want to extract it into a  
helper anyway.

> +
> +		/* see if it's a hostname */
> +		hp = gethostbyname(haddr);
> +		if (!hp) {
> +			fprintf(stderr, "%s: gethostbyname on %s failed: %d\n",
> +					argv[0], haddr, h_errno);
> +			error = h_errno;
> +			usage(argv[0]);
> +		}
> +
> +		switch (hp->h_addrtype) {
> +		case AF_INET:
> +			ipv6 = 0;
> +			memcpy(&sin.sin_addr, hp->h_addr_list[0],
> +			       hp->h_length);
> +			if (sin.sin_addr.s_addr == INADDR_NONE) {
> +				fprintf(stderr, "%s: Bad hostaddr %s\n",
> +						argv[0], haddr);
> +				usage(argv[0]);
> +			}
> +			break;
> +#ifdef IPV6_SUPPORTED
> +		case AF_INET6:
> +			ipv4 = 0;
> +			memcpy(&sin6.sin6_addr, hp->h_addr_list[0],
> +			       hp->h_length);
> +			break;
> +#endif /* IPV6_SUPPORTED */
> +		default:
> +			fprintf(stderr, "%s: unsupported address family %d\n",
> +					argv[0], hp->h_addrtype);
> +			exit(0);
> +		}
> +	}
> +
> +family_check:
> +	/* make sure at least one address family is enabled */
> +	if (!ipv4 && !ipv6) {
> +		fprintf(stderr, "no address families enabled\n");
> +		exit(1);
> +	}

Is this needed if you don't have -4 and -6?  I'm still familiarizing  
myself with these patches, but I have a vague feeling that this  
checking could be made much simpler, especially if the netconfig- 
related logic was introduced at the same time rather than in a  
separate patch.

> +
> +	/* make sure at least one protocol type is enabled */
> 	if (!NFSCTL_UDPISSET(protobits) && !NFSCTL_TCPISSET(protobits)) {
> 		fprintf(stderr, "invalid protocol specified\n");
> 		exit(1);
> 	}
> +
> +	/* make sure that at least one version is enabled */
> 	found_one = 0;
> 	for (c = NFSD_MINVERS; c <= NFSD_MAXVERS; c++) {
> 		if (NFSCTL_VERISSET(versbits, c))
> @@ -126,14 +182,11 @@ main(int argc, char **argv)
> 		exit(1);
> 	}			
>
> +	/* must have TCP for NFSv4 */
> 	if (NFSCTL_VERISSET(versbits, 4) && !NFSCTL_TCPISSET(protobits)) {
> 		fprintf(stderr, "version 4 requires the TCP protocol\n");
> 		exit(1);
> 	}
> -	if (haddr == NULL) {
> -		struct in_addr in = {INADDR_ANY};
> -		haddr = strdup(inet_ntoa(in));
> -	}
>
> 	if (chdir(NFS_STATEDIR)) {
> 		fprintf(stderr, "%s: chdir(%s) failed: %s\n",
> @@ -148,6 +201,12 @@ main(int argc, char **argv)
> 				"%s: invalid server count (%d), using 1\n",
> 				argv[0], count);
> 			count = 1;
> +		} else if (count == 0) {
> +			/*
> +			 * don't bother setting anything else if the threads
> +			 * are coming down anyway.
> +			 */
> +			goto set_threads;
> 		}
> 	}
> 	/* KLUDGE ALERT:
> @@ -163,24 +222,55 @@ main(int argc, char **argv)
> 		(void) dup2(fd, 2);
> 	}
> 	closeall(3);
> +	openlog("nfsd", LOG_PID, LOG_DAEMON);

Might be nice if rpc.nfsd used xlog() instead.  Maybe for another day.

> -	sin.sin_family = AF_INET;
> -	sin.sin_port = htons(port);
> -	sin.sin_addr.s_addr = inet_addr(haddr);
> +	/*
> +	 * skip everything but setting of number of threads if sockets are
> +	 * already open and in use.
> +	 */
> +	if (nfssvc_inuse())
> +		goto set_threads;
>
> 	/*
> 	 * must set versions before the fd's so that the right versions get
> 	 * registered with rpcbind. Note that on older kernels w/o the right
> 	 * interfaces, these are a no-op.
> 	 */
> -	if (!nfssvc_inuse()) {
> -		nfssvc_setvers(versbits, minorvers4);
> -		error = nfssvc_setfds(protobits, (struct sockaddr *) &sin,  
> sizeof(sin));
> -		if (error)
> -			goto out;
> +	nfssvc_setvers(versbits, minorvers4);
> +
> +	if (ipv4) {
> +		sin.sin_family = AF_INET;
> +		sin.sin_port = htons(port);
> +		if (!haddr)
> +			sin.sin_addr.s_addr = INADDR_ANY;
> +
> +		if (nfssvc_setfds(protobits, (struct sockaddr *) &sin,  
> sizeof(sin)))
> +			ipv4 = 0;
> 	}
>
> -	openlog("nfsd", LOG_PID, LOG_DAEMON);
> +#ifdef IPV6_SUPPORTED
> +	if (ipv6) {
> +		sin6.sin6_family = AF_INET6;
> +		sin6.sin6_port = htons(port);
> +		if (!haddr)
> +			sin6.sin6_addr = in6addr_any;
> +
> +		if (nfssvc_setfds(protobits, (struct sockaddr *) &sin6,  
> sizeof(sin6)))
> +			ipv6 = 0;
> +	}
> +#endif /* IPV6_SUPPORTED */
> +
> +	/*
> +	 * if ipv4 and ipv6 are both 0 here, then we were unable to pass  
> off sockets
> +	 * to the kernel. Don't try to bring up any threads.
> +	 */
> +	if (!ipv4 && !ipv6 && count > 0) {
> +		syslog(LOG_ERR, "nfssvc: failed to hand off sockets to kernel\n");
> +		error = -1;
> +		goto out;
> +	}
> +
> +set_threads:
> 	if ((error = nfssvc_threads(port, count)) < 0) {
> 		int e = errno;
> 		syslog(LOG_ERR, "nfssvc: %s", strerror(e));
> @@ -188,6 +278,8 @@ main(int argc, char **argv)
> 	}
>
> out:
> +	free(haddr);
> +	closelog();
> 	return (error != 0);
> }
>
> -- 
> 1.6.0.6
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
