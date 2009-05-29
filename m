From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 5/5] nfs-utils: limit protocols and families used by nfsd to those listed in /etc/netconfig
Date: Fri, 29 May 2009 11:30:17 -0400
Message-ID: <BED3D54F-0EF3-4AB4-954A-765D1454AF83@oracle.com>
References: <1243425275-6284-1-git-send-email-jlayton@redhat.com> <1243425275-6284-6-git-send-email-jlayton@redhat.com> <91B388AD-66DF-4204-B0C2-9131D5AA4651@oracle.com> <20090529072050.0f24e385@tlielax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:58827 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbZE2Pav (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2009 11:30:51 -0400
In-Reply-To: <20090529072050.0f24e385-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 29, 2009, at 7:20 AM, Jeff Layton wrote:

> On Wed, 27 May 2009 12:30:21 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
>
>>
>> On May 27, 2009, at 7:54 AM, Jeff Layton wrote:
>>
>>> ...disable any that aren't listed or aren't marked as "visible".
>>
>> I kind of favor the converse approach -- enable the ones that _are_
>> marked visible -- which appears to be the more common usage of
>> netconfig.
>>
>
> Fair enough. That may be cleaner. I'll probably change it to do that.
>
>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>> ---
>>> support/include/nfslib.h |    2 +
>>> support/nfs/nfssvc.c     |   69 +++++++++++++++++++++++++++++++++++ 
>>> ++
>>> +++++++++
>>> utils/nfsd/nfsd.c        |   32 +++++++++++++++------
>>> 3 files changed, 94 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/support/include/nfslib.h b/support/include/nfslib.h
>>> index 4cb1dc0..bae0902 100644
>>> --- a/support/include/nfslib.h
>>> +++ b/support/include/nfslib.h
>>> @@ -133,6 +133,8 @@ int			nfsctl(int, struct nfsctl_arg *, union
>>> nfsctl_res *);
>>> int			nfssvc_inuse(void);
>>> int			nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa,
>>> 					socklen_t addrlen);
>>> +unsigned int		nfssvc_set_family_proto(const sa_family_t family,
>>> +						unsigned int ctlbits);
>>> void			nfssvc_setvers(unsigned int ctlbits, int minorvers4);
>>> int			nfssvc_threads(unsigned short port, int nrservs);
>>> int			nfsaddclient(struct nfsctl_client *clp);
>>> diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
>>> index 2aa5281..a91c892 100644
>>> --- a/support/nfs/nfssvc.c
>>> +++ b/support/nfs/nfssvc.c
>>> @@ -18,8 +18,13 @@
>>> #include <errno.h>
>>> #include <syslog.h>
>>>
>>> +#ifdef HAVE_LIBTIRPC
>>> +#include <netdb.h>
>>> +#include <netconfig.h>
>>> +#endif
>>>
>>> #include "nfslib.h"
>>> +#include "nfsrpc.h"
>>>
>>> #define NFSD_PORTS_FILE     "/proc/fs/nfsd/portlist"
>>> #define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
>>> @@ -54,6 +59,70 @@ nfssvc_inuse(void)
>>> 	return 0;
>>> }
>>>
>>> +#ifdef HAVE_LIBTIRPC
>>> +static unsigned int
>>> +nfssvc_netid_visible(const sa_family_t family, const unsigned short
>>> protocol)
>>> +{
>>> +	char *nc_protofmly, *nc_proto;
>>> +	struct netconfig *nconf;
>>> +	struct protoent *proto;
>>> +	void *handle;
>>> +
>>> +	switch (family) {
>>> +	case AF_LOCAL:
>>> +	case AF_INET:
>>> +		nc_protofmly = NC_INET;
>>> +		break;
>>> +	case AF_INET6:
>>> +		nc_protofmly = NC_INET6;
>>> +		break;
>>> +	default:
>>> +		return 0;
>>> +	}
>>> +
>>> +	proto = getprotobynumber(protocol);
>>> +	if (proto == NULL)
>>> +		return 0;
>>> +	nc_proto = proto->p_name;
>>
>> Oddly I don't see any usage in libtirpc of getprotobynumber(3).  It
>> seems to stick with defined constants such as NC_TCP.  I suspect  
>> there
>> is really no guaranteed relationship between getprotobynumber and
>> getnetconfig.
>>
>> I guess this is exactly the friction point between the world of TI- 
>> RPC
>> and netids and the kernel's world which doesn't have that concept.
>>
>
> Hmm good point...I'll plan to switch the next iteration of this set  
> not
> to use getprotobynumber.
>
> FWIW, you may want to have a look at nfs_gp_get_netid since it does  
> the
> same thing.

All of that code will get a fair scrubbing after we finish the first  
pass of IPv6 support in nfs-utils.

>>> +
>>> +	handle = setnetconfig();
>>> +	while((nconf = getnetconfig(handle))) {
>>> +		if (!(nconf->nc_flag & NC_VISIBLE))
>>> +			continue;
>>> +		if (nconf->nc_protofmly &&
>>> +		    strcmp(nconf->nc_protofmly, nc_protofmly))
>>> +			continue;
>>> +		if (nconf->nc_proto && strcmp(nconf->nc_proto, nc_proto))
>>> +			continue;
>>> +		endnetconfig(handle);
>>> +		return 1;
>>> +	}
>>> +	endnetconfig(handle);
>>> +	return 0;
>>> +}
>>> +#else
>>> +static unsigned int
>>> +nfssvc_netid_visible(const sa_family_t family, const unsigned short
>>> protocol)
>>> +{
>>> +	return 1;
>>> +}
>>> +#endif
>>> +
>>> +/* given a family and ctlbits, disable any that aren't listed in
>>> netconfig */
>>> +unsigned int
>>> +nfssvc_set_family_proto(const sa_family_t family, unsigned int
>>> ctlbits)
>>> +{
>>> +	if (NFSCTL_UDPISSET(ctlbits) &&
>>> +	    !nfssvc_netid_visible(family, IPPROTO_UDP))
>>> +		NFSCTL_UDPUNSET(ctlbits);
>>> +
>>> +	if (NFSCTL_TCPISSET(ctlbits) &&
>>> +	    !nfssvc_netid_visible(family, IPPROTO_TCP))
>>> +		NFSCTL_TCPUNSET(ctlbits);
>>> +
>>> +	return ctlbits;
>>> +}
>>> +
>>> int
>>> nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t
>>> addrlen)
>>> {
>>> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
>>> index 77c7e1b..45bede9 100644
>>> --- a/utils/nfsd/nfsd.c
>>> +++ b/utils/nfsd/nfsd.c
>>> @@ -54,6 +54,8 @@ main(int argc, char **argv)
>>> 	int minorvers4 = NFSD_MAXMINORVERS4;	/* nfsv4 minor version */
>>> 	char	*haddr = NULL;
>>> 	int	ipv4 = 1;
>>> +	unsigned int proto4;
>>> +	unsigned int proto6;
>>> #ifdef IPV6_SUPPORTED
>>> 	int	ipv6 = 1;
>>> #else  /* IPV6_SUPPORTED */
>>> @@ -159,15 +161,25 @@ main(int argc, char **argv)
>>> 	}
>>>
>>> family_check:
>>> -	/* make sure at least one address family is enabled */
>>> -	if (!ipv4 && !ipv6) {
>>> -		fprintf(stderr, "no address families enabled\n");
>>> -		exit(1);
>>> +	/* limit protocols to use based on /etc/netconfig */
>>> +	proto4 = nfssvc_set_family_proto(AF_INET, protobits);
>>> +	proto6 = nfssvc_set_family_proto(AF_INET6, protobits);
>>> +
>>> +	/* make sure at least one protocol type is enabled */
>>> +	if (ipv4 && !NFSCTL_UDPISSET(proto4) && ! 
>>> NFSCTL_TCPISSET(proto4)) {
>>> +		fprintf(stderr, "WARNING: no protocols enabled for IPv4\n");
>>> +		ipv4 = 0;
>>> 	}
>>>
>>> 	/* make sure at least one protocol type is enabled */
>>> -	if (!NFSCTL_UDPISSET(protobits) && !NFSCTL_TCPISSET(protobits)) {
>>> -		fprintf(stderr, "invalid protocol specified\n");
>>> +	if (ipv6 && !NFSCTL_UDPISSET(proto6) && ! 
>>> NFSCTL_TCPISSET(proto6)) {
>>> +		fprintf(stderr, "WARNING: no protocols enabled for IPv6\n");
>>> +		ipv6 = 0;
>>> +	}
>>> +
>>> +	/* make sure at least one address family is enabled */
>>> +	if (!ipv4 && !ipv6) {
>>> +		fprintf(stderr, "no address families enabled\n");
>>> 		exit(1);
>>> 	}
>>>
>>> @@ -183,7 +195,9 @@ family_check:
>>> 	}			
>>>
>>> 	/* must have TCP for NFSv4 */
>>> -	if (NFSCTL_VERISSET(versbits, 4) && !NFSCTL_TCPISSET(protobits)) {
>>> +	if (NFSCTL_VERISSET(versbits, 4) &&
>>> +	    !NFSCTL_TCPISSET(proto4) &&
>>> +	    !NFSCTL_TCPISSET(proto6)) {
>>> 		fprintf(stderr, "version 4 requires the TCP protocol\n");
>>> 		exit(1);
>>> 	}
>>> @@ -244,7 +258,7 @@ family_check:
>>> 		if (!haddr)
>>> 			sin.sin_addr.s_addr = INADDR_ANY;
>>>
>>> -		if (nfssvc_setfds(protobits, (struct sockaddr *) &sin,
>>> sizeof(sin)))
>>> +		if (nfssvc_setfds(proto4, (struct sockaddr *) &sin, sizeof(sin)))
>>> 			ipv4 = 0;
>>> 	}
>>>
>>> @@ -255,7 +269,7 @@ family_check:
>>> 		if (!haddr)
>>> 			sin6.sin6_addr = in6addr_any;
>>>
>>> -		if (nfssvc_setfds(protobits, (struct sockaddr *) &sin6,
>>> sizeof(sin6)))
>>> +		if (nfssvc_setfds(proto6, (struct sockaddr *) &sin6,  
>>> sizeof(sin6)))
>>> 			ipv6 = 0;
>>> 	}
>>> #endif /* IPV6_SUPPORTED */
>>> -- 
>>> 1.6.0.6
>>>
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>
>
> -- 
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



