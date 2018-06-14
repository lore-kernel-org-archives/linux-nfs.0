Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55058 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755360AbeFNNwC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Jun 2018 09:52:02 -0400
Date: Thu, 14 Jun 2018 09:52:01 -0400
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, kinglongmee@gmail.com
Subject: [PATCH] Reallow AUTH_NULL on v4 mounts.
Message-ID: <20180614135201.GB24594@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Kinglong Mee noted that the loop in seicnfo_addflavor (which sets the
security flavors allowed on the v4 pseudoroot) was adding flavors 1 and
0 twice; this is because flav_map ends with these entries:

	{ "unix",       AUTH_UNIX               },
        { "sys",        AUTH_SYS                },
        { "null",       AUTH_NULL               },
        { "none",       AUTH_NONE               },

where AUTH_UNIX == AUTH_SYS == 1 and AUTH_NULL == AUTH_NONE == 1.  We
need to allow two names for each of those two security flavors for
historical reasons.

The patch correctly fixed this by fixing the check for a duplicate
flavor number in secinfo_addflavor().  However it also went one step
further and rejected the flavor number 0.  This is unnecessary and
causes the kernel to fail any NFSv4 mounts using AUTH_NULL.

The fact that we've apparently gone a few years without anyone noticing
this suggests AUTH_NULL isn't used very much!  Still, this should be
fixed....

Fixes: e69eaaf93626
Cc: Kinglong Mee <kinglongmee@gmail.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/v4root.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index d735dbfe192d..c93bd4db51c8 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -69,9 +69,6 @@ set_pseudofs_security(struct exportent *pseudo, int flags)
 	for (flav = flav_map; flav < flav_map + flav_map_size; flav++) {
 		struct sec_entry *new;
 
-		if (!flav->fnum)
-			continue;
-
 		i = secinfo_addflavor(flav, pseudo);
 		new = &pseudo->e_secinfo[i];
 
-- 
2.17.1

