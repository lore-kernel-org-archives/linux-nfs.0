From: "Jayachandran C." <jchandra@digeo.com>
Subject: [NFSD] Fix issues reported by coverity in include/linux/nfsd/nfsfh.h
Date: Thu, 1 Dec 2005 08:24:05 -0800
Message-ID: <20051201162405.GD4571@random.pao.digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EhrEN-0005RF-EM
	for nfs@lists.sourceforge.net; Thu, 01 Dec 2005 08:24:23 -0800
Received: from packet.digeo.com ([12.110.80.53])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EhrEL-00065w-Rl
	for nfs@lists.sourceforge.net; Thu, 01 Dec 2005 08:24:23 -0800
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

This patch tries to fix two minor issues reported in include/linux/nfsd/nfsfh.h
by Coverity, please review and apply if correct.

Errors reported:
CID: 3589
Checker: FORWARD_NULL
File: include/linux/nfsd/nfsfh.h
Function: fh_unlock
Description: Variable "(fhp)->fh_dentry" tracked as NULL was dereferenced.

CID: 2657
Checker: FORWARD_NULL
File: include/linux/nfsd/nfsfh.h
Function: fh_copy
Description: Variable "dentry" tracked as NULL was dereferenced.

Patch Description:
1. In fh_copy, the check "src->fh_dentry || src->fh_locked" does not
   seem to make sense. If "fh_dentry" is NULL and fh_locked is set
   (which should not happen), we should not dereference fh_dentry and
   panic.  

2. In fh_unlock, return after reporting error if fh_dentry == NULL,
   this will be consistent with the other places where fh_dentry is
   checked.


Signed-off-by: Jayachandran C. <c.jayachandran at gmail.com>

---

 nfsfh.h |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff -ur linux-2.6.15-rc3-git1.clean/include/linux/nfsd/nfsfh.h linux-2.6.15-rc3-git1/include/linux/nfsd/nfsfh.h
--- linux-2.6.15-rc3-git1.clean/include/linux/nfsd/nfsfh.h	Thu Oct 27 17:02:08 2005
+++ linux-2.6.15-rc3-git1/include/linux/nfsd/nfsfh.h	Thu Dec  1 05:31:52 2005
@@ -218,11 +218,13 @@
 static __inline__ struct svc_fh *
 fh_copy(struct svc_fh *dst, struct svc_fh *src)
 {
-	if (src->fh_dentry || src->fh_locked) {
+	if (src->fh_dentry) {
 		struct dentry *dentry = src->fh_dentry;
 		printk(KERN_ERR "fh_copy: copying %s/%s, already verified!\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name);
 	}
+	if (src->fh_locked) 
+		printk(KERN_ERR "fh_copy: already locked!\n");
 			
 	*dst = *src;
 	return dst;
@@ -328,8 +330,10 @@
 static inline void
 fh_unlock(struct svc_fh *fhp)
 {
-	if (!fhp->fh_dentry)
+	if (!fhp->fh_dentry) {
 		printk(KERN_ERR "fh_unlock: fh not verified!\n");
+		return;
+	}
 
 	if (fhp->fh_locked) {
 		fill_post_wcc(fhp);


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
