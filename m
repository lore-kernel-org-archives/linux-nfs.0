Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45538 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085Ab1JTCNN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Oct 2011 22:13:13 -0400
Received: by ywf7 with SMTP id 7so2323875ywf.19
        for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 19:13:12 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 3/7] nfsd4: seq->status_flags may be used unitialized
Date: Wed, 19 Oct 2011 19:13:06 -0700
Message-Id: <1319076786-13391-1-git-send-email-benny@tonian.com>
In-Reply-To: <4E9F82FC.2000904@tonian.com>
References: <4E9F82FC.2000904@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Reported-by: Gopala Suryanarayana <gsuryanarayana@vmware.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4state.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ccdb9b2..ec361bb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1931,11 +1931,13 @@ static bool nfsd4_request_too_big(struct svc_rqst *rqstp,
 		atomic_inc(&clp->cl_refcount);
 		switch (clp->cl_cb_state) {
 		case NFSD4_CB_DOWN:
-			seq->status_flags |= SEQ4_STATUS_CB_PATH_DOWN;
+			seq->status_flags = SEQ4_STATUS_CB_PATH_DOWN;
 			break;
 		case NFSD4_CB_FAULT:
-			seq->status_flags |= SEQ4_STATUS_BACKCHANNEL_FAULT;
+			seq->status_flags = SEQ4_STATUS_BACKCHANNEL_FAULT;
 			break;
+		default:
+			seq->status_flags = 0;
 		}
 	}
 	kfree(conn);
-- 
1.7.6

