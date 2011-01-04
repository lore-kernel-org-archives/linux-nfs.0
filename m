Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:40916 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099Ab1ADEvS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 23:51:18 -0500
Date: Tue, 4 Jan 2011 15:51:07 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrpc: modifying positive sunrpc cache entries is racy
Message-ID: <20110104155107.0ff2c199@notabene.brown>
In-Reply-To: <20110104030805.GA3194@fieldses.org>
References: <20101229204752.GC12218@fieldses.org>
	<20110103222605.GA24811@fieldses.org>
	<20110104030805.GA3194@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 3 Jan 2011 22:08:05 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Mon, Jan 03, 2011 at 05:26:05PM -0500, J. Bruce Fields wrote:
> > On Wed, Dec 29, 2010 at 03:47:52PM -0500, bfields wrote:
> > > From: J. Bruce Fields <bfields@redhat.com>
> > > 
> > > Once a sunrpc cache entry is non-NEGATIVE, we should be replacing it
> > > (and allowing any concurrent users to destroy it on last put) instead of
> > > trying to update it in place.
> > 
> > Or the following seems simpler.
> > 
> > (And I was thinking it was necessary to ensure that the right thing
> > happened to the cached xprt->xpt_auth_cache entry--though on a second
> > look I see that sunrpc_cache_update also expires the replaced entry
> > immediately.  Still, this seems simpler if it also works.)
> 
> Eh, on third thoughts: we probably do want a real negative entry created
> in the cache, so I think the original patch was correct!

I like your second thought better than your third.
I don't see any reason to push this item out of the cache extra quickly.
In fact I think it would still be correct to just remove those two lines and
not set expiry_time to 0.  auth_unix_lookup will never find that IP address,
and so it doesn't matter if it remains in the cache or not.
I guess there could result in the cache appearing to contain different data
depending on whether you look at it the 'old' way or the 'new' way, but I
don't that is a real problem, and setting expiry_time to 0 overcomes that.

What was the substance of your third thought?

BTW, you could use sunrpc_invalidate rather than just setting expiry_time to
zero, which would hurry it out of the cache a bit faster.


And this all made me realise that there is more code that can be placed under
CONFIG_NFSD_DEPRECTATED.


SUNRPC: Remove more code when NFSD_DEPRECATED is not configured

Signed-off-by: NeilBrown <neilb@suse.de>


diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 6950c98..c2aebe8 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -255,10 +255,13 @@ static inline time_t get_expiry(char **bpp)
 	return rv - boot.tv_sec;
 }
 
+#ifdef CONFIG_NFSD_DEPRECATED
 static inline void sunrpc_invalidate(struct cache_head *h,
 				     struct cache_detail *detail)
 {
 	h->expiry_time = seconds_since_boot() - 1;
 	detail->nextcheck = seconds_since_boot();
 }
+#endif /* CONFIG_NFSD_DEPRECATED */
+
 #endif /*  _LINUX_SUNRPC_CACHE_H_ */
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 560677d..92d47ad 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -30,7 +30,9 @@
 
 struct unix_domain {
 	struct auth_domain	h;
+#ifdef CONFIG_NFSD_DEPRECATED
 	int	addr_changes;
+#endif /* CONFIG_NFSD_DEPRECATED */
 	/* other stuff later */
 };
 
@@ -64,7 +66,9 @@ struct auth_domain *unix_domain_find(char *name)
 			return NULL;
 		}
 		new->h.flavour = &svcauth_unix;
+#ifdef CONFIG_NFSD_DEPRECATED
 		new->addr_changes = 0;
+#endif /* CONFIG_NFSD_DEPRECATED */
 		rv = auth_domain_lookup(name, &new->h);
 	}
 }
@@ -92,7 +96,9 @@ struct ip_map {
 	char			m_class[8]; /* e.g. "nfsd" */
 	struct in6_addr		m_addr;
 	struct unix_domain	*m_client;
+#ifdef CONFIG_NFSD_DEPRECATED
 	int			m_add_change;
+#endif /* CONFIG_NFSD_DEPRECATED */
 };
 
 static void ip_map_put(struct kref *kref)
@@ -146,7 +152,9 @@ static void update(struct cache_head *cnew, struct cache_head *citem)
 
 	kref_get(&item->m_client->h.ref);
 	new->m_client = item->m_client;
+#ifdef CONFIG_NFSD_DEPRECATED
 	new->m_add_change = item->m_add_change;
+#endif /* CONFIG_NFSD_DEPRECATED */
 }
 static struct cache_head *ip_map_alloc(void)
 {
@@ -331,6 +339,7 @@ static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
 	ip.h.flags = 0;
 	if (!udom)
 		set_bit(CACHE_NEGATIVE, &ip.h.flags);
+#ifdef CONFIG_NFSD_DEPRECATED
 	else {
 		ip.m_add_change = udom->addr_changes;
 		/* if this is from the legacy set_client system call,
@@ -339,6 +348,7 @@ static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
 		if (expiry == NEVER)
 			ip.m_add_change++;
 	}
+#endif /* CONFIG_NFSD_DEPRECATED */
 	ip.h.expiry_time = expiry;
 	ch = sunrpc_cache_update(cd, &ip.h, &ipm->h,
 				 hash_str(ipm->m_class, IP_HASHBITS) ^
@@ -358,6 +368,7 @@ static inline int ip_map_update(struct net *net, struct ip_map *ipm,
 	return __ip_map_update(sn->ip_map_cache, ipm, udom, expiry);
 }
 
+#ifdef CONFIG_NFSD_DEPRECATED
 int auth_unix_add_addr(struct net *net, struct in6_addr *addr, struct auth_domain *dom)
 {
 	struct unix_domain *udom;
@@ -426,6 +437,7 @@ void svcauth_unix_purge(void)
 	}
 }
 EXPORT_SYMBOL_GPL(svcauth_unix_purge);
+#endif /* CONFIG_NFSD_DEPRECATED */
 
 static inline struct ip_map *
 ip_map_cached_get(struct svc_xprt *xprt)
