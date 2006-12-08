From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 18] knfsd: nfsd: simplify exp_pseudoroot
Date: Fri, 8 Dec 2006 12:13:46 +1100
Message-ID: <1061208011346.30615@suse.de>
References: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUIx-00037e-6V
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:35 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUIx-00014E-3E
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:36 -0800
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

Note there's no need for special handling of -EAGAIN here; nfserrno() does
what we want already.  So this is a pure cleanup with no change in
functionality.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2006-12-08 12:08:20.000000000 +1100
+++ ./fs/nfsd/export.c	2006-12-08 12:08:25.000000000 +1100
@@ -1163,12 +1163,10 @@ exp_pseudoroot(struct auth_domain *clp, 
 	mk_fsid_v1(fsidv, 0);
 
 	exp = exp_find(clp, 1, fsidv, creq);
-	if (IS_ERR(exp) && PTR_ERR(exp) == -EAGAIN)
-		return nfserr_dropit;
+	if (IS_ERR(exp))
+		return nfserrno(PTR_ERR(exp));
 	if (exp == NULL)
 		return nfserr_perm;
-	else if (IS_ERR(exp))
-		return nfserrno(PTR_ERR(exp));
 	rv = fh_compose(fhp, exp, exp->ex_dentry, NULL);
 	exp_put(exp);
 	return rv;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
