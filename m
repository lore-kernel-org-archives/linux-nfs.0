From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] include/linux/nfsd/nfsfh.h: fix a NULL
Date: Sun, 12 Nov 2006 14:17:48 +0100
Message-ID: <20061112131748.GI25057@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjFDZ-00051l-D8
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 05:17:49 -0800
Received: from emailhub.stusta.mhn.de ([141.84.69.5]
	helo=mailout.stusta.mhn.de)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GjFDa-0007nn-4j
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 05:17:50 -0800
To: neilb@cse.unsw.edu.au
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

dereference
Reply-To: 
Fcc: =sent-mail

When we know fhp->fh_dentry is NULL, a code path where it's being 
dereferenced isn't a good choice.

Spotted by the coverity checker.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6/include/linux/nfsd/nfsfh.h.old	2006-11-12 14:13:34.000000000 +0100
+++ linux-2.6/include/linux/nfsd/nfsfh.h	2006-11-12 14:13:49.000000000 +0100
@@ -330,8 +330,7 @@ fh_unlock(struct svc_fh *fhp)
 {
 	if (!fhp->fh_dentry)
 		printk(KERN_ERR "fh_unlock: fh not verified!\n");
-
-	if (fhp->fh_locked) {
+	else if (fhp->fh_locked) {
 		fill_post_wcc(fhp);
 		mutex_unlock(&fhp->fh_dentry->d_inode->i_mutex);
 		fhp->fh_locked = 0;


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
