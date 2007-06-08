From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] gitignore updates
Date: Fri, 8 Jun 2007 16:12:03 -0400
Message-ID: <20070608201203.GF32061@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HwkoV-0003zp-Qs
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 13:12:03 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HwkoX-0005GH-NB
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 13:12:07 -0700
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

Update gitignore to ignore some generated files.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 utils/gssd/.gitignore  |    3 +++
 utils/statd/.gitignore |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)
 create mode 100644 utils/gssd/.gitignore
 create mode 100644 utils/statd/.gitignore

diff --git a/utils/gssd/.gitignore b/utils/gssd/.gitignore
new file mode 100644
index 0000000..aba7b13
--- /dev/null
+++ b/utils/gssd/.gitignore
@@ -0,0 +1,3 @@
+gss_clnt_send_err
+gssd
+svcgssd
diff --git a/utils/statd/.gitignore b/utils/statd/.gitignore
new file mode 100644
index 0000000..99b0cce
--- /dev/null
+++ b/utils/statd/.gitignore
@@ -0,0 +1 @@
+sm-notify
-- 
1.5.2.rc3


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
