From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] Nfs4 over Ipv6 patch to fix ipv6 subnetting in /etc/exports
Date: Wed, 2 Dec 2009 18:32:16 -0500
Message-ID: <5A28692A-9683-4B49-A016-6639BD80E1BC@oracle.com>
References: <4B16EF49.8040106@silka.with-linux.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Kelly Anderson <kelly-lACMDn57031vQQPgy9v2K1aTQe2KTcn/@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:58946 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755397AbZLBXdd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2009 18:33:33 -0500
In-Reply-To: <4B16EF49.8040106-lACMDn57031vQQPgy9v2K1aTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[Cc: correct mailing list]

On Dec 2, 2009, at 5:50 PM, Kelly Anderson wrote:

> Hopefully this mail gets through to someone who can apply this patch  
> to NfsUtils git.
>
> I have been trying on and off for a year or so to get Nfs4 mounts to  
> work over Ipv6.  Finally with the latest git it seemed to work.   
> That is, it worked when you wildcard all internet addresses.
>
> /home/nfs4   
> *(rw,fsid=0,sync,root_squash,no_all_squash,no_subtree_check)
>
> Unfortunately subnetting wasn't working, so I dug into the code to  
> figure out why.  It turned out that it was something simple (once I  
> managed to get my head into the code).  I've attached a patch  
> against the current git that fixes it.  With the patch applied, ipv6  
> subnetting such as the following works.
>
> /home/nfs4  2001:470:b:3e::/ 
> 64(rw,fsid=0,sync,root_squash,no_all_squash,no_subtree_check)
> /home/nfs4  2001:470:b:3e::/ffff:ffff:ffff:ffff:: 
> (rw,fsid=0,sync,root_squash,no_all_squash,no_subtree_check)

IPv6 support in mountd is entirely experimental (ie not guaranteed to  
work), and exists only my personal git repo, not in the official nfs- 
utils git repo.  However, it looks like you are working against my code.

Also, we prefer patches submitted inline, not as attachments, as that  
makes it easy to hit "reply" and comment on the content of the patch.   
A patch description and a Signed-off-by: line is required.  Take a  
look in the archives of this mailing list for examples.

Basically your patch misapplies the address mask in check_subnet_v6,  
so I don't think it's the right fix.  Instead of "sin6 & mask" you  
have "sin6 & sin6" which basically means the mask is ignored, and the  
check will always succeed.

Maybe the mask generation code in init_netmask() is not correct?

> Regards,
>
> Kelly Anderson
> <NfsUtils- 
> check_subnet_v6 
> .patch 
> > 
> ------------------------------------------------------------------------------
> Join us December 9, 2009 for the Red Hat Virtual Experience,
> a free event focused on virtualization and cloud computing.
> Attend in-depth sessions from your desk. Your couch. Anywhere.
> http://p.sf.net/sfu/redhat-sfdev2dev_______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>    http://vger.kernel.org/vger-lists.html#linux-nfs

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




