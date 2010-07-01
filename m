Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55455 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751927Ab0GAJxz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Jul 2010 05:53:55 -0400
Message-ID: <4C2C65DE.3030602@cn.fujitsu.com>
Date: Thu, 01 Jul 2010 17:54:38 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: NFSv3 list <linux-nfs@vger.kernel.org>,
        "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@redhat.com>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [RFC][PATCH v2] NLM: Sending nfslock request fail should not be process
 as blocked
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

hi,

Sorry for sending this patch third times.

About this patch, I have discussed with Trond before. 
He said "An unlock does not guarantee that the server will cancel the blocked
lock request.", but when server receive an UNLOCK request, it will try to
cancel the lock at first, and then unlock the file.

  codes as follows:
    ...
    567 nlmsvc_unlock(struct nlm_file *file, struct nlm_lock *lock)
    568 {
    ....
    578         /* First, cancel any lock that might be there */
    579         nlmsvc_cancel_blocked(file, lock);
    ...

as before, the UNLOCK request means it contain a CANCEL request.

So, I don't know the reason in detail.

Waiting for some better analysis. Thanks.

-------------
If local reason cause nfslock request is sent fail(means status < 0,
but resp->status not be reset), the request will be process as blocked 
at the kernel.

If the network partition cause the LOCK request be sent fail, the 
kernel will processed it as being blocked right now, but sending
an UNLOCK request is needed but CANCEL request here.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>

---
 fs/lockd/clntproc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 7932c39..b79c8b1 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -536,7 +536,7 @@ again:
 	 * Initialise resp->status to a valid non-zero value,
 	 * since 0 == nlm_lck_granted
 	 */
-	resp->status = nlm_lck_blocked;
+	resp->status = nlm_lck_denied_nolocks;
 	for(;;) {
 		/* Reboot protection */
 		fl->fl_u.nfs_fl.state = host->h_state;
-- 
1.7.0



