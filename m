From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/12] text-based mount.nfs: Plug "fg" and "bg"
	processing	into nfsmount_string()
Date: Mon, 08 Oct 2007 11:54:39 -0400
Message-ID: <20071008155439.15051.25776.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IeuwK-0007mB-HM
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:40 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IeuwP-0006br-Ja
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:45 -0700
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

We have all the pre-requisites now, so add "fg" and "bg" mount processing
to text-based NFS mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 27ada39..814c215 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -664,32 +664,32 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 	struct mount_options *options = NULL;
 	struct sockaddr_in saddr;
 	char *hostname;
-	int err, retval = EX_FAIL;
+	int retval = EX_FAIL;
 
 	if (!parse_devname(spec, &hostname))
-		goto out;
-	err = fill_ipv4_sockaddr(hostname, &saddr);
-	free(hostname);
-	if (!err)
-		goto out;
+		return retval;
+	if (!fill_ipv4_sockaddr(hostname, &saddr))
+		goto fail;
 
 	options = po_split(*extra_opts);
 	if (!options) {
 		nfs_error(_("%s: internal option parsing error"), progname);
-		goto out;
+		goto fail;
 	}
 
 	if (!set_mandatory_options(type, &saddr, options))
 		goto out;
 
-	if (try_mount(spec, node, type, flags, options, fake, extra_opts)) {
-		mount_error(spec, node, errno);
-		goto out;
-	}
-
-	retval = EX_SUCCESS;
+	if (po_rightmost(options, "bg", "fg") > -1)
+		retval = nfsmount_fg(spec, node, type, flags, options,
+							fake, extra_opts);
+	else
+		retval = nfsmount_bg(spec, node, type, hostname, flags,
+					options, fake, child, extra_opts);
 
 out:
 	po_destroy(options);
+fail:
+	free(hostname);
 	return retval;
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
