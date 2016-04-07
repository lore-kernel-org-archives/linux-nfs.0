Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:51188 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278AbcDGWjF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Apr 2016 18:39:05 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1aoIZr-0004iE-Hh
	for linux-nfs@vger.kernel.org; Fri, 08 Apr 2016 00:39:03 +0200
Received: from p579d0048.dip0.t-ipconnect.de ([87.157.0.72])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 08 Apr 2016 00:39:03 +0200
Received: from holger.hoffstaette by p579d0048.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 08 Apr 2016 00:39:03 +0200
To: linux-nfs@vger.kernel.org
From: Holger =?iso-8859-1?q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: Strange "SECINFO: security flavor .." messages
Date: Thu, 7 Apr 2016 22:38:55 +0000 (UTC)
Message-ID: <pan$2228f$c97142f2$8c4f16d6$23d82166@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

After restarting my server and a client re-automounts, I see the
following in the server's dmesg:

[  706.454187] NFS: SECINFO: security flavor 390003 is not supported
[  706.454621] NFS: SECINFO: security flavor 390004 is not supported
[  706.455057] NFS: SECINFO: security flavor 390005 is not supported

I've been completely unsuccessful in trying to discern what these
mean and how I can get rid of them; they don't seem to be harmful
since everything else works just fine, and has done so for years.
I think this started with NFS 4.2 not too long ago, but don't remember
for certain. The server exports several mounts, ext4 and xfs.
Clients use only NFS v4 via automount. All on 4.4.6.

Relevant server config excerpt:

holger>grep NFS /etc/kernels/kernel-config-x86_64-4.4.6
CONFIG_KERNFS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V2=m
CONFIG_NFS_V3=m
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_NFS_V4_2=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_PNFS_FLEXFILE_LAYOUT=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
# CONFIG_NFS_V4_1_MIGRATION is not set
CONFIG_NFS_V4_SECURITY_LABEL=y
# CONFIG_NFS_FSCACHE is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFSD=m
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
CONFIG_NFSD_V4=y
# CONFIG_NFSD_PNFS is not set
CONFIG_NFSD_V4_SECURITY_LABEL=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_NFS_COMMON=y

CONFIG_NFS_V4_SECURITY_LABEL was recently added in the hope that this
might be it, but no luck.

Can anybody please explain what is missing here? It's not critical,
but I really don't like seemingly unnecessary log messages that I don't
understand.

Thanks!
Holger

