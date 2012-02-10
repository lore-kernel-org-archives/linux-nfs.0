Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab2BJWCL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:11 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 00/21] NFS: Create NFS Modules
Date: Fri, 10 Feb 2012 17:01:45 -0500
Message-Id: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch series turns NFS v2, v3 and v4 into loadable kernel modules that
need to be loaded before using.  This should eventually help clean up all of
the NFS code by giving us a chance to remove most of the ifdefs that check
for CONFIG_NFS_V3 and CONFIG_NFS_V4.

This time around, I tried to move as little code as possible while still
getting everything to compile as their own module.  I still had to move a
large chunk of v4 specific code from super.c, but most other files should be
(mostly) untouched.  Rather than creating new subdirectories, I instead kept
everything in fs/nfs/, significantly cutting down on the number of patches
to modularize everything.

These patches are about a week out-of-date with Trond's nfs-for-next tree,
so I expect to spend some time addressing comments and updating them so they
apply nicely.  I have also found some bugs that I'll fix up in the next
version as well.

Patch Map
---------
- Patch 1 does basic preparations
- Patches 2 - 4 make NFS v2 an optional kernel module
- Patches 5 - 9 make NFS v3 an optional kernel module
- Patches 10 - 20 make NFS v4 an optional kernel module
- Patch 21 exports functions from nfs4.ko to nfs.ko to fix modpost errors

Known bugs
----------
- Depmod detects a dependency loop when you try to install
- #include errors when NFS v4 isn't enabled
- I don't yet use request_module()

Comments and suggestions are appreciated.  Thanks!

- Bryan
