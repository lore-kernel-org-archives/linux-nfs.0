Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59045 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755610Ab1G1UDR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2011 16:03:17 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Mi Jinlong <mijinlong@cn.fujitsu.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/6] Make top-level setup.py set up nfs4.0 as well
Date: Thu, 28 Jul 2011 16:03:02 -0400
Message-Id: <1311883384-20260-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1311883384-20260-1-git-send-email-bfields@redhat.com>
References: <1311883384-20260-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

With this, a single run of the top level setup.py will do everything.

Also I can't see any reason not to make setup.py executable.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 setup.py |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)
 mode change 100644 => 100755 setup.py

diff --git a/setup.py b/setup.py
old mode 100644
new mode 100755
index 24acb4a..1a7b30c
--- a/setup.py
+++ b/setup.py
@@ -1,3 +1,5 @@
+#!/usr/bin/env python
+
 from distutils.core import setup
 
 import sys
@@ -5,13 +7,13 @@ import os
 from os.path import join
 
 DESCRIPTION = """
-newpynfs 4.1
+pynfs
 ============
 
 Add stuff here.
 """
 
-DIRS = ["ply", "xdr", "gssapi", "rpc", "nfs4.1"] # Order is important
+DIRS = ["ply", "xdr", "gssapi", "rpc", "nfs4.1", "nfs4.0"] # Order is important
 
 def setup(*args, **kwargs):
     print "This just runs the setup.py file in each of the following dirs:"
-- 
1.7.4.1

