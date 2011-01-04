Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35251 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100Ab1ADVql (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 16:46:41 -0500
Date: Tue, 4 Jan 2011 16:46:39 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrpc: modifying positive sunrpc cache entries is racy
Message-ID: <20110104214639.GG7908@fieldses.org>
References: <20101229204752.GC12218@fieldses.org>
 <20110103222605.GA24811@fieldses.org>
 <20110104030805.GA3194@fieldses.org>
 <20110104155107.0ff2c199@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110104155107.0ff2c199@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jan 04, 2011 at 03:51:07PM +1100, NeilBrown wrote:
> And this all made me realise that there is more code that can be placed under
> CONFIG_NFSD_DEPRECTATED.
> 
> 
> SUNRPC: Remove more code when NFSD_DEPRECATED is not configured
> 
> Signed-off-by: NeilBrown <neilb@suse.de>

I did need one change to get a succesful !CONFIG_NFSD_DEPRECATED
compile.

--b.

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 46e1cbc..30916b0 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -422,6 +422,7 @@ struct auth_domain *auth_unix_lookup(struct net *net, struct in6_addr *addr)
 	return rv;
 }
 EXPORT_SYMBOL_GPL(auth_unix_lookup);
+#endif /* CONFIG_NFSD_DEPRECATED */
 
 void svcauth_unix_purge(void)
 {
@@ -435,7 +436,6 @@ void svcauth_unix_purge(void)
 	}
 }
 EXPORT_SYMBOL_GPL(svcauth_unix_purge);
-#endif /* CONFIG_NFSD_DEPRECATED */
 
 static inline struct ip_map *
 ip_map_cached_get(struct svc_xprt *xprt)
