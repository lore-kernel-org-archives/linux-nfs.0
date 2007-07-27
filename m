From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] knfsd: set the response bitmask for
	NFS4_CREATE_EXCLUSIVE
Date: Fri, 27 Jul 2007 17:17:58 -0400
Message-ID: <45932.1735929281$1185571105@news.gmane.org>
References: <11855710801310-git-send-email->
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEXCD-0006BS-LZ
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 14:18:06 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEXCF-0004jC-22
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 14:18:05 -0700
In-Reply-To: <11855710801310-git-send-email->
Message-Id: <3870106f1229e5c62ef479ec85cc9ca21b81d090.1185570967.git.bfields@citi.umich.edu>
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

From: Jeff Layton <jlayton@redhat.com>

RFC 3530 says:

 If the server uses an attribute to store the exclusive
 create verifier, it will signify which attribute by setting the
 appropriate bit in the attribute mask that is returned in the
 results.

Linux uses the atime and mtime to store the verifier, but sends a zeroed
out bitmask back to the client. This patch makes sure that we set the
correct bits in the bitmask in this situation.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4proc.c |   10 +++++++++-
 fs/nfsd/vfs.c      |    5 ++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3c62712..29b7e63 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -100,7 +100,15 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
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
index ee96a89..a0c2b25 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1309,7 +1309,10 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
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
-- 
1.5.3.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
