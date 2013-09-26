Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:41239 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078Ab3IZSlF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:05 -0400
Received: by mail-qa0-f51.google.com with SMTP id j15so1105084qaq.10
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:03 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 17/49] DEBUG: nfsd: more client_lock asserts
Date: Thu, 26 Sep 2013 14:41:00 -0400
Message-Id: <1380220860-13461-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b80807c..68b6f7a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -168,6 +168,7 @@ static __be32 get_client_locked(struct nfs4_client *clp)
 {
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
+	lockdep_assert_held(&nn->client_lock);
 	if (is_client_expired(clp)) {
 		WARN_ON(1);
 		printk("%s: client (clientid %08x/%08x) already expired\n",
@@ -1018,6 +1019,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
 	int idx;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
+	lockdep_assert_held(&nn->client_lock);
 	dump_sessionid(__func__, sessionid);
 	idx = hash_sessionid(sessionid);
 	/* Search in the appropriate list */
-- 
1.8.3.1

