Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60171 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932231Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 12/25] nfsd4: split out some free_generic_stateid code
Date: Wed, 14 Sep 2011 07:45:08 -0400
Message-Id: <1316000721-3289-13-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We'll use this elsewhere.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 567130d..c28432a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -411,7 +411,7 @@ static void unhash_generic_stateid(struct nfs4_stateid *stp)
 	list_del(&stp->st_perstateowner);
 }
 
-static void free_generic_stateid(struct nfs4_stateid *stp)
+static void close_generic_stateid(struct nfs4_stateid *stp)
 {
 	int i;
 
@@ -420,9 +420,16 @@ static void free_generic_stateid(struct nfs4_stateid *stp)
 			if (test_bit(i, &stp->st_access_bmap))
 				nfs4_file_put_access(stp->st_file,
 						nfs4_access_to_omode(i));
+			__clear_bit(i, &stp->st_access_bmap);
 		}
 	}
 	put_nfs4_file(stp->st_file);
+	stp->st_file = NULL;
+}
+
+static void free_generic_stateid(struct nfs4_stateid *stp)
+{
+	close_generic_stateid(stp);
 	kmem_cache_free(stateid_slab, stp);
 }
 
-- 
1.7.4.1

