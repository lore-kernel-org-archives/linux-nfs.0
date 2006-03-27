From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [Patch 3/4] Coverity #392
Date: Mon, 27 Mar 2006 10:57:12 -0800
Message-ID: <1143485832.9451.30.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FNwqk-0000tr-QE
	for nfs@lists.sourceforge.net; Mon, 27 Mar 2006 10:53:58 -0800
Received: from e31.co.us.ibm.com ([32.97.110.149])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FNwqj-0001AR-O1
	for nfs@lists.sourceforge.net; Mon, 27 Mar 2006 10:53:59 -0800
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k2RIrnhS007849
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 13:53:49 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2RIoeUw269416
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 11:50:40 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k2RIrmsK030061
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 11:53:48 -0700
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id k2RIrms4029763
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 11:53:48 -0700
To: NFS List <nfs@lists.sourceforge.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Signed-off by: Frank Filz

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1929,11 +1929,10 @@ nfsd_set_posix_acl(struct svc_fh *fhp, i
 		value = kmalloc(size, GFP_KERNEL);
 		if (!value)
 			return -ENOMEM;
-		size = posix_acl_to_xattr(acl, value, size);
-		if (size < 0) {
-			error = size;
+		error = posix_acl_to_xattr(acl, value, size);
+		if (error < 0)
 			goto getout;
-		}
+		size = error;
 	} else
 		size = 0;




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
