Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:62252 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbaD3Tj2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2014 15:39:28 -0400
Received: by mail-qc0-f179.google.com with SMTP id l6so2403907qcy.24
        for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2014 12:39:27 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Jeff Law <law@redhat.com>,
        Jakub Jelinek <jakub@redhat.com>
Subject: [PATCH] mountd: fix segfault in add_name with newer gcc compilers
Date: Wed, 30 Apr 2014 15:39:19 -0400
Message-Id: <1398886759-29090-1-git-send-email-jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I hit a segfault in add_name with a mountd built with gcc-4.9.0. Some
NULL pointer checks got reordered such that a pointer was dereferenced
before checking to see whether it was NULL. The problem was due to
nfs-utils relying on undefined behavior, which tricked gcc into assuming
that the pointer would never be NULL.

At first I assumed that this was a compiler bug, but Jakub Jelinek and
Jeff Law pointed out:

"If old is NULL, then:

	strncpy(new, old, cp-old);

is undefined behavior (even when cp == old == NULL in that case),
therefore gcc assumes that old is never NULL, as otherwise it would be
invalid.

Just guard
	strncpy(new, old, cp-old);
	new[cp-old] = 0;
with if (old) { ... }."

This patch does that. If old is NULL though, then we still need to
ensure that new is NULL terminated, lest the subsequent strcats walk off
the end of it.

Cc: Jeff Law <law@redhat.com>
Cc: Jakub Jelinek <jakub@redhat.com>
Signed-off-by: Jeff Layton <jlayton@poochiereds.net>
---
 support/export/client.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index dbf47b966522..f85e11c8b535 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -482,8 +482,12 @@ add_name(char *old, const char *add)
 		else
 			cp = cp + strlen(cp);
 	}
-	strncpy(new, old, cp-old);
-	new[cp-old] = 0;
+	if (old) {
+		strncpy(new, old, cp-old);
+		new[cp-old] = 0;
+	} else {
+		new[0] = 0;
+	}
 	if (cp != old && !*cp)
 		strcat(new, ",");
 	strcat(new, add);
-- 
1.9.0

