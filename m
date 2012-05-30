Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41417 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752999Ab2E3Sgb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 May 2012 14:36:31 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] nfsd4: return "real" sequence id in confirmed case
Date: Wed, 30 May 2012 14:36:25 -0400
Message-Id: <1338402988-17356-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1338402988-17356-1-git-send-email-bfields@redhat.com>
References: <1338402988-17356-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The client should ignore the returned sequence_id in the case where the
CONFIRMED flag is set on an exchange_id reply--and in the unconfirmed
case "1" is always the right response.  So it shouldn't actually matter
what we return here.

We could continue returning 1 just to catch clients ignoring the spec
here, but I'd rather be generous.  Other things equal, returning the
existing sequence_id seems more informative.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d53ad72..bcb4b50 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1650,7 +1650,7 @@ out_copy:
 	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
 	exid->clientid.cl_id = new->cl_clientid.cl_id;
 
-	exid->seqid = 1;
+	exid->seqid = new->cl_cs_slot.sl_seqid + 1;
 	nfsd4_set_ex_flags(new, exid);
 
 	dprintk("nfsd4_exchange_id seqid %d flags %x\n",
-- 
1.7.10.2

