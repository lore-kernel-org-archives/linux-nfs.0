Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54812 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388391AbeGXIjK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:10 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 07/24] pynfs: python3 support plan: sys.maxint -> sys.maxsize
Date: Tue, 24 Jul 2018 15:33:25 +0800
Message-Id: <20180724073342.5738-7-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

s/sys.maxint/sys.maxsize/g

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.1/testmod.py | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
index 21e9915..0cb76da 100644
--- a/nfs4.1/testmod.py
+++ b/nfs4.1/testmod.py
@@ -333,7 +333,7 @@ def parseversions(t):
 	    raise RuntimeError("Test %s has invalid version range %s"
                                % (t.fullname, t.vers_list))
     if len(t.vers_list) == 0:
-        return (0, sys.maxint)
+        return (0, sys.maxsize)
     limits = t.vers_list[0].split("-")
     if len(limits) != 2:
         raise RuntimeError("Test %s has invalid version range %s"
@@ -343,7 +343,7 @@ def parseversions(t):
     else:
         left = int(limits[0])
     if limits[1] == '':
-        right = sys.maxint
+        right = sys.maxsize
     else:
         right = int(limits[1])
     return (left, right)
-- 
2.17.1

