Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:63956 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220AbaDRSpu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:50 -0400
Received: by mail-ig0-f178.google.com with SMTP id hn18so943946igb.5
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 29/70] NFSd: Add a struct nfs4_file field to struct nfs4_stid
Date: Fri, 18 Apr 2014 14:44:23 -0400
Message-Id: <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All stateids are associated with a nfs4_file. Let's consolidate...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 ++
 fs/nfsd/state.h     | 1 +
 2 files changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 32ab3f1c83f8..5bbef4720e7c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -474,6 +474,8 @@ static void remove_stid(struct nfs4_stid *s)
 
 static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 {
+	if (s->sc_file)
+		put_nfs4_file(s->sc_file);
 	kmem_cache_free(slab, s);
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 9d0088c244a8..c6deef936693 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -85,6 +85,7 @@ struct nfs4_stid {
 	unsigned char sc_type;
 	stateid_t sc_stateid;
 	struct nfs4_client *sc_client;
+	struct nfs4_file *sc_file;
 };
 
 struct nfs4_delegation {
-- 
1.9.0

