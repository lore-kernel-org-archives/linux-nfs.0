From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/27] SUNRPC: Remove an unneeded implicit type cast
	when	calling rpc_depopulate()
Date: Fri, 26 Oct 2007 13:31:04 -0400
Message-ID: <20071026173104.31475.2321.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT1h-0007Cj-LV
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:17 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT1m-00082F-3H
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:23 -0700
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

The two arguments of rpc_depopulate() that pass in inode numbers should use
the same type as inode->i_ino: unsigned long.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpc_pipe.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 18f0a8d..57cd24e 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -512,8 +512,8 @@ rpc_get_inode(struct super_block *sb, int mode)
 /*
  * FIXME: This probably has races.
  */
-static void
-rpc_depopulate(struct dentry *parent, int start, int eof)
+static void rpc_depopulate(struct dentry *parent,
+			   unsigned long start, unsigned long eof)
 {
 	struct inode *dir = parent->d_inode;
 	struct list_head *pos, *next;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
