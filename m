Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5786C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:23:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9520520874
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:23:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387865AbeLQQXh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:23:37 -0500
Received: from relay.sw.ru ([185.231.240.75]:51788 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387823AbeLQQXg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Dec 2018 11:23:36 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gYvg6-0000zk-5J; Mon, 17 Dec 2018 19:23:34 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 0/4] use-after-free in svc_process_common()
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>,
        Konstantin Khorenko <khorenko@virtuozzo.com>
Message-ID: <8452a70e-b64b-8afc-d51e-e41a5dfcd240@virtuozzo.com>
Date:   Mon, 17 Dec 2018 19:23:33 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Unfortunately nfsv41+ clients are still not properly net-namespace-filied.

OpenVz got report on crash in svc_process_common() 
abd founf that bc_svc_process() cannot use serv->sv_bc_xprt as a pointer.

serv is global structure, but sv_bc_xprt is assigned per-netnamespace.
If nfsv41+ shares (with the same minorversion) are mounted in several containers together
then bc_svc_process() can use wrong backchannel or even access freed memory.

OpenVz got report on crash svc_process_common(),
and after careful investigations Evgenii Shatokhin have found its reproducer.
Then I've reproduced the problem on last mainline kernel.

In described scenario you need to have: 
- nodeA: VM with 2 interfaces and debug kernel with enabled KASAN.
- nodeB: any other node 
- NFS-SRV: NFSv41+ server (4.2 is used in exaple below) 

1) nodeA: mount nfsv41+ share
# mount -t nfs4 -o vers=4.2 NFS-SRV:/export/ /mnt/ns1
  VvS: here serv->sv_bc_xprt is assigned first time,
       in xs_tcp_bc_up() it is assigned to svc_xprt of mount's backchannel

2) nodeA: create net namespace, and mount the same (or any other) NFSv41+ share
# ip netns add second
# ip link set ens2 netns second
# ip netns exec second bash
(inside netns second) # dhclient ens2 
  VvS: now nets got access to external network
(inside netns second) # mount -t nfs4 -o vers=4.2 NFS-SRV:/export/ /mnt/ns2 
  VvS: now serv->sv_bc_xprt is overwritten by reference to svc_xprt of new mount's backchannel
  NB: you can mount any other NFS share but minorversion must be the same.
  NB2: if hardware allows you can use rdma transport here
  NB3: you can access nothing in mounted share, problem's trigger was enabled already.

3) NodeA, destroy mount inside netns and then netns itself.

(inside netns second) # umount /mnt/ns2
(inside netns second) # ip link set ens2 netns 1
(inside netns second) # exit
   VvS: return to init_net
# ip netns del second
   VvS: now second NFS mount and second net namespace was destroyed.

4) Node A: prepare backchannel event
# echo test1 > /mnt/ns1/test1.txt
# echo test2 > /mnt/ns1/test2.txt
# python
>>> fl=open('/mnt/ns1/test1.txt','r')
>>>

4) Node B: replace file open by NodeA
# mount -t nfs -o vers=4.2 NFS-SRV:/export/ /mnt/
# mv /mnt/test2.txt /mnt/test1.txt

===> KASAN on nodeA detect an access to already freed memory.
(see dmesg example below for details)

svc_process_common() 
        /* Setup reply header */
        rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp); <<< HERE

svc_process_common() uses already freed rqstp->rq_xprt,
it was assigned in bc_svc_process() where it was taken from serv->sv_bc_xprt.

serv->sv_bc_xprt cannot be used as a pointer,
it can be assigned per net-namespace, either in svc_bc_tcp_create() 
or in xprt_rdma_bc_up(). 
(Hopefully both transports cannot be used together in the same netns)

To fix this problem I've added new callback to struct rpc_xprt_ops,
it calls svc_find_xprt with proper name of transport's backchannel.

serv->sv_bc_xprt is used in svc_is_backchannel() too.
Here this filed is used not as pointer but as some mark of 
backchannel-compatible svc servers.
My 2nd patch replaces sv_bc_xprt pointer to boolean flag,
I hope it helps to prevent misuse of sv_bc_xprt in future.

3rd and 4th pathces are minor cleanup in debug messages. 

Vasily Averin (4):
  nfs: serv->sv_bc_xprt misuse in bc_svc_process()
  nfs: remove sv_bc_enabled using in svc_is_backchannel()
  nfs: minor typo in nfs4_callback_up_net()
  nfs: fix debug message in svc_create_xprt()

 fs/nfs/callback.c                        |  2 +-
 include/linux/sunrpc/bc_xprt.h           | 10 ++++------
 include/linux/sunrpc/svc.h               |  2 +-
 include/linux/sunrpc/xprt.h              |  1 +
 net/sunrpc/svc.c                         | 22 ++++++++++++++++------
 net/sunrpc/svc_xprt.c                    |  4 ++--
 net/sunrpc/svcsock.c                     |  2 +-
 net/sunrpc/xprtrdma/backchannel.c        |  5 +++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  2 +-
 net/sunrpc/xprtrdma/transport.c          |  1 +
 net/sunrpc/xprtrdma/xprt_rdma.h          |  1 +
 net/sunrpc/xprtsock.c                    |  7 +++++++
 12 files changed, 41 insertions(+), 18 deletions(-)

