Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45905 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab2BPS5F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 13:57:05 -0500
Received: by eekc14 with SMTP id c14so1017523eek.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 10:57:04 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] nfsd41: share_access_to_flags should consider only nfs4.x share_access flags
Date: Thu, 16 Feb 2012 20:57:00 +0200
Message-Id: <1329418620-23850-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4F3D4F1F.6080502@tonian.com>
References: <4F3D4F1F.6080502@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, it will not correctly ignore any nfsv4.1 signal flags
if the client sends them.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e8c98f0..a6cdbd5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2633,7 +2633,7 @@ static __be32 nfsd4_check_seqid(struct nfsd4_compound_state *cstate, struct nfs4
 
 static int share_access_to_flags(u32 share_access)
 {
-	share_access &= ~NFS4_SHARE_WANT_MASK;
+	share_access &= NFS4_SHARE_ACCESS_MASK;
 
 	return share_access == NFS4_SHARE_ACCESS_READ ? RD_STATE : WR_STATE;
 }
-- 
1.7.6.5

