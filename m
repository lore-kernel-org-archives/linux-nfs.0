Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:59843 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752888AbbAZMIG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jan 2015 07:08:06 -0500
Received: by mail-ie0-f175.google.com with SMTP id ar1so8172795iec.6
        for <linux-nfs@vger.kernel.org>; Mon, 26 Jan 2015 04:08:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <935803842.386714.1422264689223.JavaMail.zimbra@desy.de>
References: <130621862.279655.1421851650684.JavaMail.zimbra@desy.de>
	<CAHQdGtRXRVz-NMtKUDxowkYMrYs0R2D6U1b6=WDnzBUBvbHY3A@mail.gmail.com>
	<CAN-5tyH52i+UbrxfAj=zPfQ1p6uOvE7JfcyLv2Etmm+gC=gdHQ@mail.gmail.com>
	<1421869687.4674.2.camel@primarydata.com>
	<1192395468.285001.1421873884470.JavaMail.zimbra@desy.de>
	<1366785487.376442.1422133679079.JavaMail.zimbra@desy.de>
	<935803842.386714.1422264689223.JavaMail.zimbra@desy.de>
Date: Mon, 26 Jan 2015 07:08:05 -0500
Message-ID: <CAABAsM65K_BgUEAnVPsZrVkrP+J1GZ-xQm7RRoMNC9MTPkiuJg@mail.gmail.com>
Subject: Re: Yet another kernel crash in NFS4 state recovery
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 26, 2015 at 4:31 AM, Mkrtchyan, Tigran
<tigran.mkrtchyan@desy.de> wrote:
> we rebooted back into a kernel without the fix an it crashed almost immediately.

Thanks Tigran! That sounds pretty conclusive.
I'll make sure to push the fix upstream.

Cheers
  Trond


