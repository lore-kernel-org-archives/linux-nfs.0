Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:57310 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752384AbeC0RoC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Mar 2018 13:44:02 -0400
From: "Jianhong.Yin" <yin-jianhong@163.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 2/2] [pynfs] fix nfs4.1/use_local.py; and add symlink to it in nfs4.0
Date: Wed, 28 Mar 2018 01:43:57 +0800
Message-Id: <20180327174357.13255-1-yin-jianhong@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---
 nfs4.0/use_local.py | 1 +
 nfs4.1/use_local.py | 4 +---
 2 files changed, 2 insertions(+), 3 deletions(-)
 create mode 120000 nfs4.0/use_local.py

diff --git a/nfs4.0/use_local.py b/nfs4.0/use_local.py
new file mode 120000
index 0000000..3c3ddc2
--- /dev/null
+++ b/nfs4.0/use_local.py
@@ -0,0 +1 @@
+../nfs4.1/use_local.py
\ No newline at end of file
diff --git a/nfs4.1/use_local.py b/nfs4.1/use_local.py
index 3dbb0b2..9a1dcaa 100644
--- a/nfs4.1/use_local.py
+++ b/nfs4.1/use_local.py
@@ -4,9 +4,7 @@ from os.path import join, split
 cwd = os.getcwd()
 if True or cwd not in sys.path:
     head, tail = split(cwd)
-    dirs = [ join(head, "gssapi"),
-             join(head, "xdr"),
-             join(head, "ply"),
+    dirs = [ join(head, "xdr"),
              join(head), # rpc
              cwd,
              ]
-- 
2.14.3

