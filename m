From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 9] knfsd: nfsd4: simplify nfsv4->posix
	translation
Date: Tue, 13 Feb 2007 10:44:12 +1100
Message-ID: <1070212234412.29254@suse.de>
References: <20070213103941.28958.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGkqo-0005WK-7K
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:44:50 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HGkqn-00026g-Bl
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:44:52 -0800
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
The code that splits an incoming nfsv4 ACL into inheritable and effective parts
can be combined with the the code that translates each to a posix acl,
resulting in simpler code that requires one less pass through the ACL.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |  133 ++++++++++++++--------------------------------------
 1 file changed, 38 insertions(+), 95 deletions(-)

diff .prev/fs/nfsd/nfs4acl.c ./fs/nfsd/nfs4acl.c
--- .prev/fs/nfsd/nfs4acl.c	2007-02-13 10:01:42.000000000 +1100
+++ ./fs/nfsd/nfs4acl.c	2007-02-13 10:04:17.000000000 +1100
@@ -129,9 +129,7 @@ struct ace_container {
 
 static short ace2type(struct nfs4_ace *);
 static int _posix_to_nfsv4_one(struct posix_acl *, struct nfs4_acl *, unsigned int);
-static struct posix_acl *_nfsv4_to_posix_one(struct nfs4_acl *, unsigned int);
 int nfs4_acl_add_ace(struct nfs4_acl *, u32, u32, u32, int, uid_t);
-static int nfs4_acl_split(struct nfs4_acl *, struct nfs4_acl *);
 
 struct nfs4_acl *
 nfs4_acl_posix_to_nfsv4(struct posix_acl *pacl, struct posix_acl *dpacl,
@@ -344,46 +342,6 @@ sort_pacl(struct posix_acl *pacl)
 	return;
 }
 
-int
-nfs4_acl_nfsv4_to_posix(struct nfs4_acl *acl, struct posix_acl **pacl,
-		struct posix_acl **dpacl, unsigned int flags)
-{
-	struct nfs4_acl *dacl;
-	int error = -ENOMEM;
-
-	*pacl = NULL;
-	*dpacl = NULL;
-
-	dacl = nfs4_acl_new();
-	if (dacl == NULL)
-		goto out;
-
-	error = nfs4_acl_split(acl, dacl);
-	if (error)
-		goto out_acl;
-
-	*pacl = _nfsv4_to_posix_one(acl, flags);
-	if (IS_ERR(*pacl)) {
-		error = PTR_ERR(*pacl);
-		*pacl = NULL;
-		goto out_acl;
-	}
-
-	*dpacl = _nfsv4_to_posix_one(dacl, flags);
-	if (IS_ERR(*dpacl)) {
-		error = PTR_ERR(*dpacl);
-		*dpacl = NULL;
-	}
-out_acl:
-	if (error) {
-		posix_acl_release(*pacl);
-		*pacl = NULL;
-	}
-	nfs4_acl_free(dacl);
-out:
-	return error;
-}
-
 /*
  * While processing the NFSv4 ACE, this maintains bitmasks representing
  * which permission bits have been allowed and which denied to a given
@@ -668,76 +626,61 @@ static void process_one_v4_ace(struct po
 	}
 }
 
-static struct posix_acl *
-_nfsv4_to_posix_one(struct nfs4_acl *n4acl, unsigned int flags)
+int nfs4_acl_nfsv4_to_posix(struct nfs4_acl *acl, struct posix_acl **pacl,
+			    struct posix_acl **dpacl, unsigned int flags)
 {
-	struct posix_acl_state state;
-	struct posix_acl *pacl;
+	struct posix_acl_state effective_acl_state, default_acl_state;
 	struct nfs4_ace *ace;
 	int ret;
 
-	ret = init_state(&state, n4acl->naces);
+	ret = init_state(&effective_acl_state, acl->naces);
 	if (ret)
-		return ERR_PTR(ret);
-
-	list_for_each_entry(ace, &n4acl->ace_head, l_ace)
-		process_one_v4_ace(&state, ace);
-
-	pacl = posix_state_to_acl(&state, flags);
-
-	free_state(&state);
-
-	if (!IS_ERR(pacl))
-		sort_pacl(pacl);
-	return pacl;
-}
-
-static int
-nfs4_acl_split(struct nfs4_acl *acl, struct nfs4_acl *dacl)
-{
-	struct list_head *h, *n;
-	struct nfs4_ace *ace;
-	int error = 0;
-
-	list_for_each_safe(h, n, &acl->ace_head) {
-		ace = list_entry(h, struct nfs4_ace, l_ace);
-
+		return ret;
+	ret = init_state(&default_acl_state, acl->naces);
+	if (ret)
+		goto out_estate;
+	ret = -EINVAL;
+	list_for_each_entry(ace, &acl->ace_head, l_ace) {
 		if (ace->type != NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE &&
 		    ace->type != NFS4_ACE_ACCESS_DENIED_ACE_TYPE)
-			return -EINVAL;
-
+			goto out_dstate;
 		if (ace->flag & ~NFS4_SUPPORTED_FLAGS)
-			return -EINVAL;
-
+			goto out_dstate;
 		if ((ace->flag & NFS4_INHERITANCE_FLAGS) == 0) {
-			/* Leave this ace in the effective acl: */
+			process_one_v4_ace(&effective_acl_state, ace);
 			continue;
 		}
+		if (!(flags & NFS4_ACL_DIR))
+			goto out_dstate;
 		/*
 		 * Note that when only one of FILE_INHERIT or DIRECTORY_INHERIT
 		 * is set, we're effectively turning on the other.  That's OK,
 		 * according to rfc 3530.
 		 */
-		if (ace->flag & NFS4_ACE_INHERIT_ONLY_ACE) {
-			/* Add this ace to the default acl and remove it
-			 * from the effective acl: */
-			error = nfs4_acl_add_ace(dacl, ace->type, ace->flag,
-				ace->access_mask, ace->whotype, ace->who);
-			if (error)
-				return error;
-			list_del(h);
-			kfree(ace);
-			acl->naces--;
-		} else {
-			/* Add this ace to the default, but leave it in
-			 * the effective acl as well: */
-			error = nfs4_acl_add_ace(dacl, ace->type, ace->flag,
-				ace->access_mask, ace->whotype, ace->who);
-			if (error)
-				return error;
-		}
+		process_one_v4_ace(&default_acl_state, ace);
+
+		if (!(ace->flag & NFS4_ACE_INHERIT_ONLY_ACE))
+			process_one_v4_ace(&effective_acl_state, ace);
 	}
-	return 0;
+	*pacl = posix_state_to_acl(&effective_acl_state, flags);
+	if (IS_ERR(*pacl)) {
+		ret = PTR_ERR(*pacl);
+		goto out_dstate;
+	}
+	*dpacl = posix_state_to_acl(&default_acl_state, flags);
+	if (IS_ERR(*dpacl)) {
+		ret = PTR_ERR(*dpacl);
+		posix_acl_release(*pacl);
+		goto out_dstate;
+	}
+	sort_pacl(*pacl);
+	sort_pacl(*dpacl);
+	ret = 0;
+out_dstate:
+	free_state(&default_acl_state);
+out_estate:
+	free_state(&effective_acl_state);
+	return ret;
 }
 
 static short

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
