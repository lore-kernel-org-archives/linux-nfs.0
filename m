From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 17 of 17 - upcall/update for export tables
Date: Fri, 11 Oct 2002 15:28:01 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsLB-0003cE-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLe-0003j7-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:30 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By tone With Smtp ;
	Fri, 11 Oct 2002 15:28:16 +1000
To: Linus Torvalds <torvalds@transmeta.com>
cc: linux-kernel@vger.kernel.org
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

Add _request and _parse methods for nfsd.fh and
nfsd.exports tables.

nfsd.fh maps a filehandle-fragment to a path for a client,
and nfsd.exports maps a path to export options for a client.


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c          |  216 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 216 insertions(+)

--- ./fs/nfsd/export.c	2002/10/11 02:00:11	1.7
+++ ./fs/nfsd/export.c	2002/10/11 04:27:49	1.8
@@ -77,11 +77,124 @@ void expkey_put(struct cache_head *item,
 	}
 }
 
+void expkey_request(struct cache_detail *cd,
+		    struct cache_head *h,
+		    char **bpp, int *blen)
+{
+	/* client fsidtype \xfsid */
+	struct svc_expkey *ek = container_of(h, struct svc_expkey, h);
+	char type[5];
+
+	add_word(bpp, blen, ek->ek_client->name);
+	snprintf(type, 5, "%d", ek->ek_fsidtype);
+	add_word(bpp, blen, type);
+	add_hex(bpp, blen, (char*)ek->ek_fsid, ek->ek_fsidtype==0?8:4);
+	(*bpp)[-1] = '\n';
+}
+
+static struct svc_expkey *svc_expkey_lookup(struct svc_expkey *, int);
+int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
+{
+	/* client fsidtype fsid [path] */
+	char *buf;
+	int len;
+	struct auth_domain *dom = NULL;
+	int err;
+	int fsidtype;
+	char *ep;
+	struct svc_expkey key;
+
+	if (mesg[mlen-1] != '\n')
+		return -EINVAL;
+	mesg[mlen-1] = 0;
+
+	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	err = -ENOMEM;
+	if (!buf) goto out;
+
+	err = -EINVAL;
+	if ((len=get_word(&mesg, buf, PAGE_SIZE)) <= 0)
+		goto out;
+
+	err = -ENOENT;
+	dom = auth_domain_find(buf);
+	if (!dom)
+		goto out;
+	dprintk("found domain %s\n", buf);
+
+	err = -EINVAL;
+	if ((len=get_word(&mesg, buf, PAGE_SIZE)) <= 0)
+		goto out;
+	fsidtype = simple_strtoul(buf, &ep, 10);
+	if (*ep)
+		goto out;
+	dprintk("found fsidtype %d\n", fsidtype);
+	if (fsidtype > 1)
+		goto out;
+	if ((len=get_word(&mesg, buf, PAGE_SIZE)) <= 0)
+		goto out;
+	dprintk("found fsid length %d\n", len);
+	if (len != ((fsidtype==0)?8:4))
+		goto out;
+
+	/* OK, we seem to have a valid key */
+	key.h.flags = 0;
+	key.h.expiry_time = get_expiry(&mesg);
+	if (key.h.expiry_time == 0)
+		goto out;
+
+	key.ek_client = dom;	
+	key.ek_fsidtype = fsidtype;
+	memcpy(key.ek_fsid, buf, len);
+
+	/* now we want a pathname, or empty meaning NEGATIVE  */
+	if ((len=get_word(&mesg, buf, PAGE_SIZE)) < 0)
+		goto out;
+	dprintk("Path seems to be <%s>\n", buf);
+	err = 0;
+	if (len == 0)
+		set_bit(CACHE_NEGATIVE, &key.h.flags);
+	else {
+		struct nameidata nd;
+		struct svc_expkey *ek;
+		struct svc_export *exp;
+		err = path_lookup(buf, 0, &nd);
+		if (err)
+			goto out;
+
+		dprintk("Found the path %s\n", buf);
+		exp = exp_get_by_name(dom, nd.mnt, nd.dentry, NULL);
+
+		err = -ENOENT;
+		if (!exp)
+			goto out_nd;
+		key.ek_export = exp;
+		dprintk("And found export\n");
+		
+		ek = svc_expkey_lookup(&key, 2);
+		if (ek)
+			expkey_put(&ek->h, &svc_expkey_cache);
+		svc_export_put(&exp->h, &svc_export_cache);
+		err = 0;
+	out_nd:
+		path_release(&nd);
+	}
+
+ out:
+	if (dom)
+		auth_domain_put(dom);
+	if (buf)
+		kfree(buf);
+	return err;
+}
+
 struct cache_detail svc_expkey_cache = {
 	.hash_size	= EXPKEY_HASHMAX,
 	.hash_table	= expkey_table,
 	.name		= "nfsd.fh",
 	.cache_put	= expkey_put,
+	.cache_request	= expkey_request,
+	.cache_parse	= expkey_parse,
 };
 
 static inline int svc_expkey_match (struct svc_expkey *a, struct svc_expkey *b)
