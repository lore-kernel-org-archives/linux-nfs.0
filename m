Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56801 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752868Ab1ACSbA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 13:31:00 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] nfsd: stop translating EAGAIN to nfserr_dropit
Date: Mon,  3 Jan 2011 13:30:53 -0500
Message-Id: <1294079454-17891-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1294079454-17891-1-git-send-email-bfields@redhat.com>
References: <1294079454-17891-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We no longer need this.

Also, EWOULDBLOCK is generally a synonym for EAGAIN, but that may not be
true on all architectures, so map it as well.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsproc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index dc9c2e3..fd608a2 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -735,7 +735,8 @@ nfserrno (int errno)
 		{ nfserr_stale, -ESTALE },
 		{ nfserr_jukebox, -ETIMEDOUT },
 		{ nfserr_jukebox, -ERESTARTSYS },
-		{ nfserr_dropit, -EAGAIN },
+		{ nfserr_jukebox, -EAGAIN },
+		{ nfserr_jukebox, -EWOULDBLOCK },
 		{ nfserr_jukebox, -ENOMEM },
 		{ nfserr_badname, -ESRCH },
 		{ nfserr_io, -ETXTBSY },
-- 
1.7.1

