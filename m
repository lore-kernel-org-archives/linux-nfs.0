From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/12] text-based mount.nfs: rename
	fix_up_mounthost_opt()
Date: Mon, 08 Oct 2007 11:53:41 -0400
Message-ID: <20071008155341.15051.76029.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IeuvP-0007dS-MY
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:53:43 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IeuvT-0000ow-Ps
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:53:49 -0700
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

Spell out _option, just like other mount-option specific functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index b31b3a2..3d83f9e 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -191,10 +191,10 @@ static int append_clientaddr_option(struct sockaddr_in *saddr,
 }
 
 /*
- * Called to resolve the 'mounthost=' hostname and append a new
- * option using an IPv4 address.
+ * Resolve the 'mounthost=' hostname and append a new option using
+ * the resulting IPv4 address.
  */
-static int fix_up_mounthost_opt(struct mount_options *options)
+static int fix_mounthost_option(struct mount_options *options)
 {
 	struct sockaddr_in maddr;
 	char *mounthost, new_option[32];
@@ -251,7 +251,7 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 	if (!append_addr_option(&saddr, options))
 		goto out;
 
-	if (!fix_up_mounthost_opt(options))
+	if (!fix_mounthost_option(options))
 		goto out;
 
 	if (po_join(options, extra_opts) == PO_FAILED) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
