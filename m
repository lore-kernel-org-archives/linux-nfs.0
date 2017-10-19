Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:47927 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753422AbdJSRHa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Oct 2017 13:07:30 -0400
Received: by mail-vk0-f65.google.com with SMTP id j2so5789062vki.4
        for <linux-nfs@vger.kernel.org>; Thu, 19 Oct 2017 10:07:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171018212329.GA29604@fieldses.org>
References: <20171011170705.45533-1-trond.myklebust@primarydata.com>
 <CAN-5tyGL1N51N7stAqxBMWZBDMQQs+BnLGd2owA1sWfpdLLFRQ@mail.gmail.com>
 <CAN-5tyEXeesbAk02LsGDjwoBqZr6q8AzWUhMSV0-V2aUwm44dA@mail.gmail.com>
 <20171016183623.GB12608@fieldses.org> <20171018212329.GA29604@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 19 Oct 2017 13:07:29 -0400
Message-ID: <CAN-5tyHbNgj33Ec8Ww4LYU_OEwo6RA0E2STL1qZYfsbg_AjUwA@mail.gmail.com>
Subject: Re: [PATCH v2] NFSv4.1: Fix up replays of interrupted requests
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 18, 2017 at 5:23 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Oct 16, 2017 at 02:36:23PM -0400, bfields wrote:
>> On Mon, Oct 16, 2017 at 01:07:57PM -0400, Olga Kornievskaia wrote:
>> > Network trace reveals that server is not working properly (thus
>> > getting Bruce's attention here).
>> >
>> > Skipping ahead, the server replies to a SEQUENCE call with a reply
>> > that has a count=5 operations but only has a sequence in it.
>> >
>> > The flow of steps is the following.
>> >
>> > Client sends
>> > call COPY seq=16 slot=0 highslot=1(application at this point receives
>> > a ctrl-c so it'll go ahead and close 2files it has opened)
>>
>> Is cachethis set on that the SEQUENCE op in that copy compound?
>>
>> > call CLOSE  seq=1 slot=1 highslot=1
>> > call SEQUENCE seq=16 slot=0 highslot=1
>> > reply CLOSE OK
>> > reply SEQUENCE ERR_DELAY
>> > another call CLOSE seq=2 slot=1 and successful reply
>> > reply COPY ..
>> > call SEQUENCE seq=16 slot=0 highslot=0
>> > reply SEQUENCE opcount=5
>>
>> And that's the whole reply?
>>
>> Do you have a binary capture that I could look at?
>
> Thanks, yes, the client behavior is arguably out of spec (it's sending a
> "retry" that doesn't match the original call), but I understand why it's
> doing this, and clearly responding with a corrupted reply isn't right.
> (And probably the client can deal with any reply short of one that's
> actually corrupted.)  Do the following patches help?  (Actually I think
> either one on its own should do the job, but I haven't done much
> testing.)
>

Bruce,

I tested your suggested 2 patches and the same scenario where client
ctrl-c's the COPY. Now the SEQUENCE that client sends that reused the
COPY's slot returns a good reply back (SEQ_MISORDERED)

Trond,

Client is still oops-ing the same way:

[  267.251995] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000020^M
[  267.257917] IP: _nfs41_proc_sequence+0xdd/0x1a0 [nfsv4]^M
[  267.259651] PGD 0 P4D 0 ^M
[  267.260436] Oops: 0002 [#1] SMP^M
[  267.261396] Modules linked in: nfsv4 dns_resolver nfs rfcomm fuse
xt_CHECKSUM ipt_MASQUERADE nf_nat_masquerade_ipv4 tun ip6t_rpfilter
ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack
ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc
ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
ip6table_mangle ip6table_security ip6table_raw iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
libcrc32c iptable_mangle iptable_security iptable_raw ebtable_filter
ebtables ip6table_filter ip6_tables iptable_filter bnep
vmw_vsock_vmci_transport vsock dm_mirror dm_region_hash dm_log dm_mod
snd_seq_midi snd_seq_midi_event coretemp crct10dif_pclmul crc32_pclmul
ghash_clmulni_intel pcbc ppdev aesni_intel crypto_simd cryptd
glue_helper vmw_balloon snd_ens1371 btusb^M
[  267.276890]  pcspkr snd_ac97_codec btrtl btbcm btintel ac97_bus
uvcvideo snd_seq videobuf2_vmalloc bluetooth videobuf2_memops
videobuf2_v4l2 videobuf2_core snd_pcm nfit videodev snd_rawmidi
snd_timer rfkill snd_seq_device libnvdimm sg snd vmw_vmci ecdh_generic
soundcore shpchp i2c_piix4 parport_pc parport nfsd auth_rpcgss nfs_acl
lockd grace sunrpc ip_tables ext4 mbcache jbd2 sr_mod cdrom
ata_generic sd_mod pata_acpi vmwgfx drm_kms_helper syscopyarea
sysfillrect sysimgblt fb_sys_fops crc32c_intel ttm drm serio_raw ahci
libahci mptspi scsi_transport_spi ata_piix mptscsih e1000 libata
mptbase i2c_core^M
[  267.287534] CPU: 1 PID: 48 Comm: kworker/1:1 Not tainted 4.14.0-rc5+ #43^M
[  267.288939] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015^M
[  267.291096] Workqueue: events nfs4_renew_state [nfsv4]^M
[  267.292159] task: ffff88007a00c5c0 task.stack: ffffc90000b74000^M
[  267.293352] RIP: 0010:_nfs41_proc_sequence+0xdd/0x1a0 [nfsv4]^M
[  267.294514] RSP: 0018:ffffc90000b77d68 EFLAGS: 00010246^M
[  267.295568] RAX: ffff880078165900 RBX: ffff88007807cc00 RCX:
0000000000000000^M
[  267.296995] RDX: 00000000ffff8001 RSI: 0000000000000000 RDI:
ffff880078165940^M
[  267.298422] RBP: ffffc90000b77df8 R08: 000000000001ee40 R09:
ffff880078165900^M
[  267.299883] R10: ffff880078165900 R11: 0000000000000235 R12:
ffffc90000b77d90^M
[  267.301311] R13: 0000000000000000 R14: 0000000000000000 R15:
ffffffffa08744d0^M
[  267.302788] FS:  0000000000000000(0000) GS:ffff88007b640000(0000)
knlGS:0000000000000000^M
[  267.304493] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033^M
[  267.305657] CR2: 0000000000000020 CR3: 0000000001c09001 CR4:
00000000001606e0^M
[  267.307113] Call Trace:^M
[  267.307633]  nfs41_proc_async_sequence+0x1d/0x60 [nfsv4]^M
[  267.308725]  nfs4_renew_state+0x10b/0x1a0 [nfsv4]^M
[  267.309690]  process_one_work+0x149/0x360^M
[  267.310507]  worker_thread+0x4d/0x3c0^M
[  267.311255]  kthread+0x109/0x140^M
[  267.311918]  ? rescuer_thread+0x380/0x380^M
[  267.312798]  ? kthread_park+0x60/0x60^M
[  267.313573]  ret_from_fork+0x25/0x30^M
[  267.314354] Code: e0 48 85 c0 0f 84 8e 00 00 00 0f b6 50 10 48 c7
40 08 00 00 00 00 48 c7 40 18 00 00 00 00 83 e2 fc 88 50 10 48 8b 15
b3 4e 3c e1 <41> 80 66 20 fd 45 84 ed 4c 89 70 08 4c 89 70 18 c7 40 2c
00 00 ^M
[  267.318088] RIP: _nfs41_proc_sequence+0xdd/0x1a0 [nfsv4] RSP:
ffffc90000b77d68^M
[  267.319555] CR2: 0000000000000020^M
[  267.320367] ---[ end trace c6ea9d44a9646e38 ]---^M

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
