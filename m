From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 9] knfsd: nfsd4: refactor exp_pseudoroot
Date: Tue, 5 Sep 2006 09:15:43 +1000
Message-ID: <1060904231543.23100@suse.de>
References: <20060905090617.21303.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKNfR-0000Kn-G9
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:15:49 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKNfV-00046u-6q
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:15:53 -0700
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


From: J.Bruce Fields <bfields@fieldses.org>

We could be using more common code in exp_pseudoroot().  This will also
simplify some changes we need to make later.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2006-09-04 17:09:49.000000000 +1000
+++ ./fs/nfsd/export.c	2006-09-04 17:18:25.000000000 +1000
@@ -1048,30 +1048,24 @@ int
 exp_pseudoroot(struct auth_domain *clp, struct svc_fh *fhp,
 	       struct cache_req *creq)
 {
-	struct svc_expkey *fsid_key;
 	struct svc_export *exp;
 	int rv;
 	u32 fsidv[2];
 
 	mk_fsid_v1(fsidv, 0);
 
-	fsid_key = exp_find_key(clp, 1, fsidv, creq);
-	if (IS_ERR(fsid_key) && PTR_ERR(fsid_key) == -EAGAIN)
+	exp = exp_find(clp, 1, fsidv, creq);
+	if (IS_ERR(exp) && PTR_ERR(exp) == -EAGAIN)
 		return nfserr_dropit;
-	if (!fsid_key || IS_ERR(fsid_key))
-		return nfserr_perm;
-
-	exp = exp_get_by_name(clp, fsid_key->ek_mnt, fsid_key->ek_dentry, creq);
 	if (exp == NULL)
 		rv = nfserr_perm;
 	else if (IS_ERR(exp))
 		rv = nfserrno(PTR_ERR(exp));
 	else {
 		rv = fh_compose(fhp, exp,
-				fsid_key->ek_dentry, NULL);
+				exp->ex_dentry, NULL);
 		exp_put(exp);
 	}
-	cache_put(&fsid_key->h, &svc_expkey_cache);
 	return rv;
 }
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
