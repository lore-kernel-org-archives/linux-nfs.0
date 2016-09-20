Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35062 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932692AbcITQ4w (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 12:56:52 -0400
Received: by mail-qk0-f193.google.com with SMTP id w204so1432716qka.2
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 09:56:52 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v6 26/29] NFSv4: Don't test open_stateid unless it is set
Date: Tue, 20 Sep 2016 12:56:08 -0400
Message-Id: <1474390571-17106-27-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474390571-17106-26-git-send-email-trond.myklebust@primarydata.com>
References: <1474390571-17106-1-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-2-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-3-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-4-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-5-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-6-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-7-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-8-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-9-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-10-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-11-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-12-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-13-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-14-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-15-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-16-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-17-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-18-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-19-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-20-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-21-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-22-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-23-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-24-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-25-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-26-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to test the NFS_OPEN_STATE flag for whether or not the
open_stateid is valid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 552bea2af811..995b646c9aea 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2587,6 +2587,11 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 	struct rpc_cred *cred = state->owner->so_cred;
 	int status;
 
+	if (test_bit(NFS_OPEN_STATE, &state->flags) == 0) {
+		if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
+			return NFS_OK;
+		return -NFS4ERR_BAD_STATEID;
+	}
 	/* If a state reset has been done, test_stateid is unneeded */
 	if ((test_bit(NFS_O_RDONLY_STATE, &state->flags) == 0) &&
 	    (test_bit(NFS_O_WRONLY_STATE, &state->flags) == 0) &&
-- 
2.7.4

