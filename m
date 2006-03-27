From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [Patch 2/4] Coverity #733
Date: Mon, 27 Mar 2006 10:57:10 -0800
Message-ID: <1143485830.9451.29.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FNwqc-0000tI-Iy
	for nfs@lists.sourceforge.net; Mon, 27 Mar 2006 10:53:50 -0800
Received: from e31.co.us.ibm.com ([32.97.110.149])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FNwqa-0004hb-Ge
	for nfs@lists.sourceforge.net; Mon, 27 Mar 2006 10:53:50 -0800
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k2RIrhL0007749
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 13:53:43 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2RIoYUw265972
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 11:50:34 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k2RIrgP4005130
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 11:53:42 -0700
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av01.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id k2RIrg6r005122
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 11:53:42 -0700
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

This one could be considered a false positive since the only call to
nfs4_acl_nfsv4_to_posix() passes in a non-NULL pointer to dpacl, but the
code does check for non-NULL dpacl later.

Signed-off by: Frank Filz

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -378,7 +378,9 @@ nfs4_acl_nfsv4_to_posix(struct nfs4_acl 
 	int error = -ENOMEM;
 
 	*pacl = NULL;
-	*dpacl = NULL;
+
+	if (dpacl != NULL)
+		*dpacl = NULL;
 
 	dacl = nfs4_acl_new();
 	if (dacl == NULL)




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
