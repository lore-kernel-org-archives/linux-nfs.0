From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Resubmit: [Patch 4/4] Coverity #324 and Coverity #323
Date: Thu, 30 Mar 2006 09:20:39 -0800
Message-ID: <1143739239.9451.38.camel@dyn9047022153>
References: <1143485836.9451.31.camel@dyn9047022153>
	 <1143486523.28645.51.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FP3tM-0008Dm-8N
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 12:37:16 -0800
Received: from over.co.us.ibm.com ([32.97.110.157])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FP3tL-0006ZM-05
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 12:37:15 -0800
Received: from e34.co.us.ibm.com (e34.boulder.ibm.com [9.17.249.44])
	by bldfb.esmtp.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k2UHH7W9022889
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <nfs@lists.sourceforge.net>; Thu, 30 Mar 2006 12:17:07 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k2UHGlC1006740
	for <nfs@lists.sourceforge.net>; Thu, 30 Mar 2006 12:16:47 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2UHDZS1263500
	for <nfs@lists.sourceforge.net>; Thu, 30 Mar 2006 10:13:35 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k2UHGg5g002540
	for <nfs@lists.sourceforge.net>; Thu, 30 Mar 2006 10:16:42 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1143486523.28645.51.camel@lade.trondhjem.org>
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

On Mon, 2006-03-27 at 14:08 -0500, Trond Myklebust wrote:
> Secondly, if fhp is NULL, then we really _ought_ to Oops in fh_unlock(),
> 'cos that would be a nasty evil coding ERROR that needs to be analysed
> and debugged.

Ok, I re-examined this. Looking at fh_lock, I see that the correct
behavior is to return without locking when fh_dentry is NULL. I've also
fixed Coverity #323, which is a similar issue in the same source file.

Frank

Signed-of by: Frank Filz

diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -218,7 +218,7 @@ void	fh_put(struct svc_fh *);
 static __inline__ struct svc_fh *
 fh_copy(struct svc_fh *dst, struct svc_fh *src)
 {
-	if (src->fh_dentry || src->fh_locked) {
+	if (src->fh_dentry && src->fh_locked) {
 		struct dentry *dentry = src->fh_dentry;
 		printk(KERN_ERR "fh_copy: copying %s/%s, already verified!\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name);
@@ -328,8 +328,10 @@ fh_lock(struct svc_fh *fhp)
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
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
