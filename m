Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vps-1015933-8657.cp.tsukaeru.ne.jp ([175.45.136.198]:47888 "EHLO
	vps-1015933-8657.cp.tsukaeru.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754049AbaKOPN7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Nov 2014 10:13:59 -0500
Received: from www.qgenuity.com (localhost [IPv6:::1])
	by vps-1015933-8657.cp.tsukaeru.ne.jp (Postfix) with ESMTPA id 719B529E005C
	for <linux-nfs@vger.kernel.org>; Sun, 16 Nov 2014 00:07:23 +0900 (JST)
Message-ID: <e7097d3e747a2a1e46c37d88cea3c8a2.squirrel@www.qgenuity.com>
Date: Sun, 16 Nov 2014 00:07:23 +0900
Subject: Setting up NFS on Centos 6.6
From: cl@qgenuity.com
To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'm having an unusual amount of trouble setting up Centos 6.6 as an NFS
server. I have already created my exportfs file and run "chkconfig nfs
on".

My copy of centos is running inside a virtual bubble. The server provider
has loaded the nfsd module.

I run:
chkconfig nfs on
service rpcbind start
service nfs start

The final command produces:
# service nfs start
FATAL: Module nfsd not found.
FATAL: Error running install command for nfsd
Starting NFS services:                                     [  OK  ]
Starting NFS quotas:                                       [  OK  ]
Starting NFS mountd:                                       [  OK  ]
Starting NFS daemon:                                       [  OK  ]
Starting RPC idmapd:                                       [  OK  ]

(I've been following the guide found here:
http://openvz.org/NFS_server_inside_container which says that "module nfsd
not found" is no problem.)

showmount -e produces:
Export list for (server):
/(directory) (address)

but when I try to mount
mount -t nfs -v (address):/(dir) /mnt/nfs
mount.nfs: timeout set for (date)
mount.nfs: trying text-based options 'vers=4,addr=::1,clientaddr=::1'
mount.nfs: mount(2): No such device
mount.nfs: No such device


Does anyone know what I need to do to get nfs working?

Thank you.


