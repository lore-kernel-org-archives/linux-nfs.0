From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 9] knfsd: nfsd4: represent nfsv4 acl with array
	instead of linked list
Date: Tue, 13 Feb 2007 10:44:18 +1100
Message-ID: <1070212234418.29268@suse.de>
References: <20070213103941.28958.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGkqw-0005X3-BK
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:44:58 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HGkqx-00027a-6c
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:45:00 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: J. Bruce Fields <bfields@citi.umich.edu>
Simplify the memory management and code a bit by representing acls with an
array instead of a linked list.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c        |  153 ++++++++++++---------------------------------
 ./fs/nfsd/nfs4xdr.c        |   43 +++++-------
 ./include/linux/nfs4.h     |    3 
 ./include/linux/nfs4_acl.h |    9 +-
 4 files changed, 69 insertions(+), 139 deletions(-)

diff .prev/fs/nfsd/nfs4acl.c ./fs/nfsd/nfs4acl.c
--- .prev/fs/nfsd/nfs4acl.c	2007-02-13 10:04:17.000000000 +1100
+++ ./fs/nfsd/nfs4acl.c	2007-02-13 10:23:49.000000000 +1100
@@ -128,74 +128,58 @@ struct ace_container {
 };
 
 static short ace2type(struct nfs4_ace *);
-static int _posix_to_nfsv4_one(struct posix_acl *, struct nfs4_acl *, unsigned int);
-int nfs4_acl_add_ace(struct nfs4_acl *, u32, u32, u32, int, uid_t);
+static void _posix_to_nfsv4_one(struct posix_acl *, struct nfs4_acl *,
+				unsigned int);
+void nfs4_acl_add_ace(struct nfs4_acl *, u32, u32, u32, int, uid_t);
 
 struct nfs4_acl *
 nfs4_acl_posix_to_nfsv4(struct posix_acl *pacl, struct posix_acl *dpacl,
 			unsigned int flags)
 {
 	struct nfs4_acl *acl;
-	int error = -EINVAL;
+	int size = 0;
 
-	if ((pacl != NULL &&
-		(posix_acl_valid(pacl) < 0 || pacl->a_count == 0)) ||
-	    (dpacl != NULL &&
-		(posix_acl_valid(dpacl) < 0 || dpacl->a_count == 0)))
-		goto out_err;
-
-	acl = nfs4_acl_new();
-	if (acl == NULL) {
-		error = -ENOMEM;
-		goto out_err;
-	}
+	if (pacl) {
+		if (posix_acl_valid(pacl) < 0)
+			return ERR_PTR(-EINVAL);
+		size += 2*pacl->a_count;
+	}
+	if (dpacl) {
+		if (posix_acl_valid(dpacl) < 0)
+			return ERR_PTR(-EINVAL);
+		size += 2*dpacl->a_count;
+	}
+
+	/* Allocate for worst case: one (deny, allow) pair each: */
+	acl = nfs4_acl_new(size);
+	if (acl == NULL)
+		return ERR_PTR(-ENOMEM);
 
-	if (pacl != NULL) {
-		error = _posix_to_nfsv4_one(pacl, acl,
-						flags & ~NFS4_ACL_TYPE_DEFAULT);
-		if (error < 0)
-			goto out_acl;
-	}
+	if (pacl)
+		_posix_to_nfsv4_one(pacl, acl, flags & ~NFS4_ACL_TYPE_DEFAULT);
 
-	if (dpacl != NULL) {
-		error = _posix_to_nfsv4_one(dpacl, acl,
-						flags | NFS4_ACL_TYPE_DEFAULT);
-		if (error < 0)
-			goto out_acl;
-	}
-
-	return acl;
-
-out_acl:
-	nfs4_acl_free(acl);
-out_err:
-	acl = ERR_PTR(error);
+	if (dpacl)
+		_posix_to_nfsv4_one(dpacl, acl, flags | NFS4_ACL_TYPE_DEFAULT);
 
 	return acl;
 }
 
-static int
+static void
 nfs4_acl_add_pair(struct nfs4_acl *acl, int eflag, u32 mask, int whotype,
 		uid_t owner, unsigned int flags)
 {
-	int error;
-
-	error = nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE,
+	nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE,
 				 eflag, mask, whotype, owner);
-	if (error < 0)
-		return error;
-	error = nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
+	nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
 				eflag, deny_mask(mask, flags), whotype, owner);
