From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [Patch 1/4] Coverity #848
Date: Mon, 27 Mar 2006 10:57:08 -0800
Message-ID: <1143485828.9451.28.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FNwqV-0000t4-NF
	for nfs@lists.sourceforge.net; Mon, 27 Mar 2006 10:53:43 -0800
Received: from e36.co.us.ibm.com ([32.97.110.154])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FNwqU-0004gI-LM
	for nfs@lists.sourceforge.net; Mon, 27 Mar 2006 10:53:43 -0800
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k2RIrbRw022018
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 13:53:37 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2RIugwd190670
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 11:56:42 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k2RIraV7004923
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 11:53:36 -0700
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av01.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id k2RIraeR004885
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 11:53:36 -0700
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

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -221,7 +221,7 @@ static int nfsaclsvc_encode_getaclres(st
 		struct nfsd3_getaclres *resp)
 {
 	struct dentry *dentry = resp->fh.fh_dentry;
-	struct inode *inode = dentry->d_inode;
+	struct inode *inode;
 	int w = nfsacl_size(
 		(resp->mask & NFS_ACL)   ? resp->acl_access  : NULL,
 		(resp->mask & NFS_DFACL) ? resp->acl_default : NULL);




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
