Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:51542 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751655AbdJSVTm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Oct 2017 17:19:42 -0400
Received: by mail-vk0-f67.google.com with SMTP id 137so6202346vkk.8
        for <linux-nfs@vger.kernel.org>; Thu, 19 Oct 2017 14:19:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHQUB0x1YhdMosM1pg12kuK9gEeqW2ruufxfFsPLHL_Ew@mail.gmail.com>
References: <CAN-5tyEXeesbAk02LsGDjwoBqZr6q8AzWUhMSV0-V2aUwm44dA@mail.gmail.com>
 <1508361919-30495-1-git-send-email-bfields@redhat.com> <CAN-5tyHBv9iFfTEPTgCfNyBo9veiqWiD_2xzVwhHjQ_tNdMFZw@mail.gmail.com>
 <20171019181718.GF16942@parsley.fieldses.org> <CAN-5tyFCBrfLnw91R5awik6+miCO7vGfB-K40D1yQw-+nJ6eiQ@mail.gmail.com>
 <20171019202015.GG16942@parsley.fieldses.org> <CAN-5tyHQUB0x1YhdMosM1pg12kuK9gEeqW2ruufxfFsPLHL_Ew@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 19 Oct 2017 17:19:40 -0400
Message-ID: <CAN-5tyGb9EuYH90LLdDDNZJHWs3RPxK6FvjneKFsM4Yao=Vk0g@mail.gmail.com>
Subject: Re: [PATCH 1/2] nfsd4: fix cached replies to solo SEQUENCE compounds
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 19, 2017 at 5:04 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Thu, Oct 19, 2017 at 4:20 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>> On Thu, Oct 19, 2017 at 02:34:20PM -0400, Olga Kornievskaia wrote:
>>> On Thu, Oct 19, 2017 at 2:17 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>>> > On Thu, Oct 19, 2017 at 01:21:46PM -0400, Olga Kornievskaia wrote:
>>> >> On Wed, Oct 18, 2017 at 5:25 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>>> >> > From: "J. Bruce Fields" <bfields@redhat.com>
>>> >> >
>>> >> > Currently our handling of 4.1+ requests without "cachethis" set is
>>> >> > confusing and not quite correct.
>>> >> >
>>> >> > Suppose a client sends a compound consisting of only a single SEQUENCE
>>> >> > op, and it matches the seqid in a session slot (so it's a retry), but
>>> >> > the previous request with that seqid did not have "cachethis" set.
>>> >> >
>>> >> > The obvious thing to do might be to return NFS4ERR_RETRY_UNCACHED_REP,
>>> >> > but the protocol only allows that to be returned on the op following the
>>> >> > SEQUENCE, and there is no such op in this case.
>>> >> >
>>> >> > The protocol permits us to cache replies even if the client didn't ask
>>> >> > us to.  And it's easy to do so in the case of solo SEQUENCE compounds.
>>> >> >
>>> >> > So, when we get a solo SEQUENCE, we can either return the previously
>>> >> > cached reply or NFSERR_SEQ_FALSE_RETRY if we notice it differs in some
>>> >> > way from the original call.
>>> >>
>>> >> I'm confused in my testing the error was SEQ_MISORDERED and not
>>> >> SEQ_FALSE_RETRY error?
>>> >
>>> > Yes, I must have a typo somewhere, but I haven't spotted it yet.  That
>>> > was with both patches applied?
>>>
>>> Yes both patches.
>>
>> Some days I wonder if I should just turn in my C programmer card.
>>
>> --b.
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 7bd3ad88b85c..8aeda6ad15b9 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -2294,7 +2294,7 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
>>
>>         slot->sl_flags |= NFSD4_SLOT_INITIALIZED;
>>         if (!nfsd4_cache_this(resp)) {
>> -               slot->sl_flags &= !NFSD4_SLOT_CACHED;
>> +               slot->sl_flags &= ~NFSD4_SLOT_CACHED;
>>                 return;
>>         }
>>         slot->sl_flags |= NFSD4_SLOT_CACHED;
>
> I got this crash upon receiving the SEQUENCE that reused the slot that
> was used by the ctrl-c-ed COPY.
>
> ipa17 login: [  111.474529] BUG: unable to handle kernel NULL pointer
> dereference at 0000000000000004^M
> [  111.480037] IP: same_creds+0x35/0xa0 [nfsd]^M
> [  111.481313] PGD 0 P4D 0 ^M
> [  111.482151] Oops: 0000 [#1] SMP^M
> [  111.483169] Modules linked in: rfcomm fuse xt_CHECKSUM
> ipt_MASQUERADE nf_nat_masquerade_ipv4 tun ip6t_rpfilter ipt_REJECT
> nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set
> nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat
> nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle
> ip6table_security ip6table_raw iptable_nat nf_conntrack_ipv4
> nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle
> iptable_security iptable_raw ebtable_filter ebtables ip6table_filter
> ip6_tables iptable_filter bnep vmw_vsock_vmci_transport vsock
> snd_seq_midi snd_seq_midi_event coretemp crct10dif_pclmul crc32_pclmul
> ghash_clmulni_intel pcbc ppdev aesni_intel crypto_simd cryptd
> glue_helper vmw_balloon pcspkr snd_ens1371 snd_ac97_codec ac97_bus
> snd_seq btusb btrtl btbcm btintel uvcvideo^M
> [  111.498649]  snd_pcm bluetooth videobuf2_vmalloc videobuf2_memops
> videobuf2_v4l2 videobuf2_core snd_timer videodev snd_rawmidi sg rfkill
> snd_seq_device nfit ecdh_generic snd soundcore libnvdimm shpchp
> vmw_vmci i2c_piix4 parport_pc parport nfsd nfs_acl nfsv4 dns_resolver
> nfs lockd auth_rpcgss grace sunrpc fscache ip_tables xfs libcrc32c
> sr_mod cdrom ata_generic pata_acpi sd_mod crc32c_intel serio_raw
> vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops
> ttm drm ahci libahci e1000 ata_piix i2c_core mptspi scsi_transport_spi
> mptscsih mptbase libata dm_mirror dm_region_hash dm_log dm_mod^M
> [  111.510205] CPU: 0 PID: 9397 Comm: nfsd Not tainted 4.14.0-rc5+ #51^M
> [  111.511462] Hardware name: VMware, Inc. VMware Virtual
> Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015^M
> [  111.513587] task: ffff8800298645c0 task.stack: ffffc90002f94000^M
> [  111.514790] RIP: 0010:same_creds+0x35/0xa0 [nfsd]^M
> [  111.515742] RSP: 0018:ffffc90002f97d40 EFLAGS: 00010246^M
> [  111.516864] RAX: 0000000000000000 RBX: ffff88002986c000 RCX:
> 0000000000000002^M
> [  111.518299] RDX: 00000000000003e8 RSI: ffff88002cdb1008 RDI:
> ffff88002986c158^M
> [  111.519734] RBP: ffffc90002f97dc8 R08: 0000000000000000 R09:
> ffff8800758ce980^M
> [  111.521295] R10: ffff880029918000 R11: ffff880029910080 R12:
> ffff880029918000^M
> [  111.522776] R13: ffff8800299100a0 R14: ffff880074525128 R15:
> ffff880079b31000^M
> [  111.524239] FS:  0000000000000000(0000) GS:ffff88007b600000(0000)
> knlGS:0000000000000000^M
> [  111.526005] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033^M
> [  111.527147] CR2: 0000000000000004 CR3: 0000000001c09002 CR4:
> 00000000001606f0^M
> [  111.529485] Call Trace:^M
> [  111.530259]  ? nfsd4_sequence+0x20b/0x710 [nfsd]^M
> [  111.531646]  ? unix_gid_lookup+0x4f/0x70 [sunrpc]^M
> [  111.533012]  ? ttwu_do_activate+0x7a/0x90^M
> [  111.534085]  nfsd4_proc_compound+0x3c2/0x790 [nfsd]^M
> [  111.535367]  nfsd_dispatch+0xb9/0x250 [nfsd]^M
> [  111.536397]  svc_process_common+0x383/0x700 [sunrpc]^M
> [  111.537604]  svc_process+0x105/0x1c0 [sunrpc]^M
> [  111.538558]  nfsd+0xe9/0x160 [nfsd]^M
> [  111.539332]  kthread+0x109/0x140^M
> [  111.539990]  ? nfsd_destroy+0x60/0x60 [nfsd]^M
> [  111.540934]  ? kthread_park+0x60/0x60^M
> [  111.541700]  ret_from_fork+0x25/0x30^M
> [  111.542421] Code: 97 c1 83 7e 10 08 0f 97 c2 31 c0 38 d1 74 02 f3
> c3 8b 0f 39 0e 75 f8 8b 57 04 39 56 04 75 f0 4c 8b 46 08 4c 8b 4f 08
> 41 8b 49 04 <41> 3b 48 04 75 de 85 c9 7e 24 41 8b 50 08 41 39 51 08 75
> d0 31 ^M
> [  111.546121] RIP: same_creds+0x35/0xa0 [nfsd] RSP: ffffc90002f97d40^M
> [  111.547390] CR2: 0000000000000004^M
> [  111.548110] ---[ end trace 7a283d3e387df937 ]---^M

(gdb) l *(same_creds+0x35)
0x21615 is in same_creds (fs/nfsd/nfs4state.c:2054).
2049
2050 static bool groups_equal(struct group_info *g1, struct group_info *g2)
2051 {
2052 int i;
2053
2054 if (g1->ngroups != g2->ngroups)
2055 return false;
2056 for (i=0; i<g1->ngroups; i++)
2057 if (!gid_eq(g1->gid[i], g2->gid[i]))
2058 return false;

(gdb) l *(nfsd4_sequence+0x20b)
0x25c4b is in nfsd4_sequence (fs/nfsd/nfs4state.c:3105).
3100 * really a replay of the old one:
3101 */
3102 if (slot->sl_opcnt < argp->opcnt)
3103 return false;
3104 /* This is the only check explicitly called by spec: */
3105 if (!same_creds(&rqstp->rq_cred, &slot->sl_cred))
3106 return false;
3107 /*
3108 * There may be more comparisons we could actually do, but the
3109 * spec doesn't require us to catch every case where the calls
