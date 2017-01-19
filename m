Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:40452 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753618AbdASQtE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Jan 2017 11:49:04 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 16AE3280700
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jan 2017 17:48:29 +0100 (CET)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
        by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 0B71713E88
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jan 2017 17:48:28 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] pynfs: do not fail test which expects STALE_STATEID
Date: Thu, 19 Jan 2017 17:48:25 +0100
Message-Id: <20170119164825.5962-1-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Stale stateid tests assume to know how state ids are constructed.
When this is not the case, then server will return BAD_STATEID
and test will fail.

update **check** function to always add BAD_STATEID status code
to the warning list.

Some code duplication, due to testing framework structure.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 nfs4.0/servertests/environment.py   | 6 ++++++
 nfs4.1/server41tests/environment.py | 6 ++++++
 2 files changed, 12 insertions(+)

diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
index 11658b3..c6ede8f 100644
--- a/nfs4.0/servertests/environment.py
+++ b/nfs4.0/servertests/environment.py
@@ -248,6 +248,12 @@ def check(res, stat=NFS4_OK, msg=None, warnlist=[]):
         if not (debug_fail and msg):
             return
 
+    # stale state id test expect some structure stateid.other field.
+    # as this is not the case for all server, do not fail tests if they
+    # have returned BAD_STATEID
+    if res.status == NFS4ERR_STALE_STATEID:
+        warnlist.append(NFS4ERR_BAD_STATEID)
+
     statnames = [nfsstat4[stat] for stat in statlist]
     desired = ' or '.join(statnames)
     if not desired:
diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index a910a69..8bae69b 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -282,6 +282,12 @@ def check(res, stat=NFS4_OK, msg=None, warnlist=[]):
         if not (debug_fail and msg):
             return
 
+    # stale state id test expect some structure stateid.other field.
+    # as this is not the case for all server, do not fail tests if they
+    # have returned BAD_STATEID
+    if res.status == NFS4ERR_STALE_STATEID:
+        warnlist.append(NFS4ERR_BAD_STATEID)
+
     statnames = [nfsstat4[stat] for stat in statlist]
     desired = ' or '.join(statnames)
     if not desired:
-- 
2.9.3

