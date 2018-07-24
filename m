Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:52780 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388448AbeGXIjn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:43 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 22/24] pynfs: python3 support plan: fix ord() failure on python3
Date: Tue, 24 Jul 2018 15:33:40 +0800
Message-Id: <20180724073342.5738-22-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/nfs4lib.py | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index 79e386e..82fa4d8 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -144,7 +144,10 @@ class CBServer(rpc.RPCServer):
         self.client = client
         rpc.RPCServer.__init__(self, prog=self.prog, vers=1, port=self.port)
         packed = struct.pack('>H', self.port)
-        self.dotport = '.%s.%s' % (ord(packed[0]), ord(packed[1]))
+        try:     #for python2
+            self.dotport = '.%s.%s' % (ord(packed[0]), ord(packed[1]))
+        except:  #for python3
+            self.dotport = '.%s.%s' % ((packed[0]), (packed[1]))
         self.nfs4packer = FancyNFS4Packer()
         self.nfs4unpacker = FancyNFS4Unpacker('')
         self.recall_lock = threading.Lock()
-- 
2.17.1

