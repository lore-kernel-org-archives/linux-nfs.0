Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:58788 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751009AbeERVNF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 May 2018 17:13:05 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2728940711DD
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2018 21:13:05 +0000 (UTC)
Received: from rhel7u5-node2.dwysocha.net (dhcp145-42.rdu.redhat.com [10.13.145.42])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 1BBCFADF98
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2018 21:13:05 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] Fix 16-byte memory leak in gssp_accept_sec_context_upcall
Date: Fri, 18 May 2018 17:13:04 -0400
Message-Id: <1526677984-29854-1-git-send-email-dwysocha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a 16-byte memory leak inside sunrpc/auth_gss on an nfs server when
a client mounts with 'sec=krb5' in a simple mount / umount loop.  The leak
is seen by either monitoring the kmalloc-16 slab or with kmemleak enabled

unreferenced object 0xffff92e6a045f030 (size 16):
  comm "nfsd", pid 1096, jiffies 4294936658 (age 761.110s)
  hex dump (first 16 bytes):
    2a 86 48 86 f7 12 01 02 02 00 00 00 00 00 00 00  *.H.............
  backtrace:
    [<000000004b2b79a7>] gssx_dec_buffer+0x79/0x90 [auth_rpcgss]
    [<000000002610ac1a>] gssx_dec_accept_sec_context+0x215/0x6dd [auth_rpcgss]
    [<000000004fd0e81d>] rpcauth_unwrap_resp+0xa9/0xe0 [sunrpc]
    [<000000002b099233>] call_decode+0x1e9/0x840 [sunrpc]
    [<00000000954fc846>] __rpc_execute+0x80/0x3f0 [sunrpc]
    [<00000000c83a961c>] rpc_run_task+0x10d/0x150 [sunrpc]
    [<000000002c2cdcd2>] rpc_call_sync+0x4d/0xa0 [sunrpc]
    [<000000000b74eea2>] gssp_accept_sec_context_upcall+0x196/0x470 [auth_rpcgss]
    [<000000003271273f>] svcauth_gss_proxy_init+0x188/0x520 [auth_rpcgss]
    [<000000001cf69f01>] svcauth_gss_accept+0x3a6/0xb50 [auth_rpcgss]

If you map the above to code you'll see the following call chain
  gssx_dec_accept_sec_context
    gssx_dec_ctx  (missing from kmemleak output)
      gssx_dec_buffer(xdr, &ctx->mech)

Inside gssx_dec_buffer there is 'kmemdup' where we allocate memory for
any gssx_buffer (buf) and store into buf->data.  In the above instance,
'buf == &ctx->mech).

Further up in the chain in gssp_accept_sec_context_upcall we see ctx->mech
is part of a stack variable 'struct gssx_ctx rctxh'.  Now later inside
gssp_accept_sec_context_upcall after gssp_call, there is a number of
memcpy and kfree statements, but there is no kfree(rctxh.mech.data)
after the memcpy into data->mech_oid.data.

With this patch applied and the same mount / unmount loop, the kmalloc-16
slab is stable and kmemleak enabled no longer shows the above backtrace.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 net/sunrpc/auth_gss/gss_rpc_upcall.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index 46b295e..d98e2b6 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -298,9 +298,11 @@ int gssp_accept_sec_context_upcall(struct net *net,
 	if (res.context_handle) {
 		data->out_handle = rctxh.exported_context_token;
 		data->mech_oid.len = rctxh.mech.len;
-		if (rctxh.mech.data)
+		if (rctxh.mech.data) {
 			memcpy(data->mech_oid.data, rctxh.mech.data,
 						data->mech_oid.len);
+			kfree(rctxh.mech.data);
+		}
 		client_name = rctxh.src_name.display_name;
 	}
 
-- 
1.8.3.1

