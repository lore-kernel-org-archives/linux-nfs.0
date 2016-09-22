Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36137 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934960AbcIVRkL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:40:11 -0400
Received: by mail-it0-f67.google.com with SMTP id n143so5337103ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:40:11 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 29/31] NFSv4: Fix retry issues with nfs41_test/free_stateid
Date: Thu, 22 Sep 2016 13:39:19 -0400
Message-Id: <1474565961-21303-30-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-29-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-15-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-16-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-17-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-18-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-19-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-20-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-21-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-22-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-23-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-24-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-25-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-26-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-27-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-28-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-29-git-send-email-trond.myklebust@primarydata.com>
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

