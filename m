From: NeilBrown <neilb@suse.de>
Subject: [PATCH 006 of 9] knfsd: nfsd4: fix error return on
	unsupported acl
Date: Tue, 13 Feb 2007 10:44:32 +1100
Message-ID: <1070212234432.29300@suse.de>
References: <20070213103941.28958.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGkrN-0005dA-H7
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:45:25 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HGkrO-0000sd-2E
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:45:27 -0800
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
We should be returning ATTRNOTSUPP, not NOTSUPP, when acls are unsupported.

Also fix a comment.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |    2 +-
 ./fs/nfsd/vfs.c     |    5 ++++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff .prev/fs/nfsd/nfs4xdr.c ./fs/nfsd/nfs4xdr.c
--- .prev/fs/nfsd/nfs4xdr.c	2007-02-13 10:36:40.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2007-02-13 10:37:00.000000000 +1100
@@ -253,7 +253,7 @@ nfsd4_decode_fattr(struct nfsd4_compound
 		return status;
 
 	/*
-	 * According to spec, unsupported attributes return ERR_NOTSUPP;
+	 * According to spec, unsupported attributes return ERR_ATTRNOTSUPP;
 	 * read-only attributes return ERR_INVAL.
 	 */
 	if ((bmval[0] & ~NFSD_SUPPORTED_ATTRS_WORD0) || (bmval[1] & ~NFSD_SUPPORTED_ATTRS_WORD1))

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2007-02-13 09:50:24.000000000 +1100
+++ ./fs/nfsd/vfs.c	2007-02-13 10:37:00.000000000 +1100
@@ -466,7 +466,10 @@ out:
 	posix_acl_release(dpacl);
 	return (error);
 out_nfserr:
-	error = nfserrno(host_error);
+	if (host_error == -EOPNOTSUPP)
+		error = nfserr_attrnotsupp;
+	else
+		error = nfserrno(host_error);
 	goto out;
 }
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
