From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/21] NFS: Clean-up: use correct type when converting
	NFS	blocks to local blocks
Date: Sun, 01 Jul 2007 12:12:19 -0400
Message-ID: <20070701161219.2786.47495.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I523Y-0004RN-KQ
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:13:48 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I523c-0004x1-0Y
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:13:52 -0700
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

inode->i_blocks is a blkcnt_t these days, which can be a u64 or unsigned
long, depending on the setting of CONFIG_LSF.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ad2b40d..76cf55d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -183,9 +183,9 @@ unsigned long nfs_block_bits(unsigned long bsize, unsigned char *nrbitsp)
 /*
  * Calculate the number of 512byte blocks used.
  */
-static inline unsigned long nfs_calc_block_size(u64 tsize)
+static inline blkcnt_t nfs_calc_block_size(u64 tsize)
 {
-	loff_t used = (tsize + 511) >> 9;
+	blkcnt_t used = (tsize + 511) >> 9;
 	return (used > ULONG_MAX) ? ULONG_MAX : used;
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
