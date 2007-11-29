From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 28/29] NFS: Pull covers off IPv6 address parsing
Date: Thu, 29 Nov 2007 14:42:23 -0500
Message-ID: <20071129194223.4170.65862.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpJM-0001w2-Vk
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:44:36 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpJQ-0003n7-0k
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:44:43 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Now that the needed IPv6 infrastructure is in place, allow the NFS client's
IP address parser to generate AF_INET6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7c10189..10bdf3c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -627,11 +627,21 @@ static int nfs_verify_server_address(struct sockaddr_storage *ssp)
 static void nfs_parse_server_address(char *value,
 				     struct sockaddr_storage *ssp)
 {
-	struct sockaddr_in *ap = (void *)ssp;
+	if (strchr(value, ':')) {
+		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)ssp;
+		u8 *addr = (u8 *)&ap->sin6_addr.in6_u;
 
-	ap->sin_family = AF_INET;
-	if (in4_pton(value, -1, (u8 *)&ap->sin_addr.s_addr, '\0', NULL))
-		return;
+		ap->sin6_family = AF_INET6;
+		if (in6_pton(value, -1, addr, '\0', NULL))
+			return;
+	} else {
+		struct sockaddr_in *ap = (struct sockaddr_in *)ssp;
+		u8 *addr = (u8 *)&ap->sin_addr.s_addr;
+
+		ap->sin_family = AF_INET;
+		if (in4_pton(value, -1, addr, '\0', NULL))
+			return;
+	}
 
 	ssp->ss_family = AF_UNSPEC;
 }


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

