Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:61690 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753683AbaIONOc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 09:14:32 -0400
Received: by mail-qg0-f54.google.com with SMTP id z60so3888977qgd.27
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 06:14:31 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v4 9/9] nfsd: skip subsequent UMH "create" operations after the first one for v4.0 clients
Date: Mon, 15 Sep 2014 09:14:10 -0400
Message-Id: <1410786850-18194-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1410786850-18194-1-git-send-email-jlayton@primarydata.com>
References: <1410786850-18194-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the case of v4.0 clients, we may call into the "create" client
tracking operation multiple times (once for each openowner). Upcalling
for each one of those is wasteful and slow however. We can skip doing
further "create" operations after the first one if we know that one has
already been done.

v4.1+ clients generally only call into this function once (on
RECLAIM_COMPLETE), and we can't skip upcalling on the create even if the
STABLE bit is set. Doing so would make it impossible for nfsdcltrack to
lift the grace period early since the timestamp has a different meaning
in the case where the client is expected to issue a RECLAIM_COMPLETE.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4recover.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 41f3efbfd1df..29b4e3fc59f4 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1281,6 +1281,22 @@ nfsd4_umh_cltrack_create(struct nfs4_client *clp)
 	char *hexid, *has_session, *grace_start;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
+	/*
+	 * With v4.0 clients, there's little difference in outcome between a
+	 * create and check operation, and we can end up calling into this
+	 * function multiple times per client (once for each openowner). So,
+	 * for v4.0 clients skip upcalling once the client has been recorded
+	 * on stable storage.
+	 *
+	 * For v4.1+ clients, the outcome of the two operations is different,
+	 * so we must ensure that we upcall for the create operation. v4.1+
+	 * clients call this on RECLAIM_COMPLETE though, so we should only end
+	 * up doing a single create upcall per client.
+	 */
+	if (clp->cl_minorversion == 0 &&
+	    test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
+		return;
+
 	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
 	if (!hexid) {
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
-- 
1.9.3

