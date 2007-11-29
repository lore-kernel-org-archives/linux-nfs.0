From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 06/29] NFS: Increase size of cl_ipaddr field to hold
	IPv6	addresses
Date: Thu, 29 Nov 2007 14:40:23 -0500
Message-ID: <20071129194023.4170.79442.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpG8-0001US-Oi
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:16 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpGD-0007gJ-NJ
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:23 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

The nfs_client's cl_ipaddr field needs to be larger to hold strings that
represent IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 include/linux/nfs_fs_sb.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 8a3061c..c64773f 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -63,7 +63,7 @@ struct nfs_client {
 	/* Our own IP address, as a null-terminated string.
 	 * This is used to generate the clientid, and the callback address.
 	 */
-	char			cl_ipaddr[16];
+	char			cl_ipaddr[48];
 	unsigned char		cl_id_uniquifier;
 #endif
 };


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

