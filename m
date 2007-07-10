From: NeilBrown <neilb@suse.de>
Subject: [PATCH 019 of 20] knfsd: nfsd: allow auth_sys nlm on
	rpcsec_gss exports
Date: Tue, 10 Jul 2007 12:28:16 +1000
Message-ID: <1070710022816.13624@suse.de>
References: <20070710121949.12548.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J . Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I85Sc-0005D9-3i
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:28:18 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I85Sf-0001na-84
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:28:21 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: J. Bruce Fields <bfields@citi.umich.edu>

Our clients (like other clients, as far as I know) use only auth_sys for
nlm, even when using rpcsec_gss for the main nfs operations.

Administrators that want to deny non-kerberos-authenticated locking
requests will need to turn off NFS protocol versions less than 4....

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsfh.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2007-07-10 12:18:34.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2007-07-10 12:19:36.000000000 +1000
@@ -249,10 +249,16 @@ fh_verify(struct svc_rqst *rqstp, struct
 	if (error)
 		goto out;
 
-	/* Check security flavor */
-	error = check_nfsd_access(exp, rqstp);
-	if (error)
-		goto out;
+	if (!(access & MAY_LOCK)) {
+		/*
+		 * pseudoflavor restrictions are not enforced on NLM,
+		 * which clients virtually always use auth_sys for,
+		 * even while using RPCSEC_GSS for NFS.
+		 */
+		error = check_nfsd_access(exp, rqstp);
+		if (error)
+			goto out;
+	}
 
 	/* Finally, check access permissions. */
 	error = nfsd_permission(rqstp, exp, dentry, access);

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
