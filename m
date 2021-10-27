Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB085C433EF
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Oct 2021 02:23:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D0ED760D42
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Oct 2021 02:23:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234446AbhJ0CZw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Oct 2021 22:25:52 -0400
Received: from mail.kernel.org ([198.145.29.99]:55598 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S233224AbhJ0CZw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Oct 2021 22:25:52 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 582976023F
        for <linux-nfs@vger.kernel.org>; Wed, 27 Oct 2021 02:23:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1635301407;
        bh=I57E4xwAH+YHfUM/5xdtEvjz9DkMaQIDdLO70onULnc=;
        h=From:To:Subject:Date:From;
        b=SBJCT0zWMWJMOV5JK7b9utc93GppS8xLSYOSBYIMIhXuz7FKZ3DIQjjfeeyYux3cB
         jTIsQN9lm/nXHnkkG95CY1ana5mAcO6pRXbaVNieUjB0HbFlzWzzYMKyFFo0lEgAHg
         uc0IY2lcRYQKBzKz7Q5/SruZKVq6LRojRuJpAq1GUANB+B/XWlnk4vlvMKvhzkKlSX
         o2qGnFyA7hfH34DeNaOm2jjJSQ3wuTvv1yI/F4fFGq3yJ2EWs/b4dbEn3SbikvaVIa
         h5RLMIIfZzzGXNNdiwDLhHuhpZzD4I6Z/NX/Z+87uQmVLOjfJLxDbsl9W0mZLU7NSY
         hvKzHmsoJLEzg==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix a regression in nfs_set_open_stateid_locked()
Date:   Tue, 26 Oct 2021 22:17:21 -0400
Message-Id: <20211027021721.58935-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.31.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

If we already hold open state on the client, yet the server gives us a
completely different stateid to the one we already hold, then we
currently treat it as if it were an out-of-sequence update, and wait for
5 seconds for other updates to come in.
This commit fixes the behaviour so that we immediately start processing
of the new stateid, and then leave it to the call to
nfs4_test_and_free_stateid() to decide what to do with the old stateid.

Fixes: b4868b44c562 ("NFSv4: Wait for stateid updates after CLOSE/OPEN_DOWNGRADE")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1c485edf1d07..1c94f54cab58 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1604,15 +1604,16 @@ static bool nfs_stateid_is_sequential(struct nfs4_state *state,
 {
 	if (test_bit(NFS_OPEN_STATE, &state->flags)) {
 		/* The common case - we're updating to a new sequence number */
-		if (nfs4_stateid_match_other(stateid, &state->open_stateid) &&
-			nfs4_stateid_is_next(&state->open_stateid, stateid)) {
-			return true;
+		if (nfs4_stateid_match_other(stateid, &state->open_stateid)) {
+			if (nfs4_stateid_is_next(&state->open_stateid, stateid))
+				return true;
+			return false;
 		}
-	} else {
-		/* This is the first OPEN in this generation */
-		if (stateid->seqid == cpu_to_be32(1))
-			return true;
+		/* The server returned a new stateid */
 	}
+	/* This is the first OPEN in this generation */
+	if (stateid->seqid == cpu_to_be32(1))
+		return true;
 	return false;
 }
 
-- 
2.31.1

