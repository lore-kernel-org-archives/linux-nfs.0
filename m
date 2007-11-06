From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/15] nfs(5) man page: Fix minor style problem in
	FILES	section
Date: Mon, 05 Nov 2007 20:03:49 -0500
Message-ID: <20071106010349.5037.82609.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCr7-0004gA-Rf
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:50 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCrD-0004WE-FB
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:55 -0800
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

Add an omitted description in the FILES section.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index f4c0790..b673cef 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1049,7 +1049,9 @@ NFS version 4 ACLs are not fully compatible with POSIX ACLs,
 thus some translation between the two is required
 in an environment that mixes POSIX ACLs and NFS version 4. 
 .SH FILES
+.TP 1.5i
 .I /etc/fstab
+file system table
 .SH "SEE ALSO"
 .BR fstab "(5), " mount "(8), " umount "(8), " exports (5)
 .SH AUTHOR


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
