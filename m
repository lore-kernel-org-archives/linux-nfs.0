Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:54075 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755042Ab3KUCOT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Nov 2013 21:14:19 -0500
From: mark.doffman@codethink.co.uk
To: ceph-devel@vger.kernel.org
Cc: Rob Taylor <rob.taylor@codethink.co.uk>, sage@inktank.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Mark Doffman <mark.doffman@codethink.co.uk>
Subject: [PATCH 2/4] Documentation: Document the cephroot functionality
Date: Wed, 20 Nov 2013 20:13:42 -0600
Message-Id: <1385000024-23463-3-git-send-email-mark.doffman@codethink.co.uk>
In-Reply-To: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
References: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Rob Taylor <rob.taylor@codethink.co.uk>

Document using the cephfs as a root device, its purpose,
functionality and use.

Signed-off-by: Mark Doffman <mark.doffman@codethink.co.uk>
Signed-off-by: Rob Taylor <rob.taylor@codethink.co.uk>
Reviewed-by: Ian Molton <ian.molton@codethink.co.uk>
---
 Documentation/filesystems/{ => ceph}/ceph.txt |  0
 Documentation/filesystems/ceph/cephroot.txt   | 81 +++++++++++++++++++++++++++
 2 files changed, 81 insertions(+)
 rename Documentation/filesystems/{ => ceph}/ceph.txt (100%)
 create mode 100644 Documentation/filesystems/ceph/cephroot.txt

diff --git a/Documentation/filesystems/ceph.txt b/Documentation/filesystems/ceph/ceph.txt
similarity index 100%
rename from Documentation/filesystems/ceph.txt
rename to Documentation/filesystems/ceph/ceph.txt
diff --git a/Documentation/filesystems/ceph/cephroot.txt b/Documentation/filesystems/ceph/cephroot.txt
new file mode 100644
index 0000000..ae0f5bb
--- /dev/null
+++ b/Documentation/filesystems/ceph/cephroot.txt
@@ -0,0 +1,81 @@
+Mounting the root filesystem via Ceph (cephroot)
+===============================================
+
+Written 2013 by Rob Taylor <rob.taylor@codethink.co.uk>
+
+derived from nfsroot.txt:
+
+Written 1996 by Gero Kuhlmann <gero@gkminix.han.de>
+Updated 1997 by Martin Mares <mj@atrey.karlin.mff.cuni.cz>
+Updated 2006 by Nico Schottelius <nico-kernel-nfsroot@schottelius.org>
+Updated 2006 by Horms <horms@verge.net.au>
+
+
+
+In order to use a diskless system, such as an X-terminal or printer server
+for example, it is necessary for the root filesystem to be present on a
+non-disk device. This may be an initramfs (see Documentation/filesystems/
+ramfs-rootfs-initramfs.txt), a ramdisk (see Documentation/initrd.txt), a
+filesystem mounted via NFS or a filesystem mounted via Ceph. The following
+text describes on how to use Ceph for the root filesystem.
+
+For the rest of this text 'client' means the diskless system, and 'server'
+means the Ceph server.
+
+
+1.) Enabling cephroot capabilities
+    -----------------------------
+
+In order to use cephroot, CEPH_FS needs to be selected as
+built-in during configuration. Once this has been selected, the cephroot
+option will become available, which should also be selected.
+
+In the networking options, kernel level autoconfiguration can be selected,
+along with the types of autoconfiguration to support. Selecting all of
+DHCP, BOOTP and RARP is safe.
+
+
+2.) Kernel command line
+    -------------------
+
+When the kernel has been loaded by a boot loader (see below) it needs to be
+told what root fs device to use. And in the case of cephroot, where to find
+both the server and the name of the directory on the server to mount as root.
+This can be established using the following kernel command line parameters:
+
+root=/dev/ceph
+
+This is necessary to enable the pseudo-Ceph-device. Note that it's not a
+real device but just a synonym to tell the kernel to use Ceph instead of
+a real device.
+
+cephroot=<monaddr>:/[<subdir>],<ceph-opts>
+
+  <monaddr>     Monitor address. Each takes the form host[:port]. If the port
+		is not specified, the Ceph default of 6789 is assumed.
+
+  <subdir>	A subdirectory subdir may be specified if a subset of the file
+		system is to be mounted
+
+  <ceph-opts>	Standard Ceph options. All options are separated by commas.
+		See Documentation/filesystems/ceph/ceph.txt for options and
+		their defaults.
+
+4.) References
+    ----------
+
+
+5.) Credits
+    -------
+
+  cephroot was derived from nfsroot by Rob Taylor <rob.taylor@codethink.co.uk>
+  and Mark Doffman <mark.doffman@codethink.co.uk>
+
+  The nfsroot code in the kernel and the RARP support have been written
+  by Gero Kuhlmann <gero@gkminix.han.de>.
+
+  The rest of the IP layer autoconfiguration code has been written
+  by Martin Mares <mj@atrey.karlin.mff.cuni.cz>.
+
+  In order to write the initial version of nfsroot I would like to thank
+  Jens-Uwe Mager <jum@anubis.han.de> for his help.
-- 
1.8.4

