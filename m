From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/3] NFS: ignore mode change if it's just for clearing
	setuid/setgid bits
Date: Thu, 30 Aug 2007 11:06:48 -0400
Message-ID: <200708301506.l7UF6mRM002138@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-cifs-client@lists.samba.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQlbj-00029C-Re
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 08:06:55 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQlbl-0002QO-7j
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 08:06:58 -0700
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

If the ATTR_KILL_S*ID bits are set then any mode change is only for
clearing the setuid/setgid bits. For NFS skip the mode change and
let the server handle it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/inode.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 45633f9..441bd8b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -327,6 +327,10 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 
 	nfs_inc_stats(inode, NFSIOS_VFSSETATTR);
 
+	/* skip mode change if it's just for clearing setuid/setgid */
+	if (attr->ia_valid & (ATTR_KILL_SUID | ATTR_KILL_SGID))
+		attr->ia_valid &= ~ATTR_MODE;
+
 	if (attr->ia_valid & ATTR_SIZE) {
 		if (!S_ISREG(inode->i_mode) || attr->ia_size == i_size_read(inode))
 			attr->ia_valid &= ~ATTR_SIZE;
-- 
1.5.2.1


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
