From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 08/15] SUNRPC: Ensure rpcauth_prune_expired() respects
 the nr_to_scan parameter
Date: Fri, 14 May 2010 14:37:22 -0400
Message-ID: <1273862242.4732.39.camel@localhost.localdomain>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>
	 <4BED7BAD.20509@oracle.com> <1273857200.4732.2.camel@localhost.localdomain>
	 <4BED894A.6090507@oracle.com>
	 <1273860432.4732.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48484 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753713Ab0ENShY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 May 2010 14:37:24 -0400
In-Reply-To: <1273860432.4732.30.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-05-14 at 14:07 -0400, Trond Myklebust wrote: 
> On Fri, 2010-05-14 at 13:32 -0400, Chuck Lever wrote: 
> > When mm calls with nr_to_scan set to zero, it doesn't expect a -1 
> > return, it just uses the returned value.  mm checks for a -1 return only 
> > when a non-zero scan count argument is passed.
> > 
> > So the check you added here (and in the access cache shrinker) to return 
> > -1 when the gfp_mask doesn't contain GFP_KERNEL could cause some 
> > trouble.  It would be safer if we return -1 _after_ checking for 
> > nr_to_scan == 0.
> 
> Oh... You're referring to the change that was added in Patch 6/15
> SUNRPC: Dont run rpcauth_cache_shrinker() when gfp_mask is GFP_NOFS? I
> got confused...
> 
> I can perhaps rather add a check for nr_to_scan != 0 in that patch...

OK... How about the following? (and ditto for the access cache shrinker)

-------------------------------------------------------------------------------------------- 
>From 8048209c54b95046a23cd994b3d0520757ea5845 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 13 May 2010 12:51:03 -0400
Subject: [PATCH 06/15] SUNRPC: Dont run rpcauth_cache_shrinker() when gfp_mask is GFP_NOFS

Under some circumstances, put_rpccred() can end up allocating memory, so
check the gfp_mask to prevent deadlocks.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 95afe79..0667a36 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -270,6 +270,8 @@ rpcauth_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
 	LIST_HEAD(free);
 	int res;
 
+	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
+		return (nr_to_scan == 0) ? 0 : -1;
 	if (list_empty(&cred_unused))
 		return 0;
 	spin_lock(&rpc_credcache_lock);
-- 
1.6.6.1


