Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga03-in.huawei.com ([119.145.14.66]:5029 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455Ab3LDFzR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 00:55:17 -0500
From: Weng Meiling <wengmeiling.weng@huawei.com>
To: <stable@vger.kernel.org>
CC: <bfields@fieldses.org>, <skinsbursky@parallels.com>,
        <linux-nfs@vger.kernel.org>, <lizefan@huawei.com>,
        <h.huangqiang@huawei.com>
Subject: [PATCH 3.4 0/9] fix the NULL pointer when use nfs in different net ns 
Date: Wed, 4 Dec 2013 13:53:26 +0800
Message-ID: <1386136415-30976-1-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When testing NFS in different network namespace with stable-3.4,
the situation start NFSd in one non init_net network namespace,
and stop it in another one will trigger kernel panic, because
RPCBIND client is stored per net, and will be NULL on NFSd shutdown.

Walk through the code, this problem also exists in stable-3.5
to stable-3.7. Stanislav Kinsbursky had committed a fixed patch
for 3.8: commit f7fb86c6e639360ad9c253cec534819ef928a674 (nfsd:
use "init_net" for portmapper). But it causes another bug, When
starting NFSd in a non init_net network namespace will trigger
kernel panic. Because RPCBIND client will be NULL when register
RPC service with the local portmapper in svc_addsock(). 
This new bug also exists in 3.8, but disappears after patch
commit 11f779421a39b86da8a523d97e5fd3477878d44f ("containerize
NFSd filesystem") in 3.9.

So backport Stanislav's patches from 3.8 to fix the former bug and 
cleanup init_net reference, and then using the current->nsproxy->net_ns
to repalce the init_net to make NFSd keep using a consistent network
namespace all the time to resolve the new bug.

After this patchset, testing NFS in different network namespace will
not trigger kernel panic any more, and other NFS client can use the 
NFS server's shared files normally which was started in init_net namespace:

# ip netns add test 
# ip netns list 
test
# ip netns exec test service nfsserver start 
Starting kernel based NFS server: idmapd mountd statd nfsd sm-notify    done
# service nfsserver status 
Checking for kernel based NFS server: idmapd                            running
 mountd                                                                 running
 statd                                                                  running
 nfsd                                                                   running
sles28:~ # 
# service nfsserver stop
Shutting down kernel based NFS server: nfsd statd mountd idmapd         done
# service nfsserver status 
Checking for kernel based NFS server: idmapd                            unused
 mountd                                                                 unused
 statd                                                                  unused
 nfsd                                                                   unused
 
# dmesg
[   74.505511] eth0: no IPv6 routers present
[   99.412867] RPC: Registered named UNIX socket transport module.
[   99.412871] RPC: Registered udp transport module.
[   99.412873] RPC: Registered tcp transport module.
[   99.412875] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   99.637872] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[  100.055152] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[  100.058699] NFSD: starting 90-second grace period
[  129.449088] nfsd: last server has exited, flushing export cache



Stanislav Kinsbursky (8):
  nfsd: use "init_net" for portmapper
  nfsd: pass net to nfsd_init_socks()
  nfsd: pass net to nfsd_startup() and nfsd_shutdown()
  nfsd: pass net to nfsd_create_serv()
  nfsd: pass net to nfsd_svc()
  nfsd: pass net to nfsd_set_nrthreads()
  nfsd: pass net to __write_ports() and down
  nfsd: pass proper net to nfsd_destroy() from NFSd kthreads
  
Weng Meiling (1):  
  nfsd: use the current net ns in write_threads() and write_ports()

 fs/nfsd/nfsctl.c | 34 +++++++++++++++++++---------------
 fs/nfsd/nfsd.h   |  6 +++---
 fs/nfsd/nfssvc.c | 40 +++++++++++++++++++---------------------
 3 files changed, 41 insertions(+), 39 deletions(-)

-- 
1.8.2.2


