Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752199AbcBVVCN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2016 16:02:13 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: dros@monkey.org
Cc: linux-nfs@vger.kernel.org
Subject: [nfsometer PATCH 2/2] trace.py: Add some more error handling to probe_mounts()
Date: Mon, 22 Feb 2016 16:02:11 -0500
Message-Id: <1456174931-61514-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1456174931-61514-1-git-send-email-smayhew@redhat.com>
References: <1456174931-61514-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An nfsometer run can fail very early into the process due to things like
directory permissions, kerberos creds, and root squashing.  Try to give
the user some idea why the failure occurred instead of dumping a
backtrace.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfsometerlib/trace.py | 85 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 84 insertions(+), 1 deletion(-)

diff --git a/nfsometerlib/trace.py b/nfsometerlib/trace.py
index cd1d3c3..0ab9f85 100644
--- a/nfsometerlib/trace.py
+++ b/nfsometerlib/trace.py
@@ -20,6 +20,7 @@ import multiprocessing
 import signal
 import random
 import atexit
+import pwd
 
 from cmd import *
 from config import *
@@ -517,6 +518,77 @@ def probe_detect(probe_trace_dir, mountopt):
 
     return detect
 
+def _is_auth_gss():
+    lines = [ x.strip() for x in file('/proc/self/mountstats') ]
+    mounted_on = ' mounted on %s with ' % MOUNTDIR
+    start = -1
+    end = -1
+
+    for i, line in enumerate(lines):
+        if line.find(mounted_on) >= 0:
+            assert start == -1
+            start = i
+        elif start >= 0 and line.startswith('device '):
+            assert end == -1
+            end = i
+
+    if end < 0:
+        end = len(lines)
+
+    if start >= 0:
+        lines = lines[start:end]
+    else:
+        return False
+
+    for line in lines:
+        if line.startswith('sec:'):
+            label, data = line.split(':')
+            data = data.strip()
+            if data.startswith('flavor=6'):
+                return True
+    return False
+
+def _has_creds():
+    return os.stat(os.path.join(RUNNING_TRACE_DIR,
+                                'klist_user.start')).st_size != 1
+
+def _has_tkt(server):
+    princ = re.compile('nfs/' + server + '\S+$')
+    lines = [ x.strip() for x in file(os.path.join(RUNNING_TRACE_DIR,
+                                                   'klist_user.start')) ]
+    for i, line in enumerate(lines):
+        if re.search(princ, line):
+            return True
+    return False
+
+def _eperm_helper(opts):
+    server, path = opts.serverpath.split(':')
+    if _is_auth_gss():
+        if _has_creds():
+            if _has_tkt(server):
+                info = str.format(
+                    ' Check {:s} on {:s} and ensure user {:s} has the correct'
+                    ' permission.', path, server,
+                    pwd.getpwuid(os.getuid())[0])
+            else:
+                info = str.format(
+                    ' No nfs service ticket for {:s} in user {:s}\'s'
+                    ' credential cache.', server,
+                    pwd.getpwuid(os.getuid())[0])
+        else:
+            info = str.format(
+                ' User {:s} has no kerberos credentials.',
+                pwd.getpwuid(os.getuid())[0])
+    elif os.getuid() == 0:
+        info = str.format(
+            ' Check for root squashing in the export options for {:s} on'
+            ' {:s}.', path, server)
+    else:
+       info = str.format(
+            ' Check {:s} on {:s} and ensure user {:s} has the correct'
+            ' permission.', path, server, pwd.getpwuid(os.getuid())[0])
+    return info
+
 #
 # public api commands
 #
@@ -746,7 +818,18 @@ def probe_mounts(opts):
         start(m, opts.serverpath, '__nfsometer-probe', [], [], is_probe=True)
         fpath = os.path.join(RUNROOT, '__nfsometer-probe')
 
-        cmd('mkdir -p "%s"' % RUNROOT)
+        try:
+            cmd('mkdir -p "%s"' % RUNROOT)
+        except CmdErrorCode, e:
+            msg = str.format('"mkdir -p {:s}" failed.', RUNROOT)
+            # try to hint why it failed
+            if e.code == errno.EPERM:
+                msg += _eperm_helper(opts)
+            else:
+                msg += e.errstr
+            warn(msg)
+            # and bail out right now
+            sys.exit(1)
 
         f = file(fpath, 'w+')
         f.write('nfsometer probe to determine server features: %s' % m)
-- 
2.4.3

