From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/12] text-based mount.nfs: refactor mandatory mount
	option	processing
Date: Mon, 08 Oct 2007 11:53:46 -0400
Message-ID: <20071008155346.15051.26660.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IeuvT-0007dh-VI
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:53:48 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IeuvZ-0000ry-3P
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:53:53 -0700
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

We're about to combine nfsmount_s() and nfs4mount_s().  Refactor the
version-specific mount option processing into a separate function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 3d83f9e..6270312 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -215,6 +215,29 @@ static int fix_mounthost_option(struct mount_options *options)
 }
 
 /*
+ * Set up mandatory mount options.
+ *
+ * Returns 1 if successful; otherwise zero.
+ */
+static int set_mandatory_options(const char *type,
+				 struct sockaddr_in *saddr,
+				 struct mount_options *options)
+{
+	if (!append_addr_option(saddr, options))
+		return 0;
+
+	if (strncmp(type, "nfs4", 4) == 0) {
+		if (!append_clientaddr_option(saddr, options))
+			return 0;
+	} else {
+		if (!fix_mounthost_option(options))
+			return 0;
+	}
+
+	return 1;
+}
+
+/*
  * nfsmount_s - Mount an NFSv2 or v3 file system using C string options
  *
  * @spec:	C string hostname:path specifying remoteshare to mount


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
