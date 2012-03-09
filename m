Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36577 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755146Ab2CIWOK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 17:14:10 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] nfsd4: make sure set CB_PATH_DOWN sequence flag set
Date: Fri,  9 Mar 2012 17:14:07 -0500
Message-Id: <1331331247-22343-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1331331247-22343-1-git-send-email-bfields@redhat.com>
References: <1331331247-22343-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Make sure this is set whenever there is no callback channel.

If a client does not set up a callback channel at all, then it will get
this flag set from the very start.  That's OK, it can just ignore the
flag if it doesn't care.  If a client does care, I think it's better to
inform it of the problem as early as possible.

Reported-by: Rick Macklem <rmacklem@uoguelph.ca>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 6f3ebb4..24b6bcf 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -986,7 +986,7 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 
 	err = setup_callback_client(clp, &conn, ses);
 	if (err) {
-		warn_no_callback_path(clp, err);
+		nfsd4_mark_cb_down(clp, err);
 		return;
 	}
 	/* Yay, the callback channel's back! Restart any callbacks: */
-- 
1.7.5.4

