Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFA7FC43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:31:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB8EC21917
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:31:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2390160AbeLURbb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Dec 2018 12:31:31 -0500
Received: from relay.sw.ru ([185.231.240.75]:40664 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731522AbeLURbb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Dec 2018 12:31:31 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gaOdv-0004s8-4h; Fri, 21 Dec 2018 20:31:23 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v3 0/8] use-after-free in svc_process_common()
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
Message-ID: <3c84476a-ce26-1171-b6e3-42d6ca3dc6e5@virtuozzo.com>
Date:   Fri, 21 Dec 2018 20:31:22 +0300
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

v3:
- first patch was reworked again,
  instead of svc_xprt search svc_process_common() now uses 
  bc_prep_reply_hdr() function pointer saved on per-netns sunrpc_net.
- first patch was splitted into 5 parts.
- comments cleanup

v2:
- first patch was reworked to satisfy Trond's requirements:
  to do not assign rqstp->rq_xprt in svc_process_common() at all,
  provide proper xpt_ops reference as a new parameter,
  adopt functions potentially called from svc_process_common() 
   to properly handle rqstp->rq_xprt = NULL case.


nfsv41+ clients are still not properly net-namespace-filied.

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
(see dmesg example in attach of v1 patch version)

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

According to Trond, the whole "let's set up rqstp->rq_xprt
for the back channel" is nothing but a giant hack in order
to work around the fact that svc_process_common() uses it
to find the xpt_ops, and perform a couple of (meaningless
for the back channel) tests of xpt_flags.

Trond proposed to pass in the xpt_ops as a new parameter to
svc_process_common(), and make those xpt_flags tests check
for whether or not rqstp->rq_xprt is actually non-NULL.

It also required to store a pointer to struct net in the
struct svc_rqst so that functions called from inside
svc_process_common() (nfs4_callback_compound(),
svcauth_gss_accept() and some other) can find it.
Some other functions was adopted to handle empty rqstp->rq_xprt

First patch now switches svnauth_gss-* function to use SVC_NET()
2nd patch introduces svc_rqst->rq_bc_net used during processing 
 of back channel requests
3rd patch introduces sunrpc_net->bc_prep_reply_hdr function pointer
4rd patch is fix of use-after-free

5th patch replaces sv_bc_xprt pointer to boolean flag,
serv->sv_bc_xprt is used in svc_is_backchannel() too.
Here this field is used not as pointer but as some mark of 
back channel-compatible svc servers.

Rest of patches are minor cleanup. 

Vasily Averin (8):
  sunrpc: use SVC_NET() in svcauth_gss_* functions
  sunrpc: introduce svc_rqst->rq_bc_net
  sunrpc: introduce per-netns sunrpc_net->bc_prep_reply_hdr()
  sunrpc: use-after-free in svc_process_common()
  nfs: remove sv_bc_enabled using in svc_is_backchannel()
  sunrpc: make visible processing error in bc_svc_process()
  sunrpc: fix debug message in svc_create_xprt()
  nfs: minor typo in nfs4_callback_up_net()

 fs/nfs/callback.c                        |  2 +-
 include/linux/sunrpc/bc_xprt.h           | 10 ++++------
 include/linux/sunrpc/svc.h               |  8 +++++---
 include/trace/events/sunrpc.h            |  6 ++++--
 net/sunrpc/auth_gss/svcauth_gss.c        |  8 ++++----
 net/sunrpc/netns.h                       |  2 ++
 net/sunrpc/svc.c                         | 22 +++++++++++++++-------
 net/sunrpc/svc_xprt.c                    | 14 ++++++++++----
 net/sunrpc/svcsock.c                     |  5 ++++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  2 +-
 10 files changed, 50 insertions(+), 29 deletions(-)

-- 
2.17.1

