From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/27] NFS: Ensure nfs_wcc_update_inode always
	converts file	size to loff_t
Date: Fri, 26 Oct 2007 13:31:47 -0400
Message-ID: <20071026173147.31475.30475.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT2H-0007EL-V7
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:54 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT2N-0008QT-B5
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:59 -0700
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

The nfs_wcc_update_inode() function omits logic to convert the type of
the NFS on-the-wire value of a file's size (__u64) to the type of file
size value stored in struct inode (loff_t, which is signed).

Everywhere else in the NFS client I checked already correctly converts the
file size type.

This effects only very large files.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/inode.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index db5d96d..cd0e57f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -814,8 +814,9 @@ static void nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			if (S_ISDIR(inode->i_mode))
 				nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 		}
-		if (inode->i_size == fattr->pre_size && nfsi->npages == 0)
-			inode->i_size = fattr->size;
+		if (inode->i_size == nfs_size_to_loff_t(fattr->pre_size) &&
+		    nfsi->npages == 0)
+			inode->i_size = nfs_size_to_loff_t(fattr->size);
 	}
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
