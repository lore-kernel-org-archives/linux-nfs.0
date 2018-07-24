Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:52738 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388439AbeGXIje (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:34 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 18/24] pynfs: python3 support plan: fix 'TypeError: must be str, not bytes'
Date: Tue, 24 Jul 2018 15:33:36 +0800
Message-Id: <20180724073342.5738-18-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py b/nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py
index 778d379..5b7fe33 100644
--- a/nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py
+++ b/nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py
@@ -13,7 +13,10 @@ class SecAuthSys(SecFlavor):
         try:
             p = Packer()
             p.pack_int(stamp)
-            p.pack_string(machinename)
+            try:    # for python2
+                p.pack_string(machinename)
+            except: # for python3
+                p.pack_string(bytes(machinename, 'utf-8'))
             p.pack_uint(uid)
             p.pack_uint(gid)
             p.pack_array(gids, p.pack_uint)
-- 
2.17.1

