Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53127 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753583Ab0KKKAX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Nov 2010 05:00:23 -0500
Message-ID: <4CDBBF86.6080800@cn.fujitsu.com>
Date: Thu, 11 Nov 2010 18:03:50 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS4.1: server gets drc mem fail should reply error at create_session
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When server gets drc mem fail, it should reply error to client.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3876a9c..ea6466c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -745,6 +745,8 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 	 */
 	slotsize = nfsd4_sanitize_slot_size(fchan->maxresp_cached);
 	numslots = nfsd4_get_drc_mem(slotsize, fchan->maxreqs);
+	if (numslots < 1)
+		return NULL;
 
 	new = alloc_session(slotsize, numslots);
 	if (!new) {
-- 
1.7.0.1



