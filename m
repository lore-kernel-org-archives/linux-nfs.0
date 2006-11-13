From: Neil Brown <neilb@suse.de>
Subject: Re: [2.6 patch] include/linux/nfsd/nfsfh.h:fh_unlock():
	change an error to a BUG_ON()
Date: Mon, 13 Nov 2006 15:52:00 +1100
Message-ID: <17751.63984.838723.340682@cse.unsw.edu.au>
References: <20061112131748.GI25057@stusta.de>
	<1163347127.6612.66.camel@lade.trondhjem.org>
	<20061112174831.GD3382@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjTnn-0003EE-7J
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 20:52:11 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GjTno-0006TL-0b
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 20:52:12 -0800
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: message from Adrian Bunk on Sunday November 12
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

On Sunday November 12, bunk@stusta.de wrote:
> > 
> > This issue has come up on lkml before. Please just convert that check
> > for fhp->fh_dentry into a BUG_ON().
> 
> Patch below.
> 

Thanks.  I might that the opportunity to do a bit more cleaning up
here and suggest this version .

NeilBrown

---------------------------
Subject: Replace some warning ins nfsfh.h with BUG_ON or WARN_ON

A couple of the warning will be followed by an Oops if they ever fire,
so may as well be BUG_ON.  Another isn't obviously fatal but has never
been known to fire, so make it a WARN_ON.

Cc: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/nfsd/nfsfh.h |   15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff .prev/include/linux/nfsd/nfsfh.h ./include/linux/nfsd/nfsfh.h
--- .prev/include/linux/nfsd/nfsfh.h	2006-11-13 15:44:24.000000000 +1100
+++ ./include/linux/nfsd/nfsfh.h	2006-11-13 15:47:02.000000000 +1100
@@ -217,11 +217,7 @@ void	fh_put(struct svc_fh *);
 static __inline__ struct svc_fh *
 fh_copy(struct svc_fh *dst, struct svc_fh *src)
 {
-	if (src->fh_dentry || src->fh_locked) {
-		struct dentry *dentry = src->fh_dentry;
-		printk(KERN_ERR "fh_copy: copying %s/%s, already verified!\n",
-			dentry->d_parent->d_name.name, dentry->d_name.name);
-	}
+	WARN_ON(src->fh_dentry || src->fh_locked);
 			
 	*dst = *src;
 	return dst;
@@ -300,10 +296,8 @@ fh_lock_nested(struct svc_fh *fhp, unsig
 	dfprintk(FILEOP, "nfsd: fh_lock(%s) locked = %d\n",
 			SVCFH_fmt(fhp), fhp->fh_locked);
 
-	if (!fhp->fh_dentry) {
-		printk(KERN_ERR "fh_lock: fh not verified!\n");
-		return;
-	}
+	BUG_ON(!dentry);
+
 	if (fhp->fh_locked) {
 		printk(KERN_WARNING "fh_lock: %s/%s already locked!\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name);
@@ -328,8 +322,7 @@ fh_lock(struct svc_fh *fhp)
 static inline void
 fh_unlock(struct svc_fh *fhp)
 {
-	if (!fhp->fh_dentry)
-		printk(KERN_ERR "fh_unlock: fh not verified!\n");
+	BUG_ON(!fhp->fh_dentry);
 
 	if (fhp->fh_locked) {
 		fill_post_wcc(fhp);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
