From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [PATCH] Fix bug nfslock request sending fail will be process as blocked
Date: Fri, 12 Mar 2010 18:17:05 +0800
Message-ID: <4B9A14A1.3000008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	NFSv3 list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61075 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932238Ab0CLKP7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Mar 2010 05:15:59 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


If local reason cause nfslock request send fail(means status < 0,
resp->status not be reset), the request will be process as blocked 
at first now.

This patch initialize resp->status to nlm_lck_denied_nolocks, it 
can make the following process correctly.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/lockd/clntproc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index c81249f..a631582 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -535,7 +535,7 @@ again:
 	 * Initialise resp->status to a valid non-zero value,
 	 * since 0 == nlm_lck_granted
 	 */
-	resp->status = nlm_lck_blocked;
+	resp->status = nlm_lck_denied_nolocks;
 	for(;;) {
 		/* Reboot protection */
 		fl->fl_u.nfs_fl.state = host->h_state;
-- 
1.6.5.2


