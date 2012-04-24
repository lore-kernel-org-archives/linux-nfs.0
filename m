Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64122 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754680Ab2DXPEI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 11:04:08 -0400
Message-ID: <4F96C0E3.9090007@redhat.com>
Date: Tue, 24 Apr 2012 17:04:03 +0200
From: Niels de Vos <ndevos@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpcbind: Only listen on requested hostnames for NC_TPI_COTS
 connections
References: <1335194692-6714-1-git-send-email-ndevos@redhat.com> <82D8C43F-5C40-444C-9573-B4FF95F615DA@oracle.com> <4F957D30.9010102@redhat.com> <7C71F75F-3F15-401B-8700-38B0EBE2B595@oracle.com>
In-Reply-To: <7C71F75F-3F15-401B-8700-38B0EBE2B595@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi again,

On 04/23/2012 06:22 PM, Chuck Lever wrote:
 >
 > On Apr 23, 2012, at 12:02 PM, Niels de Vos wrote:
 >
 >> On 04/23/2012 05:33 PM, Chuck Lever wrote:
 >>> Hi-
 >>>
 >>> On Apr 23, 2012, at 11:24 AM, Niels de Vos wrote:
 >>>
 >>>> There is a check for NC_TPI_CLTS connections which correctly binds
only
 >>>> to the hostnames/addresses given on the commandline (-h option). This
 >>>> implementation does not take non NC_TPI_CLTS like NC_TPI_COTS and
 >>>> NC_TPI_COTS_ORD into account. This causes non NC_TPI_CLTS protocols to
 >>>> listen on the "0.0.0.0" and "::" wildcard addresses.
 >>>>
 >>>> This patch simplifies the code, and moves the check for
