Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56017 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753583Ab0KKKAT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Nov 2010 05:00:19 -0500
Message-ID: <4CDBBF7C.90108@cn.fujitsu.com>
Date: Thu, 11 Nov 2010 18:03:40 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS4.1: Fix bug server don't reply the right fore_channel
 to client at create_session
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

At the latest kernel(2.6.37-rc1), server just initialize the forechannel
at init_forechannel_attrs, but don't reflect it to reply.

After initialize the session success, we should copy the forechannel info
to nfsd4_create_session struct.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f1e5ec6..3876a9c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1556,6 +1556,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	status = nfs_ok;
 	memcpy(cr_ses->sessionid.data, new->se_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
+	memcpy(&cr_ses->fore_channel, &new->se_fchannel,
+		sizeof(struct nfsd4_channel_attrs));
 	cs_slot->sl_seqid++;
 	cr_ses->seqid = cs_slot->sl_seqid;
 
-- 
1.7.0.1


