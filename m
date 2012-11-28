Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47468 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752359Ab2K1BM3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 20:12:29 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Date: Wed, 28 Nov 2012 12:11:22 +1100
Subject: [PATCH 1/3] gssd_proc: use pollsize, not FD_ALLOC_BLOCK,
 in get_poll_index().
Cc: linux-nfs@vger.kernel.org
Message-ID: <20121128011122.2475.42464.stgit@notabene.brown>
In-Reply-To: <20121128010939.2475.13123.stgit@notabene.brown>
References: <20121128010939.2475.13123.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

get_poll_index wants to walk the entire "pollarray", but uses
the constant FD_ALLOC_BLOCK, rather than the variable
pollsize (which has the same value).  If we want to make the
size of the array variable, it is best not to use the constant.

As pollsize is 'unsigned long', 'i' should be too.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 utils/gssd/gssd_proc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index ec251fa..2d7ec94 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -398,10 +398,10 @@ process_clnt_dir_files(struct clnt_info * clp)
 static int
 get_poll_index(int *ind)
 {
-	int i;
+	unsigned int i;
 
 	*ind = -1;
-	for (i=0; i<FD_ALLOC_BLOCK; i++) {
+	for (i=0; i<pollsize; i++) {
 		if (pollarray[i].events == 0) {
 			*ind = i;
 			break;


