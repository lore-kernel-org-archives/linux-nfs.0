From: NeilBrown <neilb@suse.de>
Subject: [PATCH 009 of 14] knfsd: Use new cache code for rsc cache
Date: Thu, 9 Mar 2006 17:52:08 +1100
Message-ID: <1060309065208.24617@suse.de>
References: <20060309174755.24381.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHF1N-0000eO-TN
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:53:13 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHF1M-0000Ix-W8
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:53:14 -0800
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
 ./net/sunrpc/auth_gss/svcauth_gss.c |   74 +++++++++++++++++++++++++++++++-----
 1 file changed, 64 insertions(+), 10 deletions(-)

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2006-03-09 17:15:43.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2006-03-09 17:15:58.000000000 +1100
@@ -345,7 +345,8 @@ struct rsc {
 
 static struct cache_head *rsc_table[RSC_HASHMAX];
 static struct cache_detail rsc_cache;
-static struct rsc *rsc_lookup(struct rsc *item, int set);
+static struct rsc *rsc_update(struct rsc *new, struct rsc *old);
+static struct rsc *rsc_lookup(struct rsc *item);
 
 static void rsc_free(struct rsc *rsci)
 {
@@ -372,15 +373,21 @@ rsc_hash(struct rsc *rsci)
 	return hash_mem(rsci->handle.data, rsci->handle.len, RSC_HASHBITS);
 }
 
-static inline int
-rsc_match(struct rsc *new, struct rsc *tmp)
+static int
+rsc_match(struct cache_head *a, struct cache_head *b)
 {
+	struct rsc *new = container_of(a, struct rsc, h);
+	struct rsc *tmp = container_of(b, struct rsc, h);
+
 	return netobj_equal(&new->handle, &tmp->handle);
 }
 
-static inline void
-rsc_init(struct rsc *new, struct rsc *tmp)
+static void
+rsc_init(struct cache_head *cnew, struct cache_head *ctmp)
 {
+	struct rsc *new = container_of(cnew, struct rsc, h);
+	struct rsc *tmp = container_of(ctmp, struct rsc, h);
+
 	new->handle.len = tmp->handle.len;
 	tmp->handle.len = 0;
 	new->handle.data = tmp->handle.data;
@@ -389,9 +396,12 @@ rsc_init(struct rsc *new, struct rsc *tm
 	new->cred.cr_group_info = NULL;
 }
 
-static inline void
-rsc_update(struct rsc *new, struct rsc *tmp)
+static void
+update_rsc(struct cache_head *cnew, struct cache_head *ctmp)
 {
+	struct rsc *new = container_of(cnew, struct rsc, h);
+	struct rsc *tmp = container_of(ctmp, struct rsc, h);
+
 	new->mechctx = tmp->mechctx;
 	tmp->mechctx = NULL;
 	memset(&new->seqdata, 0, sizeof(new->seqdata));
@@ -400,6 +410,16 @@ rsc_update(struct rsc *new, struct rsc *
 	tmp->cred.cr_group_info = NULL;
 }
 
+static struct cache_head *
+rsc_alloc(void)
+{
+	struct rsc *rsci = kmalloc(sizeof(*rsci), GFP_KERNEL);
+	if (rsci)
+		return &rsci->h;
+	else
+		return NULL;
+}
+
 static int rsc_parse(struct cache_detail *cd,
 		     char *mesg, int mlen)
 {
@@ -425,6 +445,10 @@ static int rsc_parse(struct cache_detail
 	if (expiry == 0)
 		goto out;
 
+	rscp = rsc_lookup(&rsci);
+	if (!rscp)
+		goto out;
+
 	/* uid, or NEGATIVE */
 	rv = get_int(&mesg, &rsci.cred.cr_uid);
 	if (rv == -EINVAL)
@@ -480,12 +504,14 @@ static int rsc_parse(struct cache_detail
 		gss_mech_put(gm);
 	}
 	rsci.h.expiry_time = expiry;
-	rscp = rsc_lookup(&rsci, 1);
+	rscp = rsc_update(&rsci, rscp);
 	status = 0;
 out:
 	rsc_free(&rsci);
 	if (rscp)
 		rsc_put(&rscp->h, &rsc_cache);
+	else
+		status = -ENOMEM;
 	return status;
 }
 
@@ -496,9 +522,37 @@ static struct cache_detail rsc_cache = {
 	.name		= "auth.rpcsec.context",
 	.cache_put	= rsc_put,
 	.cache_parse	= rsc_parse,
+	.match		= rsc_match,
+	.init		= rsc_init,
+	.update		= update_rsc,
+	.alloc		= rsc_alloc,
 };
 
-static DefineSimpleCacheLookup(rsc, rsc);
+static struct rsc *rsc_lookup(struct rsc *item)
+{
+	struct cache_head *ch;
+	int hash = rsc_hash(item);
+
+	ch = sunrpc_cache_lookup(&rsc_cache, &item->h, hash);
+	if (ch)
+		return container_of(ch, struct rsc, h);
+	else
+		return NULL;
+}
+
+static struct rsc *rsc_update(struct rsc *new, struct rsc *old)
+{
+	struct cache_head *ch;
+	int hash = rsc_hash(new);
+
+	ch = sunrpc_cache_update(&rsc_cache, &new->h,
+				 &old->h, hash);
+	if (ch)
+		return container_of(ch, struct rsc, h);
+	else
+		return NULL;
+}
+
 
 static struct rsc *
 gss_svc_searchbyctx(struct xdr_netobj *handle)
@@ -509,7 +563,7 @@ gss_svc_searchbyctx(struct xdr_netobj *h
 	memset(&rsci, 0, sizeof(rsci));
 	if (dup_to_netobj(&rsci.handle, handle->data, handle->len))
 		return NULL;
-	found = rsc_lookup(&rsci, 0);
+	found = rsc_lookup(&rsci);
 	rsc_free(&rsci);
 	if (!found)
 		return NULL;


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