-	return error;
 }
 
 /* We assume the acl has been verified with posix_acl_valid. */
-static int
+static void
 _posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
 						unsigned int flags)
 {
 	struct posix_acl_entry *pa, *pe, *group_owner_entry;
-	int error = -EINVAL;
 	u32 mask, mask_mask;
 	int eflag = ((flags & NFS4_ACL_TYPE_DEFAULT) ?
 					NFS4_INHERITANCE_FLAGS : 0);
@@ -211,23 +195,16 @@ _posix_to_nfsv4_one(struct posix_acl *pa
 	pa = pacl->a_entries;
 	BUG_ON(pa->e_tag != ACL_USER_OBJ);
 	mask = mask_from_posix(pa->e_perm, flags | NFS4_ACL_OWNER);
-	error = nfs4_acl_add_pair(acl, eflag, mask, NFS4_ACL_WHO_OWNER, 0, flags);
-	if (error < 0)
-		goto out;
+	nfs4_acl_add_pair(acl, eflag, mask, NFS4_ACL_WHO_OWNER, 0, flags);
 	pa++;
 
 	while (pa->e_tag == ACL_USER) {
 		mask = mask_from_posix(pa->e_perm, flags);
-		error = nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
+		nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
 				eflag,  mask_mask, NFS4_ACL_WHO_NAMED, pa->e_id);
-		if (error < 0)
-			goto out;
-
 
-		error = nfs4_acl_add_pair(acl, eflag, mask,
+		nfs4_acl_add_pair(acl, eflag, mask,
 				NFS4_ACL_WHO_NAMED, pa->e_id, flags);
-		if (error < 0)
-			goto out;
 		pa++;
 	}
 
@@ -238,34 +215,25 @@ _posix_to_nfsv4_one(struct posix_acl *pa
 
 	if (pacl->a_count > 3) {
 		BUG_ON(pa->e_tag != ACL_GROUP_OBJ);
-		error = nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
+		nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
 				NFS4_ACE_IDENTIFIER_GROUP | eflag, mask_mask,
 				NFS4_ACL_WHO_GROUP, 0);
-		if (error < 0)
-			goto out;
 	}
 	group_owner_entry = pa;
 	mask = mask_from_posix(pa->e_perm, flags);
-	error = nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE,
+	nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE,
 			NFS4_ACE_IDENTIFIER_GROUP | eflag, mask,
 			NFS4_ACL_WHO_GROUP, 0);
-	if (error < 0)
-		goto out;
 	pa++;
 
 	while (pa->e_tag == ACL_GROUP) {
 		mask = mask_from_posix(pa->e_perm, flags);
-		error = nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
+		nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
 				NFS4_ACE_IDENTIFIER_GROUP | eflag, mask_mask,
 				NFS4_ACL_WHO_NAMED, pa->e_id);
-		if (error < 0)
-			goto out;
-
-		error = nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE,
+		nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE,
 		    		NFS4_ACE_IDENTIFIER_GROUP | eflag, mask,
 		    		NFS4_ACL_WHO_NAMED, pa->e_id);
-		if (error < 0)
-			goto out;
 		pa++;
 	}
 
@@ -273,19 +241,15 @@ _posix_to_nfsv4_one(struct posix_acl *pa
 
 	pa = group_owner_entry;
 	mask = mask_from_posix(pa->e_perm, flags);
-	error = nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
+	nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
 			NFS4_ACE_IDENTIFIER_GROUP | eflag,
 			deny_mask(mask, flags), NFS4_ACL_WHO_GROUP, 0);
-	if (error < 0)
-		goto out;
 	pa++;
 	while (pa->e_tag == ACL_GROUP) {
 		mask = mask_from_posix(pa->e_perm, flags);
-		error = nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
+		nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
 		    		NFS4_ACE_IDENTIFIER_GROUP | eflag,
 		    		deny_mask(mask, flags), NFS4_ACL_WHO_NAMED, pa->e_id);
-		if (error < 0)
-			goto out;
 		pa++;
 	}
 
@@ -293,10 +257,7 @@ _posix_to_nfsv4_one(struct posix_acl *pa
 		pa++;
 	BUG_ON(pa->e_tag != ACL_OTHER);
 	mask = mask_from_posix(pa->e_perm, flags);
-	error = nfs4_acl_add_pair(acl, eflag, mask, NFS4_ACL_WHO_EVERYONE, 0, flags);
-
-out:
-	return error;
+	nfs4_acl_add_pair(acl, eflag, mask, NFS4_ACL_WHO_EVERYONE, 0, flags);
 }
 
 static void
