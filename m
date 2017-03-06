Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33964 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752910AbdCFKwB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Mar 2017 05:52:01 -0500
Received: by mail-it0-f66.google.com with SMTP id r141so9109768ita.1
        for <linux-nfs@vger.kernel.org>; Mon, 06 Mar 2017 02:50:26 -0800 (PST)
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] nfs4: fix a typo of NFS_ATTR_FATTR_GROUP_NAME
Message-ID: <dca17f2f-419d-72fb-a570-6e780f1bb7fd@gmail.com>
Date: Mon, 6 Mar 2017 17:49:42 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This typo cause a memory leak, and a bad client's group id.
unreferenced object 0xffff96d8073998d0 (size 8):
  comm "kworker/0:3", pid 34224, jiffies 4295361338 (age 761.752s)
  hex dump (first 8 bytes):
    30 00 39 07 d8 96 ff ff                          0.9.....
  backtrace:
    [<ffffffffb883212a>] kmemleak_alloc+0x4a/0xa0
    [<ffffffffb8237bc0>] __kmalloc+0x140/0x220
    [<ffffffffc05c921c>] xdr_stream_decode_string_dup+0x7c/0x110 [sunrpc]
    [<ffffffffc08edcf0>] decode_getfattr_attrs+0x940/0x1630 [nfsv4]
    [<ffffffffc08eea7b>] decode_getfattr_generic.constprop.108+0x9b/0x100 [nfsv4]
    [<ffffffffc08eebaf>] nfs4_xdr_dec_open+0xcf/0x100 [nfsv4]
    [<ffffffffc05bf9c7>] rpcauth_unwrap_resp+0xa7/0xe0 [sunrpc]
    [<ffffffffc05afc70>] call_decode+0x1e0/0x810 [sunrpc]
    [<ffffffffc05bc64d>] __rpc_execute+0x8d/0x420 [sunrpc]
    [<ffffffffc05bc9f2>] rpc_async_schedule+0x12/0x20 [sunrpc]
    [<ffffffffb80bb077>] process_one_work+0x197/0x430
    [<ffffffffb80bb35e>] worker_thread+0x4e/0x4a0
    [<ffffffffb80c1d41>] kthread+0x101/0x140
    [<ffffffffb8839a5c>] ret_from_fork+0x2c/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff

Fixes: 686a816ab6 ("NFSv4: Clean up owner/group attribute decode")
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f0369e3..80ce289 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3942,7 +3942,7 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
 		if (len <= 0)
 			goto out;
 		dprintk("%s: name=%s\n", __func__, group_name->data);
-		return NFS_ATTR_FATTR_OWNER_NAME;
+		return NFS_ATTR_FATTR_GROUP_NAME;
 	} else {
 		len = xdr_stream_decode_opaque_inline(xdr, (void **)&p,
 				XDR_MAX_NETOBJ);
-- 
2.9.3

