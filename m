Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0024.hostedemail.com ([216.40.44.24]:45758 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753362AbbC3Xx6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 19:53:58 -0400
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by smtpgrave04.hostedemail.com (Postfix) with ESMTP id 182BEB1DC0
	for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2015 23:47:45 +0000 (UTC)
From: Joe Perches <joe@perches.com>
To: linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 15/25] nfsd: nfs4state: Use bool function return values of true/false not 1/0
Date: Mon, 30 Mar 2015 16:46:13 -0700
Message-Id: <e4691019bb72de53b949ea8784da676c95478b55.1427759009.git.joe@perches.com>
In-Reply-To: <cover.1427759009.git.joe@perches.com>
References: <cover.1427759009.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the normal return values for bool functions

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 26e9baa..fbb8dcb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2603,7 +2603,7 @@ out_no_session:
 static bool nfsd4_compound_in_session(struct nfsd4_session *session, struct nfs4_sessionid *sid)
 {
 	if (!session)
-		return 0;
+		return false;
 	return !memcmp(sid, &session->se_sessionid, sizeof(*sid));
 }
 
-- 
2.1.2

