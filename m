Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33360 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752453AbaLFC41 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Dec 2014 21:56:27 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB62uRjk007435
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 5 Dec 2014 21:56:27 -0500
Received: from bcodding-csb.redhat.com (vpn-55-170.rdu2.redhat.com [10.10.55.170])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB62uQq0001079
	for <linux-nfs@vger.kernel.org>; Fri, 5 Dec 2014 21:56:26 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: remount with security change should return EINVAL
Date: Fri,  5 Dec 2014 21:52:49 -0500
Message-Id: <e4fb183aaa5faf4fac14e0f81ad3a40f604f68d4.1417834215.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A remount that alters security flavors can appear to succeed when it should
instead return -EINVAL.  Check to see if the current security flavor exists
within the flavors specified in the remount options, and if not fail the
remount.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/super.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 31a11b0..e6275e0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2191,7 +2191,7 @@ nfs_compare_remount_data(struct nfs_server *nfss,
 	    data->version != nfss->nfs_client->rpc_ops->version ||
 	    data->minorversion != nfss->nfs_client->cl_minorversion ||
 	    data->retrans != nfss->client->cl_timeout->to_retries ||
-	    data->selected_flavor != nfss->client->cl_auth->au_flavor ||
+	    !nfs_auth_info_match(&data->auth_info, nfss->client->cl_auth->au_flavor) ||
 	    data->acregmin != nfss->acregmin / HZ ||
 	    data->acregmax != nfss->acregmax / HZ ||
 	    data->acdirmin != nfss->acdirmin / HZ ||
@@ -2239,7 +2239,6 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	data->wsize = nfss->wsize;
 	data->retrans = nfss->client->cl_timeout->to_retries;
 	data->selected_flavor = nfss->client->cl_auth->au_flavor;
-	data->auth_info = nfss->auth_info;
 	data->acregmin = nfss->acregmin / HZ;
 	data->acregmax = nfss->acregmax / HZ;
 	data->acdirmin = nfss->acdirmin / HZ;
-- 
1.7.1

