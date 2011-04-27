Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21819 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759806Ab1D0TrX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2011 15:47:23 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 2/3] NFSD: Check status from nfsd4_map_bcts_dir()
Date: Wed, 27 Apr 2011 15:47:15 -0400
Message-Id: <1303933636-22134-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1303933636-22134-1-git-send-email-bjschuma@netapp.com>
References: <1303933636-22134-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

Compiling gave me this warning:
fs/nfsd/nfs4state.c: In function ‘nfsd4_bind_conn_to_session’:
fs/nfsd/nfs4state.c:1623:9: warning: variable ‘status’ set but not used
[-Wunused-but-set-variable]

The local variable "status" was being set by nfsd4_map_bcts_dir() and
then ignored before calling nfsd4_new_conn().

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4state.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4cf04e1..e00061a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1637,8 +1637,9 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 		return nfserr_badsession;
 
 	status = nfsd4_map_bcts_dir(&bcts->dir);
-	nfsd4_new_conn(rqstp, cstate->session, bcts->dir);
-	return nfs_ok;
+	if (!status)
+		nfsd4_new_conn(rqstp, cstate->session, bcts->dir);
+	return status;
 }
 
 static bool nfsd4_compound_in_session(struct nfsd4_session *session, struct nfs4_sessionid *sid)
-- 
1.7.4.4

