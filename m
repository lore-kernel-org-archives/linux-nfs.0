Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:45175 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbaBJQhH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Feb 2014 11:37:07 -0500
Received: by mail-ie0-f178.google.com with SMTP id rl12so434614iec.37
        for <linux-nfs@vger.kernel.org>; Mon, 10 Feb 2014 08:37:07 -0800 (PST)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs] nfs4.1 server: DSs should have diff server owners
Date: Mon, 10 Feb 2014 11:37:02 -0500
Message-Id: <1392050222-1470-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use getpid() to generate the minor_id component of the server owner.

Witout this, all DSs are considered to be the same server by NFS clients
that detect server trunking, such as the upstream Linux client.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/config.py | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/config.py b/nfs4.1/config.py
index 4f91e84..2238aee 100644
--- a/nfs4.1/config.py
+++ b/nfs4.1/config.py
@@ -3,6 +3,7 @@ from nfs4_const import *
 import nfs4_const
 import nfs4lib
 from copy import deepcopy
+import os
 
 class ConfigAction(Exception):
     pass
@@ -129,7 +130,7 @@ class ServerConfig(object):
               ]
 
     def __init__(self):
-        self.minor_id = 0
+        self.minor_id = os.getpid()
         self.major_id = "PyNFSv4.1"
         self._owner = server_owner4(self.minor_id, self.major_id)
         self.scope = "Default_Scope"
-- 
1.8.3.4 (Apple Git-47)

