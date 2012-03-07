Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31278 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030623Ab2CGTwg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Mar 2012 14:52:36 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Fred.Isaman@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/3] pynfs: Fix bug in xdrgen __repr__ generation
Date: Wed,  7 Mar 2012 14:52:29 -0500
Message-Id: <1331149951-2430-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an enum type is defined as opaque the generated __repr__ function raises
an exception trying to use the list as a key for a dict.get() lookup.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 xdr/xdrgen.py |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/xdr/xdrgen.py b/xdr/xdrgen.py
index 0148f96..6d89bfe 100755
--- a/xdr/xdrgen.py
+++ b/xdr/xdrgen.py
@@ -786,6 +786,9 @@ class Info(object):
             if t.type in name_dict:
                 p = name_dict[t.type]
                 if p.parent and p.type == 'enum':
+                    if t.array:
+                        return "( '(' + ', '.join([ const.%s.get(x, x) " \
+                               "for x in self.%s ]) + ')' )" % (p.id, t.id)
                     return "const.%s.get(self.%s, self.%s)" % (p.id, t.id, t.id)
             return "repr(self.%s)" % t.id
         indent2 = prefix + indent
-- 
1.7.4.4

