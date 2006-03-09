From: NeilBrown <neilb@suse.de>
Subject: [PATCH 007 of 14] knfsd: Use new cache_lookup for svc_expkey cache.
Date: Thu, 9 Mar 2006 17:51:58 +1100
Message-ID: <1060309065158.24593@suse.de>
References: <20060309174755.24381.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHF1F-0000b2-Oe
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:53:05 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHF1C-00070c-Km
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:53:05 -0800
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
 ./fs/nfsd/export.c |  136 ++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 99 insertions(+), 37 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2006-03-09 17:15:14.000000000 +1100
+++ ./fs/nfsd/export.c	2006-03-09 17:15:15.000000000 +1100
@@ -57,17 +57,6 @@ static int		exp_verify_string(char *cp, 
 #define	EXPKEY_HASHMASK		(EXPKEY_HASHMAX -1)
 static struct cache_head *expkey_table[EXPKEY_HASHMAX];
 
-static inline int svc_expkey_hash(struct svc_expkey *item)
-{
-	int hash = item->ek_fsidtype;
-	char * cp = (char*)item->ek_fsid;
-	int len = key_len(item->ek_fsidtype);
-
-	hash ^= hash_mem(cp, len, EXPKEY_HASHBITS);
-	hash ^= hash_ptr(item->ek_client, EXPKEY_HASHBITS);
-	return hash & EXPKEY_HASHMASK;
-}
-
 void expkey_put(struct cache_head *item, struct cache_detail *cd)
 {
 	if (cache_put(item, cd)) {
@@ -97,7 +86,8 @@ static void expkey_request(struct cache_
 	(*bpp)[-1] = '\n';
 }
 
-static struct svc_expkey *svc_expkey_lookup(struct svc_expkey *, int);
+static struct svc_expkey *svc_expkey_update(struct svc_expkey *new, struct svc_expkey *old);
+static struct svc_expkey *svc_expkey_lookup(struct svc_expkey *);
 static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 {
 	/* client fsidtype fsid [path] */
@@ -108,6 +98,7 @@ static int expkey_parse(struct cache_det
 	int fsidtype;
 	char *ep;
 	struct svc_expkey key;
+	struct svc_expkey *ek;
 
 	if (mesg[mlen-1] != '\n')
 		return -EINVAL;
@@ -152,20 +143,25 @@ static int expkey_parse(struct cache_det
 	key.ek_fsidtype = fsidtype;
 	memcpy(key.ek_fsid, buf, len);
 
+	ek = svc_expkey_lookup(&key);
+	err = -ENOMEM;
+	if (!ek)
+		goto out;
+
 	/* now we want a pathname, or empty meaning NEGATIVE  */
+	err = -EINVAL;
 	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) < 0)
 		goto out;
 	dprintk("Path seems to be <%s>\n", buf);
 	err = 0;
 	if (len == 0) {
-		struct svc_expkey *ek;
 		set_bit(CACHE_NEGATIVE, &key.h.flags);
-		ek = svc_expkey_lookup(&key, 1);
+		ek = svc_expkey_update(&key, ek);
 		if (ek)
 			expkey_put(&ek->h, &svc_expkey_cache);
+		else err = -ENOMEM;
 	} else {
 		struct nameidata nd;
-		struct svc_expkey *ek;
 		err = path_lookup(buf, 0, &nd);
 		if (err)
 			goto out;
@@ -174,10 +170,11 @@ static int expkey_parse(struct cache_det
 		key.ek_mnt = nd.mnt;
 		key.ek_dentry = nd.dentry;
 		
-		ek = svc_expkey_lookup(&key, 1);
+		ek = svc_expkey_update(&key, ek);
 		if (ek)
 			expkey_put(&ek->h, &svc_expkey_cache);
-		err = 0;
+		else
+			err = -ENOMEM;
 		path_release(&nd);
 	}
 	cache_flush();
@@ -213,29 +210,25 @@ static int expkey_show(struct seq_file *
 	seq_printf(m, "\n");
 	return 0;
 }
-	
-struct cache_detail svc_expkey_cache = {
-	.owner		= THIS_MODULE,
-	.hash_size	= EXPKEY_HASHMAX,
-	.hash_table	= expkey_table,
-	.name		= "nfsd.fh",
-	.cache_put	= expkey_put,
-	.cache_request	= expkey_request,
-	.cache_parse	= expkey_parse,
-	.cache_show	= expkey_show,
-};
 
-static inline int svc_expkey_match (struct svc_expkey *a, struct svc_expkey *b)
+static inline int expkey_match (struct cache_head *a, struct cache_head *b)
 {
-	if (a->ek_fsidtype != b->ek_fsidtype ||
-	    a->ek_client != b->ek_client ||
-	    memcmp(a->ek_fsid, b->ek_fsid, key_len(a->ek_fsidtype)) != 0)
+	struct svc_expkey *orig = container_of(a, struct svc_expkey, h);
+	struct svc_expkey *new = container_of(b, struct svc_expkey, h);
+
+	if (orig->ek_fsidtype != new->ek_fsidtype ||
+	    orig->ek_client != new->ek_client ||
+	    memcmp(orig->ek_fsid, new->ek_fsid, key_len(orig->ek_fsidtype)) != 0)
 		return 0;
 	return 1;
 }
 
-static inline void svc_expkey_init(struct svc_expkey *new, struct svc_expkey *item)
+static inline void expkey_init(struct cache_head *cnew,
+				   struct cache_head *citem)
 {
+	struct svc_expkey *new = container_of(cnew, struct svc_expkey, h);
+	struct svc_expkey *item = container_of(citem, struct svc_expkey, h);
+
 	kref_get(&item->ek_client->ref);
 	new->ek_client = item->ek_client;
 	new->ek_fsidtype = item->ek_fsidtype;
@@ -244,13 +237,80 @@ static inline void svc_expkey_init(struc
 	new->ek_fsid[2] = item->ek_fsid[2];
 }
 
-static inline void svc_expkey_update(struct svc_expkey *new, struct svc_expkey *item)
+static inline void expkey_update(struct cache_head *cnew,
+				   struct cache_head *citem)
 {
+	struct svc_expkey *new = container_of(cnew, struct svc_expkey, h);
+	struct svc_expkey *item = container_of(citem, struct svc_expkey, h);
+
 	new->ek_mnt = mntget(item->ek_mnt);
 	new->ek_dentry = dget(item->ek_dentry);
 }
 
-static DefineSimpleCacheLookup(svc_expkey, svc_expkey)
+static struct cache_head *expkey_alloc(void)
+{
+	struct svc_expkey *i = kmalloc(sizeof(*i), GFP_KERNEL);
+	if (i)
+		return &i->h;
+	else
+		return NULL;
+}
+
+struct cache_detail svc_expkey_cache = {
+	.owner		= THIS_MODULE,
+	.hash_size	= EXPKEY_HASHMAX,
+	.hash_table	= expkey_table,
+	.name		= "nfsd.fh",
+	.cache_put	= expkey_put,
+	.cache_request	= expkey_request,
+	.cache_parse	= expkey_parse,
+	.cache_show	= expkey_show,
+	.match		= expkey_match,
+	.init		= expkey_init,
+	.update       	= expkey_update,
+	.alloc		= expkey_alloc,
+};
+
+static struct svc_expkey *
+svc_expkey_lookup(struct svc_expkey *item)
+{
+	struct cache_head *ch;
+	int hash = item->ek_fsidtype;
+	char * cp = (char*)item->ek_fsid;
+	int len = key_len(item->ek_fsidtype);
+
+	hash ^= hash_mem(cp, len, EXPKEY_HASHBITS);
+	hash ^= hash_ptr(item->ek_client, EXPKEY_HASHBITS);
+	hash &= EXPKEY_HASHMASK;
+
+	ch = sunrpc_cache_lookup(&svc_expkey_cache, &item->h,
+				 hash);
+	if (ch)
+		return container_of(ch, struct svc_expkey, h);
+	else
+		return NULL;
+}
+
+static struct svc_expkey *
+svc_expkey_update(struct svc_expkey *new, struct svc_expkey *old)
+{
+	struct cache_head *ch;
+	int hash = new->ek_fsidtype;
+	char * cp = (char*)new->ek_fsid;
+	int len = key_len(new->ek_fsidtype);
+
+	hash ^= hash_mem(cp, len, EXPKEY_HASHBITS);
+	hash ^= hash_ptr(new->ek_client, EXPKEY_HASHBITS);
+	hash &= EXPKEY_HASHMASK;
+
+	ch = sunrpc_cache_update(&svc_expkey_cache, &new->h,
+				 &old->h, hash);
+	if (ch)
+		return container_of(ch, struct svc_expkey, h);
+	else
+		return NULL;
+}
+
 
 #define	EXPORT_HASHBITS		8
 #define	EXPORT_HASHMAX		(1<< EXPORT_HASHBITS)
@@ -549,7 +609,7 @@ exp_find_key(svc_client *clp, int fsid_t
 	key.ek_fsidtype = fsid_type;
 	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
 
-	ek = svc_expkey_lookup(&key, 0);
+	ek = svc_expkey_lookup(&key);
 	if (ek != NULL)
 		if ((err = cache_check(&svc_expkey_cache, &ek->h, reqp)))
 			ek = ERR_PTR(err);
@@ -569,7 +629,9 @@ static int exp_set_key(svc_client *clp, 
 	key.h.expiry_time = NEVER;
 	key.h.flags = 0;
 
-	ek = svc_expkey_lookup(&key, 1);
+	ek = svc_expkey_lookup(&key);
+	if (ek)
+		ek = svc_expkey_update(&key,ek);
 	if (ek) {
 		expkey_put(&ek->h, &svc_expkey_cache);
 		return 0;


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
