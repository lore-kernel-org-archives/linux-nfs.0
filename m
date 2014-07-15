Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:35549 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347AbaGOOYU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 10:24:20 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: [PATCH v3 00/21] NFS/RDMA client patches for 3.17
Message-Id: <59034BAD-306F-462F-A274-3EB06C0CBE47@oracle.com>
Date: Tue, 15 Jul 2014 10:24:16 -0400
To: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The main purpose of this series is to address connection drop
recovery issues by fixing FRMR re-use to make it less likely the
client will deadlock due to a memory management operation error.

Some clean-ups and other fixes are present as well.

See topic branch nfs-rdma-for-3.17 in

git://git.linux-nfs.org/projects/cel/cel-2.6.git

I tested with NFSv3 and NFSv4 on all three supported memory
registration modes. Used cthon04, iozone, and dbench with both
Solaris and Linux NFS/RDMA servers. Used xfstests with Linux.

v3:
Only two substantive changes:

- Patch 08/21 now uses generic IB helpers for managing FRMR
  rkeys

- Add Tested-by: from Steve Wise


v2:
Many patches from v1 have been written or replaced.

The MW ref counting approach in v1 is abandoned. Instead, I've
eliminated signaling FAST_REG_MR and LOCAL_INV, and added
appropriate recovery mechanisms after a transport reconnect that
should prevent rkey dis-synchrony entirely.

A couple of optimizations have been added, including:

- Allocating each MW separately rather than carving each out of a
  large piece of contiguous memory

- Now that the receive CQ upcall handler dequeues a bundle of CQEs
  at once, fire off the reply handler tasklet just once per upcall
  to reduce context switches and how often hard IRQs are disabled

Jury is still out on the latter.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



