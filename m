From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] NFS: Ensure we return zero if applications
	attempt to	write zero bytes
Date: Mon, 12 Nov 2007 12:16:58 -0500
Message-ID: <20071112171658.3053.11728.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ircun-0006t1-O3
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 09:17:38 -0800
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ircus-0005F7-QQ
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 09:17:42 -0800
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

A zero byte count direct write request should be a successful no-op, not an
error.

Signed-off-by: Chuck Lever <cel@netapp.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/direct.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 88d5d1c..4d726e9 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -890,6 +890,8 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	retval = generic_write_checks(file, &pos, &count, 0);
 	if (retval)
 		goto out;
+	if (!count)
+		goto out;	/* return 0 */
 
 	retval = -EINVAL;
 	if ((ssize_t) count < 0)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
