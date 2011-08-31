Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43847 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755244Ab1HaVpf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Aug 2011 17:45:35 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1QysbH-0005P8-DP
	for linux-nfs@vger.kernel.org; Wed, 31 Aug 2011 17:45:35 -0400
Date: Wed, 31 Aug 2011 17:45:35 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: remove typoed replay field
Message-ID: <20110831214535.GI19223@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Wow, I wonder how long that typo's been there.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/state.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

Queuing for 3.2.

diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f02badd..6b706a6 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -312,7 +312,6 @@ struct nfs4_replay {
 	__be32			rp_status;
 	unsigned int		rp_buflen;
 	char			*rp_buf;
-	unsigned		intrp_allocated;
 	struct knfsd_fh		rp_openfh;
 	char			rp_ibuf[NFSD4_REPLAY_ISIZE];
 };
-- 
1.7.4.1

