Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36371 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758345Ab2FAVBi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 17:01:38 -0400
From: andros@netapp.com
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 3/6] PYNFS use loopback addresses for MDS<->DS communication
Date: Tue, 29 May 2012 17:57:56 -0400
Message-Id: <1338328679-28837-4-git-send-email-andros@netapp.com>
In-Reply-To: <1338328679-28837-1-git-send-email-andros@netapp.com>
References: <1338328679-28837-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@netapp.com>

if a loopback addresses is specified for a DS, use that address for MDS to DS
communication and remove it from the advertised addresses in getdeviceinfo
(it obviously would never work).

this is useful for testing network partitions - you can bring down / firewall
off an interface without breaking MDS<->DS communications.

an example dataservers.conf:

192.168.55.1:12345,127.0.0.1:12345/pynfs_mds
192.168.55.1:12346,127.0.0.1:12346/pynfs_mds

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 nfs4.1/dataserver.py |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index 65e4f55..dd2a535 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -187,9 +187,27 @@ class DSDevice(object):
                     log.critical("Could not parse line: %r" % line)
                     sys.exit(1)
 
-                # for now, just use the last path for local connections
-                server, port = server_list[-1]
-                server_list = server_list[:-1]
+                # if there is a (IPv4) loopback address in the multipath list,
+                # use that as the connection to the DS, but dont advertise it
+                loopback_idx = -1
+                for i, serverport in enumerate(server_list):
+                    if serverport[0] == '127.0.0.1':
+                        loopback_idx = i
+                        break
+
+                if loopback_idx >= 0:
+                    print "Using loopback address for MDS->DS communication only"
+                    server_list = list(server_list)
+                    server, port = server_list.pop(loopback_idx)
+                else:
+                    # just use the last path for local connections
+                    server, port = server_list[-1]
+
+                if not server_list:
+                    log.critical("At least one non-loopback address must " +
+                                 "be specified for each DS")
+                    sys.exit(1)
+
                 print server, port, path
                 try:
                     log.info("Adding dataserver ip:%s port:%s path:%s" %
@@ -210,9 +228,7 @@ class DSDevice(object):
         index = 0
         for d in self.list:
             if d.active:
-                multipath = []
-                multipath.extend(d.get_multipath_netaddr4s())
-                multipath.append(d.get_netaddr4())
+                multipath = d.get_multipath_netaddr4s()
                 netaddrs.append(multipath)
                 stripe_indices.append(index)
                 index = index + 1
-- 
1.7.7.6

