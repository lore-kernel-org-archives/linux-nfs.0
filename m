From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 14] knfsd: Remove noise about filehandle being
	uptodate.
Date: Tue, 27 Jun 2006 17:19:50 +1000
Message-ID: <1060627071950.26624@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7rZ-0006Es-Ip
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:19:57 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7rZ-00079Q-6r
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:19:57 -0700
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


There is a perfectly valid situation where fh_update gets called on an
already uptodate filehandle - in nfsd_create_v3 where a
CREATE_UNCHECKED finds an existing file and wants to just set the
size.

We could possible optimise out the call in that case, but the only
harm involved is that fh_update prints a warning, so it is easier to
remove the warning.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsfh.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2006-06-27 12:15:18.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2006-06-27 12:16:05.000000000 +1000
@@ -461,7 +461,7 @@ fh_update(struct svc_fh *fhp)
 	} else {
 		int size;
 		if (fhp->fh_handle.fh_fileid_type != 0)
-			goto out_uptodate;
+			goto out;
 		datap = fhp->fh_handle.fh_auth+
 			fhp->fh_handle.fh_size/4 -1;
 		size = (fhp->fh_maxsize - fhp->fh_handle.fh_size)/4;
@@ -481,10 +481,6 @@ out_negative:
 	printk(KERN_ERR "fh_update: %s/%s still negative!\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 	goto out;
-out_uptodate:
-	printk(KERN_ERR "fh_update: %s/%s already up-to-date!\n",
-		dentry->d_parent->d_name.name, dentry->d_name.name);
-	goto out;
 }
 
 /*

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
