Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31278 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030592Ab2CGTwn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Mar 2012 14:52:43 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Fred.Isaman@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 3/3] pynfs: use list.append() instead += list in xdrgen
Date: Wed,  7 Mar 2012 14:52:31 -0500
Message-Id: <1331149951-2430-3-git-send-email-dros@netapp.com>
In-Reply-To: <1331149951-2430-1-git-send-email-dros@netapp.com>
References: <1331149951-2430-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

list.append is MUCH faster even when dealing lists with few items

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 xdr/xdrgen.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/xdr/xdrgen.py b/xdr/xdrgen.py
index 963e01b..1f2a768 100755
--- a/xdr/xdrgen.py
+++ b/xdr/xdrgen.py
@@ -793,7 +793,7 @@ class Info(object):
             return "repr(self.%s)" % t.id
         indent2 = prefix + indent
         reprbody = ''.join(["%sif self.%s is not None:\n" \
-                            "%s%sout += ['%s=%%s' %% %s]\n" %
+                            "%s%sout.append('%s=%%s' %% %s)\n" %
                             (indent2, var.id, indent2, indent, var.id, special(var))
                             for var in varlist])
         return "%sdef __repr__(self):\n%sout = []\n" \
-- 
1.7.4.4

