Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31605 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757626Ab0D3QuN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Apr 2010 12:50:13 -0400
Message-ID: <4BD9BF01.2000508@panasas.com>
Date: Thu, 29 Apr 2010 20:16:49 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
CC: pNFS Mailing List <pnfs@linux-nfs.org>, Steve Dickson <steved@redhat.com>
Subject: pnfs git tree status 2010-04-29
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I released the following today:

pnfs-all-2.6.33-2010-04-29
pnfs-all-2.6.34-rc5-2010-04-29

As usual, cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff v2.6.33 pnfs-all-2.6.33-2010-04-29
git diff v2.6.34-rc5 pnfs-all-2.6.34-rc5-2010-04-29

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

Latest patches (since 2010-04-21):

pnfs-all-2.6.33:
Benny Halevy (1):
      pnfs-block: revert workaround for NFS4_GETDEVINFO_MAXSIZE

J. Bruce Fields (1):
      pnfs-block: fix compile breakage

Mike Sager (1):
      pnfsblock: use the session max response size for getdeviceinfo's maxcount

Zhang Jingwang (1):
      SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents

Zhengju Sha (1):
      pnfsd: using sbid instead of fsid while returning device list to client

nfs-upstream:
Trond Myklebust (1):
      NFS: Fix an unstable write data integrity race

pnfs-submit:
Tao Guo (1):
      pnfs: Reduce layout lookup times with sorted lseg list.

pnfs-block:
J. Bruce Fields (1):
      SQUASHME: pnfs-block: fix compile breakage

Mike Sager (1):
      pnfsblock: use the session max response size for getdeviceinfo's maxcount

Zhang Jingwang (1):
      SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents

pnfsd-files:
Benny Halevy (1):
      pnfsd: define layout_lock

Zhengju Sha (1):
      SQUASHME: pnfsd: using sbid instead of fsid while returning device list to client

