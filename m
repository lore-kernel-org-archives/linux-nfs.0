Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:45392 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbaFENzv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:55:51 -0400
Received: by mail-ie0-f176.google.com with SMTP id rl12so866855iec.7
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 06:55:50 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs v2 02/16] dataserver: only catch connection error
Date: Thu,  5 Jun 2014 09:55:30 -0400
Message-Id: <1401976544-36374-3-git-send-email-dros@primarydata.com>
In-Reply-To: <1401976544-36374-1-git-send-email-dros@primarydata.com>
References: <1401976544-36374-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This specifically checks for the error being reported, otherwise a
other exceptions like a programming error  will be caught and treated
as connection errors.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/dataserver.py | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index ade55e1..aca07ee 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -9,6 +9,7 @@ import nfs4client
 import hashlib
 import sys
 import nfs4_ops as op
+import socket
 
 log = logging.getLogger("Dataserver Manager")
 
@@ -198,7 +199,7 @@ class DSDevice(object):
                     ds = DataServer(server, port, path, mdsds=self.mdsds,
                                     multipath_servers=server_list)
                     self.list.append(ds)
-                except:
+                except socket.error:
                     log.critical("cannot access %s:%i/%s" %
                                  (server, port, '/'.join(path)))
                     sys.exit(1)
-- 
1.8.5.2 (Apple Git-48)

