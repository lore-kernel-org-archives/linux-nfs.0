From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 24/25] NFS: Parse IPv6 addresses in
	nfs_parse_server_address
Date: Tue, 13 Nov 2007 13:33:07 -0500
Message-ID: <20071113183307.5087.96750.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0ZQ-0000d2-AV
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:33:08 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0ZV-0000Yu-MY
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:33:14 -0800
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

Add the ability to parse IPv6 addresses passed in via the 'addr=' and
'mountaddr=' mount options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/super.c |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2abef88..c066016 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -622,11 +622,25 @@ static void nfs_parse_server_address(char *value,
 				     struct sockaddr_storage *ssp,
 				     size_t *len)
 {
-	struct sockaddr_in *ap = (struct sockaddr_in *)ssp;
-
-	ap->sin_family = AF_INET;
-	ap->sin_addr.s_addr = in_aton(value);
-	*len = sizeof(*ap);
+	if (strchr(value, ':') == NULL) {
+		struct sockaddr_in *ap = (struct sockaddr_in *)ssp;
+		u8 buf[4];
+
+		if (in4_pton(value, -1, buf, '\0', NULL)) {
+			ap->sin_family = AF_INET;
+			memcpy(&ap->sin_addr.s_addr, buf, sizeof(buf));
+			*len = sizeof(*ap);
+		}
+	} else {
+		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)ssp;
+		u8 buf[16];
+
+		if (in6_pton(value, -1, buf, '\0', NULL)) {
+			ap->sin6_family = AF_INET6;
+			memcpy(&ap->sin6_addr.in6_u, buf, sizeof(buf));
+			*len = sizeof(*ap);
+		}
+	}
 }
 
 /*


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
