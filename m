From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: [BUG] nfs version 2 broken
Date: Wed, 01 Feb 2006 07:07:45 +0100
Message-ID: <43E05031.2000107@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: neilb@cse.unsw.edu.au, trond.myklebust@fys.uio.no,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030408AbWBAGHT@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi everybody,

The good news is that I finally succeeded to boot over network
using the PXE-bootrom / ip dhcp autoconfig / nfsroot method.
But "ip=dhcp root=/dev/nfs nfsroot=%s" is not the way to go
with recent kernels. This results in a kernel panic caused by
the inability to find root. Things go wrong immediately after
rpc port lookup:

 > NFS: Buggy server - nlink == 0!
 > nfs_fhget failed

Well, adding ",v3" to the nfsroot parameter helps, forcing the
client not to use the default nfs version 2 but nfs version 3.

All machines use kernel 2.6.15-git7.

cu,
 Knut
