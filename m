Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:60400 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388391AbeGXIjT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:19 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 11/24] pynfs: python3 support plan: xdrgen: remove 'L' suffix of long integer
Date: Tue, 24 Jul 2018 15:33:29 +0800
Message-Id: <20180724073342.5738-11-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 xdr/xdrgen.py | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/xdr/xdrgen.py b/xdr/xdrgen.py
index 8856b4c..b5119cc 100755
--- a/xdr/xdrgen.py
+++ b/xdr/xdrgen.py
@@ -341,10 +341,7 @@ def p_constant(t):
     '''constant : CONST10
                 | CONST8
                 | CONST16'''
-    if len(t[1]) > 9:
-        t[0] = t[1] + 'L'
-    else:
-        t[0] = t[1]
+    t[0] = t[1]
 
 def p_value(t):
     '''value : constant
-- 
2.17.1

