From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 9/9] mount.nfs: Add a block comment before
	mount_error() and	umount_error()
Date: Fri, 24 Aug 2007 13:11:53 -0400
Message-ID: <20070824171153.10418.74058.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOchP-0003xg-5v
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:55 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOchT-0002Dh-Bh
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:59 -0700
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

Add block comments before mount_error() and umount_error() to help
distinguish them from the other error reporting functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/error.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/utils/mount/error.c b/utils/mount/error.c
index cab84c9..1f60b79 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -121,6 +121,13 @@ void mount_errors(char *server, int will_retry, int bg)
 		fprintf(stderr, "%s\n", errbuf);
 }
 
+/*
+ * mount_error - report a foreground mount error
+ * @spec: C string containing the device name being mounted
+ * @mount_point: C string containing the pathname of the local mounted on dir
+ * @error: errno value to report
+ *
+ */
 void mount_error(const char *spec, const char *mount_point, int error)
 {
 	switch(error) {
@@ -148,7 +155,10 @@ void mount_error(const char *spec, const char *mount_point, int error)
 }
 
 /*
- * Report a failed umount
+ * umount_error - report a failed umount request
+ * @err: errno value to report
+ * @dev: C string containing the pathname of the local mounted on dir
+ *
  */
 void umount_error(int err, const char *dev)
 {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
