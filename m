Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57403 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674Ab2DXFsD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 01:48:03 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Date: Tue, 24 Apr 2012 15:46:38 +1000
Subject: [PATCH 3/6] nfsd_fh: if two exports are possible,
 choose the one without V4ROOT
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Message-ID: <20120424054638.20130.88078.stgit@notabene.brown>
In-Reply-To: <20120424054003.20130.16209.stgit@notabene.brown>
References: <20120424054003.20130.16209.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When nfsd_fh it looking for an export for a particular
client and file-handle, it might find two exports for the same path:
one with NFSEXP_V4ROOT, one with out.

As nfsd_fh calls cache_export_ent to give the export information to
the kernel it much choose the same export that auth_authenticate
chooses for get_rootfh which it also passes cache_export_ent (via
cache_export).
i.e. it must choose the non-V4ROOT on where possible.

Also change
   strcmp(foo, bar)
to
   strcmp(foo, bar) == 0
because I have a pathological fear of the former.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 utils/mountd/cache.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index b01c0bd..0af6404 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -596,11 +596,20 @@ static void nfsd_fh(FILE *f)
 				found_path = strdup(path);
 				if (found_path == NULL)
 					goto out;
-			} else if (strcmp(found->e_path, exp->m_export.e_path)
+			} else if (strcmp(found->e_path, exp->m_export.e_path) != 0
 				   && !subexport(found, &exp->m_export))
 			{
 				xlog(L_WARNING, "%s and %s have same filehandle for %s, using first",
 				     found_path, path, dom);
+			} else {
+				/* same path, if one is V4ROOT, choose the other */
+				if (found->e_flags & NFSEXP_V4ROOT) {
+					found = &exp->m_export;
+					free(found_path);
+					found_path = strdup(path);
+					if (found_path == NULL)
+						goto out;
+				}
 			}
 		}
 	}


