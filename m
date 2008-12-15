From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/6] nfsd: add etoosmall to nfserrno
Date: Mon, 15 Dec 2008 19:40:15 +0200
Message-ID: <1229362815-9683-1-git-send-email-bhalevy@panasas.com>
References: <49469601.7020101@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53655 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbYLORko (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2008 12:40:44 -0500
In-Reply-To: <49469601.7020101@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Dean Hildebrand <dhildeb@us.ibm.com>

Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfsproc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 5cffeca..6f7f263 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -622,6 +622,7 @@ nfserrno (int errno)
 		{ nfserr_badname, -ESRCH },
 		{ nfserr_io, -ETXTBSY },
 		{ nfserr_notsupp, -EOPNOTSUPP },
+		{ nfserr_toosmall, -ETOOSMALL },
 	};
 	int	i;
 
-- 
1.6.0.2

