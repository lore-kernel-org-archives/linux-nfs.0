From: "Robert P. J. Day" <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
Subject: [NFS] [PATCH] NFS: Identify root_nfs_parse_addr() as truly __init.
Date: Fri, 30 Nov 2007 12:45:39 -0500 (EST)
Message-ID: <alpine.LFD.0.9999.0711301243280.6488@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iy9vp-0006dD-TX
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 09:45:42 -0800
Received: from astoria.ccjclearline.com ([64.235.106.9])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Iy9vt-0008Di-T6
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 09:45:48 -0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


Signed-off-by: Robert P. J. Day <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>

---

  unless there's a reason not to, might as well tag that function as
truly __init to match its definition.

  not compile tested.

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 2d15d4a..f42fe64 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -298,7 +298,7 @@ extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struc
 extern u64 nfs_compat_user_ino64(u64 fileid);

 /* linux/net/ipv4/ipconfig.c: trims ip addr off front of name, too. */
-extern __be32 root_nfs_parse_addr(char *name); /*__init*/
+extern __be32 root_nfs_parse_addr(char *name) __init;

 static inline void nfs_fattr_init(struct nfs_fattr *fattr)
 {
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================

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