@@ -147,11 +260,114 @@ void svc_export_put(struct cache_head *i
 	}
 }
 
+void svc_export_request(struct cache_detail *cd,
+			struct cache_head *h,
+			char **bpp, int *blen)
+{
+	/*  client path */
+	struct svc_export *exp = container_of(h, struct svc_export, h);
+	char *pth;
+
+	add_word(bpp, blen, exp->ex_client->name);
+	pth = d_path(exp->ex_dentry, exp->ex_mnt, *bpp, *blen);
+	add_word(bpp, blen, pth);
+	(*bpp)[-1] = '\n';
+}
+
+static struct svc_export *svc_export_lookup(struct svc_export *, int);
+int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
+{
+	/* client path expiry [flags anonuid anongid fsid] */
+	char *buf;
+	int len;
+	int err;
+	struct auth_domain *dom = NULL;
+	struct nameidata nd;
+	struct svc_export exp, *expp;
+	int an_int;
+
+	nd.dentry = NULL;
+
+	if (mesg[mlen-1] != '\n')
+		return -EINVAL;
+	mesg[mlen-1] = 0;
+
+	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	err = -ENOMEM;
+	if (!buf) goto out;
+
+	/* client */
+	len = get_word(&mesg, buf, PAGE_SIZE);
+	if (len <= 0) return -EINVAL;
+	err = -ENOENT;
+	dom = auth_domain_find(buf);
+	if (!dom)
+		goto out;
+
+	/* path */
+	err = -EINVAL;
+	if ((len=get_word(&mesg, buf, PAGE_SIZE)) <= 0)
+		goto out;
+	err = path_lookup(buf, 0, &nd);
+	if (err) goto out;
+
+	exp.h.flags = 0;
+	exp.ex_client = dom;
+	exp.ex_mnt = nd.mnt;
+	exp.ex_dentry = nd.dentry;
+
+	/* expiry */
+	err = -EINVAL;
+	exp.h.expiry_time = get_expiry(&mesg);
+	if (exp.h.expiry_time == 0)
+		goto out;
+
+	/* flags */
+	err = get_int(&mesg, &an_int);
+	if (err == -ENOENT)
+		set_bit(CACHE_NEGATIVE, &exp.h.flags);
+	else {
+		if (err || an_int < 0) goto out;	
+		exp.ex_flags= an_int;
+	
+		/* anon uid */
+		err = get_int(&mesg, &an_int);
+		if (err) goto out;
+		exp.ex_anon_uid= an_int;
+
+		/* anon gid */
+		err = get_int(&mesg, &an_int);
+		if (err) goto out;
+		exp.ex_anon_gid= an_int;
+
+		/* fsid */
+		err = get_int(&mesg, &an_int);
+		if (err) goto out;
+		exp.ex_fsid = an_int;
+	}
+
+	expp = svc_export_lookup(&exp, 1);
+	if (expp)
+		exp_put(expp);
+	err = 0;
+
+ out:
+	if (nd.dentry)
+		path_release(&nd);
+	if (dom)
+		auth_domain_put(dom);
+	if (buf)
+		kfree(buf);
+	return err;
+}
+
 struct cache_detail svc_export_cache = {
 	.hash_size	= EXPORT_HASHMAX,
 	.hash_table	= export_table,
 	.name		= "nfsd.export",
 	.cache_put	= svc_export_put,
+	.cache_request	= svc_export_request,
+	.cache_parse	= svc_export_parse,
 };
 
 static inline int svc_export_match(struct svc_export *a, struct svc_export *b)


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
