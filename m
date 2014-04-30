Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga03-in.huawei.com ([119.145.14.66]:45457 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbaD3Cqq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 22:46:46 -0400
From: Weng Meiling <wengmeiling.weng@huawei.com>
To: <stable@vger.kernel.org>
CC: <bfields@fieldses.org>, <greg@kroah.com>, <lizefan@huawei.com>,
        <skinsbursky@parallels.com>, <h.huangqiang@huawei.com>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3.4 0/9] fix the NULL pointer when use nfs in diferent net ns
Date: Wed, 30 Apr 2014 10:43:35 +0800
Message-ID: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After 3.4 stable apply commit f7fb86c6e639(nfsd: use "init_net"
for portmapper). When starting NFSd in a non init_net network 
namespace will trigger kernel panic. Because RPCBIND client 
will be NULL when register RPC service with the local portmapper
in svc_addsock(). This new bug also exists in 3.8, but disappears
after patch commit 11f779421a39("containerize NFSd filesystem") in
3.9. 

So backport Stanislav's patches from 3.8 and 3.9 to cleanup init_net
reference, and get proper network namespace from superblock instead of 
using hard-coded "init_net" to make NFSd keep using a consistent network
namespace all the time to resolve the bug.

After this patchset, testing NFS in different network namespace will
not trigger kernel panic any more, and other NFS client can use the 
NFS server's shared files normally which was started in init_net namespace.

v1->v2:
- no commit 7fb86c6e639(nfsd: use "init_net" for portmapper) which has been
  apply to 3.4 stable in the first version
- one more fix patch commit 3064639423c4(nfsd: check passed socket's net matches
  NFSd superblock's one) for commit 11f779421a39("nfsd: containerize NFSd filesystem")
- fix build error for commit db6e182c17cb(nfsd: pass net to nfsd_init_socks())

Stanislav Kinsbursky (9):
  nfsd: pass net to nfsd_init_socks()
  nfsd: pass net to nfsd_startup() and nfsd_shutdown()
  nfsd: pass net to nfsd_create_serv()
  nfsd: pass net to nfsd_svc()
  nfsd: pass net to nfsd_set_nrthreads()
  nfsd: pass net to __write_ports() and down
  nfsd: pass proper net to nfsd_destroy() from NFSd kthreads
  nfsd: containerize NFSd filesystem
  nfsd: check passed socket's net matches NFSd superblock's one

 fs/nfsd/nfsctl.c               | 62 +++++++++++++++++++++++++++++-------------
 fs/nfsd/nfsd.h                 |  6 ++--
 fs/nfsd/nfssvc.c               | 41 ++++++++++++++--------------
 include/linux/sunrpc/svcsock.h |  1 +
 net/sunrpc/svcsock.c           | 16 +++++++++++
 5 files changed, 83 insertions(+), 43 deletions(-)

-- 
1.8.2.2


