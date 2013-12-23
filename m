Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:42433 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504Ab3LWJb0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Dec 2013 04:31:26 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so3242371pab.37
        for <linux-nfs@vger.kernel.org>; Mon, 23 Dec 2013 01:31:26 -0800 (PST)
Message-ID: <52B802E9.4070607@gmail.com>
Date: Mon, 23 Dec 2013 17:31:21 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSD: fix a bug which causing nfsd deny CREATE_SESSION
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

check_forechannel_attrs have get drc memory, 
nfsd must put it when check_backchannel_attrs failed.

After many requests with bad back channel attrs, 
nfsd will deny any client's CREATE_SESSION forever.

A new test case named CSESS29 for pynfs will send in another mail.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 105d6fa..4e2c9ba 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1913,7 +1913,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		return status;
 	status = check_backchannel_attrs(&cr_ses->back_channel);
 	if (status)
-		return status;
+		goto out_release_drc_mem;
 	status = nfserr_jukebox;
 	new = alloc_session(&cr_ses->fore_channel);
 	if (!new)
-- 
1.8.4.2
