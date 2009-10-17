From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 3/3] nfsmount.conf: New variables that explicitly set default
 (Release 3)
Date: Sat, 17 Oct 2009 09:40:52 -0400
Message-ID: <4AD9C964.4030106@RedHat.com>
References: <4AD9C871.3000400@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3495 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901AbZJQNlE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Oct 2009 09:41:04 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n9HDf82I030323
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2009 09:41:08 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-234.rdu.redhat.com [10.11.10.234])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n9HDf7cV018389
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2009 09:41:08 -0400
In-Reply-To: <4AD9C871.3000400-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 04f6cc992b99d09855736bccf33f1eb96af82244
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Oct 12 17:16:56 2009 -0400

    Added the defaultproto and defaultvers variable to the mount
    configuration file.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/nfsmount.conf b/utils/mount/nfsmount.conf
index 991838f..0d65056 100644
--- a/utils/mount/nfsmount.conf
+++ b/utils/mount/nfsmount.conf
@@ -28,10 +28,24 @@
 # This statically named section defines global mount 
 # options that can be applied on all NFS mount.
 #
-# Protocol Version [2,3]
-# Nfsvers=3
-#
-# Network Transport [udp,tcp,rdma] (Note: values are case sensitive)
+# Protocol Version [2,3,4]
+# This defines the default protocol version which will
+# be used to start the negotiation with the server.
+# Defaultvers=4
+#
+# Setting this option makes it mandatory the server supports the
+# given version. The mount will fail if the given version is 
+# not support by the server. 
+# Nfsvers=4
+#
+# Network Protocol [udp,tcp,rdma] (Note: values are case sensitive)
+# This defines the default network protocol which will
+# be used to start the negotiation with the server.
+# Defaultproto=tcp
+#
+# Setting this option makes it mandatory the server supports the
+# given network protocol. The mount will fail if the given network
+# protocol is not supported by the server.
 # Proto=tcp
 #
 # The number of times a request will be retired before 

