Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54816 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388391AbeGXIjM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:12 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 08/24] pynfs: python3 support plan: cStringIO -> StringIO
Date: Tue, 24 Jul 2018 15:33:26 +0800
Message-Id: <20180724073342.5738-8-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

try:      # python2
    import cStringIO.StringIO as StringIO
except:   # python3
    from io import StringIO

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/nfs4state.py | 5 ++---
 nfs4.1/fs.py        | 5 ++++-
 xdr/xdrgen.py       | 5 ++++-
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/nfs4.0/nfs4state.py b/nfs4.0/nfs4state.py
index 180e642..cd36edd 100755
--- a/nfs4.0/nfs4state.py
+++ b/nfs4.0/nfs4state.py
@@ -5,10 +5,9 @@ import nfs4acl
 import nfs4lib
 import os, time, array, random, string
 try:
-    import cStringIO
-    StringIO = cStringIO
+    import cStringIO.StringIO as StringIO
 except:
-    import StringIO
+    from io import StringIO
 from stat import *
 import sha
 
diff --git a/nfs4.1/fs.py b/nfs4.1/fs.py
index e2c7eca..e8d413e 100644
--- a/nfs4.1/fs.py
+++ b/nfs4.1/fs.py
@@ -6,7 +6,10 @@ from nfs4lib import NFS4Error
 import struct
 import logging
 from locking import Lock, RWLock
-from cStringIO import StringIO
+try:
+    import cStringIO.StringIO as StringIO
+except:
+    from io import StringIO
 import time
 from xdrdef.nfs4_pack import NFS4Packer
 
diff --git a/xdr/xdrgen.py b/xdr/xdrgen.py
index 0aa1a52..8856b4c 100755
--- a/xdr/xdrgen.py
+++ b/xdr/xdrgen.py
@@ -215,7 +215,10 @@
 
 import sys
 import keyword
-import StringIO
+try:
+    import cStringIO.StringIO as StringIO
+except:
+    from io import StringIO
 import time
 import os
 # Allow to be run stright from package
-- 
2.17.1

