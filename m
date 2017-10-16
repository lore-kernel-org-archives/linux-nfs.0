Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f176.google.com ([209.85.217.176]:45049 "EHLO
        mail-ua0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755260AbdJPTUH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 15:20:07 -0400
Received: by mail-ua0-f176.google.com with SMTP id f46so10477488uae.1
        for <linux-nfs@vger.kernel.org>; Mon, 16 Oct 2017 12:20:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171016183623.GB12608@fieldses.org>
References: <20171011170705.45533-1-trond.myklebust@primarydata.com>
 <CAN-5tyGL1N51N7stAqxBMWZBDMQQs+BnLGd2owA1sWfpdLLFRQ@mail.gmail.com>
 <CAN-5tyEXeesbAk02LsGDjwoBqZr6q8AzWUhMSV0-V2aUwm44dA@mail.gmail.com> <20171016183623.GB12608@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 16 Oct 2017 15:20:05 -0400
Message-ID: <CAN-5tyGxD3wNaDwteoCb9Gs=PN=HFbqT_DhjwT=3953BUU2=wg@mail.gmail.com>
Subject: Re: [PATCH v2] NFSv4.1: Fix up replays of interrupted requests
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 16, 2017 at 2:36 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Oct 16, 2017 at 01:07:57PM -0400, Olga Kornievskaia wrote:
>> Network trace reveals that server is not working properly (thus
>> getting Bruce's attention here).
>>
>> Skipping ahead, the server replies to a SEQUENCE call with a reply
>> that has a count=5 operations but only has a sequence in it.
>>
>> The flow of steps is the following.
>>
>> Client sends
>> call COPY seq=16 slot=0 highslot=1(application at this point receives
>> a ctrl-c so it'll go ahead and close 2files it has opened)
>
> Is cachethis set on that the SEQUENCE op in that copy compound?

Cachethis=no.

>> call CLOSE  seq=1 slot=1 highslot=1
>> call SEQUENCE seq=16 slot=0 highslot=1
>> reply CLOSE OK
>> reply SEQUENCE ERR_DELAY
>> another call CLOSE seq=2 slot=1 and successful reply
>> reply COPY ..
>> call SEQUENCE seq=16 slot=0 highslot=0
>> reply SEQUENCE opcount=5
>
> And that's the whole reply?

Here's a text of the malformed packet.
  14023 2017-10-16 12:32:41.779109    192.168.1.89
192.168.1.94          NFS      150    V4 Reply (Call In
14022)[Malformed Packet]

Frame 14023: 150 bytes on wire (1200 bits), 150 bytes captured (1200
bits) on interface 0
Ethernet II, Src: Vmware_9f:a3:15 (00:0c:29:9f:a3:15), Dst:
Vmware_8d:33:b1 (00:0c:29:8d:33:b1)
Internet Protocol Version 4, Src: 192.168.1.89, Dst: 192.168.1.94
Transmission Control Protocol, Src Port: 2049, Dst Port: 938, Seq:
5129, Ack: 6141, Len: 84
Remote Procedure Call, Type:Reply XID:0x3c21001c
Network File System, Ops(5): SEQUENCE
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]
    Status: NFS4ERR_BAD_STATEID (10025)
    Tag: <EMPTY>
    Operations (count: 5)
        Opcode: SEQUENCE (53)
            Status: NFS4_OK (0)
            sessionid: cbd8e459928bea510200000000000000
            seqid: 0x00000016
            slot id: 0
            high slot id: 30
            target high slot id: 30
            status flags: 0x00000000
                .... .... .... .... .... .... .... ...0 =
SEQ4_STATUS_CB_PATH_DOWN: Not set
                .... .... .... .... .... .... .... ..0. =
SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING: Not set
                .... .... .... .... .... .... .... .0.. =
SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED: Not set
                .... .... .... .... .... .... .... 0... =
SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED: Not set
                .... .... .... .... .... .... ...0 .... =
SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED: Not set
                .... .... .... .... .... .... ..0. .... =
SEQ4_STATUS_ADMIN_STATE_REVOKED: Not set
                .... .... .... .... .... .... .0.. .... =
SEQ4_STATUS_RECALLABLE_STATE_REVOKED: Not set
                .... .... .... .... .... .... 0... .... =
SEQ4_STATUS_LEASE_MOVED: Not set
                .... .... .... .... .... ...0 .... .... =
SEQ4_STATUS_RESTART_RECLAIM_NEEDED: Not set
                .... .... .... .... .... ..0. .... .... =
SEQ4_STATUS_CB_PATH_DOWN_SESSION: Not set
                .... .... .... .... .... .0.. .... .... =
SEQ4_STATUS_BACKCHANNEL_FAULT: Not set
                .... .... .... .... .... 0... .... .... =
SEQ4_STATUS_DEVID_CHANGED: Not set
                .... .... .... .... ...0 .... .... .... =
SEQ4_STATUS_DEVID_DELETED: Not set
[Malformed Packet: NFS]
    [Expert Info (Error/Malformed): Malformed Packet (Exception occurred)]

> Do you have a binary capture that I could look at?

I didn't think mailing list allowed attachment. I can send mail just
to you with the packet trace. I can also post to the mailing list text
output from the wireshark for the packets.


>> So I'm assuming server is replying from the reply cache for the COPY
>> seq=16 slot=0.. but it's only sending part of it back? Is that legit?
>
> No.--b.
>
>>
>> In any case, I think the client shouldn't be oops-ing.
>>
>> [  138.136387] BUG: unable to handle kernel NULL pointer dereference
>> at 0000000000000020^M
>> [  138.140134] IP: _nfs41_proc_sequence+0xdd/0x1a0 [nfsv4]^M
>> [  138.141687] PGD 0 P4D 0 ^M
>> [  138.142462] Oops: 0002 [#1] SMP^M
>> [  138.143413] Modules linked in: nfsv4 dns_resolver nfs rfcomm fuse
>> xt_CHECKSUM ipt_MASQUERADE nf_nat_masquerade_ipv4 tun ip6t_rpfilter
>> ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack
>> ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc
>> ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
>> ip6table_mangle ip6table_security ip6table_raw iptable_nat
>> nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
>> libcrc32c iptable_mangle iptable_security iptable_raw ebtable_filter
>> ebtables ip6table_filter ip6_tables iptable_filter
>> vmw_vsock_vmci_transport vsock bnep dm_mirror dm_region_hash dm_log
>> dm_mod snd_seq_midi snd_seq_midi_event coretemp crct10dif_pclmul
>> crc32_pclmul ghash_clmulni_intel pcbc uvcvideo snd_ens1371
>> snd_ac97_codec ac97_bus snd_seq ppdev videobuf2_vmalloc^M
>> [  138.158839]  btusb videobuf2_memops videobuf2_v4l2 videobuf2_core
>> aesni_intel btrtl nfit btbcm crypto_simd cryptd videodev snd_pcm
>> btintel glue_helper vmw_balloon libnvdimm bluetooth snd_rawmidi
>> snd_timer pcspkr snd_seq_device snd shpchp rfkill vmw_vmci sg
>> ecdh_generic soundcore i2c_piix4 parport_pc parport nfsd auth_rpcgss
>> nfs_acl lockd grace sunrpc ip_tables ext4 mbcache jbd2 sr_mod cdrom
>> sd_mod ata_generic pata_acpi vmwgfx drm_kms_helper syscopyarea
>> sysfillrect sysimgblt fb_sys_fops ttm drm ahci libahci crc32c_intel
>> ata_piix mptspi scsi_transport_spi serio_raw libata mptscsih e1000
>> mptbase i2c_core^M
>> [  138.169453] CPU: 3 PID: 541 Comm: kworker/3:3 Not tainted 4.14.0-rc5+ #41^M
>> [  138.170829] Hardware name: VMware, Inc. VMware Virtual
>> Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015^M
>> [  138.172960] Workqueue: events nfs4_renew_state [nfsv4]^M
>> [  138.174020] task: ffff880033c80000 task.stack: ffffc90000d80000^M
>> [  138.175232] RIP: 0010:_nfs41_proc_sequence+0xdd/0x1a0 [nfsv4]^M
>> [  138.176392] RSP: 0018:ffffc90000d83d68 EFLAGS: 00010246^M
>> [  138.177444] RAX: ffff880073646200 RBX: ffff88002c944800 RCX:
>> 0000000000000000^M
>> [  138.178932] RDX: 00000000fffd7000 RSI: 0000000000000000 RDI:
>> ffff880073646240^M
>> [  138.180357] RBP: ffffc90000d83df8 R08: 000000000001ee40 R09:
>> ffff880073646200^M
>> [  138.181955] R10: ffff880073646200 R11: 0000000000000139 R12:
>> ffffc90000d83d90^M
>> [  138.184014] R13: 0000000000000000 R14: 0000000000000000 R15:
>> ffffffffa08784d0^M
>> [  138.185439] FS:  0000000000000000(0000) GS:ffff88007b6c0000(0000)
>> knlGS:0000000000000000^M
>> [  138.187144] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033^M
>> [  138.188469] CR2: 0000000000000020 CR3: 0000000001c09003 CR4:
>> 00000000001606e0^M
>> [  138.189952] Call Trace:^M
>> [  138.190478]  nfs41_proc_async_sequence+0x1d/0x60 [nfsv4]^M
>> [  138.191549]  nfs4_renew_state+0x10b/0x1a0 [nfsv4]^M
>> [  138.192555]  process_one_work+0x149/0x360^M
>> [  138.193367]  worker_thread+0x4d/0x3c0^M
>> [  138.194157]  kthread+0x109/0x140^M
>> [  138.194816]  ? rescuer_thread+0x380/0x380^M
>> [  138.195673]  ? kthread_park+0x60/0x60^M
>> [  138.196426]  ret_from_fork+0x25/0x30^M
>> [  138.197153] Code: e0 48 85 c0 0f 84 8e 00 00 00 0f b6 50 10 48 c7
>> 40 08 00 00 00 00 48 c7 40 18 00 00 00 00 83 e2 fc 88 50 10 48 8b 15
>> b3 0e 3c e1 <41> 80 66 20 fd 45 84 ed 4c 89 70 08 4c 89 70 18 c7 40 2c
>> 00 00 ^M
>> [  138.200991] RIP: _nfs41_proc_sequence+0xdd/0x1a0 [nfsv4] RSP:
>> ffffc90000d83d68^M
>> [  138.202431] CR2: 0000000000000020^M
>> [  138.203200] ---[ end trace b25c7be5ead1a406 ]---^M
>>
>> >>
>> >> --
>> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> >> the body of a message to majordomo@vger.kernel.org
>> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
