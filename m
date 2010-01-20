Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:61269 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab0ATPh1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jan 2010 10:37:27 -0500
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, trond.myklebust@fys.uio.no
Message-Id: <8E556CE2-569B-4E6D-BD02-7EF5CA84900D@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Jeff Layton <jlayton@redhat.com>
In-Reply-To: <20100120082905.1825f806@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH] mount.nfs: prefer IPv4 addresses over IPv6 (try #2)
Date: Wed, 20 Jan 2010 10:36:36 -0500
References: <1263907662-19107-1-git-send-email-jlayton@redhat.com> <1667647A-2BB1-478D-8881-CE8EA2191F97@oracle.com> <20100120082905.1825f806@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 20, 2010, at 8:29 AM, Jeff Layton wrote:

> On Tue, 19 Jan 2010 10:43:34 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
>
>>
>> On Jan 19, 2010, at 8:27 AM, Jeff Layton wrote:
>>
>>> We're poised to enable IPv6 in nfs-utils in distros. There is a
>>> potential problem however. mount.nfs will prefer IPv6 addrs.
>>>
>>> If someone has a working IPv4 server today that has an IPv6 address,
>>> then clients may start trying to mount over that address. If the
>>> server
>>> doesn't support NFS serving over IPv6 (and virtually no linux  
>>> servers
>>> currently do), then the mount will start failing.
>>>
>>> Avoid this problem by making the mount code prefer IPv4 addresses
>>> when they are available and an address family isn't specified.
>>>
>>> This is the second attempt at this patch. This moves the changes
>>> into nfs_validate_options. Chuck also mentioned parameterizing this
>>> behavior too. This patch doesn't include that, as I wasn't exactly
>>> clear on what he had in mind.
>>>
>
> After playing around with this some more, I'm coming to the conclusion
> that my first patch for this (the one that modified nfs_lookup) is
> really the best one.
>
> As Chuck pointed out, we need to have the address resolution behave
> consistently, so I'd need to have other places that currently call
> nfs_lookup do something similar.
>
> There are 4 callers of nfs_lookup currently:
>
> nfs_gethostbyname
> nfs_umount_do_umnt
> nfs_fix_mounthost_option
> nfs_validate_options
>
> ...all of these with the exception of nfs_gethostbyname will need to  
> do
> this "sorting". nfs_gethostbyname passes in AF_INET for the family, so
> it's guaranteed to return a IPv4 address or nothing anyway.
>
> I've tried a more-or-less exhaustive combination of proto=/mountproto=
> options (and lack thereof) and I think with the original patch I  
> posted
> it works as expected.
>
> On IRC, Chuck mentioned replacing nfs_lookup with direct calls to
> getaddrinfo, but that's a larger change and I don't really think it's
> necessary.
>
> Chuck also suggested that we should have mount.nfs never attempt to  
> use
> an IPv6 address unless someone explicitly adds proto=tcp6|udp6. I'm  
> not
> a fan of that solution. I think if a hostname resolves to only an IPv6
> address it ought to "just work" and mount via that address without
> needing extra options.
>
> For discussion, the original patch follows:

For the record, we looked at Solaris behavior yesterday.  With bi- 
family servers, its mount command tries IPv6 first, but appears smart  
enough to fall back to IPv4.  One thing we haven't tried is to see how  
difficult it would be to fix the real problem by adding proper  
protocol family negotiation to our own mount command.  This patch is  
predicated on the idea that would be hard to implement, which hasn't  
been demonstrated.

I'm worried about putting this preference behavior in released code,  
and then changing it yet again later.  I don't know how much time we  
have to fix this, but if we have a few days, I could try implementing  
real protocol family negotiation.

If you go forward with this solution, it should be made clear in the  
documenting comments (and in the patch description) that this is a  
temporary workaround.  If we intend to further correct this behavior  
down the road, we should avoid building on the new behavior, even by  
accident.

> -----------------[snip]-------------------
>
> mount.nfs: prefer IPv4 addresses over IPv6
>
> We're poised to enable IPv6 in nfs-utils in distros. There is a  
> potential
> problem however. mount.nfs will prefer IPv6 addrs.
>
> If someone has a working IPv4 server today that has an IPv6 address,
> then clients may start trying to mount over that address. If the  
> server
> doesn't support NFS serving over IPv6 (and virtually no linux servers
> currently do), then the mount will start failing.
>
> Avoid this problem by making the mount.nfs code prefer IPv4 addresses
> when they are available.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> utils/mount/network.c |   27 ++++++++++++++++++++++-----
> 1 files changed, 22 insertions(+), 5 deletions(-)
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 92bba2d..6723f8f 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -203,7 +203,7 @@ static const unsigned int *nfs_default_proto()
> int nfs_lookup(const char *hostname, const sa_family_t family,
> 		struct sockaddr *sap, socklen_t *salen)
> {
> -	struct addrinfo *gai_results;
> +	struct addrinfo *gai_results, *gai_pref;
> 	struct addrinfo gai_hint = {
> #ifdef HAVE_DECL_AI_ADDRCONFIG
> 		.ai_flags	= AI_ADDRCONFIG,
> @@ -229,12 +229,29 @@ int nfs_lookup(const char *hostname, const  
> sa_family_t family,
> 		return ret;
> 	}
>
> -	switch (gai_results->ai_addr->sa_family) {
> +	/*
> +	 * It will probably be quite a while before we have enough IPv6
> +	 * capable servers to be able to prefer using IPv6. For now, we
> +	 * only use IPv6 when there is no IPv4 address available in the
> +	 * results.
> +	 */
> +	gai_pref = gai_results;
> +	while (gai_pref) {
> +		if (gai_pref->ai_addr->sa_family == AF_INET)
> +			break;
> +		gai_pref = gai_pref->ai_next;
> +	}
> +
> +	/* no IPv4 addr found, just use first on the list */
> +	if (gai_pref == NULL)
> +		gai_pref = gai_results;
> +
> +	switch (gai_pref->ai_addr->sa_family) {
> 	case AF_INET:
> 	case AF_INET6:
> -		if (len >= gai_results->ai_addrlen) {
> -			*salen = gai_results->ai_addrlen;
> -			memcpy(sap, gai_results->ai_addr, *salen);
> +		if (len >= gai_pref->ai_addrlen) {
> +			*salen = gai_pref->ai_addrlen;
> +			memcpy(sap, gai_pref->ai_addr, *salen);
> 			ret = 1;
> 		}
> 		break;
> -- 
> 1.6.5.2
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



