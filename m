From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [Patch 4/4] Coverity #324
Date: Mon, 27 Mar 2006 10:57:16 -0800
Message-ID: <1143485836.9451.31.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FNwqi-0000tg-KH
	for nfs@lists.sourceforge.net; Mon, 27 Mar 2006 10:53:56 -0800
Received: from e34.co.us.ibm.com ([32.97.110.152])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FNwqh-0004ih-JN
	for nfs@lists.sourceforge.net; Mon, 27 Mar 2006 10:53:56 -0800
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k2RIrokc006878
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 13:53:50 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2RIofUw262100
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 11:50:41 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k2RIrnhT005563
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 11:53:49 -0700
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av01.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id k2RIrnK3005538
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 11:53:49 -0700
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

diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -328,7 +328,7 @@ fh_lock(struct svc_fh *fhp)
 static inline void
 fh_unlock(struct svc_fh *fhp)
 {
-	if (!fhp->fh_dentry)
+	if (!fhp || !fhp->fh_dentry)
 		printk(KERN_ERR "fh_unlock: fh not verified!\n");
 
 	if (fhp->fh_locked) {




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
