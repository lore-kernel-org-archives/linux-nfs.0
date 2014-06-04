Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:61871 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbaFDVCQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 17:02:16 -0400
Received: by mail-ig0-f178.google.com with SMTP id h18so1554304igc.5
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 14:02:15 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs 03/17] dataserver: only catch connection error
Date: Wed,  4 Jun 2014 17:01:51 -0400
Message-Id: <1401915726-29092-4-git-send-email-dros@primarydata.com>
In-Reply-To: <1401915726-29092-1-git-send-email-dros@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
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
index 65e4f55..b8dd903 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -9,6 +9,7 @@ import nfs4client
 import hashlib
 import sys
 import nfs4_ops as op
+import socket
 
 log = logging.getLogger("Dataserver Manager")
 
@@ -197,7 +198,7 @@ class DSDevice(object):
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

