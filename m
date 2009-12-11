From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] Nfs4 over Ipv6 patch to fix ipv6 subnetting in
	/etc/exports
Date: Fri, 11 Dec 2009 13:24:24 -0500
Message-ID: <E8A3627D-67A4-4188-BD55-ECD71AE5787F@oracle.com>
References: <4B16EF49.8040106@silka.with-linux.com>
	<4B228D4B.7000007@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset="us-ascii"
Cc: Kelly Anderson <kelly-lACMDn57031vQQPgy9v2K1aTQe2KTcn/@public.gmane.org>,
	nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:58443 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753432AbZLKSZL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2009 13:25:11 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NJAB2-0005ri-IU
	for linux-nfs@vger.kernel.org; Sat, 12 Dec 2009 05:25:16 +1100
In-Reply-To: <4B228D4B.7000007-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve-

This patch is against my private repo, not against upstream nfs-utils.

On Dec 11, 2009, at 1:19 PM, Steve Dickson wrote:

> Hello,
>
> On 12/02/2009 05:50 PM, Kelly Anderson wrote:
>> --- ./support/export/client.c.orig	2009-11-30 08:06:18.000000000  
>> -0700
>> +++ ./support/export/client.c	2009-12-02 15:16:55.361725808 -0700
>> @@ -505,16 +505,16 @@ check_subnet_v6(const struct sockaddr_in
>> 			continue;
>>
>> 		if (mask_match(address->sin6_addr.s6_addr32[0],
>> -				sin6->sin6_addr.s6_addr[0],
>> +				sin6->sin6_addr.s6_addr32[0],
>> 		      		mask->sin6_addr.s6_addr32[0]) &&
>> 		    mask_match(address->sin6_addr.s6_addr32[1],
>> -				sin6->sin6_addr.s6_addr[1],
>> +				sin6->sin6_addr.s6_addr32[1],
>> 		      		mask->sin6_addr.s6_addr32[1]) &&
>> 		    mask_match(address->sin6_addr.s6_addr32[2],
>> -				sin6->sin6_addr.s6_addr[2],
>> +				sin6->sin6_addr.s6_addr32[2],
>> 		      		mask->sin6_addr.s6_addr32[2]) &&
>> 		    mask_match(address->sin6_addr.s6_addr32[3],
>> -				sin6->sin6_addr.s6_addr[3],
>> +				sin6->sin6_addr.s6_addr32[3],
>> 		      		mask->sin6_addr.s6_addr32[3]))
>> 			return 1;
>> 	}
> I'm a bit confused here... I don't see a check_subnet_v6() routine
> in support/export/client.c and from the git logs says there never
> was a routine called check_subnet_v6()... what am I missing?
>
> In the future, please add the Signed-off-by: label to the bottom
> of the patch description... thanks!
>
>
> steved.
>
> ------------------------------------------------------------------------------
> Return on Information:
> Google Enterprise Search pays you back
> Get the facts.
> http://p.sf.net/sfu/google-dev2dev
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>    http://vger.kernel.org/vger-lists.html#linux-nfs
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





------------------------------------------------------------------------------
Return on Information:
Google Enterprise Search pays you back
Get the facts.
http://p.sf.net/sfu/google-dev2dev
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

