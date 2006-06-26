From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/5] NFSv4: Ensure nfs4_lock_expired() caches
	delegated locks
Date: Mon, 26 Jun 2006 19:30:08 -0400
Message-ID: <20060626233008.6059.63173.stgit@lade.trondhjem.org>
References: <20060626232936.6059.50399.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv0Ww-0001qj-P3
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 16:30:10 -0700
Received: from dh134.citi.umich.edu ([141.211.133.134] helo=lade.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fv0Wv-0004SS-1b
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 16:30:11 -0700
To: linux-kernel@vger.kernel.org
In-Reply-To: <20060626232936.6059.50399.stgit@lade.trondhjem.org>
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b8c6375..8bdfe3f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3454,10 +3454,10 @@ static int nfs4_lock_reclaim(struct nfs4
 	struct nfs4_exception exception = { };
 	int err;
 
-	/* Cache the lock if possible... */
-	if (test_bit(NFS_DELEGATED_STATE, &state->flags))
-		return 0;
 	do {
+		/* Cache the lock if possible... */
+		if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
+			return 0;
 		err = _nfs4_do_setlk(state, F_SETLK, request, 1);
 		if (err != -NFS4ERR_DELAY)
 			break;
@@ -3476,6 +3476,8 @@ static int nfs4_lock_expired(struct nfs4
 	if (err != 0)
 		return err;
 	do {
+		if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
+			return 0;
 		err = _nfs4_do_setlk(state, F_SETLK, request, 0);
 		if (err != -NFS4ERR_DELAY)
 			break;

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
