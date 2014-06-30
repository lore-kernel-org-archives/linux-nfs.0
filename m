Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:61984 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbaF3Pwl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:41 -0400
Received: by mail-qa0-f49.google.com with SMTP id w8so6506860qac.8
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:40 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 091/114] nfsd: protect clid and verifier generation with client_lock
Date: Mon, 30 Jun 2014 11:50:00 -0400
Message-Id: <1404143423-24381-92-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The clid counter is a global counter currently. Move it to be a per-net
property so that it can be properly protected by the nn->client_lock
instead of relying on the client_mutex.

The verifier generator is also potentially racy if there are two
simultaneous callers. Generate the verifier when we generate the clid
value, so it's also created under the client_lock. With this, there's
no need to keep two counters as they'd always be in sync anyway, so
just use the clientid_counter for both.

As Trond points out, what would be best is to eventually move this
code to use IDR instead of the hash tables. That would also help ensure
uniqueness, but that's probably best done as a separate project.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/netns.h     |  6 +++---
 fs/nfsd/nfs4state.c | 21 +++++++++------------
 2 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index f89042ae0056..831abbdc6c52 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -92,11 +92,11 @@ struct nfsd_net {
 	bool nfsd_net_up;
 	bool lockd_up;
 
-	/*
-	 * Time of server startup
-	 */
+	/* Time of server startup */
 	struct timeval nfssvc_boot;
 
+	u32 clientid_counter;
+
 	struct svc_serv *nfsd_serv;
 };
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0298dac8009c..4799d6e652d0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1754,28 +1754,26 @@ static bool mach_creds_match(struct nfs4_client *cl, struct svc_rqst *rqstp)
 	return 0 == strcmp(cl->cl_cred.cr_principal, cr->cr_principal);
 }
 
-static void gen_clid(struct nfs4_client *clp, struct nfsd_net *nn)
-{
-	static u32 current_clientid = 1;
-
-	clp->cl_clientid.cl_boot = nn->boot_time;
-	clp->cl_clientid.cl_id = current_clientid++; 
-}
-
-static void gen_confirm(struct nfs4_client *clp)
+static void gen_confirm(struct nfs4_client *clp, struct nfsd_net *nn)
 {
 	__be32 verf[2];
-	static u32 i;
 
 	/*
 	 * This is opaque to client, so no need to byte-swap. Use
 	 * __force to keep sparse happy
 	 */
 	verf[0] = (__force __be32)get_seconds();
-	verf[1] = (__force __be32)i++;
+	verf[1] = (__force __be32)nn->clientid_counter;
 	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));
 }
 
+static void gen_clid(struct nfs4_client *clp, struct nfsd_net *nn)
+{
+	clp->cl_clientid.cl_boot = nn->boot_time;
+	clp->cl_clientid.cl_id = nn->clientid_counter++;
+	gen_confirm(clp, nn);
+}
+
 static struct nfs4_stid *
 find_stateid_locked(struct nfs4_client *cl, stateid_t *t)
 {
@@ -1824,7 +1822,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	clear_bit(0, &clp->cl_cb_slot_busy);
 	copy_verf(clp, verf);
 	rpc_copy_addr((struct sockaddr *) &clp->cl_addr, sa);
-	gen_confirm(clp);
 	clp->cl_cb_session = NULL;
 	clp->net = net;
 	return clp;
-- 
1.9.3

