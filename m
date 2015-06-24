Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:36507 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882AbbFXQKf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2015 12:10:35 -0400
Received: by ykdr198 with SMTP id r198so26370180ykd.3
        for <linux-nfs@vger.kernel.org>; Wed, 24 Jun 2015 09:10:34 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: thomas.haynes@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfs: fix potential credential leak in ff_layout_update_mirror_cred
Date: Wed, 24 Jun 2015 12:10:23 -0400
Message-Id: <1435162224-1184-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1435162224-1184-1-git-send-email-jeff.layton@primarydata.com>
References: <1435162224-1184-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we have two tasks racing to update a mirror's credentials, then they
can end up leaking one (or more) sets of credentials. The first task
will set mirror->cred and then the second task will just overwrite it.

Use a cmpxchg to ensure that the creds are only set once. If we get to
the point where we would set mirror->cred and find that they're already
set, then we just release the creds that were just found.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 77a2d026aa12..c19b9a88f748 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -324,7 +324,8 @@ static int ff_layout_update_mirror_cred(struct nfs4_ff_layout_mirror *mirror,
 				__func__, PTR_ERR(cred));
 			return PTR_ERR(cred);
 		} else {
-			mirror->cred = cred;
+			if (cmpxchg(&mirror->cred, NULL, cred))
+				put_rpccred(cred);
 		}
 	}
 	return 0;
-- 
2.4.3

