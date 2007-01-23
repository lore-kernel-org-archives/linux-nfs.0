From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 5] knfsd: Replace some warning ins nfsfh.h with
	BUG_ON or WARN_ON
Date: Tue, 23 Jan 2007 11:22:26 +1100
Message-ID: <1070123002226.27856@suse.de>
References: <20070123111558.27683.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Adrian Bunk <bunk@stusta.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H99R4-0007RU-JV
	for nfs@lists.sourceforge.net; Mon, 22 Jan 2007 16:22:51 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H99R5-0002EY-To
	for nfs@lists.sourceforge.net; Mon, 22 Jan 2007 16:22:52 -0800
To: Andrew Morton <akpm@osdl.org>
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


A couple of the warning will be followed by an Oops if they ever fire,
so may as well be BUG_ON.  Another isn't obviously fatal but has never
been known to fire, so make it a WARN_ON.

Cc: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/nfsd/nfsfh.h |   15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff .prev/include/linux/nfsd/nfsfh.h ./include/linux/nfsd/nfsfh.h
--- .prev/include/linux/nfsd/nfsfh.h	2007-01-23 11:13:44.000000000 +1100
+++ ./include/linux/nfsd/nfsfh.h	2007-01-23 11:15:00.000000000 +1100
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
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
