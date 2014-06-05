Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:34802 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbaFEN4C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:56:02 -0400
Received: by mail-ig0-f169.google.com with SMTP id a13so3131669igq.4
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 06:56:01 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs v2 14/16] 4.1 server: get rid of old op_getdeviceinfo
Date: Thu,  5 Jun 2014 09:55:42 -0400
Message-Id: <1401976544-36374-15-git-send-email-dros@primarydata.com>
In-Reply-To: <1401976544-36374-1-git-send-email-dros@primarydata.com>
References: <1401976544-36374-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This has been commented out for a while.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/nfs4server.py | 21 ---------------------
 1 file changed, 21 deletions(-)

diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
index 3d2d4cf..7ca4d92 100755
--- a/nfs4.1/nfs4server.py
+++ b/nfs4.1/nfs4server.py
@@ -1867,27 +1867,6 @@ class NFS4Server(rpc.Server):
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

