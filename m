Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35878 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755046AbcIQFNt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:49 -0400
Received: by mail-io0-f194.google.com with SMTP id z135so2380200ioe.3
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 14/25] NFSv4: Ensure we don't re-test revoked and freed stateids
Date: Sat, 17 Sep 2016 01:13:22 -0400
Message-Id: <1474089213-104014-15-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-14-git-send-email-trond.myklebust@primarydata.com>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-2-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-3-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-4-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-5-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-6-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-7-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-8-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-9-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-10-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-11-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-12-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-13-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-14-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes a potential infinite loop in nfs_reap_expired_delegations.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index f431fde13e90..34aa5dfbe99e 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -647,6 +647,7 @@ static void nfs_mark_delegation_revoked(struct nfs_server *server,
 		struct nfs_delegation *delegation)
 {
 	set_bit(NFS_DELEGATION_REVOKED, &delegation->flags);
+	delegation->stateid.type = NFS4_INVALID_STATEID_TYPE;
 	nfs_mark_return_delegation(server, delegation);
 }
 
@@ -885,6 +886,8 @@ static inline bool nfs4_server_rebooted(const struct nfs_client *clp)
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

