Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57393 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751632Ab2DXFrr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 01:47:47 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Date: Tue, 24 Apr 2012 15:46:38 +1000
Subject: [PATCH 1/6] lookup_export: really prefer nonV4ROOT exports.
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Message-ID: <20120424054638.20130.13975.stgit@notabene.brown>
In-Reply-To: <20120424054003.20130.16209.stgit@notabene.brown>
References: <20120424054003.20130.16209.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lookup_export() claims to "Always prefer non-V4ROOT mounts" (meaning
"exports") but actually prefers V4ROOT exports - once it has 'found'
one it will never replace it.

So fix that inversion, and add code so that it proactively prefers a
non-V4ROOT whether it is found before or after a V4ROOT.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 utils/mountd/cache.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ac9cdbd..b01c0bd 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -772,10 +772,14 @@ lookup_export(char *dom, char *path, struct addrinfo *ai)
 				found_type = i;
 				continue;
 			}
-
-			/* Always prefer non-V4ROOT mounts */
-			if (found->m_export.e_flags & NFSEXP_V4ROOT)
+			/* Always prefer non-V4ROOT exports */
+			if (exp->m_export.e_flags & NFSEXP_V4ROOT)
 				continue;
+			if (found->m_export.e_flags & NFSEXP_V4ROOT) {
+				found = exp;
+				found_type = i;
+				continue;
+			}
 
 			/* If one is a CROSSMOUNT, then prefer the longest path */
 			if (((found->m_export.e_flags & NFSEXP_CROSSMOUNT) ||


