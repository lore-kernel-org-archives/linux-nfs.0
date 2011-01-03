Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56796 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034Ab1ACSa6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 13:30:58 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] nfsd4: don't drop requests on -ENOMEM
Date: Mon,  3 Jan 2011 13:30:50 -0500
Message-Id: <1294079454-17891-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1294079454-17891-1-git-send-email-bfields@redhat.com>
References: <1294079454-17891-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We never want to drop a request if we could return a JUKEBOX/DELAY error
instead; so, convert to nfserr_jukebox and let nfsd_dispatch() convert
that to a dropit error as a last resort if JUKEBOX/DELAY is unavailable
(as in the NFSv2 case).

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsproc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 08e1726..dc9c2e3 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -736,7 +736,7 @@ nfserrno (int errno)
 		{ nfserr_jukebox, -ETIMEDOUT },
 		{ nfserr_jukebox, -ERESTARTSYS },
 		{ nfserr_dropit, -EAGAIN },
-		{ nfserr_dropit, -ENOMEM },
+		{ nfserr_jukebox, -ENOMEM },
 		{ nfserr_badname, -ESRCH },
 		{ nfserr_io, -ETXTBSY },
 		{ nfserr_notsupp, -EOPNOTSUPP },
-- 
1.7.1

