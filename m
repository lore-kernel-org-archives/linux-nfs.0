From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 12 of 16] nfsd4: acl error fix
Date: Tue, 22 Mar 2005 16:42:01 +1100
Message-ID: <E1DDc9R-0002Kq-Tv@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDc9d-0006kn-5f
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:13 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDc9b-0005eN-Pl
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:13 -0800
To: Andrew Morton <akpm@osdl.org>
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


When a client sends an ACL that is a legal NFSv4 ACL, but that we don't support
(because we can't represent it using a POSIX ACL), the correct error to return
is NFS4ERR_ATTRNOTSUPP.

(rfc3530, section 5.11.1: "If the server recieves a request to set an ACE that
it cannot store, it MUST reject the request with NFS4ERR_ATTRNOTSUPP.  If the
server receives a request to set an ACE that it can store but cannot enforce,
the server SHOULD reject the request with NFS4ERR_ATTRNOTSUPP").

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |    3 +++
 ./fs/nfsd/nfs4xdr.c |    5 ++++-
 ./fs/nfsd/vfs.c     |    7 +++++--
 3 files changed, 12 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4acl.c~current~ ./fs/nfsd/nfs4acl.c
--- ./fs/nfsd/nfs4acl.c~current~	2005-03-22 16:36:36.000000000 +1100
+++ ./fs/nfsd/nfs4acl.c	2005-03-22 16:36:36.000000000 +1100
@@ -93,6 +93,9 @@ deny_mask(u32 allow_mask, unsigned int f
 	return ret;
 }
 
+/* XXX: modify functions to return NFS errors; they're only ever
+ * used by nfs code, after all.... */
+
 static int
 mode_from_nfs4(u32 perm, unsigned short *mode, unsigned int flags)
 {

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2005-03-22 16:35:20.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2005-03-22 16:36:36.000000000 +1100
@@ -1331,7 +1331,10 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 		if (bmval0 & FATTR4_WORD0_ACL) {
 			if (status == -EOPNOTSUPP)
 				bmval0 &= ~FATTR4_WORD0_ACL;
-			else if (status != 0)
+			else if (status == -EINVAL) {
+				status = nfserr_attrnotsupp;
+				goto out;
+			} else if (status != 0)
 				goto out_nfserr;
 		}
 	}

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-03-22 16:35:20.000000000 +1100
+++ ./fs/nfsd/vfs.c	2005-03-22 16:36:36.000000000 +1100
@@ -393,7 +393,7 @@ set_nfsv4_acl_one(struct dentry *dentry,
 	}
 out:
 	kfree(buf);
-	return (error);
+	return error;
 }
 
 int
@@ -417,7 +417,10 @@ nfsd4_set_nfs4_acl(struct svc_rqst *rqst
 		flags = NFS4_ACL_DIR;
 
 	error = nfs4_acl_nfsv4_to_posix(acl, &pacl, &dpacl, flags);
-	if (error < 0)
+	if (error == -EINVAL) {
+		error = nfserr_attrnotsupp;
+		goto out;
+	} else if (error < 0)
 		goto out_nfserr;
 
 	if (pacl) {


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
