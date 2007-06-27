From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] knfsd: set the response bitmask for
 NFS4_CREATE_EXCLUSIVE (repost)
Date: Wed, 27 Jun 2007 09:29:03 -0400
Message-ID: <20070627092903.82f468cd.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3XZv-0002hm-O1
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 06:29:03 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3XZy-0006bo-Qx
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 06:29:07 -0700
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

Haven't seen any comments on this patch so far. Neil, any thoughts?

--------------[snip]--------------

RFC 3530 says:

 If the server uses an attribute to store the exclusive
 create verifier, it will signify which attribute by setting the
 appropriate bit in the attribute mask that is returned in the
 results.

Linux uses the atime and mtime to store the verifier, but sends a zeroed out
bitmask back to the client. This patch makes sure that we set the correct
bits in the bitmask in this situation.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8522729..da20674 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -99,7 +99,15 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 		status = nfsd_create_v3(rqstp, current_fh, open->op_fname.data,
 					open->op_fname.len, &open->op_iattr,
 					&resfh, open->op_createmode,
-					(u32 *)open->op_verf.data, &open->op_truncate, &created);
+					(u32 *)open->op_verf.data,
+					&open->op_truncate, &created);
+
+		/* If we ever decide to use different attrs to store the
+		 * verifier in nfsd_create_v3, then we'll need to change this
+		 */
+		if (open->op_createmode == NFS4_CREATE_EXCLUSIVE && status == 0)
+			open->op_bmval[1] |= (FATTR4_WORD1_TIME_ACCESS |
+						FATTR4_WORD1_TIME_MODIFY);
 	} else {
 		status = nfsd_lookup(rqstp, current_fh,
 				     open->op_fname.data, open->op_fname.len, &resfh);

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
