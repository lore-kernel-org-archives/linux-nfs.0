Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f53.google.com ([209.85.220.53]:62670 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab3L3LWr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Dec 2013 06:22:47 -0500
Received: by mail-pa0-f53.google.com with SMTP id hz1so11466253pad.26
        for <linux-nfs@vger.kernel.org>; Mon, 30 Dec 2013 03:22:47 -0800 (PST)
Message-ID: <52C1577B.9080100@gmail.com>
Date: Mon, 30 Dec 2013 19:22:35 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "J.,Bruce Fields" <bfields@fieldses.org>,
        Gareth Williams <gareth@garethwilliams.me.uk>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        trond.myklebust@primarydata.com
Subject: Re: Question ref Running NFS at V4 Only
References: <52B47A12.2070202@garethwilliams.me.uk>	<20131223173956.GA9221@fieldses.org>	<52BD53CA.5050205@gmail.com>	<7FD776EA-EAA8-41E0-9567-BF3924D365AC@oracle.com>	<20131227184309.GA9161@fieldses.org>	<01763B6D-C8CB-46B7-87AC-CE189496019A@oracle.com>	<6E281EC9-49CB-4BDA-BDF3-7A6F4B703156@gmail.com>	<CAB6yy34woYZaJ=k=Ga9iT_mmBWBiCUj1SprT=Se2SVrOu6YO_Q@mail.gmail.com>	<5D65FDE6-D1AB-442C-BFD8-141AB87FF321@gmail.com> <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com>
In-Reply-To: <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/29/2013 05:11 PM, Kinglong Mee wrote:
> Hi all,
> 
> I found the commit 561ec1603171cd9b38dcf6cac53e8710f437a48d
> "SUNRPC: call_connect_status should recheck bind and connect status on error"
> causes the loop. Without this patch, I can get error immediately as
> Williams reports.
> 
> I will make a patch for this problem without the commit.
> Before that, we need fix the loop.

After reverting that commit, two new patches for this problem will be sent out.

thanks,
Kinglong Mee
 
> On Sun, Dec 29, 2013 at 4:17 PM, Kinglong Mee <kinglongmee@gmail.com> wrote:
>> After open the debug log, found rpc.nfsd hang in a loop in __rpc_execute.
>>
>> [ 6179.978202] RPC:     1 sync task resuming
>> [ 6179.981254] RPC:     1 xprt_connect_status: retrying
>> [ 6179.984289] RPC:     1 call_connect_status (status -11)
>> [ 6179.987292] RPC:     1 call_bind (status 0)
>> [ 6179.990273] RPC:     1 call_connect xprt da4d5000 is not connected
>> [ 6179.993271] RPC:     1 xprt_connect xprt da4d5000 is not connected
>> [ 6179.996196] RPC:     1 sleep_on(queue "xprt_pending" time 5876962)
>> [ 6179.999043] RPC:     1 added to queue da4d518c "xprt_pending"
>> [ 6180.001885] RPC:     1 setting alarm for 60000 ms
>> [ 6180.004725] RPC:       xs_connect scheduled xprt da4d5000
>> [ 6180.007549] RPC:     1 sync task going to sleep
>> [ 6180.049927] RPC:       disconnecting xprt da4d5000 to reuse port
>> [ 6180.054460] RPC:       AF_UNSPEC connect return code 0
>> [ 6180.059560] RPC:       worker connecting xprt da4d5000 via tcp to
>> 127.0.0.1 (port 111)
>> [ 6180.062384] RPC:       xs_tcp_state_change client da4d5000...
>> [ 6180.065013] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
>> [ 6180.067891] RPC:       disconnected transport da4d5000
>> [ 6180.070465] RPC:     1 __rpc_wake_up_task (now 5877036)
>> [ 6180.073014] RPC:     1 disabling timer
>> [ 6180.075553] RPC:     1 removed from queue da4d518c "xprt_pending"
>> [ 6180.078036] RPC:       __rpc_wake_up_task done
>> [ 6180.080545] RPC:       da4d5000 connect status 115 connected 0 sock state
>> 7
>> [ 6180.085953] RPC:     1 sync task resuming
>> [ 6180.088376] RPC:     1 xprt_connect_status: retrying
>> [ 6180.090699] RPC:     1 call_connect_status (status -11)
>>
>> thanks,
>> Kinglong Mee
>>
>> 在 2013年12月29日，下午2:39，Kinglong Mee <kinglongmee@gmail.com> 写道：
>>
>> I get the trace when rpc.nfsd hang.
>>
>> 1608 Dec 29 14:25:12 localhost kernel: [ 1224.449293] rpc.nfsd
>> D c0d94300     0  1199    991 0x00000080
>>
>> 1609 Dec 29 14:25:12 localhost kernel: [ 1224.451347]  d9a9bc98
>> 00000086 c046aa48 c0d94300 ddb66540 c0d79300 58625871 0000011c
>>
>> 1610 Dec 29 14:25:12 localhost kernel: [ 1224.453426]  c0d79300
>> dfff4300 dcd93a80 c0461738 00000000 c0d94300 00000000 00000020
>>
>> 1611 Dec 29 14:25:12 localhost kernel: [ 1224.455701]  da4d53a0
>> 00000020 ddb66540 da4d53b0 d9a9bc84 c046add9 dcd93a80 00000292
>>
>> 1612 Dec 29 14:25:12 localhost kernel: [ 1224.457853] Call Trace:
>>
>> 1613 Dec 29 14:25:12 localhost kernel: [ 1224.459919]  [<c046aa48>] ?
>> insert_work+0x38/0x80
>>
>> 1614 Dec 29 14:25:12 localhost kernel: [ 1224.462055]  [<c0461738>] ?
>> mod_timer+0xe8/0x1c0
>>
>> 1615 Dec 29 14:25:12 localhost kernel: [ 1224.464230]  [<c046add9>] ?
>> __queue_delayed_work+0x89/0x140
>>
>> 1616 Dec 29 14:25:12 localhost kernel: [ 1224.466304]  [<e092d970>] ?
>> __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
>>
>> 1617 Dec 29 14:25:12 localhost kernel: [ 1224.468561]  [<c09bd543>]
>> schedule+0x23/0x60
>>
>> 1618 Dec 29 14:25:12 localhost kernel: [ 1224.470671]  [<e092d99d>]
>> rpc_wait_bit_killable+0x2d/0x80 [sunrpc]
>>
>> 1619 Dec 29 14:25:12 localhost kernel: [ 1224.472785]  [<c09bdae1>]
>> __wait_on_bit+0x51/0x70
>>
>> 1620 Dec 29 14:25:12 localhost kernel: [ 1224.474974]  [<e092d970>] ?
>> __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
>>
>> 1621 Dec 29 14:25:12 localhost kernel: [ 1224.477170]  [<e092d970>] ?
>> __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
>>
>> 1622 Dec 29 14:25:12 localhost kernel: [ 1224.479389]  [<c09bdb5b>]
>> out_of_line_wait_on_bit+0x5b/0x70
>>
>> 1623 Dec 29 14:25:12 localhost kernel: [ 1224.481739]  [<c048e440>] ?
>> autoremove_wake_function+0x40/0x40
>>
>> 1624 Dec 29 14:25:12 localhost kernel: [ 1224.483881]  [<e092e703>]
>> __rpc_execute+0x1f3/0x3a0 [sunrpc]
>>
>> 1625 Dec 29 14:25:12 localhost kernel: [ 1224.486030]  [<c0516283>] ?
>> mempool_alloc_slab+0x13/0x20
>>
>> 1626 Dec 29 14:25:12 localhost kernel: [ 1224.488194]  [<c051638e>] ?
>> mempool_alloc+0x3e/0x100
>>
>> 1627 Dec 29 14:25:12 localhost kernel: [ 1224.490307]  [<e0925d80>] ?
>> call_bind_status+0x260/0x260 [sunrpc]
>>
>> 1628 Dec 29 14:25:12 localhost kernel: [ 1224.492559]  [<c048e09c>] ?
>> wake_up_bit+0x1c/0x20
>>
>> 1629 Dec 29 14:25:12 localhost kernel: [ 1224.494844]  [<e092f866>]
>> rpc_execute+0x56/0x90 [sunrpc]
>>
>> 1630 Dec 29 14:25:12 localhost kernel: [ 1224.496935]  [<e0926cf9>]
>> rpc_run_task+0x59/0x70 [sunrpc]
>>
>> 1631 Dec 29 14:25:12 localhost kernel: [ 1224.499122]  [<e0926d4c>]
>> rpc_call_sync+0x3c/0x90 [sunrpc]
>>
>> 1632 Dec 29 14:25:12 localhost kernel: [ 1224.501260]  [<e0926de8>]
>> rpc_ping+0x48/0x60 [sunrpc]
>>
>> 1633 Dec 29 14:25:12 localhost kernel: [ 1224.503367]  [<e092703b>]
>> rpc_bind_new_program+0x4b/0x70 [sunrpc]
>>
>> 1634 Dec 29 14:25:12 localhost kernel: [ 1224.505608]  [<e0938333>]
>> rpcb_create_local+0x163/0x1f0 [sunrpc]
>>
>> 1635 Dec 29 14:25:12 localhost kernel: [ 1224.507720]  [<e0932199>] ?
>> __svc_create+0x119/0x1f0 [sunrpc]
>>
>> 1636 Dec 29 14:25:12 localhost kernel: [ 1224.509830]  [<e0932016>]
>> svc_rpcb_setup+0x16/0x30 [sunrpc]
>>
>> 1637 Dec 29 14:25:12 localhost kernel: [ 1224.511963]  [<e0932052>]
>> svc_bind+0x22/0x30 [sunrpc]
>>
>> 1638 Dec 29 14:25:12 localhost kernel: [ 1224.514056]  [<e09b73a4>]
>> nfsd_create_serv+0xc4/0x1d0 [nfsd]
>>
>> 1639 Dec 29 14:25:12 localhost kernel: [ 1224.516844]  [<e09b7600>] ?
>> nfsd_destroy+0x70/0x70 [nfsd]
>>
>> 1640 Dec 29 14:25:12 localhost kernel: [ 1224.518870]  [<e09b8d1f>]
>> write_ports+0x21f/0x2b0 [nfsd]
>>
>> 1641 Dec 29 14:25:12 localhost kernel: [ 1224.521359]  [<c06a182c>] ?
>> _copy_from_user+0x2c/0x40
>>
>> 1642 Dec 29 14:25:12 localhost kernel: [ 1224.523358]  [<c05854fe>] ?
>> simple_transaction_get+0x8e/0xa0
>>
>> 1643 Dec 29 14:25:12 localhost kernel: [ 1224.525383]  [<e09b8b00>] ?
>> write_recoverydir+0xf0/0xf0 [nfsd]
>>
>> 1644 Dec 29 14:25:12 localhost kernel: [ 1224.527386]  [<e09b7f3b>]
>> nfsctl_transaction_write+0x3b/0x60 [nfsd]
>>
>> 1645 Dec 29 14:25:12 localhost kernel: [ 1224.529302]  [<e09b7f00>] ?
>> export_features_show+0x30/0x30 [nfsd]
>>
>> 1646 Dec 29 14:25:12 localhost kernel: [ 1224.531366]  [<c0564695>]
>> vfs_write+0x95/0x1c0
>>
>> 1647 Dec 29 14:25:12 localhost kernel: [ 1224.533401]  [<c0564d49>]
>> SyS_write+0x49/0x90
>>
>> 1648 Dec 29 14:25:12 localhost kernel: [ 1224.535380]  [<c09c730d>]
>> sysenter_do_call+0x12/0x28
>>
>> thanks,
>> Kinglong Mee
>>
>> 2013/12/28 Kinglong Mee <kinglongmee@gmail.com>:
>>
>>
>> 在 2013年12月28日，上午3:40，Chuck Lever <chuck.lever@oracle.com> 写道：
>>
>>
>> On Dec 27, 2013, at 1:43 PM, J.;Bruce Fields <bfields@fieldses.org> wrote:
>>
>> On Fri, Dec 27, 2013 at 11:05:05AM -0500, Chuck Lever wrote:
>>
>> Hi-
>>
>> On Dec 27, 2013, at 5:17 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
>>
>> On 12/24/2013 01:39 AM, J. Bruce Fields wrote:
>>
>> On Fri, Dec 20, 2013 at 05:10:42PM +0000, Gareth Williams wrote:
>>
>> Hi,
>>
>> I'm trying to run NFS with protocol version 4 only (that is, with v2
>> & v3 disabled) on a CentOS 6.5 install running as a KVM guest.
>>
>> The RedHat documentation (amongst others) states that rpcbind isn't
>> needed with v4, but if I start nfs without rpcbind I get errors.
>>
>>
>> I suspect the kernel code needs to be fixed to not attempt to register
>> with rpcbind n the v4-only case.  (Or to attempt to register but ignore
>> any error, I'm not sure which is best.)
>>
>> And this may not be the only issue in the v4-only case.  This isn't
>> really a priority for me right now, but I'd happily look at patches.
>>
>>
>> Hi all,
>>
>> I make a patch for this problem, please have a check, thanks.
>>
>> From 64c1f96348213f39b9411ab25699a292edbef4ef Mon Sep 17 00:00:00 2001
>> From: Kinglong Mee <kinglongmee@gmail.com>
>> Date: Fri, 27 Dec 2013 18:06:25 +0800
>> Subject: [PATCH] NFSD: supports nfsv4 service without rpcbind
>>
>> 1. set vs_hidden in nfsd_version4 to avoid register nfsv4 to rpcbind
>>
>>
>> IMO we do want the NFS port registered if rpcbind is running.  NFSv4 is not
>> a hidden service, like the client's callback server which can only be
>> discovered by a forward advertisement (SETCLIENTID).
>>
>> I think I prefer ignoring the rpcb_set error for NFSv4.
>>
>>
>> Agreed.  My only concern would be that there be no unnecessary delays or
>> errors logged in the v4-only case if rpcbind isn't running.
>>
>>
>> I believe the rpcb_set upcall now uses the AF_LOCAL transport, which should
>> be able to detect immediately that rpcbind is not listening.
>>
>> The OP did not report a delay or hang, thankfully.
>>
>>
>> I meet a problem when testing on Fedora 20 with latest kernel,
>> svc_register for  nfsv4 not report immediately, instead of a delay and
>> return EIO.
>>
>> After that, rpc.nfsd also hang there, not return utils rpcbind start.
>> I will have a check for that.
>>
>> thanks.
>> Kinglong Mee
>>
>>
>>
>> --b.
>>
>>
>>
>> 2. don't start lockd when only supports nfsv4.
>>
>> Reported-by: Gareth Williams <gareth@garethwilliams.me.uk>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>> fs/nfsd/netns.h    |  3 +++
>> fs/nfsd/nfs4proc.c |  1 +
>> fs/nfsd/nfsctl.c   |  3 +++
>> fs/nfsd/nfssvc.c   | 21 ++++++++++++++++-----
>> 4 files changed, 23 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
>> index 849a7c3..ae2c179 100644
>> --- a/fs/nfsd/netns.h
>> +++ b/fs/nfsd/netns.h
>> @@ -96,6 +96,9 @@ struct nfsd_net {
>>
>> bool nfsd_net_up;
>>
>> + bool lockd_up;
>> + u32 nfsd_needs_lockd;
>> +
>> /*
>> * Time of server startup
>> */
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 419572f..1496376 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1881,6 +1881,7 @@ struct svc_version nfsd_version4 = {
>> .vs_proc = nfsd_procedures4,
>> .vs_dispatch = nfsd_dispatch,
>> .vs_xdrsize = NFS4_SVC_XDRSIZE,
>> + .vs_hidden = 1,
>> };
>>
>> /*
>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>> index 7f55517..8c7b0f0 100644
>> --- a/fs/nfsd/nfsctl.c
>> +++ b/fs/nfsd/nfsctl.c
>> @@ -575,6 +575,9 @@ static ssize_t __write_versions(struct file *file, char
>> *buf, size_t size)
>> switch(num) {
>> case 2:
>> case 3:
>> + nfsd_vers(num, sign == '-' ? NFSD_CLEAR : NFSD_SET);
>> + nn->nfsd_needs_lockd = nfsd_vers(num, NFSD_TEST);
>> + break;
>> case 4:
>> nfsd_vers(num, sign == '-' ? NFSD_CLEAR : NFSD_SET);
>> break;
>> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
>> index 760c85a..2b841d8 100644
>> --- a/fs/nfsd/nfssvc.c
>> +++ b/fs/nfsd/nfssvc.c
>> @@ -255,9 +255,14 @@ static int nfsd_startup_net(int nrservs, struct net
>> *net)
>> ret = nfsd_init_socks(net);
>> if (ret)
>> goto out_socks;
>> - ret = lockd_up(net);
>> - if (ret)
>> - goto out_socks;
>> +
>> + if (nn->nfsd_needs_lockd && !nn->lockd_up) {
>> + ret = lockd_up(net);
>> + if (ret)
>> + goto out_socks;
>> + nn->lockd_up = 1;
>> + }
>> +
>> ret = nfs4_state_start_net(net);
>> if (ret)
>> goto out_lockd;
>> @@ -266,7 +271,10 @@ static int nfsd_startup_net(int nrservs, struct net
>> *net)
>> return 0;
>>
>> out_lockd:
>> - lockd_down(net);
>> + if (nn->lockd_up) {
>> + lockd_down(net);
>> + nn->lockd_up = 0;
>> + }
>> out_socks:
>> nfsd_shutdown_generic();
>> return ret;
>> @@ -277,7 +285,10 @@ static void nfsd_shutdown_net(struct net *net)
>> struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>>
>> nfs4_state_shutdown_net(net);
>> - lockd_down(net);
>> + if (nn->lockd_up) {
>> + lockd_down(net);
>> + nn->lockd_up = 0;
>> + }
>> nn->nfsd_net_up = false;
>> nfsd_shutdown_generic();
>> }
>> --
>> 1.8.4.2
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
> 

