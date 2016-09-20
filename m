Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33922 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753999AbcITQ4j (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 12:56:39 -0400
Received: by mail-qk0-f196.google.com with SMTP id b204so1439780qkc.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 09:56:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v6 16/29] NFSv4: Ensure we don't re-test revoked and freed stateids
Date: Tue, 20 Sep 2016 12:55:58 -0400
Message-Id: <1474390571-17106-17-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474390571-17106-16-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes a potential infinite loop in nfs_reap_expired_delegations.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 0ffead281555..484f14700108 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -656,6 +656,7 @@ static void nfs_mark_delegation_revoked(struct nfs_server *server,
 		struct nfs_delegation *delegation)
 {
 	set_bit(NFS_DELEGATION_REVOKED, &delegation->flags);
+	delegation->stateid.type = NFS4_INVALID_STATEID_TYPE;
 	nfs_mark_return_delegation(server, delegation);
 }
 
@@ -894,6 +895,8 @@ static inline bool nfs4_server_rebooted(const struct nfs_client *clp)
 static void nfs_mark_test_expired_delegation(struct nfs_server *server,
 	    struct nfs_delegation *delegation)
 {
+	if (delegation->stateid.type == NFS4_INVALID_STATEID_TYPE)
+		return;
 	clear_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags);
 	set_bit(NFS_DELEGATION_TEST_EXPIRED, &delegation->flags);
 	set_bit(NFS4CLNT_DELEGATION_EXPIRED, &server->nfs_client->cl_state);
-- 
2.7.4

