Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47474 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752359Ab2K1BMi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 20:12:38 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Date: Wed, 28 Nov 2012 12:11:22 +1100
Subject: [PATCH 2/3] gssd_proc: remove pointless test against FD_ALLOC_BLOCK
 in process_pipedir
Cc: linux-nfs@vger.kernel.org
Message-ID: <20121128011122.2475.4388.stgit@notabene.brown>
In-Reply-To: <20121128010939.2475.13123.stgit@notabene.brown>
References: <20121128010939.2475.13123.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I can see no possible point for this test against FD_ALLOC_BLOCK,
so just remove the test.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 utils/gssd/gssd_proc.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 2d7ec94..425b582 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -567,9 +567,8 @@ process_pipedir(char *pipe_name)
 
 	update_old_clients(namelist, j, pipe_name);
 	for (i=0; i < j; i++) {
-		if (i < FD_ALLOC_BLOCK
-				&& !strncmp(namelist[i]->d_name, "clnt", 4)
-				&& !find_client(namelist[i]->d_name, pipe_name))
+		if (!strncmp(namelist[i]->d_name, "clnt", 4)
+		    && !find_client(namelist[i]->d_name, pipe_name))
 			process_clnt_dir(namelist[i]->d_name, pipe_name);
 		free(namelist[i]);
 	}


