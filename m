Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:33879 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbaFDVCg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 17:02:36 -0400
Received: by mail-ie0-f180.google.com with SMTP id tp5so66395ieb.39
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 14:02:35 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs 15/17] 4.1 server: get rid of old op_getdeviceinfo
Date: Wed,  4 Jun 2014 17:02:03 -0400
Message-Id: <1401915726-29092-16-git-send-email-dros@primarydata.com>
In-Reply-To: <1401915726-29092-1-git-send-email-dros@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This has been commented out for a while.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/nfs4server.py | 21 ---------------------
 1 file changed, 21 deletions(-)

diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
index 088e8c4..594e9d5 100755
--- a/nfs4.1/nfs4server.py
+++ b/nfs4.1/nfs4server.py
@@ -1870,27 +1870,6 @@ class NFS4Server(rpc.Server):
                                   new_cookie >= len(list))
         return encode_status(NFS4_OK, res)
 
-#     def op_getdeviceinfo(self, arg, env): # STUB
-#         check_session(env)
-#         # check_cfh(env)
-#         # fs = env.cfh.fs
-#         # STUB - only deals with block volumes
-#         kind = arg.gdia_layout_type
-#         if kind != LAYOUT4_BLOCK_VOLUME:
-#             return encode_status(NFS4ERR_INVAL)
-#         # STUB - want to pull this from fs, not block module
-#         d = block.devices.get(arg.gdia_device_id, None)
-#         if d is None:
-#             return encode_status(NFS4ERR_INVAL)
-#         address = device_addr4(LAYOUT4_BLOCK_VOLUME, d.get_addr())
-#         # Check that we don't exceed count
-#         p = nfs4lib.FancyNFS4Packer()
-#         p.pack_device_addr4(address)
-#         if len(p.get_buffer()) > arg.gdia_maxcount:
-#             return encode_status(NFS4ERR_TOOSMALL, gdir_mincount = len(p.get_buffer()))
-#         res = GETDEVICEINFO4resok(address, 0)
-#         return encode_status(NFS4_OK, res)
-
     def op_getdeviceinfo(self, arg, env): # STUB
         # STUB - ignoring notifications
         check_session(env)
-- 
1.8.5.2 (Apple Git-48)

