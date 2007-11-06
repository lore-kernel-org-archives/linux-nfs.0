From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] mount.nfs: eliminate a double unlock_mtab
Date: Mon, 05 Nov 2007 19:55:17 -0500
Message-ID: <20071106005517.4721.1673.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCj6-0003sz-6b
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 16:55:32 -0800
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCjA-0002DB-Qx
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 16:55:38 -0800
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

add_mtab() calls unlock_mtab() twice in one of its error exit paths.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 21946f7..db150de 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -244,7 +244,6 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 	lock_mtab();
 
 	if ((mtab = setmntent(MOUNTED, "a+")) == NULL) {
-		unlock_mtab();
 		nfs_error(_("Can't open mtab: %s"),
 				strerror(errno));
 		goto fail_unlock;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
