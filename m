From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] knfsd: set the response bitmask for
 NFS4_CREATE_EXCLUSIVE (repost)
Date: Wed, 27 Jun 2007 21:30:47 -0400
Message-ID: <20070627213047.1ecf1c09.jlayton@redhat.com>
References: <20070627092903.82f468cd.jlayton@redhat.com>
	<18050.54805.859007.848292@notabene.brown>
	<20070627212805.GA6267@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfsv4@linux-nfs.org,
	nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3iqO-00040b-UZ
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 18:30:51 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3iqS-00065i-4n
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 18:30:52 -0700
In-Reply-To: <20070627212805.GA6267@fieldses.org>
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

Here's a respun patch that includes an updated comment in nfsd_create_v3.
Look ok?

------------[snip]-----------

RFC 3530 says:

 If the server uses an attribute to store the exclusive
 create verifier, it will signify which attribute by setting the
 appropriate bit in the attribute mask that is returned in the
 results.

Linux uses the atime and mtime to store the verifier, but sends a zeroed
out bitmask back to the client. This patch makes sure that we set the
correct bits in the bitmask in this situation.

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
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7e6aa24..339b9d0 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1284,7 +1284,10 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	if (createmode == NFS3_CREATE_EXCLUSIVE) {
 		/* solaris7 gets confused (bugid 4218508) if these have
-		 * the high bit set, so just clear the high bits.
+		 * the high bit set, so just clear the high bits. If this is
+		 * ever changed to use different attrs for storing the
+		 * verifier, then do_open_lookup() will also need to be fixed
+		 * accordingly.
 		 */
 		v_mtime = verifier[0]&0x7fffffff;
 		v_atime = verifier[1]&0x7fffffff;

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
