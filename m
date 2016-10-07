Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33200 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753229AbcJGTBa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Oct 2016 15:01:30 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd: handle EUCLEAN
Date: Fri,  7 Oct 2016 15:01:27 -0400
Message-Id: <1475866887-26734-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1475866887-26734-1-git-send-email-bfields@redhat.com>
References: <1475866887-26734-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Eric Sandeen reports that xfs can return this if filesystem corruption
prevented completing the operation.

Reported-by: Eric Sandeen <sandeen@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsproc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index a56ee10204d9..78cd77042a25 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -791,6 +791,7 @@ nfserrno (int errno)
 		{ nfserr_toosmall, -ETOOSMALL },
 		{ nfserr_serverfault, -ESERVERFAULT },
 		{ nfserr_serverfault, -ENFILE },
+		{ nfserr_io, -EUCLEAN },
 	};
 	int	i;
 
-- 
2.7.4

