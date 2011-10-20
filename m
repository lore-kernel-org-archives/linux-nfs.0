Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38534 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755320Ab1JTCNl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Oct 2011 22:13:41 -0400
Received: by gyb13 with SMTP id 13so2302978gyb.19
        for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 19:13:40 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 7/7] nfsd4: share_access_to_flags should consider only nfs4.x share_access flags
Date: Wed, 19 Oct 2011 19:13:37 -0700
Message-Id: <1319076817-13550-1-git-send-email-benny@tonian.com>
In-Reply-To: <4E9F82FC.2000904@tonian.com>
References: <4E9F82FC.2000904@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Currently, it will not correctl ignore and nfsv4.1 signal flags if the client
sends them.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5c3377c..a687e1a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2555,7 +2555,7 @@ static __be32 nfsd4_check_seqid(struct nfsd4_compound_state *cstate, struct nfs4
 
 static int share_access_to_flags(u32 share_access)
 {
-	share_access &= ~NFS4_SHARE_WANT_MASK;
+	share_access &= NFS4_SHARE_ACCESS_MASK;
 
 	return share_access == NFS4_SHARE_ACCESS_READ ? RD_STATE : WR_STATE;
 }
-- 
1.7.6

