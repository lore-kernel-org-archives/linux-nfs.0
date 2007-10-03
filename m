From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [RFC] [PATCH 2/2] nfs: Remove function
	nfs_verify_change_attributes
Date: Wed, 03 Oct 2007 17:50:10 +0530
Message-ID: <1191414010.20470.54.camel@jays-ws.blr.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id38U-0006to-Ql
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 05:15:33 -0700
Received: from victor.provo.novell.com ([137.65.250.26])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Id38Y-0003cf-QN
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 05:15:36 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The function nfs_verify_change_attributes() is misleading and no longer
required if [PATCH 1/2] of this patchset is included. One would normally
expect the function to return true if there is a change in attributes
but, the function does the other way around.

* Please note that this patch assumes inclusion of the previous patch
[PATCH 1/2] nfs: Fix i_size update in O_DIRECT write which remove the
last invocation of this function.

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>

---

 include/linux/nfs_fs.h |   13 -------------
 1 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 7250eea..d103cc0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -264,19 +264,6 @@ static inline long nfs_save_change_attri
 	return NFS_I(inode)->cache_change_attribute;
 }
 
-/**
- * nfs_verify_change_attribute - Detects NFS inode cache updates
- * @inode - pointer to inode
- * @chattr - previously saved change attribute
- * Return "false" if metadata has been updated (or is in the process of
- * being updated) since the change attribute was saved.
- */
-static inline int nfs_verify_change_attribute(struct inode *inode, unsigned long chattr)
-{
-	return !nfs_caches_unstable(inode)
-		&& time_after_eq(chattr, NFS_I(inode)->cache_change_attribute);
-}
-
 /*
  * linux/fs/nfs/inode.c
  */

-- 
Suresh Jayaraman


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
