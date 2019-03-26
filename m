Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7ACFC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:06:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 919B42075D
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:06:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731770AbfCZWGd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Mar 2019 18:06:33 -0400
Received: from mx1.redhat.com ([209.132.183.28]:61401 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731828AbfCZWGb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Mar 2019 18:06:31 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6140F3082E91;
        Tue, 26 Mar 2019 22:06:31 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-200.rdu2.redhat.com [10.10.122.200])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 45C7888B2B;
        Tue, 26 Mar 2019 22:06:31 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 1FD4B21345; Tue, 26 Mar 2019 18:06:30 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org, jlayton@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH RFC v3 5/5] nfsd: handle legacy client tracking records sent by nfsdcld
Date:   Tue, 26 Mar 2019 18:06:30 -0400
Message-Id: <20190326220630.2911-6-smayhew@redhat.com>
In-Reply-To: <20190326220630.2911-1-smayhew@redhat.com>
References: <20190326220630.2911-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Tue, 26 Mar 2019 22:06:31 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The new nfsdcld will do a one-time "upgrade" where it searches for
records from nfsdcltrack and the legacy tracking during startup.
Legacy records will be prefixed with the string "hash:", which we need
to strip off before adding to the reclaim_str_hashtbl.  When legacy
records are encountered, set the new cn_has_legacy flag in the cld_net.
When this flag is set, if the search for a reclaim record based on the
client name string fails, then do a second search based on the hash of
the name string.

Note that if there are legacy records then the grace period will not
be lifted early via the tracking of RECLAIM_COMPLETEs.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/nfs4recover.c | 39 +++++++++++++++++++++++++++++++++++----
 1 file changed, 35 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index d60001da1dbf..3a123c88120a 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -731,6 +731,7 @@ struct cld_net {
 	spinlock_t		 cn_lock;
 	struct list_head	 cn_list;
 	unsigned int		 cn_xid;
+	bool			 cn_has_legacy;
 };
 
 struct cld_upcall {
@@ -787,6 +788,7 @@ __cld_pipe_inprogress_downcall(const struct cld_msg __user *cmsg,
 	uint8_t cmd;
 	struct xdr_netobj name;
 	uint16_t namelen;
+	struct cld_net *cn = nn->cld_net;
 
 	if (get_user(cmd, &cmsg->cm_cmd)) {
 		dprintk("%s: error when copying cmd from userspace", __func__);
@@ -799,6 +801,11 @@ __cld_pipe_inprogress_downcall(const struct cld_msg __user *cmsg,
 		if (IS_ERR_OR_NULL(name.data))
 			return -EFAULT;
 		name.len = namelen;
+		if (name.len > 5 && memcmp(name.data, "hash:", 5) == 0) {
+			name.len = name.len - 5;
+			memmove(name.data, name.data + 5, name.len);
+			cn->cn_has_legacy = true;
+		}
 		if (!nfs4_client_to_reclaim(name, nn)) {
 			kfree(name.data);
 			return -EFAULT;
@@ -969,6 +976,7 @@ __nfsd4_init_cld_pipe(struct net *net)
 	}
 
 	cn->cn_pipe->dentry = dentry;
+	cn->cn_has_legacy = false;
 	nn->cld_net = cn;
 	return 0;
 
@@ -1171,6 +1179,10 @@ nfsd4_cld_check(struct nfs4_client *clp)
 {
 	struct nfs4_client_reclaim *crp;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	struct cld_net *cn = nn->cld_net;
+	int status;
+	char dname[HEXDIR_LEN];
+	struct xdr_netobj name;
 
 	/* did we already find that this client is stable? */
 	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
@@ -1178,12 +1190,31 @@ nfsd4_cld_check(struct nfs4_client *clp)
 
 	/* look for it in the reclaim hashtable otherwise */
 	crp = nfsd4_find_reclaim_client(clp->cl_name, nn);
-	if (crp) {
-		crp->cr_clp = clp;
-		return 0;
-	}
+	if (crp)
+		goto found;
+
+	if (cn->cn_has_legacy) {
+		status = nfs4_make_rec_clidname(dname, &clp->cl_name);
+		if (status)
+			return -ENOENT;
+
+		name.data = kmemdup(dname, HEXDIR_LEN, GFP_KERNEL);
+		if (!name.data) {
+			dprintk("%s: failed to allocate memory for name.data!\n",
+				__func__);
+			return -ENOENT;
+		}
+		name.len = HEXDIR_LEN;
+		crp = nfsd4_find_reclaim_client(name, nn);
+		kfree(name.data);
+		if (crp)
+			goto found;
 
+	}
 	return -ENOENT;
+found:
+	crp->cr_clp = clp;
+	return 0;
 }
 
 static int
-- 
2.17.2

