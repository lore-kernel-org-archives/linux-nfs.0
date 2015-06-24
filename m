Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:35757 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbbFXQKg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2015 12:10:36 -0400
Received: by ykdy1 with SMTP id y1so26369344ykd.2
        for <linux-nfs@vger.kernel.org>; Wed, 24 Jun 2015 09:10:36 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: thomas.haynes@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfs: always update creds in mirror, even when we have an already connected ds
Date: Wed, 24 Jun 2015 12:10:24 -0400
Message-Id: <1435162224-1184-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1435162224-1184-1-git-send-email-jeff.layton@primarydata.com>
References: <1435162224-1184-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A ds can be associated with more than one mirror, but we currently skip
setting a mirror's credentials if we find that it's already set up with
a connected client.

The upshot is that we can end up sending DS writes with MDS credentials
instead of properly setting them up. Fix nfs4_ff_layout_prepare_ds to
always verify that the mirror's credentials are set up, even when we
have a DS that's already connected.

Reported-by: Tom Haynes <thomas.haynes@primarydata.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index c19b9a88f748..f13e1969eedd 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -387,7 +387,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	/* matching smp_wmb() in _nfs4_pnfs_v3/4_ds_connect */
 	smp_rmb();
 	if (ds->ds_clp)
-		goto out;
+		goto out_update_creds;
 
 	flavor = nfs4_ff_layout_choose_authflavor(mirror);
 
@@ -431,7 +431,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 			}
 		}
 	}
-
+out_update_creds:
 	if (ff_layout_update_mirror_cred(mirror, ds))
 		ds = NULL;
 out:
-- 
2.4.3

