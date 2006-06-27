From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 14] knfsd: Ignore ref_fh when crossing a
	mountpoint.
Date: Tue, 27 Jun 2006 17:19:56 +1000
Message-ID: <1060627071956.26636@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7rf-0006Hr-W8
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:04 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7rf-0007CE-6l
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:04 -0700
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


nfsd tries to return to a client the same sort of filehandle as was
used by the client.  This removes some filehandle aliasing issues and
means that a server upgrade followed by a downgrade will not confused
clients not restarted during that time.

However when crossing a mountpoint, the filehandle used for one
filesystem doesn't provide any useful information on what sort of
filehandle should be used on the other, and can provide misleading
information.  So if the reference filehandle is on a different
filesystem to the one being generated, ignore it.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsfh.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2006-06-27 12:16:05.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2006-06-27 12:16:27.000000000 +1000
@@ -312,8 +312,8 @@ int
 fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry, struct svc_fh *ref_fh)
 {
 	/* ref_fh is a reference file handle.
-	 * if it is non-null, then we should compose a filehandle which is
-	 * of the same version, where possible.
+	 * if it is non-null and for the same filesystem, then we should compose
+	 * a filehandle which is of the same version, where possible.
 	 * Currently, that means that if ref_fh->fh_handle.fh_version == 0xca
 	 * Then create a 32byte filehandle using nfs_fhbase_old
 	 *
@@ -332,7 +332,7 @@ fh_compose(struct svc_fh *fhp, struct sv
 		parent->d_name.name, dentry->d_name.name,
 		(inode ? inode->i_ino : 0));
 
-	if (ref_fh) {
+	if (ref_fh && ref_fh->fh_export == exp) {
 		ref_fh_version = ref_fh->fh_handle.fh_version;
 		if (ref_fh_version == 0xca)
 			ref_fh_fsid_type = 0;

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
