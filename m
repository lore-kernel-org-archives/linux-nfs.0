Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:34261 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755995Ab3JROEG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Oct 2013 10:04:06 -0400
Received: by mail-qc0-f180.google.com with SMTP id e9so1694758qcy.39
        for <linux-nfs@vger.kernel.org>; Fri, 18 Oct 2013 07:04:05 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: reject version and minorversion changes on remount attempts
Date: Fri, 18 Oct 2013 10:03:37 -0400
Message-Id: <1382105017-18468-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reported-by: Eric Doutreleau <edoutreleau@genoscope.cns.fr>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a03b9c6..137572b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2143,6 +2143,8 @@ nfs_compare_remount_data(struct nfs_server *nfss,
 	if (data->flags != nfss->flags ||
 	    data->rsize != nfss->rsize ||
 	    data->wsize != nfss->wsize ||
+	    data->version != nfss->nfs_client->rpc_ops->version ||
+	    data->minorversion != nfss->nfs_client->cl_minorversion ||
 	    data->retrans != nfss->client->cl_timeout->to_retries ||
 	    data->auth_flavors[0] != nfss->client->cl_auth->au_flavor ||
 	    data->acregmin != nfss->acregmin / HZ ||
@@ -2197,6 +2199,8 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	data->timeo = 10U * nfss->client->cl_timeout->to_initval / HZ;
 	data->nfs_server.port = nfss->port;
 	data->nfs_server.addrlen = nfss->nfs_client->cl_addrlen;
+	data->version = nfsvers;
+	data->minorversion = nfss->nfs_client->cl_minorversion;
 	memcpy(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
 		data->nfs_server.addrlen);
 
-- 
1.8.3.1

