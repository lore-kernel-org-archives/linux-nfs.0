From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] mount.nfs: Replace a "return 0;
	" that should be an "exit(0); "
Date: Fri, 10 Aug 2007 18:19:50 -0400
Message-ID: <20070810221950.21712.90137.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJcpj-0007cj-FF
	for nfs@lists.sourceforge.net; Fri, 10 Aug 2007 15:19:51 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IJcpm-0003oO-Gc
	for nfs@lists.sourceforge.net; Fri, 10 Aug 2007 15:19:55 -0700
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 94435c8..a6e1685 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -431,7 +431,7 @@ int main(int argc, char *argv[])
 			break;
 		case 'V':
 			printf("%s: ("PACKAGE_STRING")\n", progname);
-			return 0;
+			exit(0);
 		case 'w':
 			flags &= ~MS_RDONLY;
 			break;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
