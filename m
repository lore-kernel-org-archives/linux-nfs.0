Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4A58C10F11
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:06:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7C23E2087E
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:06:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731483AbfCZWGb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Mar 2019 18:06:31 -0400
Received: from mx1.redhat.com ([209.132.183.28]:44960 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731816AbfCZWGb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Mar 2019 18:06:31 -0400
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 03CF63086237;
        Tue, 26 Mar 2019 22:06:31 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-200.rdu2.redhat.com [10.10.122.200])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B56A91001E67;
        Tue, 26 Mar 2019 22:06:30 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 16BEB21341; Tue, 26 Mar 2019 18:06:30 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org, jlayton@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH RFC v3 3/5] nfsd: keep a tally of RECLAIM_COMPLETE operations when using nfsdcld
Date:   Tue, 26 Mar 2019 18:06:28 -0400
Message-Id: <20190326220630.2911-4-smayhew@redhat.com>
In-Reply-To: <20190326220630.2911-1-smayhew@redhat.com>
References: <20190326220630.2911-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 26 Mar 2019 22:06:31 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When using nfsdcld for NFSv4 client tracking, track the number of
RECLAIM_COMPLETE operations we receive from "known" clients to help in
deciding if we can lift the grace period early (or whether we need to
start a v4 grace period at all).

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/netns.h       |  3 +++
 fs/nfsd/nfs4recover.c |  3 +++
 fs/nfsd/nfs4state.c   | 33 ++++++++++++++++++++++++++++++++-
 fs/nfsd/nfsctl.c      |  1 +
 4 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 32cb8c027483..b42aaa22fba2 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -104,6 +104,9 @@ struct nfsd_net {
 	time_t nfsd4_grace;
 	bool somebody_reclaimed;
 
+	bool track_reclaim_completes;
+	atomic_t nr_reclaim_complete;
+
 	bool nfsd_net_up;
 	bool lockd_up;
 
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 89c2a27956d0..09e3c9352778 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1270,6 +1270,8 @@ nfs4_cld_state_init(struct net *net)
 	for (i = 0; i < CLIENT_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&nn->reclaim_str_hashtbl[i]);
 	nn->reclaim_str_hashtbl_size = 0;
+	nn->track_reclaim_completes = true;
+	atomic_set(&nn->nr_reclaim_complete, 0);
 
 	return 0;
 }
@@ -1279,6 +1281,7 @@ nfs4_cld_state_shutdown(struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
+	nn->track_reclaim_completes = false;
 	kfree(nn->reclaim_str_hashtbl);
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 898f1c8c66ca..4b96d41ab695 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -77,6 +77,7 @@ static u64 current_sessionid = 1;
 /* forward declarations */
 static bool check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner);
 static void nfs4_free_ol_stateid(struct nfs4_stid *stid);
+void nfsd4_end_grace(struct nfsd_net *nn);
 
 /* Locking: */
 
@@ -1988,6 +1989,22 @@ destroy_client(struct nfs4_client *clp)
 	__destroy_client(clp);
 }
 
+static void inc_reclaim_complete(struct nfs4_client *clp)
+{
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	if (!nn->track_reclaim_completes)
+		return;
+	if (!nfsd4_find_reclaim_client(clp->cl_name, nn))
+		return;
+	if (atomic_inc_return(&nn->nr_reclaim_complete) ==
+			nn->reclaim_str_hashtbl_size) {
+		printk(KERN_INFO "NFSD: all clients done reclaiming, ending NFSv4 grace period (net %x)\n",
+				clp->net->ns.inum);
+		nfsd4_end_grace(nn);
+	}
+}
+
 static void expire_client(struct nfs4_client *clp)
 {
 	unhash_client(clp);
@@ -3339,6 +3356,7 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp,
 
 	status = nfs_ok;
 	nfsd4_client_record_create(cstate->session->se_client);
+	inc_reclaim_complete(cstate->session->se_client);
 out:
 	return status;
 }
@@ -4698,7 +4716,6 @@ nfsd4_end_grace(struct nfsd_net *nn)
 	if (nn->grace_ended)
 		return;
 
-	dprintk("NFSD: end of grace period\n");
 	nn->grace_ended = true;
 	/*
 	 * If the server goes down again right now, an NFSv4
@@ -4734,6 +4751,10 @@ static bool clients_still_reclaiming(struct nfsd_net *nn)
 	unsigned long double_grace_period_end = nn->boot_time +
 						2 * nn->nfsd4_lease;
 
+	if (nn->track_reclaim_completes &&
+			atomic_read(&nn->nr_reclaim_complete) ==
+			nn->reclaim_str_hashtbl_size)
+		return false;
 	if (!nn->somebody_reclaimed)
 		return false;
 	nn->somebody_reclaimed = false;
@@ -4764,6 +4785,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 		new_timeo = 0;
 		goto out;
 	}
+	dprintk("NFSD: end of grace period\n");
 	nfsd4_end_grace(nn);
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&nn->client_lock);
@@ -7253,10 +7275,19 @@ nfs4_state_start_net(struct net *net)
 		return ret;
 	locks_start_grace(net, &nn->nfsd4_manager);
 	nfsd4_client_tracking_init(net);
+	if (nn->track_reclaim_completes && nn->reclaim_str_hashtbl_size == 0)
+		goto skip_grace;
 	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %x)\n",
 	       nn->nfsd4_grace, net->ns.inum);
 	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_grace * HZ);
 	return 0;
+
+skip_grace:
+	printk(KERN_INFO "NFSD: no clients to reclaim, skipping NFSv4 grace period (net %x)\n",
+			net->ns.inum);
+	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_lease * HZ);
+	nfsd4_end_grace(nn);
+	return 0;
 }
 
 /* initialization to perform when the nfsd service is started: */
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f2feb2d11bae..6667d3a4f839 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1242,6 +1242,7 @@ static __net_init int nfsd_init_net(struct net *net)
 	nn->nfsd4_lease = 90;	/* default lease time */
 	nn->nfsd4_grace = 90;
 	nn->somebody_reclaimed = false;
+	nn->track_reclaim_completes = false;
 	nn->clverifier_counter = prandom_u32();
 	nn->clientid_counter = prandom_u32();
 	nn->s2s_cp_cl_id = nn->clientid_counter++;
-- 
2.17.2

