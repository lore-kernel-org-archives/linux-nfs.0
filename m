From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 9] knfsd: nfsd4: clean up exp_pseudoroot
Date: Tue, 5 Sep 2006 09:15:48 +1000
Message-ID: <1060904231548.23112@suse.de>
References: <20060905090617.21303.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKNfW-0000Lp-80
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:15:54 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKNfZ-0005T9-KG
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:15:58 -0700
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

The previous patch enables some minor simplification here.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2006-09-04 17:18:25.000000000 +1000
+++ ./fs/nfsd/export.c	2006-09-04 17:20:22.000000000 +1000
@@ -1058,14 +1058,11 @@ exp_pseudoroot(struct auth_domain *clp, 
 	if (IS_ERR(exp) && PTR_ERR(exp) == -EAGAIN)
 		return nfserr_dropit;
 	if (exp == NULL)
-		rv = nfserr_perm;
+		return nfserr_perm;
 	else if (IS_ERR(exp))
-		rv = nfserrno(PTR_ERR(exp));
-	else {
-		rv = fh_compose(fhp, exp,
-				exp->ex_dentry, NULL);
-		exp_put(exp);
-	}
+		return nfserrno(PTR_ERR(exp));
+	rv = fh_compose(fhp, exp, exp->ex_dentry, NULL);
+	exp_put(exp);
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
