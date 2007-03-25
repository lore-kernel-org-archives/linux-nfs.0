From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] remove nfs4_acl_add_ace()
Date: Sun, 25 Mar 2007 16:58:32 +0200
Message-ID: <20070325145832.GL16477@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, "J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HVUBh-00089x-Vb
	for nfs@lists.sourceforge.net; Sun, 25 Mar 2007 07:59:21 -0700
Received: from mailout.stusta.mhn.de ([141.84.69.5] helo=mailhub.stusta.mhn.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HVUBk-00007z-2E
	for nfs@lists.sourceforge.net; Sun, 25 Mar 2007 07:59:20 -0700
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

nfs4_acl_add_ace() can now be removed.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 20 Feb 2007

 fs/nfsd/nfs4acl.c        |   17 -----------------
 include/linux/nfs4_acl.h |    1 -
 2 files changed, 18 deletions(-)

--- linux-2.6.20-mm2/include/linux/nfs4_acl.h.old	2007-02-18 22:40:31.000000000 +0100
+++ linux-2.6.20-mm2/include/linux/nfs4_acl.h	2007-02-18 22:40:36.000000000 +0100
@@ -44,7 +44,6 @@
 #define NFS4_ACL_MAX 170
 
 struct nfs4_acl *nfs4_acl_new(int);
-void nfs4_acl_add_ace(struct nfs4_acl *, u32, u32, u32, int, uid_t);
 int nfs4_acl_get_whotype(char *, u32);
 int nfs4_acl_write_who(int who, char *p);
 int nfs4_acl_permission(struct nfs4_acl *acl, uid_t owner, gid_t group,
--- linux-2.6.20-mm2/fs/nfsd/nfs4acl.c.old	2007-02-18 22:40:43.000000000 +0100
+++ linux-2.6.20-mm2/fs/nfsd/nfs4acl.c	2007-02-18 22:41:50.000000000 +0100
@@ -137,7 +137,6 @@
 static short ace2type(struct nfs4_ace *);
 static void _posix_to_nfsv4_one(struct posix_acl *, struct nfs4_acl *,
 				unsigned int);
-void nfs4_acl_add_ace(struct nfs4_acl *, u32, u32, u32, int, uid_t);
 
 struct nfs4_acl *
 nfs4_acl_posix_to_nfsv4(struct posix_acl *pacl, struct posix_acl *dpacl,
@@ -785,21 +784,6 @@
 	return acl;
 }
 
-void
-nfs4_acl_add_ace(struct nfs4_acl *acl, u32 type, u32 flag, u32 access_mask,
-		int whotype, uid_t who)
-{
-	struct nfs4_ace *ace = acl->aces + acl->naces;
-
-	ace->type = type;
-	ace->flag = flag;
-	ace->access_mask = access_mask;
-	ace->whotype = whotype;
-	ace->who = who;
-
-	acl->naces++;
-}
-
 static struct {
 	char *string;
 	int   stringlen;
@@ -851,6 +835,5 @@
 }
 
 EXPORT_SYMBOL(nfs4_acl_new);
-EXPORT_SYMBOL(nfs4_acl_add_ace);
 EXPORT_SYMBOL(nfs4_acl_get_whotype);
 EXPORT_SYMBOL(nfs4_acl_write_who);


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
