From: NeilBrown <neilb@suse.de>
Subject: [PATCH 007 of 9] knfsd: nfsd4: acls: fix inheritance
Date: Tue, 5 Sep 2006 09:15:59 +1000
Message-ID: <1060904231559.23136@suse.de>
References: <20060905090617.21303.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKNfh-0000R9-A2
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:16:05 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKNfk-0004G3-PA
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:16:09 -0700
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

We can be a little more flexible about the flags allowed for inheritance
(in particular, we can deal with either the presence or the absence of
INHERIT_ONLY), but we should probably reject other combinations that we
don't understand.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |   43 ++++++++++++++++++++++++++++++-------------
 1 file changed, 30 insertions(+), 13 deletions(-)

diff .prev/fs/nfsd/nfs4acl.c ./fs/nfsd/nfs4acl.c
--- .prev/fs/nfsd/nfs4acl.c	2006-09-04 17:20:49.000000000 +1000
+++ ./fs/nfsd/nfs4acl.c	2006-09-04 17:26:00.000000000 +1000
@@ -63,6 +63,8 @@
 #define NFS4_INHERITANCE_FLAGS (NFS4_ACE_FILE_INHERIT_ACE \
 		| NFS4_ACE_DIRECTORY_INHERIT_ACE | NFS4_ACE_INHERIT_ONLY_ACE)
 
+#define NFS4_SUPPORTED_FLAGS (NFS4_INHERITANCE_FLAGS | NFS4_ACE_IDENTIFIER_GROUP)
+
 #define MASK_EQUAL(mask1, mask2) \
 	( ((mask1) & NFS4_ACE_MASK_ALL) == ((mask2) & NFS4_ACE_MASK_ALL) )
 
@@ -721,22 +723,37 @@ nfs4_acl_split(struct nfs4_acl *acl, str
 		    ace->type != NFS4_ACE_ACCESS_DENIED_ACE_TYPE)
 			return -EINVAL;
 
-		if ((ace->flag & NFS4_INHERITANCE_FLAGS)
-				!= NFS4_INHERITANCE_FLAGS)
-			continue;
+		if (ace->flag & ~NFS4_SUPPORTED_FLAGS)
+			return -EINVAL;
 
-		error = nfs4_acl_add_ace(dacl, ace->type, ace->flag,
+		switch (ace->flag & NFS4_INHERITANCE_FLAGS) {
+		case 0:
+			/* Leave this ace in the effective acl: */
+			continue;
+		case NFS4_INHERITANCE_FLAGS:
+			/* Add this ace to the default acl and remove it
+			 * from the effective acl: */
+			error = nfs4_acl_add_ace(dacl, ace->type, ace->flag,
 				ace->access_mask, ace->whotype, ace->who);
-		if (error < 0)
-			goto out;
-
-		list_del(h);
-		kfree(ace);
-		acl->naces--;
+			if (error)
+				return error;
+			list_del(h);
+			kfree(ace);
+			acl->naces--;
+			break;
+		case NFS4_INHERITANCE_FLAGS & ~NFS4_ACE_INHERIT_ONLY_ACE:
+			/* Add this ace to the default, but leave it in
+			 * the effective acl as well: */
+			error = nfs4_acl_add_ace(dacl, ace->type, ace->flag,
+				ace->access_mask, ace->whotype, ace->who);
+			if (error)
+				return error;
+			break;
+		default:
+			return -EINVAL;
+		}
 	}
-
-out:
-	return error;
+	return 0;
 }
 
 static short

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
