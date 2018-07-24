Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54852 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388455AbeGXIjr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:47 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 24/24] pynfs: python3 support plan: fix access class var in list comprehension
Date: Tue, 24 Jul 2018 15:33:42 +0800
Message-Id: <20180724073342.5738-24-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

see: https://stackoverflow.com/questions/13905741/accessing-class-variables-from-a-list-comprehension-in-the-class-definition

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---

Status:
'''
all patches works fine on python-2.7
and build success on python-3.6
but because xdrlib issue https://bugs.python.org/issue9544
 pynfs has not been able to run on python-3.6 now
'''

 nfs4.1/config.py | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/nfs4.1/config.py b/nfs4.1/config.py
index b4a45d7..8779fe1 100644
--- a/nfs4.1/config.py
+++ b/nfs4.1/config.py
@@ -178,8 +178,9 @@ _invalid_ops = [
 class OpsConfigServer(object):
     __metaclass__ = MetaConfig
     value = ['ERROR', 0, 0] # Note must have value == _opline(value)
-    attrs = [ConfigLine(name.lower()[3:], value, "Generic comment", _opline)
-             for name in nfs_opnum4.values()]
+    attrs = (lambda value=value: [ConfigLine(name.lower()[3:], value, "Generic comment", _opline)
+                                  for name in nfs_opnum4.values()])()
+
 
 class Actions(object):
     __metaclass__ = MetaConfig
-- 
2.17.1

