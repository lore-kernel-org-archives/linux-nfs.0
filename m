Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23881 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759425Ab2FAVPL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 17:15:11 -0400
From: andros@netapp.com
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [[PATCH resend] 2/6] PYNFS fix rpcgen
Date: Tue, 29 May 2012 18:11:25 -0400
Message-Id: <1338329489-29178-3-git-send-email-andros@netapp.com>
In-Reply-To: <1338329489-29178-1-git-send-email-andros@netapp.com>
References: <1338329489-29178-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@netapp.com>

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 xdr/xdrgen.py |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/xdr/xdrgen.py b/xdr/xdrgen.py
index 0148f96..72954d1 100755
--- a/xdr/xdrgen.py
+++ b/xdr/xdrgen.py
@@ -786,6 +786,8 @@ class Info(object):
             if t.type in name_dict:
                 p = name_dict[t.type]
                 if p.parent and p.type == 'enum':
+                    if t.array:
+                        return "','.join([ const.%s.get(x, x) for x in self.%s ])" % (p.id, t.id)
                     return "const.%s.get(self.%s, self.%s)" % (p.id, t.id, t.id)
             return "repr(self.%s)" % t.id
         indent2 = prefix + indent
-- 
1.7.7.6