> ----- Original Message -----
>> From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
>> To: "Trond Myklebust" <trond.myklebust@primarydata.com>
>> Cc: "Olga Kornievskaia" <aglo@umich.edu>, "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
>> Sent: Saturday, January 24, 2015 10:07:59 PM
>> Subject: Re: Yet another kernel crash in NFS4 state recovery
>
>> Looks like there are no crashes any more.
>>
>> Tigran.
>>
>> ----- Original Message -----
>>> From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
>>> To: "Trond Myklebust" <trond.myklebust@primarydata.com>
>>> Cc: "Olga Kornievskaia" <aglo@umich.edu>, "Linux NFS Mailing List"
>>> <linux-nfs@vger.kernel.org>
>>> Sent: Wednesday, January 21, 2015 9:58:04 PM
>>> Subject: Re: Yet another kernel crash in NFS4 state recovery
>>
>>> Hi Trond, Olga,
>>>
>>> This is really weird. We had no problem until today.
>>> Today is started to crash every 7 minutes or so.
>>>
>>> I will try the fix tomorrow. But I have idea what have  triggered it
>>> today.
>>>
>>> Tigran.
>>>
>>> ----- Original Message -----
>>>> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
>>>> To: "Olga Kornievskaia" <aglo@umich.edu>
>>>> Cc: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>, "Linux NFS Mailing List"
>>>> <linux-nfs@vger.kernel.org>
>>>> Sent: Wednesday, January 21, 2015 8:48:07 PM
>>>> Subject: Re: Yet another kernel crash in NFS4 state recovery
>>>
>>>> On Wed, 2015-01-21 at 14:09 -0500, Olga Kornievskaia wrote:
>>>>> On Wed, Jan 21, 2015 at 1:41 PM, Trond Myklebust
>>>>> <trond.myklebust@primarydata.com> wrote:
>>>>> > On Wed, Jan 21, 2015 at 9:47 AM, Mkrtchyan, Tigran
>>>>> > <tigran.mkrtchyan@desy.de> wrote:
>>>>> >>
>>>>> >>
>>>>> >> Now with RHEL7.
>>>>> >>
>>>>> >>  [  482.016897] BUG: unable to handle kernel NULL pointer dereference at
>>>>> >>  000000000000001a
>>>>> >> [  482.017023] IP: [<ffffffffa01d7035>] rpc_peeraddr2str+0x5/0x30 [sunrpc]
>>>>> >> [  482.017023] PGD baefe067 PUD baeff067 PMD 0
>>>>> >> [  482.017023] Oops: 0000 [#1] SMP
>>>>> >> [  482.017023] Modules linked in: nfs_layout_nfsv41_files rpcsec_gss_krb5 nfsv4
>>>>> >> dns_resolver nfs fscache ip6t_rpfilter ip6t_REJECT ipt_REJECT xt_conntrack
>>>>> >> ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat
>>>>> >> nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security
>>>>> >> ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4
>>>>> >> nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security
>>>>> >> iptable_raw iptable_filter ip_tables sg ppdev kvm_intel kvm pcspkr serio_raw
>>>>> >> virtio_balloon i2c_piix4 parport_pc parport mperf nfsd auth_rpcgss nfs_acl
>>>>> >> lockd sunrpc sr_mod cdrom ata_generic pata_acpi ext4 mbcache jbd2 virtio_blk
>>>>> >> cirrus syscopyarea sysfillrect sysimgblt drm_kms_helper ttm virtio_net ata_piix
>>>>> >> drm libata virtio_pci virtio_ring virtio
>>>>> >> [  482.017023]  i2c_core floppy
>>>>> >> [  482.017023] CPU: 0 PID: 2834 Comm: xrootd Not tainted
>>>>> >> 3.10.0-123.13.2.el7.x86_64 #1
>>>>> >> [  482.017023] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs
>>>>> >> 01/01/2011
>>>>> >> [  482.017023] task: ffff8800b188cfa0 ti: ffff880232484000 task.ti:
>>>>> >> ffff880232484000
>>>>> >> [  482.017023] RIP: 0010:[<ffffffffa01d7035>]  [<ffffffffa01d7035>]
>>>>> >> rpc_peeraddr2str+0x5/0x30 [sunrpc]
>>>>> >> [  482.017023] RSP: 0018:ffff880232485708  EFLAGS: 00010246
>>>>> >> [  482.017023] RAX: 000000000001bcb0 RBX: ffff880233ded800 RCX: 0000000000000000
>>>>> >> [  482.017023] RDX: ffffffffa0494078 RSI: 0000000000000000 RDI: ffffffffffffffea
>>>>> >> [  482.017023] RBP: ffff880232485760 R08: ffff880232485740 R09: 0000000000000000
>>>>> >> [  482.017023] R10: 0000000000000000 R11: fffffffffffffff2 R12: ffff8800bac3e690
>>>>> >> [  482.017023] R13: ffff8800bac3e638 R14: 0000000000000000 R15: 0000000000000000
>>>>> >> [  482.017023] FS:  00007f0d84b79700(0000) GS:ffff88023fc00000(0000)
>>>>> >> knlGS:0000000000000000
>>>>> >> [  482.017023] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>>>> >> [  482.017023] CR2: 000000000000001a CR3: 00000000baefd000 CR4: 00000000000006f0
>>>>> >> [  482.017023] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>>>>> >> [  482.017023] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>>>> >> [  482.017023] Stack:
>>>>> >> [  482.017023]  ffffffffa04c79a5 0000000000000000 ffff880232485768
>>>>> >> ffffffffa046d858
>>>>> >> [  482.017023]  0000000000000000 ffff8800b188cfa0 ffffffff81086ac0
>>>>> >> ffff880232485740
>>>>> >> [  482.017023]  ffff880232485740 0000000096605de3 ffff880233ded800
>>>>> >> ffff880232485778
>>>>> >> [  482.017023] Call Trace:
>>>>> >> [  482.017023]  [<ffffffffa04c79a5>] ? nfs4_schedule_state_manager+0x65/0xf0
>>>>> >> [nfsv4]
>>>>> >> [  482.017023]  [<ffffffffa046d858>] ?
>>>>> >> nfs_wait_client_init_complete.part.6+0x98/0xd0 [nfs]
>>>>> >> [  482.017023]  [<ffffffff81086ac0>] ? wake_up_bit+0x30/0x30
>>>>> >> [  482.017023]  [<ffffffffa04c7a5e>] nfs4_schedule_lease_recovery+0x2e/0x60
>>>>> >> [nfsv4]
>>>>> >> [  482.017023]  [<ffffffffa04cff64>] nfs41_walk_client_list+0x104/0x340 [nfsv4]
>>>>> >> [  482.017023]  [<ffffffffa04c5679>] nfs41_discover_server_trunking+0x39/0x40
>>>>> >> [nfsv4]
>>>>> >> [  482.017023]  [<ffffffffa04c7ecd>] nfs4_discover_server_trunking+0x7d/0x2e0
>>>>> >> [nfsv4]
>>>>> >> [  482.017023]  [<ffffffffa04cf944>] nfs4_init_client+0x124/0x2f0 [nfsv4]
>>>>> >> [  482.017023]  [<ffffffffa0455eb4>] ? __fscache_acquire_cookie+0x74/0x2a0
>>>>> >> [fscache]
>>>>> >> [  482.017023]  [<ffffffffa0455eb4>] ? __fscache_acquire_cookie+0x74/0x2a0
>>>>> >> [fscache]
>>>>> >> [  482.017023]  [<ffffffffa01e62a5>] ? generic_lookup_cred+0x15/0x20 [sunrpc]
>>>>> >> [  482.017023]  [<ffffffffa01e2cc1>] ? __rpc_init_priority_wait_queue+0x81/0xc0
>>>>> >> [sunrpc]
>>>>> >> [  482.017023]  [<ffffffffa01e2d33>] ? rpc_init_wait_queue+0x13/0x20 [sunrpc]
>>>>> >> [  482.017023]  [<ffffffffa04cf649>] ? nfs4_alloc_client+0x189/0x1e0 [nfsv4]
>>>>> >> [  482.017023]  [<ffffffffa046e6ba>] nfs_get_client+0x26a/0x320 [nfs]
>>>>> >> [  482.017023]  [<ffffffffa04cee5e>] nfs4_set_ds_client+0x8e/0xe0 [nfsv4]
>>>>> >> [  482.017023]  [<ffffffffa0521779>] nfs4_fl_prepare_ds+0xe9/0x298
>>>>> >> [nfs_layout_nfsv41_files]
>>>>> >> [  482.017023]  [<ffffffffa051f4c6>] filelayout_read_pagelist+0x56/0x170
>>>>> >> [nfs_layout_nfsv41_files]
>>>>> >> [  482.017023]  [<ffffffffa04d6b17>] pnfs_generic_pg_readpages+0xe7/0x270
>>>>> >> [nfsv4]
>>>>> >> [  482.017023]  [<ffffffffa047e1c9>] nfs_pageio_doio+0x19/0x50 [nfs]
>>>>> >> [  482.017023]  [<ffffffffa047e534>] nfs_pageio_complete+0x24/0x30 [nfs]
>>>>> >> [  482.017023]  [<ffffffffa047fd2a>] nfs_readpages+0x16a/0x1d0 [nfs]
>>>>> >> [  482.017023]  [<ffffffff81141a67>] ? __page_cache_alloc+0x87/0xb0
>>>>> >> [  482.017023]  [<ffffffff8114da6c>] __do_page_cache_readahead+0x1cc/0x250
>>>>> >> [  482.017023]  [<ffffffff8114dc76>] ondemand_readahead+0x126/0x240
>>>>> >> [  482.017023]  [<ffffffff8114e051>] page_cache_sync_readahead+0x31/0x50
>>>>> >> [  482.017023]  [<ffffffff81142edb>] generic_file_aio_read+0x1ab/0x750
>>>>> >> [  482.017023]  [<ffffffffa0474971>] nfs_file_read+0x71/0xf0 [nfs]
>>>>> >> [  482.017023]  [<ffffffff811aee9d>] do_sync_read+0x8d/0xd0
>>>>> >> [  482.017023]  [<ffffffff811af57c>] vfs_read+0x9c/0x170
>>>>> >> [  482.017023]  [<ffffffff811b0242>] SyS_pread64+0x92/0xc0
>>>>> >> [  482.017023]  [<ffffffff815f2a19>] system_call_fastpath+0x16/0x1b
>>>>> >> [  482.017023] Code: c3 0f 1f 44 00 00 0f 1f 44 00 00 55 48 c7 47 50 40 72 1d a0
>>>>> >> 48 89 e5 5d c3 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 <48> 8b 47
>>>>> >> 30 89 f6 55 48 c7 c2 d8 da 1f a0 48 89 e5 48 8b 84 f0
>>>>> >> [  482.017023] RIP  [<ffffffffa01d7035>] rpc_peeraddr2str+0x5/0x30 [sunrpc]
>>>>> >> [  482.017023]  RSP <ffff880232485708>
>>>>> >> [  482.017023] CR2: 000000000000001a
>>>>> >>
>>>>> >>
>>>>> >> Looks like clp->cl_rpcclient point to nowhere when nfs4_schedule_state_manager
>>>>> >> is called.
>>>>> >>
>>>>> >
>>>>> > I'm guessing
>>>>> >
>>>>> > https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=080af20cc945d110f9912d01cf6b66f94a375b8d
>>>>> >
>>>>>
>>>>> The Oops is seen even with that patch. As I was explained, in the
>>>>> commit you pointed at the whole client structure is null. In this case
>>>>> it's the rpcclient structure that's invalid.
>>>>
>>>>
>>>> Ah. You are right... Tigran, how about the following patch?
>>>>
>>>> Cheers
>>>>  Trond
>>>> 8<---------------------------------------------------------------------
>>>> From eb8720a31e1d36415c7377f287d5d217540830c3 Mon Sep 17 00:00:00 2001
>>>> From: Trond Myklebust <trond.myklebust@primarydata.com>
>>>> Date: Wed, 21 Jan 2015 14:37:44 -0500
>>>> Subject: [PATCH] NFSv4.1: Fix an Oops in nfs41_walk_client_list
>>>>
>>>> If we start state recovery on a client that failed to initialise correctly,
>>>> then we are very likely to Oops.
>>>>
>>>> Reported-by: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
>>>> Link:
>>>> http://lkml.kernel.org/r/130621862.279655.1421851650684.JavaMail.zimbra@desy.de
>>>> Cc: stable@vger.kernel.org
>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>>> ---
>>>> fs/nfs/nfs4client.c | 2 +-
>>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>>>> index 953daa44a282..706ad10b8186 100644
>>>> --- a/fs/nfs/nfs4client.c
>>>> +++ b/fs/nfs/nfs4client.c
>>>> @@ -639,7 +639,7 @@ int nfs41_walk_client_list(struct nfs_client *new,
>>>>                     prev = pos;
>>>>
>>>>                     status = nfs_wait_client_init_complete(pos);
>>>> -                   if (status == 0) {
>>>> +                   if (pos->cl_cons_state == NFS_CS_SESSION_INITING) {
>>>>                             nfs4_schedule_lease_recovery(pos);
>>>>                             status = nfs4_wait_clnt_recover(pos);
>>>>                     }
>>>> --
>>>> 2.1.0
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
