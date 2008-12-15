From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 4/6] nfsd: delete wrong file comment from nfsd/nfs4xdr.c
Date: Mon, 15 Dec 2008 19:41:31 +0200
Message-ID: <1229362891-9803-1-git-send-email-bhalevy@panasas.com>
References: <49469601.7020101@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Marc Eshel <eshel@almaden.ibm.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53671 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754862AbYLORly (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2008 12:41:54 -0500
In-Reply-To: <49469601.7020101@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index afcdf4b..f65953b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1,6 +1,4 @@
 /*
- *  fs/nfs/nfs4xdr.c
- *
  *  Server-side XDR for NFSv4
  *
  *  Copyright (c) 2002 The Regents of the University of Michigan.
-- 
1.6.0.2

