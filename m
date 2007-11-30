From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH] NFS: Add support for AF_INET6 addresses in
	nfs_compare_super()
Date: Fri, 30 Nov 2007 14:12:37 -0500
Message-ID: <20071130191237.3431.12598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IyBIz-0006sh-9L
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 11:13:41 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IyBJ4-0004za-81
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 11:13:47 -0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Refactor nfs_compare_super() and add AF_INET6 support.

Replace the generic memcmp() to document explicitly what parts of the
addresses must match in this check, and make the comparison independent
of the lengths of both addresses.

A side benefit is both tests are more computationally efficient than a
memcmp().

Note the "void *" casts are temporary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   41 ++++++++++++++++++++++++++++++++++++++---
 1 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6b004d8..e5646a9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -45,6 +45,8 @@
 #include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
+#include <linux/in6.h>
+#include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
 #include <linux/magic.h>
 #include <linux/parser.h>
@@ -1302,15 +1304,48 @@ static int nfs_set_super(struct super_block *s, void *data)
 	return ret;
 }
 
+static int nfs_compare_super_address(struct nfs_server *server1,
+				     struct nfs_server *server2)
+{
+	struct sockaddr_storage *ssp1 = (void *)&server1->nfs_client->cl_addr;
+	struct sockaddr_storage *ssp2 = (void *)&server2->nfs_client->cl_addr;
+
+	if (ssp1->ss_family != ssp2->ss_family)
+		return 0;
+
+	switch (ssp1->ss_family) {
+	case AF_INET: {
+		struct sockaddr_in *sin1 = (struct sockaddr_in *)ssp1;
+		struct sockaddr_in *sin2 = (struct sockaddr_in *)ssp2;
+		if (sin1->sin_addr.s_addr != sin2->sin_addr.s_addr)
+			return 0;
+		if (sin1->sin_port != sin2->sin_port)
+			return 0;
+		break;
+	}
+	case AF_INET6: {
+		struct sockaddr_in6 *sin1 = (struct sockaddr_in6 *)ssp1;
+		struct sockaddr_in6 *sin2 = (struct sockaddr_in6 *)ssp2;
+		if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
+			return 0;
+		if (sin1->sin6_port != sin2->sin6_port)
+			return 0;
+		break;
+	}
+	default:
+		return 0;
+	}
+
+	return 1;
+}
+
 static int nfs_compare_super(struct super_block *sb, void *data)
 {
 	struct nfs_sb_mountdata *sb_mntdata = data;
 	struct nfs_server *server = sb_mntdata->server, *old = NFS_SB(sb);
 	int mntflags = sb_mntdata->mntflags;
 
-	if (memcmp(&old->nfs_client->cl_addr,
-				&server->nfs_client->cl_addr,
-				sizeof(old->nfs_client->cl_addr)) != 0)
+	if (!nfs_compare_super_address(old, server))
 		return 0;
 	/* Note: NFS_MOUNT_UNSHARED == NFS4_MOUNT_UNSHARED */
 	if (old->flags & NFS_MOUNT_UNSHARED)


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

