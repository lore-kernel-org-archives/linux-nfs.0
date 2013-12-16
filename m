Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:57114 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813Ab3LPHBs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Dec 2013 02:01:48 -0500
Message-ID: <52AEA550.8090507@parallels.com>
Date: Mon, 16 Dec 2013 11:01:36 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Weng Meiling <wengmeiling.weng@huawei.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: <stable@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <lizefan@huawei.com>, <h.huangqiang@huawei.com>
Subject: Re: NFSd 3.13 bug (Was "Re: [PATCH 3.4 9/9] nfsd: use the current
 net ns in write_threads() and write_ports()")
References: <1386136415-30976-1-git-send-email-wengmeiling.weng@huawei.com> <1386136415-30976-10-git-send-email-wengmeiling.weng@huawei.com> <20131204212532.GB19452@fieldses.org> <52A686A7.8060208@huawei.com> <52AE56D7.5010302@huawei.com>
In-Reply-To: <52AE56D7.5010302@huawei.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, sorry, was out of the office, network, etc.
A couple of comment below.

16.12.2013 05:26, Weng Meiling пишет:
> Hi Bruce, Stanislav:
> Do you have any ideas about this problem?
>
> On 2013/12/10 11:12, Weng Meiling wrote:
>> Hi guys,
>>
>> When I test NFS in different network namespace with the
>> 3.13-rc2 kernel, I trigger a kernel panic.
>>
>> On 2013/12/5 5:25, J. Bruce Fields wrote:
>>> On Wed, Dec 04, 2013 at 01:53:35PM +0800, Weng Meiling wrote:
>>>> Upstream commit f7fb86c6e639360ad9c253cec534819ef928a674 (nfsd: use
>>>> "init_net" for portmapper) introduced a bug.
>>>>
>>>> Starting NFSd in a non init_net network namespace will lead to
>>>> NULL pointer deference. Because RPCBIND client will be NULL when register
>>>> RPC service with the local portmapper in svc_addsock().
>>>>
>>>> BUG: unable to handle kernel NULL pointer dereference at 0000000000000060
>>>> IP: [<ffffffffa0439150>] call_start+0x10/0x30 [sunrpc]
>>>> ...
>>>> Pid: 27770, comm: rpc.nfsd ...
>>>> RIP: 0010:[<ffffffffa0439150>]  [<ffffffffa0439150>] call_start+0x10/0x30 [sunrpc]
>>>> ...
>>>>    [<ffffffffa0442841>] __rpc_execute+0x91/0x160 [sunrpc]
>>>>    [<ffffffffa0442981>] rpc_execute+0x71/0x80 [sunrpc]
>>>>    [<ffffffffa043ab49>] rpc_run_task+0x89/0xa0 [sunrpc]
>>>>    [<ffffffffa043ac5d>] rpc_call_sync+0x3d/0x70 [sunrpc]
>>>>    [<ffffffffa044b316>] rpcb_register+0xa6/0xd0 [sunrpc]
>>>>    [<ffffffffa0444ede>] __svc_register+0x1ae/0x1c0 [sunrpc]
>>>>    [<ffffffff8114f975>] ? cache_alloc_refill+0x85/0x290
>>>>    [<ffffffffa0444f7f>] svc_register+0x8f/0xc0 [sunrpc]
>>>>    [<ffffffff811504f3>] ? kmem_cache_alloc_trace+0xc3/0x1d0
>>>>    [<ffffffffa04472f8>] svc_setup_socket+0x1a8/0x2c0 [sunrpc]
>>>>    [<ffffffff81009546>] ? read_tsc+0x16/0x40
>>>>    [<ffffffffa0448078>] svc_addsock+0x118/0x1c0 [sunrpc]
>>>>    [<ffffffff81090ee5>] ? do_gettimeofday+0x15/0x50
>>>>    [<ffffffffa049e69c>] ? nfsd_create_serv+0xdc/0x150 [nfsd]
>>>>    [<ffffffff8125605c>] ? simple_strtoull+0x2c/0x50
>>>>    [<ffffffffa049fdce>] __write_ports+0x1fe/0x230 [nfsd]
>>>>    [<ffffffffa049fe37>] write_ports+0x37/0x60 [nfsd]
>>>>    [<ffffffffa049fe00>] ? __write_ports+0x230/0x230 [nfsd]
>>>>    [<ffffffffa049edd2>] nfsctl_transaction_write+0x72/0x90 [nfsd]
>>>>    [<ffffffff8116573b>] vfs_write+0xcb/0x130
>>>>    [<ffffffff81165890>] sys_write+0x50/0x90
>>>>
>>>> Fix it by using the current's network namespace so NFSd uses the
>>>> consistent net ns all the time.
>>>
>>> Everything else looks like a straightforward backport, but doing this
>>> differently from upstream makes me nervous.  Don't we also want to take
>>> 11f779421a39b86da8a523d97e5fd3477878d44f "nfsd: containerize NFSd
>>> filesystem" ?  (Stanislav?)
>>>
>>> --b.
>>>

Merging of 11f779421a39b86da8a523d97e5fd3477878d44f "nfsd: containerize NFSd
filesystem" depend on what network namespace is passed to svc_addsock(). If hard-coded init_net
is used, then no need in this commit, else otherwise.

>>
>> I backport the patch 11f779421a39b86da8a523d97e5fd3477878d44f "nfsd: containerize NFSd
>> filesystem" and test. But I trigger a bug, this bug still exists in 3.13 kernel. The following
>> is what I do:
>>
>> The steps:
>>
>> step 1: start NFS server in init_net net ns
>> #service nfsserver start
>>
>> step 2: stop NFS server in non init_net net ns
>> #ip netns add test
>> #ip netns list
>> test
>> #ip netns exec test service nfsserver stop
>>
>> step 3: start NFS server again in the non init_net net ns
>> #ip netns exec test service nfsserver start
>>
>> This step 3 will trigger kernel panic. The reason seems that "ip
>> netns exec" creates a new mount namespace, the changes to the
>> new mount namespace don't propgate to other namespaces. So
>> when stop NFS server in second step, the NFSD filesystem isn't
>> umounted.  When restart NFS server in third step, the NFSD
>> filesystem will not remount,  this result to the NFSD file
>> system superblock's net ns is still init_net and RPCBIND client
>> will be NULL when register RPC service with the local portmapper
>> in svc_addsock(). Do you have any ideas about this problem?
>>
>> the detail call trace:
>> [  497.554677] BUG: unable to handle kernel NULL pointer dereference at 0000000000000058
>> [  497.554687] IP: [<ffffffffa031a170>] call_start+0x10/0x30 [sunrpc]
>> [  497.554707] PGD 0
>> [  497.554711] Oops: 0000 [#1] SMP
>> [  497.554716] Modules linked in: nfsd lockd nfs_acl auth_rpcgss sunrpc oid_registry edd af_packet cpufreq_conservative cpufreq_userspace cpufreq_powersave loop dm_mod e1000e iTCO_wdt
>> iTCO_vendor_support i2c_i801 bnx2 ipv6 lpc_ich i7core_edac edac_core acpi_cpufreq ehci_pci button ses enclosure serio_raw sg rtc_cmos mfd_core ptp hid_generic pps_core i2c_core pcspkr ext3 jbd mbcache
>> usbhid hid uhci_hcd ehci_hcd usbcore sd_mod usb_common crc_t10dif crct10dif_common processor thermal_sys hwmon scsi_dh_rdac scsi_dh_hp_sw scsi_dh_emc scsi_dh_alua scsi_dh ata_generic ata_piix libata
>> megaraid_sas scsi_mod
>> [  497.554788] CPU: 2 PID: 7837 Comm: rpc.nfsd Not tainted 3.13.0-rc2-0.1-default+ #1
>> [  497.554793] Hardware name: Huawei Technologies Co., Ltd. Tecal RH2285          /BC11BTSA              , BIOS CTSAV036 04/27/2011
>> [  497.554800] task: ffff8800ba76e2d0 ti: ffff88043e8e8000 task.ti: ffff88043e8e8000
>> [  497.554805] RIP: 0010:[<ffffffffa031a170>]  [<ffffffffa031a170>] call_start+0x10/0x30 [sunrpc]
>> [  497.554819] RSP: 0018:ffff88043e8e9aa8  EFLAGS: 00010202
>> [  497.554823] RAX: ffffffffa033f4b8 RBX: ffff8800bb030040 RCX: 0000000000000034
>> [  497.554828] RDX: 0000000000000000 RSI: ffff8800bb0300b0 RDI: ffff8800bb030040
>> [  497.554832] RBP: ffff88043e8e9aa8 R08: 0040000000000000 R09: 0200000000000000
>> [  497.554836] R10: 0000000000000000 R11: ffff8802348fe040 R12: ffff8800bb030040
>> [  497.554841] R13: ffffffffa031a160 R14: 0000000000000000 R15: ffffffffa031a160
>> [  497.554846] FS:  00007f2fa0536700(0000) GS:ffff88023fc40000(0000) knlGS:0000000000000000
>> [  497.554851] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [  497.554855] CR2: 0000000000000058 CR3: 0000000434e30000 CR4: 00000000000007e0
>> [  497.554859] Stack:
>> [  497.554862]  ffff88043e8e9af8 ffffffffa0323f61 ffff00066c0a0100 ffff8800bb0300b0
>> [  497.554871]  000000003e8e9ae8 ffff8800bb030040 ffff8800bb030040 0000000000000000
>> [  497.554878]  0000000000000000 0000000000000002 ffff88043e8e9b28 ffffffffa03240ed
>> [  497.554886] Call Trace:
>> [  497.554902]  [<ffffffffa0323f61>] __rpc_execute+0xa1/0x190 [sunrpc]
>> [  497.554918]  [<ffffffffa03240ed>] rpc_execute+0x9d/0xc0 [sunrpc]
>> [  497.554930]  [<ffffffffa031c3e9>] rpc_run_task+0x89/0xa0 [sunrpc]
>> [  497.554943]  [<ffffffffa031c4fe>] rpc_call_sync+0x3e/0xa0 [sunrpc]
>> [  497.554961]  [<ffffffffa032d337>] rpcb_register_call+0x37/0x60 [sunrpc]
>> [  497.554979]  [<ffffffffa032d53c>] rpcb_register+0x9c/0xb0 [sunrpc]
>> [  497.554996]  [<ffffffffa03270ee>] __svc_register+0x1ae/0x1c0 [sunrpc]
>> [  497.555012]  [<ffffffffa0327190>] svc_register+0x90/0xe0 [sunrpc]
>> [  497.555029]  [<ffffffffa032a157>] svc_setup_socket+0x1e7/0x300 [sunrpc]
>> [  497.555038]  [<ffffffff810b39b3>] ? __getnstimeofday+0x43/0xd0
>> [  497.555055]  [<ffffffffa032a78a>] svc_addsock+0xca/0x1e0 [sunrpc]
>> [  497.555068]  [<ffffffffa0396b31>] ? nfsd_create_serv+0x111/0x180 [nfsd]
>> [  497.555075]  [<ffffffff8128d47e>] ? simple_strtol+0xe/0x30
>> [  497.555084]  [<ffffffffa03972b7>] ? get_int+0x57/0x70 [nfsd]
>> [  497.555094]  [<ffffffffa03977e9>] __write_ports+0x119/0x140 [nfsd]
>> [  497.555103]  [<ffffffffa039788a>] write_ports+0x7a/0xb0 [nfsd]
>> [  497.555112]  [<ffffffffa0397810>] ? __write_ports+0x140/0x140 [nfsd]
>> [  497.555122]  [<ffffffffa039713a>] nfsctl_transaction_write+0x6a/0x80 [nfsd]
>> [  497.555129]  [<ffffffff81186207>] vfs_write+0xc7/0x1e0
>> [  497.555134]  [<ffffffff8118643d>] SyS_write+0x5d/0xa0
>> [  497.555142]  [<ffffffff814deaa2>] system_call_fastpath+0x16/0x1b
>> [  497.555146] Code: 00 00 00 01 55 48 89 e5 75 0d 48 c7 47 50 60 a1 31 a0 b8 01 00 00 00 c9 c3 66 90 48 8b 47 28 48 8b 57 18 55 83 40 20 01 48 89 e5 <48> 8b 42 58 83 40 1c 01 48 c7 47 50 f0 a1 31 a0
>> c9 c3 66 66 66
>> [  497.555189] RIP  [<ffffffffa031a170>] call_start+0x10/0x30 [sunrpc]
>> [  497.555200]  RSP <ffff88043e8e9aa8>
>> [  497.555203] CR2: 0000000000000058
>> [  497.555208] ---[ end trace 34ca8d40727792e2 ]---
>>

Nice...
I'll try to reproduce and figure out, how we can fix it.
Thanks!


>>>>
>>>> Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
>>>> ---
>>>>   fs/nfsd/nfsctl.c | 5 +++--
>>>>   1 file changed, 3 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>>>> index 1d74af2..4ff0db9 100644
>>>> --- a/fs/nfsd/nfsctl.c
>>>> +++ b/fs/nfsd/nfsctl.c
>>>> @@ -15,6 +15,7 @@
>>>>   #include <linux/sunrpc/gss_krb5_enctypes.h>
>>>>   #include <linux/sunrpc/rpc_pipe_fs.h>
>>>>   #include <linux/module.h>
>>>> +#include <linux/nsproxy.h>
>>>>
>>>>   #include "idmap.h"
>>>>   #include "nfsd.h"
>>>> @@ -389,7 +390,7 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
>>>>   {
>>>>   	char *mesg = buf;
>>>>   	int rv;
>>>> -	struct net *net = &init_net;
>>>> +	struct net *net = current->nsproxy->net_ns;
>>>>
>>>>   	if (size > 0) {
>>>>   		int newthreads;
>>>> @@ -857,7 +858,7 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size,
>>>>   static ssize_t write_ports(struct file *file, char *buf, size_t size)
>>>>   {
>>>>   	ssize_t rv;
>>>> -	struct net *net = &init_net;
>>>> +	struct net *net = current->nsproxy->net_ns;
>>>>
>>>>   	mutex_lock(&nfsd_mutex);
>>>>   	rv = __write_ports(file, buf, size, net);
>>>> --
>>>> 1.8.2.2
>>>>
>>>>
>>>
>>> .
>>>
>>
>
>


-- 
Best regards,
Stanislav Kinsbursky
