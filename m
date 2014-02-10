Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:32821 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908AbaBJVsK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Feb 2014 16:48:10 -0500
Received: by mail-ie0-f180.google.com with SMTP id at1so3813000iec.25
        for <linux-nfs@vger.kernel.org>; Mon, 10 Feb 2014 13:48:10 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Don't create a gss auth cache unless rpc.gssd is running
Date: Mon, 10 Feb 2014 16:48:07 -0500
Message-Id: <1392068887-25091-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <D03884DC-C5D3-4496-8F5C-682C3E6372AD@primarydata.com>
References: <D03884DC-C5D3-4496-8F5C-682C3E6372AD@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An infinite loop is caused when nfs4_establish_lease() fails
with -EACCES. This causes nfs4_handle_reclaim_lease_error()
to sleep a bit and resets the NFS4CLNT_LEASE_EXPIRED bit.
This in turn causes nfs4_state_manager() to try and
reestablished the lease, again, again, again...

The problem is a valid RPCSEC_GSS client is being created when
rpc.gssd is not running.

Link: http://lkml.kernel.org/r/1392066375-16502-1-git-send-email-steved@redhat.com
Fixes: 0ea9de0ea6a4 (sunrpc: turn warn_gssd() log message into a dprintk())
Reported-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 6c0513a7f992..44a61e8fda6f 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -991,6 +991,8 @@ gss_create_new(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 	gss_auth->service = gss_pseudoflavor_to_service(gss_auth->mech, flavor);
 	if (gss_auth->service == 0)
 		goto err_put_mech;
+	if (!gssd_running(gss_auth->net))
+		goto err_put_mech;
 	auth = &gss_auth->rpc_auth;
 	auth->au_cslack = GSS_CRED_SLACK >> 2;
 	auth->au_rslack = GSS_VERF_SLACK >> 2;
-- 
1.8.5.3

