Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38661 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695Ab1ACW0H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 17:26:07 -0500
Date: Mon, 3 Jan 2011 17:26:05 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Cc: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] svcrpc: modifying positive sunrpc cache entries is racy
Message-ID: <20110103222605.GA24811@fieldses.org>
References: <20101229204752.GC12218@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101229204752.GC12218@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 29, 2010 at 03:47:52PM -0500, bfields wrote:
> From: J. Bruce Fields <bfields@redhat.com>
> 
> Once a sunrpc cache entry is non-NEGATIVE, we should be replacing it
> (and allowing any concurrent users to destroy it on last put) instead of
> trying to update it in place.

Or the following seems simpler.

(And I was thinking it was necessary to ensure that the right thing
happened to the cached xprt->xpt_auth_cache entry--though on a second
look I see that sunrpc_cache_update also expires the replaced entry
immediately.  Still, this seems simpler if it also works.)

--b.

commit 20771de3185bf0031aa767d3b19f3e744a465a0c
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Dec 24 14:03:38 2010 -0500

    svcrpc: modifying valid sunrpc cache entries is racy
    
    Once a sunrpc cache entry is non-NEGATIVE, we shouldn't attempt to
    modify it in place.  Otherwise someone referencing the ip_map we're
    modifying here could try to use the m_client just as we're putting the
    last reference.
    
    Instead, just set the expiry time so it expires immediately.
    
    The bug should only be seen by users of the legacy nfsd interfaces.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index a04ac91..5edc147 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -401,8 +401,7 @@ struct auth_domain *auth_unix_lookup(struct net *net, struct in6_addr *addr)
 		return NULL;
 
 	if ((ipm->m_client->addr_changes - ipm->m_add_change) >0) {
-		if (test_and_set_bit(CACHE_NEGATIVE, &ipm->h.flags) == 0)
-			auth_domain_put(&ipm->m_client->h);
+		ipm->h.expiry_time = 0;
 		rv = NULL;
 	} else {
 		rv = &ipm->m_client->h;
