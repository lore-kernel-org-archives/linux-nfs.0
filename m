Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:35078 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbbCWOx4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2015 10:53:56 -0400
Received: by ykfs63 with SMTP id s63so73270789ykf.2
        for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2015 07:53:56 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] nfsd: return correct openowner when there is a race to put one in the hash
Date: Mon, 23 Mar 2015 10:53:42 -0400
Message-Id: <1427122424-8078-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
References: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

alloc_init_open_stateowner can return an already freed entry if there is
a race to put openowners in the hashtable.

In commit 7ffb588086e9, we changed it so that we allocate and initialize
an openowner, and then check to see if a matching one got stuffed into
the hashtable in the meantime. If it did, then we free the one we just
allocated and take a reference on the one already there. There is a bug
here though. The code will then return the pointer to the one that was
allocated (and has now been freed).

This wasn't evident before as this race almost never occurred. The Linux
kernel client used to serialize requests for a single openowner.  That
has changed now with v4.0 kernels, and this race can now easily occur.

Fixes: 7ffb588086e9
Cc: <stable@vger.kernel.org> # v3.17+
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Reported-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d2f2c37dc2db..cf29d1a698b3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3221,7 +3221,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 	} else
 		nfs4_free_openowner(&oo->oo_owner);
 	spin_unlock(&clp->cl_lock);
-	return oo;
+	return ret;
 }
 
 static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
-- 
2.1.0

