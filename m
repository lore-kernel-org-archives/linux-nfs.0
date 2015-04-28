Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:51452 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965258AbbD1UV5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 16:21:57 -0400
Date: Tue, 28 Apr 2015 13:21:57 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH, RFC] backchannel overflows
Message-ID: <20150428202157.GA23972@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the client will just crap out if a CB_NULL comes in at the
same time as a slot controlled CB_COMPOUND that includes a CB_SEQUENCE.

I don't really understand how the spec wants to treat CB_NULL in
relation to the available backchannel slots, but given that it's
not part of the sequences in CB_SEQUENCE it somehow nees to bypass them.

If we make sure to overallocate the rpc-level buffers so that we
have more than the available NFS-level slots we should be safe from
this condition which makes a 4.1 server doing heavy recalls under
load very unhapy by not returning an NFS level reply to its layout
recalls.

I dont really like this patch much, so any idea for a better solution
would be highly welcome!

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 84326e9..7afb3ef 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -205,7 +205,7 @@ extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
  * so we limit their concurrency to 1 by setting up the maximum number
  * of slots for the backchannel.
  */
-#define NFS41_BC_MIN_CALLBACKS 1
+#define NFS41_BC_MIN_CALLBACKS 2
 #define NFS41_BC_MAX_CALLBACKS 1
 
 extern unsigned int nfs_callback_set_tcpport;
