Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20589 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755159Ab2IRU20 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Sep 2012 16:28:26 -0400
From: andros@netapp.com
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] SRVR: set OPEN4_RESULT_LOCKTYPE_POSIX on open
Date: Tue, 18 Sep 2012 16:28:19 -0400
Message-Id: <1348000099-13413-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Enable POSIX locking on the NFSv4.1 pynfs server

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 nfs4.1/nfs4server.py |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
index b279292..bcb6c17 100755
--- a/nfs4.1/nfs4server.py
+++ b/nfs4.1/nfs4server.py
@@ -1435,7 +1435,8 @@ class NFS4Server(rpc.Server):
             # where should it be in relation to above code?
             if self.is_mds:
                 file.layout_open_hook()
-        return sid, deleg, 0
+	# we support posix locking
+        return sid, deleg, OPEN4_RESULT_LOCKTYPE_POSIX
 
     def get_attributes(self, obj, attrs, ignore=True):
         # XXX This really should be a FSObject method, but having trouble
-- 
1.7.5.1

