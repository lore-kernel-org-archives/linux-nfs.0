From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 14] knfsd: Break the hard linkage from svc_expkey to svc_export
Date: Thu, 9 Mar 2006 17:51:32 +1100
Message-ID: <1060309065132.24533@suse.de>
References: <20060309174755.24381.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHF0n-0000YL-8z
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:52:37 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHF0m-0006ve-Kk
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:52:37 -0800
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


Current svc_expkey holds a pointer to the svc_export
structure, so updates to that structure have to be in-place,
which is a wart on the whole cache infrastruct.
So we break that linkage and just do a second lookup.

If this became a performance issue, it would be possible to put a
direct link back in which was only used conditionally.
i.e. when an object is replaced in the cache, we set a flag in the old 
object.  When dereferencing the link from svc_expkey, if the flag is set,
we drop the reference and do a fresh lookup.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c            |   60 ++++++++++++++++++++++++++++--------------
 ./include/linux/nfsd/export.h |   20 ++------------
 2 files changed, 44 insertions(+), 36 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2006-03-09 17:13:01.000000000 +1100
+++ ./fs/nfsd/export.c	2006-03-09 17:15:13.000000000 +1100
@@ -73,8 +73,10 @@ void expkey_put(struct cache_head *item,
 	if (cache_put(item, cd)) {
 		struct svc_expkey *key = container_of(item, struct svc_expkey, h);
 		if (test_bit(CACHE_VALID, &item->flags) &&
-		    !test_bit(CACHE_NEGATIVE, &item->flags))
-			exp_put(key->ek_export);
+		    !test_bit(CACHE_NEGATIVE, &item->flags)) {
+			dput(key->ek_dentry);
+			mntput(key->ek_mnt);
+		}
 		auth_domain_put(key->ek_client);
 		kfree(key);
 	}
@@ -164,26 +166,18 @@ static int expkey_parse(struct cache_det
 	} else {
 		struct nameidata nd;
 		struct svc_expkey *ek;
-		struct svc_export *exp;
 		err = path_lookup(buf, 0, &nd);
 		if (err)
 			goto out;
 
 		dprintk("Found the path %s\n", buf);
-		exp = exp_get_by_name(dom, nd.mnt, nd.dentry, NULL);
-
-		err = -ENOENT;
-		if (!exp)
-			goto out_nd;
-		key.ek_export = exp;
-		dprintk("And found export\n");
+		key.ek_mnt = nd.mnt;
+		key.ek_dentry = nd.dentry;
 		
 		ek = svc_expkey_lookup(&key, 1);
 		if (ek)
 			expkey_put(&ek->h, &svc_expkey_cache);
-		exp_put(exp);
 		err = 0;
-	out_nd:
 		path_release(&nd);
 	}
 	cache_flush();
