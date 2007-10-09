From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NLM: Fix a memory leak in nlmsvc_testlock
Date: Tue, 09 Oct 2007 11:04:57 -0400
Message-ID: <1191942297.8739.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
	Roel Kluin <12o3l@tiscali.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756017AbXJIPEa@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

The recent fix for a circular lock dependency unfortunately introduced a
potential memory leak in the event where the call to nlmsvc_lookup_host
fails for some reason.

Thanks to Roel Kluin for spotting this.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/svclock.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index d098c7a..d120ec3 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -485,8 +485,10 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 			return nlm_granted;
 		/* Create host handle for callback */
 		host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
-		if (host == NULL)
+		if (host == NULL) {
+			kfree(conf);
 			return nlm_lck_denied_nolocks;
+		}
 		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
 		if (block == NULL) {
 			kfree(conf);
