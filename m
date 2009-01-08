From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] struct pmap stuffing
Date: Thu, 08 Jan 2009 12:32:35 -0500
Message-ID: <20090108172526.19893.91621.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:30043 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbZAHRdQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2009 12:33:16 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Happy New Year.  Continuing with the IPv6 patch series for the NFS
mount command, I bring you five more patches.

These introduce a new facility for converting a set of NFS mount
options into a properly filled-in struct pmap, ripe for passing into
everyday existing functions like nfs_getport().

The final patches in today's set use this new facility to correct a
number of problems with the text-based mount command's NFS version
detection and fallback logic.

The next set of patches will use this new facility to bring IPv6
support to umount.nfs.

If you have some unit tests for mount.nfs handling version fallback
and/or operating in an environment that does not have an accessible
portmapper on the server, please try them with this series applied.

---

Chuck Lever (5):
      text-based mount command: support AF_INET6 in rewrite_mount_options()
      text-based mount command: fix mount option rewriting logic
      text-based mount options: Use new pmap stuffer when rewriting mount options
      text-based mount command: Function to stuff "struct pmap" from mount options
      text-based mount command: make po_rightmost() work for N options


 utils/mount/network.c   |  214 ++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h   |    5 +
 utils/mount/parse_opt.c |   28 +++--
 utils/mount/parse_opt.h |    9 --
 utils/mount/stropts.c   |  253 ++++++++++++++++++++++++++---------------------
 5 files changed, 378 insertions(+), 131 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
