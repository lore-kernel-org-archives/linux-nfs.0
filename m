Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32837 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754626AbdCJAi3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Mar 2017 19:38:29 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 10 Mar 2017 11:36:39 +1100
Subject: [PATCH 2/3] NFSD: fix nfsd_minorversion(.., NFSD_AVAIL)
Cc: Trond Myklebust <trondmy@primarydata.com>, linux-nfs@vger.kernel.org
Message-ID: <148910619931.3032.2841124907029105276.stgit@noble>
In-Reply-To: <148910618557.3032.8265198632788708076.stgit@noble>
References: <148910618557.3032.8265198632788708076.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Current code will return 1 if the version is supported,
and -1 if it isn't.
This is confusing and inconsistent with the one place where this
is used.
So change to return 1 if it is supported, and zero if not.
i.e. an error is never returned.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfsd/nfssvc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 786a4a2cb2d7..892137b1e330 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -167,7 +167,8 @@ nfsd_adjust_nfsd_versions4(void)
 
 int nfsd_minorversion(u32 minorversion, enum vers_op change)
 {
-	if (minorversion > NFSD_SUPPORTED_MINOR_VERSION)
+	if (minorversion > NFSD_SUPPORTED_MINOR_VERSION &&
+	    change != NFSD_AVAIL)
 		return -1;
 	switch(change) {
 	case NFSD_SET:


