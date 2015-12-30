Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:35759 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbbL3QGO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Dec 2015 11:06:14 -0500
Received: by mail-io0-f175.google.com with SMTP id 77so44666563ioc.2
        for <linux-nfs@vger.kernel.org>; Wed, 30 Dec 2015 08:06:13 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: Fix an Oopsable typo in ff_mirror_match_fh()
Date: Wed, 30 Dec 2015 11:05:45 -0500
Message-Id: <1451491545-10885-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff reports seeing an Oops in ff_layout_alloc_lseg. Turns out
copy+paste has played cruel tricks on a nested loop.

Reported-by: Jeff Layton <jeff.layton@primarydata.com>
Cc: stable@vger.kernel.org # 4.3+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 03516c80855a..405f46ba490e 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -145,7 +145,7 @@ static bool ff_mirror_match_fh(const struct nfs4_ff_layout_mirror *m1,
 		return false;
 	for (i = 0; i < m1->fh_versions_cnt; i++) {
 		bool found_fh = false;
-		for (j = 0; j < m2->fh_versions_cnt; i++) {
+		for (j = 0; j < m2->fh_versions_cnt; j++) {
 			if (nfs_compare_fh(&m1->fh_versions[i],
 					&m2->fh_versions[j]) == 0) {
 				found_fh = true;
-- 
2.5.0