@@ -640,7 +601,7 @@ int nfs4_acl_nfsv4_to_posix(struct nfs4_
 	if (ret)
 		goto out_estate;
 	ret = -EINVAL;
-	list_for_each_entry(ace, &acl->ace_head, l_ace) {
+	for (ace = acl->aces; ace < acl->aces + acl->naces; ace++) {
 		if (ace->type != NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE &&
 		    ace->type != NFS4_ACE_ACCESS_DENIED_ACE_TYPE)
 			goto out_dstate;
@@ -705,48 +666,22 @@ EXPORT_SYMBOL(nfs4_acl_posix_to_nfsv4);
 EXPORT_SYMBOL(nfs4_acl_nfsv4_to_posix);
 
 struct nfs4_acl *
-nfs4_acl_new(void)
+nfs4_acl_new(int n)
 {
 	struct nfs4_acl *acl;
 
-	if ((acl = kmalloc(sizeof(*acl), GFP_KERNEL)) == NULL)
+	acl = kmalloc(sizeof(*acl) + n*sizeof(struct nfs4_ace), GFP_KERNEL);
+	if (acl == NULL)
 		return NULL;
-
 	acl->naces = 0;
-	INIT_LIST_HEAD(&acl->ace_head);
-
 	return acl;
 }
 
 void
-nfs4_acl_free(struct nfs4_acl *acl)
-{
-	struct list_head *h;
-	struct nfs4_ace *ace;
-
-	if (!acl)
-		return;
-
-	while (!list_empty(&acl->ace_head)) {
-		h = acl->ace_head.next;
-		list_del(h);
-		ace = list_entry(h, struct nfs4_ace, l_ace);
-		kfree(ace);
-	}
-
-	kfree(acl);
-
-	return;
-}
-
-int
 nfs4_acl_add_ace(struct nfs4_acl *acl, u32 type, u32 flag, u32 access_mask,
 		int whotype, uid_t who)
 {
-	struct nfs4_ace *ace;
-
-	if ((ace = kmalloc(sizeof(*ace), GFP_KERNEL)) == NULL)
-		return -ENOMEM;
+	struct nfs4_ace *ace = acl->aces + acl->naces;
 
 	ace->type = type;
 	ace->flag = flag;
@@ -754,10 +689,7 @@ nfs4_acl_add_ace(struct nfs4_acl *acl, u
 	ace->whotype = whotype;
 	ace->who = who;
 
-	list_add_tail(&ace->l_ace, &acl->ace_head);
 	acl->naces++;
-
-	return 0;
 }
 
 static struct {
@@ -811,7 +743,6 @@ nfs4_acl_write_who(int who, char *p)
 }
 
 EXPORT_SYMBOL(nfs4_acl_new);
-EXPORT_SYMBOL(nfs4_acl_free);
 EXPORT_SYMBOL(nfs4_acl_add_ace);
 EXPORT_SYMBOL(nfs4_acl_get_whotype);
 EXPORT_SYMBOL(nfs4_acl_write_who);

diff .prev/fs/nfsd/nfs4xdr.c ./fs/nfsd/nfs4xdr.c
--- .prev/fs/nfsd/nfs4xdr.c	2007-02-13 09:50:25.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2007-02-13 10:23:49.000000000 +1100
@@ -273,42 +273,42 @@ nfsd4_decode_fattr(struct nfsd4_compound
 		iattr->ia_valid |= ATTR_SIZE;
 	}
 	if (bmval[0] & FATTR4_WORD0_ACL) {
-		int nace, i;
-		struct nfs4_ace ace;
+		int nace;
+		struct nfs4_ace *ace;
 
 		READ_BUF(4); len += 4;
 		READ32(nace);
 
-		*acl = nfs4_acl_new();
+		if (nace > NFS4_ACL_MAX)
+			return nfserr_resource;
+
+		*acl = nfs4_acl_new(nace);
 		if (*acl == NULL) {
 			host_err = -ENOMEM;
 			goto out_nfserr;
 		}
-		defer_free(argp, (void (*)(const void *))nfs4_acl_free, *acl);
+		defer_free(argp, kfree, *acl);
 
-		for (i = 0; i < nace; i++) {
+		(*acl)->naces = nace;
+		for (ace = (*acl)->aces; ace < (*acl)->aces + nace; ace++) {
 			READ_BUF(16); len += 16;
-			READ32(ace.type);
-			READ32(ace.flag);
-			READ32(ace.access_mask);
+			READ32(ace->type);
+			READ32(ace->flag);
+			READ32(ace->access_mask);
 			READ32(dummy32);
 			READ_BUF(dummy32);
 			len += XDR_QUADLEN(dummy32) << 2;
 			READMEM(buf, dummy32);
-			ace.whotype = nfs4_acl_get_whotype(buf, dummy32);
+			ace->whotype = nfs4_acl_get_whotype(buf, dummy32);
 			host_err = 0;
-			if (ace.whotype != NFS4_ACL_WHO_NAMED)
-				ace.who = 0;
-			else if (ace.flag & NFS4_ACE_IDENTIFIER_GROUP)
+			if (ace->whotype != NFS4_ACL_WHO_NAMED)
+				ace->who = 0;
+			else if (ace->flag & NFS4_ACE_IDENTIFIER_GROUP)
 				host_err = nfsd_map_name_to_gid(argp->rqstp,
-						buf, dummy32, &ace.who);
+						buf, dummy32, &ace->who);
 			else
 				host_err = nfsd_map_name_to_uid(argp->rqstp,
-						buf, dummy32, &ace.who);
-			if (host_err)
-				goto out_nfserr;
-			host_err = nfs4_acl_add_ace(*acl, ace.type, ace.flag,
-				 ace.access_mask, ace.whotype, ace.who);
+						buf, dummy32, &ace->who);
 			if (host_err)
 				goto out_nfserr;
 		}
@@ -1596,7 +1596,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 	}
 	if (bmval0 & FATTR4_WORD0_ACL) {
 		struct nfs4_ace *ace;
-		struct list_head *h;
 
 		if (acl == NULL) {
 			if ((buflen -= 4) < 0)
@@ -1609,9 +1608,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 			goto out_resource;
 		WRITE32(acl->naces);
 
-		list_for_each(h, &acl->ace_head) {
-			ace = list_entry(h, struct nfs4_ace, l_ace);
-
+		for (ace = acl->aces; ace < acl->aces + acl->naces; ace++) {
 			if ((buflen -= 4*3) < 0)
 				goto out_resource;
 			WRITE32(ace->type);
@@ -1821,7 +1818,7 @@ out_acl:
 	status = nfs_ok;
 
 out:
-	nfs4_acl_free(acl);
+	kfree(acl);
 	if (fhp == &tempfh)
 		fh_put(&tempfh);
 	return status;

diff .prev/include/linux/nfs4_acl.h ./include/linux/nfs4_acl.h
--- .prev/include/linux/nfs4_acl.h	2007-02-13 09:50:25.000000000 +1100
+++ ./include/linux/nfs4_acl.h	2007-02-13 10:23:49.000000000 +1100
@@ -39,9 +39,12 @@
 
 #include <linux/posix_acl.h>
 
-struct nfs4_acl *nfs4_acl_new(void);
-void nfs4_acl_free(struct nfs4_acl *);
-int nfs4_acl_add_ace(struct nfs4_acl *, u32, u32, u32, int, uid_t);
+/* Maximum ACL we'll accept from client; chosen (somewhat arbitrarily) to
+ * fit in a page: */
+#define NFS4_ACL_MAX 170
+
+struct nfs4_acl *nfs4_acl_new(int);
+void nfs4_acl_add_ace(struct nfs4_acl *, u32, u32, u32, int, uid_t);
 int nfs4_acl_get_whotype(char *, u32);
 int nfs4_acl_write_who(int who, char *p);
 int nfs4_acl_permission(struct nfs4_acl *acl, uid_t owner, gid_t group,

diff .prev/include/linux/nfs4.h ./include/linux/nfs4.h
--- .prev/include/linux/nfs4.h	2007-02-13 09:50:25.000000000 +1100
+++ ./include/linux/nfs4.h	2007-02-13 10:23:49.000000000 +1100
@@ -105,12 +105,11 @@ struct nfs4_ace {
 	uint32_t	access_mask;
 	int		whotype;
 	uid_t		who;
-	struct list_head l_ace;
 };
 
 struct nfs4_acl {
 	uint32_t	naces;
-	struct list_head ace_head;
+	struct nfs4_ace	aces[0];
 };
 
 typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
