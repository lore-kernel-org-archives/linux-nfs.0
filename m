From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 3/3] nfsmount.conf: New variables that explicitly set default
 (Release 2)
Date: Mon, 12 Oct 2009 17:39:44 -0400
Message-ID: <4AD3A220.2030202@RedHat.com>
References: <4AD3A0BA.3080104@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4678 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933262AbZJLVkX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2009 17:40:23 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n9CLdvTJ005753
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2009 17:39:57 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-119.rdu.redhat.com [10.11.10.119])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n9CLdupN001175
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2009 17:39:57 -0400
In-Reply-To: <4AD3A0BA.3080104-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit c85cfe6d6f484cb02ee792a81c907b2274a98fd8
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
+# defaultvers=4
+#
+# Setting this option makes it mandatory the server supports the
+# given version. The mount will fail if the given version is 
+# not support by the server. 
+# Nfsvers=4
+#
+# Network Protocol [udp,tcp,rdma] (Note: values are case sensitive)
+# This defines the default network protocol which will
+# be used to start the negotiation with the server.
+# defaultproto=tcp
+#
+# Setting this option makes it mandatory the server supports the
+# given network protocol. The mount will fail if the given network
+# protocol is not supported by the server.
 # Proto=tcp
 #
 # The number of times a request will be retired before 

