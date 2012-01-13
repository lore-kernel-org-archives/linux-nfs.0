Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932561Ab2AMULL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:11 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 00/44] NFS: Create NFS Modules
Date: Fri, 13 Jan 2012 15:10:09 -0500
Message-Id: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch series turns NFS v2, v3 and v4 into loadable kernel modules that
need to be loaded before using.  This should eventually help clean up all of
the NFS code by giving us a chance to remove most of the ifdefs that check
for CONFIG_NFS_V3 and CONFIG_NFS_V4.

I move as much code as I needed to get everything to compile, so removing
all the ifdefs will still require a bit more work.  I'm hoping that this is
a good start, however.  Whenever I created a new file with copy and pasted
code I copied the copyright line from the original file.  If somebody else
has the copyright let me know and I'll change the copyright line in a future
version of these patches.

Parts of NFS 4.1 are still compiled into the generic client but other parts
have migrated into the nfs4.ko module.  Therefore, to use v4.1 you will need
to run `modprobe nfs4`.

Patch Map
---------
- Patches 01 and 02 do basic preparations
- Patch 03 make NFS v2 a Kconfig option
- Patch 04 adds in the NFS version registering framework
- Patches 05 - 07 turn NFS v2 into a loadable module, note that v2 is directly
  compiled into nfs.ko until patch 07.
- Patches 08 - 12 do the setup and conversion of v3 into a loadable module
  with updates to the v2 module happening in patch 08.  v3 isn't a module until
  patch 12.
- Patch 13 is a small cleanup patch to remove code that is no longer used once
  v2 and v3 are turned into modules.
- Patch 14 - 44 do the necessary preperations and conversion of v4 into a
  kernel module.  Updates to the v2 and v3 modules happen througout the
  preparation patches.  v4 is moved into its own subdirectory in patch 14
  and I gradually move code over throughout the rest of the patches to avoid
  a huge "copy everything at once" patch.  v4 is still compiled into nfs.ko
  until patch 44 is applied.

Is there a `git diff` shortcut for moving a large chunk of code from one file
to another?  Patch 37 and 41 move #ifdef CONFIG_NFS_V4 blocks into the nfs4/
subdirectory, but so much needed to be moved to keep everything bisectable
that both patches are 1300+ lines.  The patches leading up to both of these
do the necessary work so I could cut and paste code without having to do much
else to get it to compile.

I use a function pointer set in an nfs_subversion structure to determine if
a v2, v3, or v4 implementation should be called in various places.  Most of
these function pointers had to be addid in places where NFS v4 did something
slighly differently.  I would eventually like to see if any of the function
pointers can be removed by defining new nfs4 functions in any of the nfs4
structures (file_system_type, super_operations, inode_operations, ...).

Comments and suggestions are appreciated.  Thanks!

- Bryan

