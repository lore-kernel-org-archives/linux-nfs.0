From: NeilBrown <neilb@suse.de>
Subject: [PATCH 006 of 14] knfsd: nfsd: call nfsd_setuser() on
	fh_compose(), fix nfsd4 permissions problem
Date: Tue, 27 Jun 2006 17:20:07 +1000
Message-ID: <1060627072007.26660@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7rt-0006Ly-2q
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:17 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7rs-0006wZ-7S
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:16 -0700
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

From: J. Bruce Fields <bfields@citi.umich.edu>


In the typical v2/v3 case the only new filehandles used as arguments to
operations are filehandles taken directly off the wire, which don't get
dentries until fh_verify() is called.

But in v4 the filehandles that are arguments to operations were often
created by previous operations (putrootfh, lookup, etc.) using
fh_compose, which sets the dentry in the filehandle without calling
nfsd_setuser().

This also means that, for example, if filesystem B is mounted on filesystem
A, and filesystem A is exported without root-squashing, then a client can
bypass the rootsquashing on B using a compound that starts at a filehandle
in A, crosses into B using lookups, and then does stuff in B.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

### Diffstat output
 ./fs/nfsd/nfsfh.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2006-06-27 12:16:27.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2006-06-27 14:41:52.000000000 +1000
@@ -187,13 +187,6 @@ fh_verify(struct svc_rqst *rqstp, struct
 			goto out;
 		}
 
-		/* Set user creds for this exportpoint */
-		error = nfsd_setuser(rqstp, exp);
-		if (error) {
-			error = nfserrno(error);
-			goto out;
-		}
-
 		/*
 		 * Look up the dentry using the NFS file handle.
 		 */
@@ -251,6 +244,14 @@ fh_verify(struct svc_rqst *rqstp, struct
 	}
 	cache_get(&exp->h);
 
+	/* Set user creds for this exportpoint; necessary even in the "just
+	 * checking" case because this may be a filehandle that was created by
+	 * fh_compose, and that is about to be used in another nfsv4 compound
+	 * operation */
+	error = nfserrno(nfsd_setuser(rqstp, exp));
+	if (error)
+		goto out;
+
 	error = nfsd_mode_check(rqstp, dentry->d_inode->i_mode, type);
 	if (error)
 		goto out;

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
