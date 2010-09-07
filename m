Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52424 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755645Ab0IGXev (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 19:34:51 -0400
Date: Tue, 7 Sep 2010 19:34:01 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: nfsd bugfix for 2.6.36
Message-ID: <20100907233401.GE24707@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I have one bugfix for 2.6.36; please pull

  git://linux-nfs.org/~bfields/linux.git for-2.6.36

to get it.  Thanks!

--b.

>From 8f34a430ac16d5fbd9d6b383184d35e152f5a963 Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@redhat.com>
Date: Thu, 2 Sep 2010 15:23:16 -0400
Subject: [PATCH] nfsd4: mask out non-access bits in nfs4_access_to_omode

This fixes an unnecessary BUG().

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3dfef06..cf0d2ff 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -440,7 +440,7 @@ test_share(struct nfs4_stateid *stp, struct nfsd4_open *open) {
 
 static int nfs4_access_to_omode(u32 access)
 {
-	switch (access) {
+	switch (access & NFS4_SHARE_ACCESS_BOTH) {
 	case NFS4_SHARE_ACCESS_READ:
 		return O_RDONLY;
 	case NFS4_SHARE_ACCESS_WRITE:
-- 
1.7.0.4

