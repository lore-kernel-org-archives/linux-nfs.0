Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39896 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932910Ab1ERQoS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 12:44:18 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] TESTS: add server-side unlink test
Date: Wed, 18 May 2011 12:44:13 -0400
Message-Id: <1305737053-17096-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1305737053-17096-1-git-send-email-bfields@redhat.com>
References: <1305737053-17096-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add a test that checks whether a delegreturn is sent when a file is
unlinked on the server using some other means than NFS.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 lib/nfs4/servertests/st_delegation.py |   19 ++++++++++++++++++-
 sample_files/server_helper.sh         |   13 +++++++++----
 2 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/lib/nfs4/servertests/st_delegation.py b/lib/nfs4/servertests/st_delegation.py
index 14a1d32..46d9f99 100644
--- a/lib/nfs4/servertests/st_delegation.py
+++ b/lib/nfs4/servertests/st_delegation.py
@@ -561,4 +561,21 @@ def testRemove(t, env):
             sleeptime = 20
     _verify_cb_occurred(t, c, count)
 
-    
+def _listToPath(components):
+    return '/'+reduce((lambda x,y:x+'/'+y), components)
+
+def testServerRemove(t, env):
+    """DELEGATION test
+
+    Get read delegation, then ensure removing the file on the server
+    recalls it.  Respond properly and send DELEGRETURN.
+
+    FLAGS: delegations
+    CODE: DELEG16
+    """
+    c = env.c1
+    count = c.cb_server.opcounts[OP_CB_RECALL]
+    c.init_connection('pynfs%i_%s' % (os.getpid(), t.code), cb_ident=0)
+    _get_deleg(t, c, c.homedir + [t.code], _recall, NFS4_OK)
+    env.serverhelper("unlink " + _listToPath(c.homedir + [t.code]));
+    _verify_cb_occurred(t, c, count)
diff --git a/sample_files/server_helper.sh b/sample_files/server_helper.sh
index 291f840..f877a9d 100644
--- a/sample_files/server_helper.sh
+++ b/sample_files/server_helper.sh
@@ -1,9 +1,11 @@
 #!/bin/bash
 
-# A simple script for the reboot tests that reboots a virtual guest.
-# It would be used by adding
-# --serverhelper=sample/send_reboot.py --serverhelperarg=SERVERNAME
-# to testserver.py's commandline arguments.
+# A simple script that can reboot a virtual guest using virsh, or unlink
+# a file on the server. It would be used by adding
+# --serverhelper=sample/server_helper.sh --serverhelperarg=SERVERNAME
+# to testserver.py's commandline arguments, where SERVERNAME is
+# something that works either as a libvirt domain or as a hostname to
+# ssh to.
 
 server=$1
 command=$2
@@ -14,4 +16,7 @@ reboot )
 	virsh destroy $server
 	virsh start $server
 	;;
+unlink )
+	path=$1
+	ssh $server "rm $1"
 esac
-- 
1.7.4.1

