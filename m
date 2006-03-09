From: NeilBrown <neilb@suse.de>
Subject: [PATCH 008 of 14] knfsd: Use new sunrpc cache for rsi cache
Date: Thu, 9 Mar 2006 17:52:03 +1100
Message-ID: <1060309065203.24605@suse.de>
References: <20060309174755.24381.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHF1J-0000dC-NV
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:53:09 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHF1H-00076U-TV
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:53:09 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>




Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/auth_gss/svcauth_gss.c |   66 ++++++++++++++++++++++++++++++++----
 1 file changed, 59 insertions(+), 7 deletions(-)

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2006-03-09 17:15:13.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2006-03-09 17:15:43.000000000 +1100
@@ -78,7 +78,8 @@ struct rsi {
 
 static struct cache_head *rsi_table[RSI_HASHMAX];
 static struct cache_detail rsi_cache;
-static struct rsi *rsi_lookup(struct rsi *item, int set);
+static struct rsi *rsi_update(struct rsi *new, struct rsi *old);
+static struct rsi *rsi_lookup(struct rsi *item);
 
 static void rsi_free(struct rsi *rsii)
 {
@@ -103,8 +104,10 @@ static inline int rsi_hash(struct rsi *i
 	     ^ hash_mem(item->in_token.data, item->in_token.len, RSI_HASHBITS);
 }
 
-static inline int rsi_match(struct rsi *item, struct rsi *tmp)
+static int rsi_match(struct cache_head *a, struct cache_head *b)
 {
+	struct rsi *item = container_of(a, struct rsi, h);
+	struct rsi *tmp = container_of(b, struct rsi, h);
 	return netobj_equal(&item->in_handle, &tmp->in_handle)
 		&& netobj_equal(&item->in_token, &tmp->in_token);
 }
@@ -125,8 +128,11 @@ static inline int dup_netobj(struct xdr_
 	return dup_to_netobj(dst, src->data, src->len);
 }
 
-static inline void rsi_init(struct rsi *new, struct rsi *item)
+static void rsi_init(struct cache_head *cnew, struct cache_head *citem)
 {
+	struct rsi *new = container_of(cnew, struct rsi, h);
+	struct rsi *item = container_of(citem, struct rsi, h);
+
 	new->out_handle.data = NULL;
 	new->out_handle.len = 0;
 	new->out_token.data = NULL;
@@ -141,8 +147,11 @@ static inline void rsi_init(struct rsi *
 	item->in_token.data = NULL;
 }
 
-static inline void rsi_update(struct rsi *new, struct rsi *item)
+static void update_rsi(struct cache_head *cnew, struct cache_head *citem)
 {
+	struct rsi *new = container_of(cnew, struct rsi, h);
+	struct rsi *item = container_of(citem, struct rsi, h);
+
 	BUG_ON(new->out_handle.data || new->out_token.data);
 	new->out_handle.len = item->out_handle.len;
 	item->out_handle.len = 0;
@@ -157,6 +166,15 @@ static inline void rsi_update(struct rsi
 	new->minor_status = item->minor_status;
 }
 
+static struct cache_head *rsi_alloc(void)
+{
+	struct rsi *rsii = kmalloc(sizeof(*rsii), GFP_KERNEL);
+	if (rsii)
+		return &rsii->h;
+	else
+		return NULL;
+}
+
 static void rsi_request(struct cache_detail *cd,
                        struct cache_head *h,
                        char **bpp, int *blen)
@@ -198,6 +216,10 @@ static int rsi_parse(struct cache_detail
 	if (dup_to_netobj(&rsii.in_token, buf, len))
 		goto out;
 
+	rsip = rsi_lookup(&rsii);
+	if (!rsip)
+		goto out;
+
 	rsii.h.flags = 0;
 	/* expiry */
 	expiry = get_expiry(&mesg);
@@ -240,12 +262,14 @@ static int rsi_parse(struct cache_detail
 			goto out;
 	}
 	rsii.h.expiry_time = expiry;
-	rsip = rsi_lookup(&rsii, 1);
+	rsip = rsi_update(&rsii, rsip);
 	status = 0;
 out:
 	rsi_free(&rsii);
 	if (rsip)
 		rsi_put(&rsip->h, &rsi_cache);
+	else
+		status = -ENOMEM;
 	return status;
 }
 
@@ -257,9 +281,37 @@ static struct cache_detail rsi_cache = {
 	.cache_put      = rsi_put,
 	.cache_request  = rsi_request,
 	.cache_parse    = rsi_parse,
+	.match		= rsi_match,
+	.init		= rsi_init,
+	.update		= update_rsi,
+	.alloc		= rsi_alloc,
 };
 
-static DefineSimpleCacheLookup(rsi, rsi)
+static struct rsi *rsi_lookup(struct rsi *item)
+{
+	struct cache_head *ch;
+	int hash = rsi_hash(item);
+
+	ch = sunrpc_cache_lookup(&rsi_cache, &item->h, hash);
+	if (ch)
+		return container_of(ch, struct rsi, h);
+	else
+		return NULL;
+}
+
+static struct rsi *rsi_update(struct rsi *new, struct rsi *old)
+{
+	struct cache_head *ch;
+	int hash = rsi_hash(new);
+
+	ch = sunrpc_cache_update(&rsi_cache, &new->h,
+				 &old->h, hash);
+	if (ch)
+		return container_of(ch, struct rsi, h);
+	else
+		return NULL;
+}
+
 
 /*
  * The rpcsec_context cache is used to store a context that is
@@ -895,7 +947,7 @@ svcauth_gss_accept(struct svc_rqst *rqst
 			goto drop;
 		}
 
-		rsip = rsi_lookup(&rsikey, 0);
+		rsip = rsi_lookup(&rsikey);
 		rsi_free(&rsikey);
 		if (!rsip) {
 			goto drop;


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
