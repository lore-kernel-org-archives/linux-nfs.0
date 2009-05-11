From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] nfs-utils: add IPv6 support to nfsd
Date: Mon, 11 May 2009 15:34:37 -0400
Message-ID: <00A26259-D5D8-4E1C-91F4-6AB5CE194870@oracle.com>
References: <1242064697-32520-1-git-send-email-jlayton@redhat.com> <1242064697-32520-4-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:58680 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758481AbZEKTe6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2009 15:34:58 -0400
In-Reply-To: <1242064697-32520-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 11, 2009, at 1:58 PM, Jeff Layton wrote:
> Add 2 new options to rpc.nfsd -- -4 and -6. -4 makes it an IPv4-only
> server, and -6 makes it IPv6-only. Restructure the -H option so that
> if the address appears to be or resolves to an IPv4 address, that
> IPv6 is disabled. Ditto if it resolves to an IPv6 address.

For rpc.statd, I'm following Olaf's suggestion to use /etc/netconfig  
to decide what transports to use for listeners.  Basically, rpc.statd  
attempts to start listeners for all visible netids (marked with 'v')  
in /etc/netconfig.  This is how Solaris works, as I understand it.   
I'm planning to take this course for rpc.mountd as well.

Maybe rpc.nfsd should follow suit?

> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> utils/nfsd/nfsd.c |  137 ++++++++++++++++++++++++++++++++++++++++ 
> +-----------
> 1 files changed, 108 insertions(+), 29 deletions(-)
>
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 25babe1..0022e65 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -41,7 +41,6 @@ static struct option longopts[] =
> };
> unsigned int protobits = NFSCTL_ALLBITS;
> unsigned int versbits = NFSCTL_ALLBITS;
> -char *haddr = NULL;
>
> int
> main(int argc, char **argv)
> @@ -49,7 +48,15 @@ main(int argc, char **argv)
> 	int	count = 1, c, error, port, fd, found_one;
> 	struct servent *ent;
> 	struct hostent *hp;
> -	struct sockaddr_in sin;
> +	struct sockaddr_in sin = { };
> +	struct sockaddr_in6 sin6 = { };
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
> @@ -57,18 +64,12 @@ main(int argc, char **argv)
> 	else
> 		port = 2049;
>
> -	while ((c = getopt_long(argc, argv, "H:hN:p:P:TU", longopts,  
> NULL)) != EOF) {
> +	while ((c = getopt_long(argc, argv, "H:hN:p:P:TU46", longopts,  
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
> @@ -92,24 +93,76 @@ main(int argc, char **argv)
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
> +		case '4':
> +			ipv6 = 0;
> +			break;
> +		case '6':
> +			ipv4 = 0;
> +			break;
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
> +		if (hp->h_addrtype == AF_INET) {
> +			ipv6 = 0;
> +			memcpy(&sin.sin_addr, hp->h_addr_list[0],
> +			       hp->h_length);
> +			if (sin.sin_addr == INADDR_NONE) {
> +				fprintf(stderr, "%s: Bad hostaddr %s\n",
> +						argv[0], haddr);
> +				usage(argv[0]);
> +			}
> +		} else if (hp->h_addrtype == AF_INET6) {
> +			ipv4 = 0;
> +			memcpy(&sin6.sin6_addr, hp->h_addr_list[0],
> +			       hp->h_length);
> +		}
> +	}
> +
> +family_check:
> +	/* make sure at least one address family is enabled */
> +	if (!ipv4 && !ipv6) {
> +		fprintf(stderr, "no address families enabled\n");
> +		exit(1);
> +	}
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
> @@ -120,14 +173,11 @@ main(int argc, char **argv)
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
> @@ -142,6 +192,12 @@ main(int argc, char **argv)
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
> @@ -157,28 +213,51 @@ main(int argc, char **argv)
> 		(void) dup2(fd, 2);
> 	}
> 	closeall(3);
> +	openlog("nfsd", LOG_PID, LOG_DAEMON);
>
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
> -		nfssvc_setvers(versbits);
> +	nfssvc_setvers(versbits);
> +
> +	if (ipv4) {
> +		sin.sin_family = AF_INET;
> +		sin.sin_port = htons(port);
> +		if (!haddr)
> +			sin.sin_addr.s_addr = INADDR_ANY;
> +
> 		nfssvc_setfds(protobits, (struct sockaddr *) &sin, sizeof(sin));
> 	}
>
> -	openlog("nfsd", LOG_PID, LOG_DAEMON);
> +	if (ipv6) {
> +		sin6.sin6_family = AF_INET6;
> +		sin6.sin6_port = htons(port);
> +		if (!haddr)
> +			sin6.sin6_addr = in6addr_any;
> +
> +		nfssvc_setfds(protobits, (struct sockaddr *) &sin6,
> +				sizeof(sin6));
> +	}
> +
> +set_threads:
> 	if ((error = nfssvc_threads(port, count)) < 0) {
> 		int e = errno;
> 		syslog(LOG_ERR, "nfssvc: %s", strerror(e));
> 		closelog();
> 	}
>
> +out:
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



