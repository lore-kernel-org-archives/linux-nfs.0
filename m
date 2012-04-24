Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57411 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752686Ab2DXFsS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 01:48:18 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Date: Tue, 24 Apr 2012 15:46:38 +1000
Subject: [PATCH 5/6] v4root: set the time-to-live for V4ROOT exports to the
 DEFAULT.
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Message-ID: <20120424054638.20130.42585.stgit@notabene.brown>
In-Reply-To: <20120424054003.20130.16209.stgit@notabene.brown>
References: <20120424054003.20130.16209.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

e_ttl is set to the default in init_exportent().
However V4ROOT exports never see init_exportent() as they are created
with dupexportent from a template.  So e_ttl does not get set and
export entries expire immediately.
This results in an upcall to mountd every time a V4ROOT directory
in accessed.

So set e_ttl in the template.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 utils/mountd/v4root.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index b4fdcce..57ee0b2 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -46,6 +46,7 @@ static nfs_export pseudo_root = {
 		.e_nsqgids = 0,
 		.e_fsid = 0,
 		.e_mountpoint = NULL,
+		.e_ttl = DEFAULT_TTL,
 	},
 	.m_exported = 0,
 	.m_xtabent = 1,


