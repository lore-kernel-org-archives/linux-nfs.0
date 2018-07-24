Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:52772 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388421AbeGXIj1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:27 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 15/24] pynfs: python3 support plan: fix 'socket' has no attribute '_socketobject'
Date: Tue, 24 Jul 2018 15:33:33 +0800
Message-Id: <20180724073342.5738-15-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/lib/rpc/rpc.py | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/nfs4.0/lib/rpc/rpc.py b/nfs4.0/lib/rpc/rpc.py
index 86075b2..93f20dc 100644
--- a/nfs4.0/lib/rpc/rpc.py
+++ b/nfs4.0/lib/rpc/rpc.py
@@ -176,9 +176,14 @@ def _send_record(self, data, chunksize=2048):
         mark = struct.pack('>L', last | len(chunk))
         self.sendall(mark + chunk)
 
-socket._socketobject.recv_all = _recv_all
-socket._socketobject.recv_record = _recv_record
-socket._socketobject.send_record = _send_record
+try:     #for python2
+    socket._socketobject.recv_all = _recv_all
+    socket._socketobject.recv_record = _recv_record
+    socket._socketobject.send_record = _send_record
+except:  #for python3
+    socket.recv_all = _recv_all
+    socket.recv_record = _recv_record
+    socket.send_record = _send_record
 
 #################################################
 
-- 
2.17.1

