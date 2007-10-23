From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH]NFS: Fix for bug in handling of errors for O_DIRECT writes
Date: Tue, 23 Oct 2007 17:09:13 -0400
Message-ID: <1193173753.20475.54.camel@heimdal.trondhjem.org>
References: <20071023123636.6732.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, Neil Brown <neilb@suse.de>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753322AbXJWVIf@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Neil Brown <neilb@suse.de>

commit eda3cef8dd2b838 ensured that if a WRITE returns an error, then
data->res.verf->committed is not tested (as it is not initialised).

commit 60fa3f769f inadvertently reverted this while fixing other problems.

So move the test so that we never examine ->committed in an error
case, and fix a speeling error while we are there.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Neil Brown <neilb@suse.de>
Acked-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
Note: only compile tested - I haven't tried triggering the bug yet.

NeilBrown

### Diffstat output
 ./fs/nfs/direct.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff .prev/fs/nfs/direct.c ./fs/nfs/direct.c
--- .prev/fs/nfs/direct.c	2007-10-23 12:31:29.000000000 +1000
+++ ./fs/nfs/direct.c	2007-10-23 12:32:07.000000000 +1000
@@ -549,13 +549,13 @@ static void nfs_direct_write_result(stru
 
 	spin_lock(&dreq->lock);
 
-	if (unlikely(dreq->error != 0))
-		goto out_unlock;
 	if (unlikely(status < 0)) {
-		/* An error has occured, so we should not commit */
+		/* An error has occurred, so we should not commit */
 		dreq->flags = 0;
 		dreq->error = status;
 	}
+	if (unlikely(dreq->error != 0))
+		goto out_unlock;
 
 	dreq->count += data->res.count;
 
