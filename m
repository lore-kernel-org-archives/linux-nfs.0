Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31278 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030646Ab2CGTwi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Mar 2012 14:52:38 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Fred.Isaman@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/3] pynfs: use has_key for enum validation in rpcgen
Date: Wed,  7 Mar 2012 14:52:30 -0500
Message-Id: <1331149951-2430-2-git-send-email-dros@netapp.com>
In-Reply-To: <1331149951-2430-1-git-send-email-dros@netapp.com>
References: <1331149951-2430-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid building a new valid list every encode/decode of an enum,
also do a cheaper lookup using a dict rather than a list.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 xdr/xdrgen.py |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/xdr/xdrgen.py b/xdr/xdrgen.py
index 6d89bfe..963e01b 100755
--- a/xdr/xdrgen.py
+++ b/xdr/xdrgen.py
@@ -857,21 +857,17 @@ class Info(object):
         
     def packenum(self, prefix, data='data'):
         prefix, data, subheader, array = self._array_pack(prefix, data)
-        varlist = ["const.%s" % l.id for l in self.body]
-        check = "%sif self.check_enum and %s not in [%s]:\n" \
+        check = "%sif self.check_enum and not const.%s.has_key(%s):\n" \
                 "%s%sraise XDRError, 'value=%%s not in enum %s' %% %s\n" % \
-                (prefix, data, ', '.join(varlist),
-                 prefix, indent, self.id, data)
+                (prefix, self.id, data, prefix, indent, self.id, data)
         pack = check + "%sself.pack_int(%s)\n" % (prefix, data)
         return subheader + pack + array
 
     def unpackenum(self, prefix, data='data'):
         prefix, data, subheader, array = self._array_unpack(prefix, data)
-        varlist = ["const.%s" % l.id for l in self.body]
-        check = "%sif self.check_enum and %s not in [%s]:\n" \
+        check = "%sif self.check_enum and not const.%s.has_key(%s):\n" \
                 "%s%sraise XDRError, 'value=%%s not in enum %s' %% %s\n" % \
-                (prefix, data, ', '.join(varlist),
-                 prefix, indent, self.id, data)
+                (prefix, self.id, data, prefix, indent, self.id, data)
         unpack = "%s%s = self.unpack_int()\n" % (prefix, data)
         return subheader + unpack + check + array
 
-- 
1.7.4.4

