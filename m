Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57407 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674Ab2DXFsL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 01:48:11 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Date: Tue, 24 Apr 2012 15:46:38 +1000
Subject: [PATCH 4/6] v4set_root: force "fsid=0" for all exports of '/'
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Message-ID: <20120424054638.20130.5981.stgit@notabene.brown>
In-Reply-To: <20120424054003.20130.16209.stgit@notabene.brown>
References: <20120424054003.20130.16209.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When "fsid=0" is not explicitly given in /etc/exports,
v4set_root creates a pseudo (NFSEXP_V4ROOT) export for '/'
with fsid 0 so that an NFSv4 client can find the root.

However if '/' is explicitly exported to the client, then that
explicit export must be used, and it will not have fsid=0.
So we must impose fsid=0 on all exports of '/'.
Without this, if '/' is exported to a client, that client will
not be able to mount '/' with NFSv4.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 utils/mountd/v4root.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index 81f813b..b4fdcce 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -192,6 +192,13 @@ v4root_set()
 				 */
 				continue;
 
+			if (strcmp(exp->m_export.e_path, "/") == 0 &&
+			    !(exp->m_export.e_flags & NFSEXP_FSID)) {
+				/* Force '/' to be exported as fsid == 0*/
+				exp->m_export.e_flags |= NFSEXP_FSID;
+				exp->m_export.e_fsid = 0;
+			}
+
 			v4root_add_parents(exp);
 			/* XXX: error handling! */
 		}


