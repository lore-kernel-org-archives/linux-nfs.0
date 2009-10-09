From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfsconfig.conf: Make transport setting case sensitive
Date: Fri, 09 Oct 2009 13:12:58 -0400
Message-ID: <4ACF6F1A.3040306@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933970AbZJIRNg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2009 13:13:36 -0400
Received: from int-mx05.intmail.prod.int.phx2.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.18])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n99HD8Ir022717
	for <linux-nfs@vger.kernel.org>; Fri, 9 Oct 2009 13:13:09 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-151.rdu.redhat.com [10.11.10.151])
	by int-mx05.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n99HD76c021497
	for <linux-nfs@vger.kernel.org>; Fri, 9 Oct 2009 13:13:08 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Author: Steve Dickson <steved@redhat.com>
Date:   Thu Oct 9 12:08:58 2009 -0400

    Make the network transports value in the mount
    config file case sensitive, since they are in the
    mount command's parsing code.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/nfsmount.conf b/utils/mount/nfsmount.conf
index f9fcfcb..991838f 100644
--- a/utils/mount/nfsmount.conf
+++ b/utils/mount/nfsmount.conf
@@ -24,14 +24,15 @@
 # All reads and writes to the 'nfsserver.foo.com' server 
 # will be done with 32k (32768 bytes) block sizes.
 #
-#[ NFSMount_Global_Options ]
+[ NFSMount_Global_Options ]
 # This statically named section defines global mount 
 # options that can be applied on all NFS mount.
 #
 # Protocol Version [2,3]
 # Nfsvers=3
-# Network Transport [Udp,Tcp,Rdma]
-# Proto=Tcp
+#
+# Network Transport [udp,tcp,rdma] (Note: values are case sensitive)
+# Proto=tcp
 #
 # The number of times a request will be retired before 
 # generating a timeout 
