From: Usha Ketineni <ketineni@us.ibm.com>
Subject: [PATCH]: Fix sparse warning in vfs.c
Date: Wed, 24 May 2006 14:27:52 -0700
Message-ID: <4474CFD8.6060000@us.ltcfwd.linux.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070004040304010300050801"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fj0tu-0000CN-MK
	for nfs@lists.sourceforge.net; Wed, 24 May 2006 14:28:18 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fj0tu-0001O7-HG
	for nfs@lists.sourceforge.net; Wed, 24 May 2006 14:28:18 -0700
Received: from e4.ny.us.ibm.com ([32.97.182.144])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Fj0tq-00058d-BN
	for nfs@lists.sourceforge.net; Wed, 24 May 2006 14:28:15 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4OLRvQm005378
	for <nfs@lists.sourceforge.net>; Wed, 24 May 2006 17:27:57 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4OLRvMa090098
	for <nfs@lists.sourceforge.net>; Wed, 24 May 2006 17:27:57 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k4OLRvdF028316
	for <nfs@lists.sourceforge.net>; Wed, 24 May 2006 17:27:57 -0400
Received: from [127.0.0.1] (IBM-RF40CZ9KB83.beaverton.ibm.com [9.47.22.61])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4OLRtsg028260
	for <nfs@lists.sourceforge.net>; Wed, 24 May 2006 17:27:56 -0400
To: nfs@lists.sourceforge.net
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

This is a multi-part message in MIME format.
--------------070004040304010300050801
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Below trivial fix casts __user attribute to avoid sparse warning




--------------070004040304010300050801
Content-Type: text/plain;
 name="patch_sparse_warnings"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_sparse_warnings"

Signed-off-by: Usha Ketineni<uketinen@us.ibm.com>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1383,7 +1383,7 @@ nfsd_readlink(struct svc_rqst *rqstp, st
 	 */
 
 	oldfs = get_fs(); set_fs(KERNEL_DS);
-	err = inode->i_op->readlink(dentry, buf, *lenp);
+	err = inode->i_op->readlink(dentry, (char __user *)buf, *lenp);
 	set_fs(oldfs);
 
 	if (err < 0)

--------------070004040304010300050801--



-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
