Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47067 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbbCYIpT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 04:45:19 -0400
Date: Wed, 25 Mar 2015 01:45:16 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, trond.myklebust@primarydata.com, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] nfsd: return correct openowner when there is a race
 to put one in the hash
Message-ID: <20150325084516.GC25682@infradead.org>
References: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
 <1427122424-8078-2-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1427122424-8078-2-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good catch!

Reviewed-by: Christoph Hellwig <hch@lst.de>

But maybe it's better to write the code so that the intent is obvious:

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f6b2a09..3c4c3d2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3215,11 +3215,13 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 	INIT_LIST_HEAD(&oo->oo_close_lru);
 	spin_lock(&clp->cl_lock);
 	ret = find_openstateowner_str_locked(strhashval, open, clp);
-	if (ret == NULL) {
-		hash_openowner(oo, clp, strhashval);
-		ret = oo;
-	} else
+	if (ret) {
 		nfs4_free_openowner(&oo->oo_owner);
+		spin_unlock(&clp->cl_lock);
+		return ret;
+	}
+
+	hash_openowner(oo, clp, strhashval);
 	spin_unlock(&clp->cl_lock);
 	return oo;
 }