-- 
2.17.1

 ==================================================================
 BUG: KASAN: use-after-free in svc_process_common+0xec/0xd80 [sunrpc]
 Read of size 8 at addr ffff8881d69d4590 by task NFSv4 callback/1907
 
 CPU: 0 PID: 1907 Comm: NFSv4 callback Not tainted 4.20.0-rc6+ #1
 Hardware name: Virtuozzo KVM, BIOS 1.10.2-3.1.vz7.3 04/01/2014
 Call Trace:
  dump_stack+0xc6/0x150
  ? dump_stack_print_info.cold.0+0x1b/0x1b
  ? kmsg_dump_rewind_nolock+0x59/0x59
  ? _raw_write_lock_irqsave+0x100/0x100
  ? __switch_to_asm+0x34/0x70
  ? svc_process_common+0xec/0xd80 [sunrpc]
  print_address_description+0x65/0x22e
  ? svc_process_common+0xec/0xd80 [sunrpc]
  kasan_report.cold.5+0x241/0x306
  svc_process_common+0xec/0xd80 [sunrpc]
  ? __cpuidle_text_end+0x8/0x8
  ? _raw_write_lock_irqsave+0xe0/0x100
  ? svc_printk+0x190/0x190 [sunrpc]
  ? __cpuidle_text_end+0x8/0x8
  ? _raw_write_lock_irqsave+0xe0/0x100
  ? prepare_to_wait+0x11f/0x210
  bc_svc_process+0x24b/0x3a0 [sunrpc]
  ? kthread_freezable_should_stop+0xff/0x170
  ? svc_fill_symlink_pathname+0xe0/0xe0 [sunrpc]
  ? _raw_spin_lock+0xe0/0xe0
  nfs41_callback_svc+0x2c1/0x340 [nfsv4]
  ? nfs_map_gid_to_group+0x230/0x230 [nfsv4]
  ? finish_wait+0x1f0/0x1f0
  ? wait_woken+0x130/0x130
  ? _raw_write_lock_irqsave+0xe0/0x100
  ? __cpuidle_text_end+0x8/0x8
  ? nfs_map_gid_to_group+0x230/0x230 [nfsv4]
  kthread+0x1ae/0x1d0
  ? kthread_park+0xb0/0xb0
  ret_from_fork+0x35/0x40
 Allocated by task 1923:
  kasan_kmalloc+0xbf/0xe0
  kmem_cache_alloc_trace+0x125/0x270
  svc_bc_tcp_create+0x38/0x80 [sunrpc]
  _svc_create_xprt+0x2dd/0x400 [sunrpc]
  svc_create_xprt+0x58/0xd0 [sunrpc]
  xs_tcp_bc_up+0x22/0x30 [sunrpc]
  nfs_callback_up+0x226/0x660 [nfsv4]
  nfs4_init_client+0x2e5/0x4b0 [nfsv4]
  nfs_get_client+0x7d3/0x860 [nfs]
  nfs4_set_client+0x1ef/0x290 [nfsv4]
  nfs4_create_server+0x268/0x520 [nfsv4]
  nfs4_remote_mount+0x31/0x60 [nfsv4]
  mount_fs+0x5c/0x19d
  vfs_kern_mount.part.33+0xbc/0x2a0
  nfs_do_root_mount+0x7f/0xc0 [nfsv4]
  nfs4_try_mount+0x7f/0xd0 [nfsv4]
  nfs_fs_mount+0xd10/0x1430 [nfs]
  mount_fs+0x5c/0x19d
  vfs_kern_mount.part.33+0xbc/0x2a0
  do_mount+0x3ab/0x16d0
  ksys_mount+0xba/0xd0
  __x64_sys_mount+0x62/0x70
  do_syscall_64+0x112/0x310
  entry_SYSCALL_64_after_hwframe+0x44/0xa9

 Freed by task 1984:
  __kasan_slab_free+0x125/0x170
  kfree+0x90/0x1e0
  svc_xprt_free+0xbc/0xe0 [sunrpc]
  svc_delete_xprt+0x44c/0x4d0 [sunrpc]
  svc_close_net+0x2de/0x340 [sunrpc]
  svc_shutdown_net+0x14/0x50 [sunrpc]
  nfs_callback_down_net+0x105/0x140 [nfsv4]
  nfs_callback_down+0x4d/0xf0 [nfsv4]
  nfs4_free_client+0x123/0x130 [nfsv4]
  nfs_put_client.part.6+0x392/0x3d0 [nfs]
  nfs41_sequence_release+0xb5/0x100 [nfsv4]
  rpc_free_task+0x5d/0xa0 [sunrpc]
  __rpc_execute+0x6f0/0x700 [sunrpc]
  process_one_work+0x5bd/0x9e0
  worker_thread+0x181/0xa90
  kthread+0x1ae/0x1d0
  ret_from_fork+0x35/0x40

 The buggy address belongs to the object at ffff8881d69d4588
  which belongs to the cache kmalloc-4k of size 4096
 The buggy address is located 8 bytes inside of
  4096-byte region [ffff8881d69d4588, ffff8881d69d5588)
 The buggy address belongs to the page:
 page:ffffea00075a7400 count:1 mapcount:0 mapping:ffff8881f600ea40 index:0x0 compound_mapcount: 0
 flags: 0x17ffe000010200(slab|head)
 raw: 0017ffe000010200 ffffea0007c26e08 ffffea000774a808 ffff8881f600ea40
 raw: 0000000000000000 0000000000070007 00000001ffffffff 0000000000000000
 page dumped because: kasan: bad access detected

 Memory state around the buggy address:
  ffff8881d69d4480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
  ffff8881d69d4500: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 >ffff8881d69d4580: fc fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                          ^
  ffff8881d69d4600: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8881d69d4680: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ==================================================================
