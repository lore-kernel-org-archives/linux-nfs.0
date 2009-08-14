Return-Path: <nfsv4-bounces@linux-nfs.org>
Subject: [PATHC] nfsd: Fix a couple issues with POSIX->NFSv4 ACL conversion
From: Frank Filz <ffilzlnx@us.ibm.com>
To: NFS List <linux-nfs@vger.kernel.org>,
        NFS V4 Mailing List <nfsv4@linux-nfs.org>
Date: Fri, 14 Aug 2009 15:02:30 -0700
Message-Id: <1250287351.32255.3.camel@dyn9047022153>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

1. GROUP@ Allow entry doesn't have NFS4_ACE_IDENTIFIER_GROUP, This
appears to have been introduced by accident as part of commit
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=bec50c47aaf6f1f9247f1860547ab394a0802a4c

2. The group deny entries end up denying tcy even though tcy was just
allowed by the allow entry. This appears to be due to:
	ace->access_mask = mask_from_posix(deny, flags);
instead of:
	ace->access_mask = deny_mask_from_posix(deny, flags);

Frank

Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
---
 fs/nfsd/nfs4acl.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index 54b8b41..ae37ec4 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -295,7 +295,7 @@ _posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
 	group_owner_entry = pa;
 
 	ace->type = NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
-	ace->flag = eflag;
+	ace->flag = eflag | NFS4_ACE_IDENTIFIER_GROUP;
 	ace->access_mask = mask_from_posix(pas.group, flags);
 	ace->whotype = NFS4_ACL_WHO_GROUP;
 	ace++;
@@ -335,7 +335,7 @@ _posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
 		if (deny) {
 			ace->type = NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
 			ace->flag = eflag | NFS4_ACE_IDENTIFIER_GROUP;
-			ace->access_mask = mask_from_posix(deny, flags);
+			ace->access_mask = deny_mask_from_posix(deny, flags);
 			ace->whotype = NFS4_ACL_WHO_NAMED;
 			ace->who = pa->e_id;
 			ace++;
-- 
1.5.2.2



_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
