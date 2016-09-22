Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33119 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965808AbcIVRjv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:39:51 -0400
Received: by mail-io0-f195.google.com with SMTP id r145so5603774ior.0
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:39:51 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 16/31] NFSv4: Ensure we don't re-test revoked and freed stateids
Date: Thu, 22 Sep 2016 13:39:06 -0400
Message-Id: <1474565961-21303-17-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-16-git-send-email-trond.myklebust@primarydata.com>
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

