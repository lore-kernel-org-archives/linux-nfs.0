Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36122 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933063AbcITQ45 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 12:56:57 -0400
Received: by mail-qk0-f195.google.com with SMTP id z143so1432949qka.3
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 09:56:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v6 29/29] NFSv4: Fix retry issues with nfs41_test/free_stateid
Date: Tue, 20 Sep 2016 12:56:11 -0400
Message-Id: <1474390571-17106-30-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474390571-17106-29-git-send-email-trond.myklebust@primarydata.com>
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
 <1474390571-17106-27-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-28-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-29-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

_nfs41_free_stateid() needs to be cached by the session, but
nfs41_test_stateid() may return NFS4ERR_RETRY_UNCACHED_REP (in which
case we should just retry).

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2e1f9c30b805..72858f900abf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8730,6 +8730,7 @@ static void nfs4_handle_delay_or_session_error(struct nfs_server *server,
 	exception->retry = 0;
 	switch(err) {
 	case -NFS4ERR_DELAY:
+	case -NFS4ERR_RETRY_UNCACHED_REP:
 		nfs4_handle_exception(server, err, exception);
 		break;
 	case -NFS4ERR_BADSESSION:
@@ -8835,7 +8836,7 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 
 	msg.rpc_argp = &data->args;
 	msg.rpc_resp = &data->res;
-	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 	if (privileged)
 		nfs4_set_sequence_privileged(&data->args.seq_args);
 
-- 
2.7.4