@@ -214,7 +208,7 @@ static int expkey_show(struct seq_file *
 	if (test_bit(CACHE_VALID, &h->flags) && 
 	    !test_bit(CACHE_NEGATIVE, &h->flags)) {
 		seq_printf(m, " ");
-		seq_path(m, ek->ek_export->ex_mnt, ek->ek_export->ex_dentry, "\\ \t\n");
+		seq_path(m, ek->ek_mnt, ek->ek_dentry, "\\ \t\n");
 	}
 	seq_printf(m, "\n");
 	return 0;
@@ -252,8 +246,8 @@ static inline void svc_expkey_init(struc
 
 static inline void svc_expkey_update(struct svc_expkey *new, struct svc_expkey *item)
 {
-	cache_get(&item->ek_export->h);
-	new->ek_export = item->ek_export;
+	new->ek_mnt = mntget(item->ek_mnt);
+	new->ek_dentry = dget(item->ek_dentry);
 }
 
 static DefineSimpleCacheLookup(svc_expkey,0) /* no inplace updates */
@@ -519,7 +513,8 @@ static int exp_set_key(svc_client *clp, 
 	key.ek_client = clp;
 	key.ek_fsidtype = fsid_type;
 	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
-	key.ek_export = exp;
+	key.ek_mnt = exp->ex_mnt;
+	key.ek_dentry = exp->ex_dentry;
 	key.h.expiry_time = NEVER;
 	key.h.flags = 0;
 
@@ -741,8 +736,8 @@ exp_export(struct nfsctl_export *nxp)
 	if ((nxp->ex_flags & NFSEXP_FSID) &&
 	    (fsid_key = exp_get_fsid_key(clp, nxp->ex_dev)) &&
 	    !IS_ERR(fsid_key) &&
-	    fsid_key->ek_export &&
-	    fsid_key->ek_export != exp)
+	    fsid_key->ek_mnt &&
+	    (fsid_key->ek_mnt != nd.mnt || fsid_key->ek_dentry != nd.dentry) )
 		goto finish;
 
 	if (exp) {
@@ -912,6 +907,24 @@ out:
 	return err;
 }
 
+struct svc_export *
+exp_find(struct auth_domain *clp, int fsid_type, u32 *fsidv,
+	 struct cache_req *reqp)
+{
+	struct svc_export *exp;
+	struct svc_expkey *ek = exp_find_key(clp, fsid_type, fsidv, reqp);
+	if (!ek || IS_ERR(ek))
+		return ERR_PTR(PTR_ERR(ek));
+
+	exp = exp_get_by_name(clp, ek->ek_mnt, ek->ek_dentry, reqp);
+	expkey_put(&ek->h, &svc_expkey_cache);
+
+	if (!exp || IS_ERR(exp))
+		return ERR_PTR(PTR_ERR(exp));
+	return exp;
+}
+
+
 /*
  * Called when we need the filehandle for the root of the pseudofs,
  * for a given NFSv4 client.   The root is defined to be the
@@ -922,6 +935,7 @@ exp_pseudoroot(struct auth_domain *clp, 
 	       struct cache_req *creq)
 {
 	struct svc_expkey *fsid_key;
+	struct svc_export *exp;
 	int rv;
 	u32 fsidv[2];
 
@@ -933,8 +947,14 @@ exp_pseudoroot(struct auth_domain *clp, 
 	if (!fsid_key || IS_ERR(fsid_key))
 		return nfserr_perm;
 
-	rv = fh_compose(fhp, fsid_key->ek_export, 
-			  fsid_key->ek_export->ex_dentry, NULL);
+	exp = exp_get_by_name(clp, fsid_key->ek_mnt, fsid_key->ek_dentry, creq);
+	if (exp == NULL)
+		rv = nfserr_perm;
+	else if (IS_ERR(exp))
+		rv = nfserrno(PTR_ERR(exp));
+	else
+		rv = fh_compose(fhp, exp,
+				fsid_key->ek_dentry, NULL);
 	expkey_put(&fsid_key->h, &svc_expkey_cache);
 	return rv;
 }

diff ./include/linux/nfsd/export.h~current~ ./include/linux/nfsd/export.h
--- ./include/linux/nfsd/export.h~current~	2006-03-09 17:12:58.000000000 +1100
+++ ./include/linux/nfsd/export.h	2006-03-09 17:15:13.000000000 +1100
@@ -67,7 +67,8 @@ struct svc_expkey {
 	int			ek_fsidtype;
 	u32			ek_fsid[3];
 
-	struct svc_export *	ek_export;
+	struct vfsmount *	ek_mnt;
+	struct dentry *		ek_dentry;
 };
 
 #define EX_SECURE(exp)		(!((exp)->ex_flags & NFSEXP_INSECURE_PORT))
@@ -114,22 +115,9 @@ static inline void exp_get(struct svc_ex
 {
 	cache_get(&exp->h);
 }
-static inline struct svc_export *
+extern struct svc_export *
 exp_find(struct auth_domain *clp, int fsid_type, u32 *fsidv,
-	 struct cache_req *reqp)
-{
-	struct svc_expkey *ek = exp_find_key(clp, fsid_type, fsidv, reqp);
-	if (ek && !IS_ERR(ek)) {
-		struct svc_export *exp = ek->ek_export;
-		int err;
-		exp_get(exp);
-		expkey_put(&ek->h, &svc_expkey_cache);
-		if ((err = cache_check(&svc_export_cache, &exp->h, reqp)))
-			exp = ERR_PTR(err);
-		return exp;
-	} else
-		return ERR_PTR(PTR_ERR(ek));
-}
+	 struct cache_req *reqp);
 
 #endif /* __KERNEL__ */
 


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
