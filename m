From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 18] knfsd: nfsd4: clarify units of
	COMPOUND_SLACK_SPACE
Date: Fri, 8 Dec 2006 12:13:36 +1100
Message-ID: <1061208011336.30591@suse.de>
References: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUIl-000378-SG
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:24 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUIm-00012w-Gl
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:25 -0800
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

A comment here incorrectly states that "slack_space" is measured in words,
not bytes.  Remove the comment, and adjust a variable name and a few
comments to clarify the situation.

This is pure cleanup; there should be no change in functionality.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c        |   10 +++++-----
 ./include/linux/nfsd/nfsd.h |    4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff .prev/fs/nfsd/nfs4proc.c ./fs/nfsd/nfs4proc.c
--- .prev/fs/nfsd/nfs4proc.c	2006-12-08 12:07:28.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2006-12-08 12:08:12.000000000 +1100
@@ -740,7 +740,7 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 	struct svc_fh	*current_fh = NULL;
 	struct svc_fh	*save_fh = NULL;
 	struct nfs4_stateowner *replay_owner = NULL;
-	int		slack_space;    /* in words, not bytes! */
+	int		slack_bytes;
 	__be32		status;
 
 	status = nfserr_resource;
@@ -790,10 +790,10 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		 * failed response to the next operation.  If we don't
 		 * have enough room, fail with ERR_RESOURCE.
 		 */
-/* FIXME - is slack_space *really* words, or bytes??? - neilb */
-		slack_space = (char *)resp->end - (char *)resp->p;
-		if (slack_space < COMPOUND_SLACK_SPACE + COMPOUND_ERR_SLACK_SPACE) {
-			BUG_ON(slack_space < COMPOUND_ERR_SLACK_SPACE);
+		slack_bytes = (char *)resp->end - (char *)resp->p;
+		if (slack_bytes < COMPOUND_SLACK_SPACE
+				+ COMPOUND_ERR_SLACK_SPACE) {
+			BUG_ON(slack_bytes < COMPOUND_ERR_SLACK_SPACE);
 			op->status = nfserr_resource;
 			goto encode_op;
 		}

diff .prev/include/linux/nfsd/nfsd.h ./include/linux/nfsd/nfsd.h
--- .prev/include/linux/nfsd/nfsd.h	2006-12-08 12:07:28.000000000 +1100
+++ ./include/linux/nfsd/nfsd.h	2006-12-08 12:08:12.000000000 +1100
@@ -275,12 +275,12 @@ static inline int is_fsid(struct svc_fh 
  * we might process an operation with side effects, and be unable to
  * tell the client that the operation succeeded.
  *
- * COMPOUND_SLACK_SPACE - this is the minimum amount of buffer space
+ * COMPOUND_SLACK_SPACE - this is the minimum bytes of buffer space
  * needed to encode an "ordinary" _successful_ operation.  (GETATTR,
  * READ, READDIR, and READLINK have their own buffer checks.)  if we
  * fall below this level, we fail the next operation with NFS4ERR_RESOURCE.
  *
- * COMPOUND_ERR_SLACK_SPACE - this is the minimum amount of buffer space
+ * COMPOUND_ERR_SLACK_SPACE - this is the minimum bytes of buffer space
  * needed to encode an operation which has failed with NFS4ERR_RESOURCE.
  * care is taken to ensure that we never fall below this level for any
  * reason.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
