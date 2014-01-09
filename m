Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f52.google.com ([209.85.220.52]:47680 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbaAIKbx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 05:31:53 -0500
Received: by mail-pa0-f52.google.com with SMTP id ld10so3152661pab.39
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jan 2014 02:31:53 -0800 (PST)
Message-ID: <52CE7A94.2060105@gmail.com>
Date: Thu, 09 Jan 2014 18:31:48 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Dr Fields James Bruce <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/5] NFSD: Using free_conn free connection
References: <52CA7862.1020203@gmail.com> <20140106184926.GC31764@fieldses.org> <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com> <20140106225346.GB3342@fieldses.org> <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com> <52CB8B79.6040907@gmail.com> <52CE7A76.3080101@gmail.com>
In-Reply-To: <52CE7A76.3080101@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Connection from alloc_conn must be freed through free_conn,
otherwise, the reference of svc_xprt will never be put. 

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7d613a7..f89f1f8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2282,7 +2282,8 @@ out:
 	if (!list_empty(&clp->cl_revoked))
 		seq->status_flags |= SEQ4_STATUS_RECALLABLE_STATE_REVOKED;
 out_no_session:
-	kfree(conn);
+	if (conn)
+		free_conn(conn);
 	spin_unlock(&nn->client_lock);
 	return status;
 out_put_session:
-- 
1.8.4.2