NC_TPI_CLTS into
 >>>> the loop when a bind() for each requested address is done. All
 >>>> connections, including NC_TPI_COTS and NC_TPI_COTS_ORD can now benefit
 >>>> from resticted bind()'ing on addresses.
 >>>
 >>> Please check the mailing list archives for linux-nfs and/or
 >>> libtirpc-devel. There may be a good reason for this asymmetrical
 >>> behavior, or at least some enlightening discussion of this idea.
 >>
 >> The only difference in the code before and after is for NC_TPI_CLTS vs
 >> (NC_TPI_CLTS or NC_TPI_COTS) and has moved to this if statement:
 >>
 >> 		if (nconf->nc_semantics != NC_TPI_CLTS) {
 >>
 >> I could not find any reasons why binding on UDP may be restricted, where
 >> binding on TCP would not.
 >
 > So you did check the mail archive?  I seem to recall other patches like
 > this in the past, and that there is a reason why rpcbind works this way.
 > I simply don't remember the specifics right at the moment.

I did, but no messages about this subject come up for me... Maybe I'm looking
in the wrong places :-/

 > One reason might be that UDP doesn't guarantee that the forward and
 > reply network paths will use the same source and destination addresses,
 > but TCP does.

Would this not rather speak against binding on a specific address for UDP?
That functionality already exists, its just TCP that ignores the option from
the command line.

 >>> Also, can you tell us why you need this change in the patch
 >>> description?
 >>
 >> Currently rpcbind provides the -h option to contain a hostname (like
 >> localhost). When the option is used, rpcbind will only listen on the
 >> "127.0.0.1" address for UDP. TCP will continue to listen on "0.0.0.0"
 >> and "::". IMHO this is inconsistent and wrong, hence my proposal to
 >> fix this.
 >
 > Let me ask a more specific question: is there a real-world use case
 > that requires this change?

It was brought to my attention that the old portmapper has this feature. When
migrating the configuration to rpcbind, it was noticed that the -h option does
not affect binding TCP sockets, only UDP. This behavior is documented in the
man-page, but is still feels inconsistent.

 >> While doing so, I noticed that the if and else branches are extremely
 >> similar and therefore I combined them.
 >
 > That is a clean up, and being a logically distinct change, generally
 > belongs in a separate patch from a patch that changes the code behavior.

If you or someone else can let me know if the change itself is acceptable,
I'll resend the patch in two pieces (behavior change, cleanup).

After more testing it seems that the patched rpcbind is not functioning
correctly. I'll have to look into that before sending a 2nd patch-set.

Thanks!


 >> Let me know if you need any further details. Thanks,
 >> Niels
 >>
 >>
 >>>
 >>>> Signed-off-by: Niels de Vos<ndevos@redhat.com>
 >>>> ---
 >>>> src/rpcbind.c |  230
++++++++++++++++++++------------------------------------
 >>>> 1 files changed, 82 insertions(+), 148 deletions(-)
 >>>>
 >>>> diff --git a/src/rpcbind.c b/src/rpcbind.c
 >>>> index 9a0504d..3f6c2a9 100644
 >>>> --- a/src/rpcbind.c
 >>>> +++ b/src/rpcbind.c
 >>>> @@ -339,172 +339,103 @@ init_transport(struct netconfig *nconf)
 >>>> 		hints.ai_socktype = si.si_socktype;
 >>>> 		hints.ai_protocol = si.si_proto;
 >>>> 	}
 >>>> -	if (nconf->nc_semantics == NC_TPI_CLTS) {
 >>>> +
 >>>> +	/*
 >>>> +	 * If no hosts were specified, just bind to INADDR_ANY.  Otherwise
 >>>> +	 * make sure 127.0.0.1 is added to the list.
 >>>> +	 */
 >>>> +	nhostsbak = nhosts;
 >>>> +	nhostsbak++;
 >>>> +	hosts = realloc(hosts, nhostsbak * sizeof(char *));
 >>>> +	if (nhostsbak == 1)
 >>>> +		hosts[0] = "*";
 >>>> +	else {
 >>>> +		if (hints.ai_family == AF_INET) {
 >>>> +			hosts[nhostsbak - 1] = "127.0.0.1";
 >>>> +		} else if (hints.ai_family == AF_INET6) {
 >>>> +			hosts[nhostsbak - 1] = "::1";
 >>>> +		} else
 >>>> +			return 1;
 >>>> +	}
 >>>> +
 >>>> +       /*
 >>>> +	* Bind to specific IPs if asked to
 >>>> +	*/
 >>>> +	checkbind = 0;
 >>>> +	while (nhostsbak>   0) {
 >>>> +		--nhostsbak;
 >>>> 		/*
 >>>> -		 * If no hosts were specified, just bind to INADDR_ANY.  Otherwise
 >>>> -		 * make sure 127.0.0.1 is added to the list.
 >>>> +		 * XXX - using RPC library internal functions.
 >>>> 		 */
 >>>> -		nhostsbak = nhosts;
 >>>> -		nhostsbak++;
 >>>> -		hosts = realloc(hosts, nhostsbak * sizeof(char *));
 >>>> -		if (nhostsbak == 1)
 >>>> -			hosts[0] = "*";
 >>>> -		else {
 >>>> -			if (hints.ai_family == AF_INET) {
 >>>> -				hosts[nhostsbak - 1] = "127.0.0.1";
 >>>> -			} else if (hints.ai_family == AF_INET6) {
 >>>> -				hosts[nhostsbak - 1] = "::1";
 >>>> -			} else
 >>>> -				return 1;
 >>>> +		if ((fd = __rpc_nconf2fd(nconf))<   0) {
 >>>> +			syslog(LOG_ERR, "cannot create socket for %s",
 >>>> +			    nconf->nc_netid);
 >>>> +			return (1);
 >>>> 		}
 >>>> -
 >>>> -	       /*
 >>>> -		* Bind to specific IPs if asked to
 >>>> -		*/
 >>>> -		checkbind = 0;
 >>>> -		while (nhostsbak>   0) {
 >>>> -			--nhostsbak;
 >>>> -			/*
 >>>> -			 * XXX - using RPC library internal functions.
 >>>> -			 */
 >>>> -			if ((fd = __rpc_nconf2fd(nconf))<   0) {
 >>>> -				syslog(LOG_ERR, "cannot create socket for %s",
 >>>> -				    nconf->nc_netid);
 >>>> -				return (1);
 >>>> +		switch (hints.ai_family) {
 >>>> +		case AF_INET:
 >>>> +			if (inet_pton(AF_INET, hosts[nhostsbak],
 >>>> +			    host_addr) == 1) {
 >>>> +				hints.ai_flags&= AI_NUMERICHOST;
 >>>> +			} else {
 >>>> +				/*
 >>>> +				 * Skip if we have an AF_INET6 adress.
 >>>> +				 */
 >>>> +				if (inet_pton(AF_INET6,
 >>>> +				    hosts[nhostsbak], host_addr) == 1)
 >>>> +					continue;
 >>>> 			}
 >>>> -			switch (hints.ai_family) {
 >>>> -			case AF_INET:
 >>>> +			break;
 >>>> +		case AF_INET6:
 >>>> +			if (inet_pton(AF_INET6, hosts[nhostsbak],
 >>>> +			    host_addr) == 1) {
 >>>> +				hints.ai_flags&= AI_NUMERICHOST;
 >>>> +			} else {
 >>>> +				/*
 >>>> +				 * Skip if we have an AF_INET adress.
 >>>> +				 */
 >>>> 				if (inet_pton(AF_INET, hosts[nhostsbak],
 >>>> -				    host_addr) == 1) {
 >>>> -					hints.ai_flags&= AI_NUMERICHOST;
 >>>> -				} else {
 >>>> -					/*
 >>>> -					 * Skip if we have an AF_INET6 adress.
 >>>> -					 */
 >>>> -					if (inet_pton(AF_INET6,
 >>>> -					    hosts[nhostsbak], host_addr) == 1)
 >>>> -						continue;
 >>>> -				}
 >>>> -				break;
 >>>> -			case AF_INET6:
 >>>> -				if (inet_pton(AF_INET6, hosts[nhostsbak],
 >>>> -				    host_addr) == 1) {
 >>>> -					hints.ai_flags&= AI_NUMERICHOST;
 >>>> -				} else {
 >>>> -					/*
 >>>> -					 * Skip if we have an AF_INET adress.
 >>>> -					 */
 >>>> -					if (inet_pton(AF_INET, hosts[nhostsbak],
 >>>> -					    host_addr) == 1)
 >>>> -						continue;
 >>>> -				}
 >>>> -	        		break;
 >>>> -			default:
 >>>> -				break;
 >>>> +				    host_addr) == 1)
 >>>> +					continue;
 >>>> 			}
 >>>> +			break;
 >>>> +		default:
 >>>> +			break;
 >>>> +		}
 >>>>
 >>>> -			/*
 >>>> -			 * If no hosts were specified, just bind to INADDR_ANY
 >>>> -			 */
 >>>> -			if (strcmp("*", hosts[nhostsbak]) == 0)
 >>>> -				hosts[nhostsbak] = NULL;
 >>>> +		/*
 >>>> +		 * If no hosts were specified, just bind to INADDR_ANY
 >>>> +		 */
 >>>> +		if (strcmp("*", hosts[nhostsbak]) == 0)
 >>>> +			hosts[nhostsbak] = NULL;
 >>>>
 >>>> +		if ((strcmp(nconf->nc_netid, "local") != 0)&&
 >>>> +		    (strcmp(nconf->nc_netid, "unix") != 0)) {
 >>>> 			if ((aicode = getaddrinfo(hosts[nhostsbak],
 >>>> -			    servname,&hints,&res)) != 0) {
 >>>> +			    servname,&hints,&res))!= 0) {
 >>>> 			  if ((aicode = getaddrinfo(hosts[nhostsbak],
 >>>> -						    "portmapper",&hints,&res)) != 0) {
 >>>> -				syslog(LOG_ERR,
 >>>> +					    "portmapper",&hints,&res))!= 0) {
 >>>> +			    syslog(LOG_ERR,
 >>>> 				    "cannot get local address for %s: %s",
 >>>> 				    nconf->nc_netid, gai_strerror(aicode));
 >>>> -				continue;
 >>>> +			    continue;
 >>>> 			  }
 >>>> 			}
 >>>> 			addrlen = res->ai_addrlen;
 >>>> 			sa = (struct sockaddr *)res->ai_addr;
 >>>> -			oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
 >>>> -                        if (bind(fd, sa, addrlen) != 0) {
 >>>> -				syslog(LOG_ERR, "cannot bind %s on %s: %m",
 >>>> -					(hosts[nhostsbak] == NULL) ? "*" :
 >>>> -					hosts[nhostsbak], nconf->nc_netid);
 >>>> -				if (res != NULL)
 >>>> -					freeaddrinfo(res);
 >>>> -				continue;
 >>>> -			} else
 >>>> -				checkbind++;
 >>>> -			(void) umask(oldmask);
 >>>> -
 >>>> -			/* Copy the address */
 >>>> -			taddr.addr.maxlen = taddr.addr.len = addrlen;
 >>>> -			taddr.addr.buf = malloc(addrlen);
 >>>> -			if (taddr.addr.buf == NULL) {
 >>>> -				syslog(LOG_ERR,
 >>>> -				    "cannot allocate memory for %s address",
 >>>> -				    nconf->nc_netid);
 >>>> +		}
 >>>> +		oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
 >>>> +		if (nconf->nc_semantics != NC_TPI_CLTS) {
 >>>> +			/* NC_TPI_COTS and NC_TPI_COTS_ORD etc */
 >>>> +			__rpc_fd2sockinfo(fd,&si);
 >>>> +			if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR,&on,
 >>>> +			    sizeof(on)) != 0) {
 >>>> +				syslog(LOG_ERR, "cannot set SO_REUSEADDR on %s",
 >>>> +					nconf->nc_netid);
 >>>> 				if (res != NULL)
 >>>> 					freeaddrinfo(res);
 >>>> 				return 1;
 >>>> 			}
 >>>> -			memcpy(taddr.addr.buf, sa, addrlen);
 >>>> -#ifdef RPCBIND_DEBUG
 >>>> -			if (debugging) {
 >>>> -				/*
 >>>> -				 * for debugging print out our universal
 >>>> -				 * address
 >>>> -				 */
 >>>> -				char *uaddr;
 >>>> -				struct netbuf nb;
 >>>> -				int sa_size = 0;
 >>>> -
 >>>> -				nb.buf = sa;
 >>>> -				switch( sa->sa_family){
 >>>> -				case AF_INET:
 >>>> -				  sa_size = sizeof (struct sockaddr_in);
 >>>> -				  break;
 >>>> -				case AF_INET6:
 >>>> -				  sa_size = sizeof (struct sockaddr_in6);				
 >>>> -				  break;
 >>>> -				}
 >>>> -				nb.len = nb.maxlen = sa_size;
 >>>> -				uaddr = taddr2uaddr(nconf,&nb);
 >>>> -				(void) fprintf(stderr,
 >>>> -				    "rpcbind : my address is %s\n", uaddr);
 >>>> -				(void) free(uaddr);
 >>>> -			}
 >>>> -#endif
 >>>> -			my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf,&taddr,
 >>>> -                                RPC_MAXDATASIZE, RPC_MAXDATASIZE);
 >>>> -			if (my_xprt == (SVCXPRT *)NULL) {
 >>>> -				syslog(LOG_ERR, "%s: could not create service",
 >>>> -                                        nconf->nc_netid);
 >>>> -				goto error;
 >>>> -			}
 >>>> -		}
 >>>> -		if (!checkbind)
 >>>> -			return 1;
 >>>> -	} else {	/* NC_TPI_COTS */
 >>>> -		if ((strcmp(nconf->nc_netid, "local") != 0)&&
 >>>> -		    (strcmp(nconf->nc_netid, "unix") != 0)) {
 >>>> -			if ((aicode = getaddrinfo(NULL, servname,&hints,&res))!= 0) {
 >>>> -			  if ((aicode = getaddrinfo(NULL, "portmapper",&hints,&res))!=
0) {
 >>>> -			  printf("cannot get local address for %s: %s",
nconf->nc_netid, gai_strerror(aicode));
 >>>> -			  syslog(LOG_ERR,
 >>>> -				    "cannot get local address for %s: %s",
 >>>> -				    nconf->nc_netid, gai_strerror(aicode));
 >>>> -				return 1;
 >>>> -			  }
 >>>> -			}
 >>>> -			addrlen = res->ai_addrlen;
 >>>> -			sa = (struct sockaddr *)res->ai_addr;
 >>>> -		}
 >>>> -		oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
 >>>> -		__rpc_fd2sockinfo(fd,&si);
 >>>> -		if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR,&on,
 >>>> -				sizeof(on)) != 0) {
 >>>> -			syslog(LOG_ERR, "cannot set SO_REUSEADDR on %s",
 >>>> -				nconf->nc_netid);
 >>>> -			if (res != NULL)
 >>>> -				freeaddrinfo(res);
 >>>> -			return 1;
 >>>> 		}
 >>>> 		if (bind(fd, sa, addrlen)<   0) {
 >>>> 			syslog(LOG_ERR, "cannot bind %s: %m", nconf->nc_netid);
 >>>> @@ -530,7 +461,7 @@ init_transport(struct netconfig *nconf)
 >>>> 			/* for debugging print out our universal address */
 >>>> 			char *uaddr;
 >>>> 			struct netbuf nb;
 >>>> -		        int sa_size2 = 0;
 >>>> +			int sa_size2 = 0;
 >>>>
 >>>> 			nb.buf = sa;
 >>>> 			switch( sa->sa_family){
 >>>> @@ -551,13 +482,16 @@ init_transport(struct netconfig *nconf)
 >>>>
 >>>> 		listen(fd, SOMAXCONN);
 >>>>
 >>>> -		my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf,&taddr,
RPC_MAXDATASIZE, RPC_MAXDATASIZE);
 >>>> +		my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf,&taddr,
 >>>> +			    RPC_MAXDATASIZE, RPC_MAXDATASIZE);
 >>>> 		if (my_xprt == (SVCXPRT *)NULL) {
 >>>> 			syslog(LOG_ERR, "%s: could not create service",
 >>>> 					nconf->nc_netid);
 >>>> 			goto error;
 >>>> 		}
 >>>> 	}
 >>>> +	if (!checkbind)
 >>>> +		return 1;
 >>>>
 >>>> #ifdef PORTMAP
 >>>> 	/*
 >>>> --
 >>>> 1.7.7.6
 >>>>
