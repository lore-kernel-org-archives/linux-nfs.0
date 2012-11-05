Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:54470 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932251Ab2KEOy4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Nov 2012 09:54:56 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1TVO4u-0000en-8W
	for linux-nfs@vger.kernel.org; Mon, 05 Nov 2012 15:55:04 +0100
Received: from host182-56-static.77-62-b.business.telecomitalia.it ([62.77.56.182])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 15:55:04 +0100
Received: from fattorare by host182-56-static.77-62-b.business.telecomitalia.it with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 15:55:04 +0100
To: linux-nfs@vger.kernel.org
From: Giovanni <fattorare@gmail.com>
Subject: PNFS Kernel - =?utf-8?b?Q09ORklHX1NQTkZT?= not found
Date: Mon, 5 Nov 2012 14:49:39 +0000 (UTC)
Message-ID: <loom.20121105T154655-381@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
I'm trying to compile the kernel in order to enable pnfs feature present in NFS
4.1 following this guide http://linux-
nfs.org/wiki/index.php/Configuring_pNFS/spnfsd
I downloaded the git repository for the kernel from git://git.linux-
nfs.org/projects/bhalevy/linux-pnfs.git
I didn't found where I can enable the kernel options CONFIG_SPNFS and
CONFIG_SPNFS_LAYOUTSEGMENT. I have found all the other options required by PNFS.
I didn't found this two string also in the source code:

[root@rh62ds1 linux-pnfs]# find .|xargs grep CONFIG_SPNFS
[root@rh62ds1 linux-pnfs]#

I have tried using the latest commit and also with the commit id
cbd09e0fb2b160a06a44aad1c21786b99401823f  as reported in the wiki guide but the
result is the same.
If I don't select this two feature, later I obtain a error when I try to execute
the process spnfsd exit with error because it doesn't found the file
/proc/fs/spnfs/ctl

Can you help me?

Giovanni Sciortino

