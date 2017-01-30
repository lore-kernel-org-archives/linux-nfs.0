Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33080 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754363AbdA3VUE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2017 16:20:04 -0500
Received: by mail-io0-f193.google.com with SMTP id 101so15896793iom.0
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2017 13:20:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170130210237.GE12608@parsley.fieldses.org>
References: <79F89BE0-79A7-46A2-9CB8-E5D25C9E90DB@netapp.com> <20170130210237.GE12608@parsley.fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 30 Jan 2017 16:20:03 -0500
Message-ID: <CAN-5tyE4QCMi7k9kg=SRC0MdpXPRMAKh2m3NgPp3KmSbuXpZ8Q@mail.gmail.com>
Subject: Re: upstream nfsd kernel oops in auth_rpcgss
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 30, 2017 at 4:02 PM, J. Bruce Fields <bfields@redhat.com> wrote=
:
> On Mon, Jan 30, 2017 at 03:15:36PM -0500, Olga Kornievskaia wrote:
>> Hi Bruce,
>>
>> I ran into this oops in the nfsd (below) (4.10-rc3 kernel). To trigger t=
his I had a client (unsuccessfully) try to mount the server with krb5 where=
 the server doesn=E2=80=99t have the rpcsec_gss_krb5 module built.
>
> Whoops, thanks for catching that.
>
>> Below code seems to fix things:
>>
>> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svc=
auth_gss.c
>> index 886e9d38..7faffd8 100644
>> --- a/net/sunrpc/auth_gss/svcauth_gss.c
>> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
>> @@ -1187,9 +1187,9 @@ static int gss_proxy_save_rsc(struct cache_detail =
*cd,
>>               status =3D -EOPNOTSUPP;
>>               /* get mech handle from OID */
>>               gm =3D gss_mech_get_by_OID(&ud->mech_oid);
>> +             rsci.cred.cr_gss_mech =3D gm;
>>               if (!gm)
>>                       goto out;
>> -             rsci.cred.cr_gss_mech =3D gm;
>>
>>               status =3D -EINVAL;
>>               /* mech-specific data: */
>>
>> I guess the problem is because rsci.cred gets initialed from something t=
hat=E2=80=99s passed in that doesn=E2=80=99t have it=E2=80=99s cr_gss_mech =
initialized to NULL. So when gss_mech_get_by_OID() fails and it calls rsc_f=
ree() and tries to free a bad pointer.
>
> Hm, yes, just above there's:
>
>         rsci.cred =3D ud->creds;
>
> and it does make me a little nervous if ud->creds isn't completely
> initialized.
>
> The only caller of gss_proxy_save_rsc is svcauth_gss_proxy_init:
>
>         status =3D gss_proxy_save_rsc(sn->rsc_cache, &ud, &handle);
>
> ud there is on the stack, and initialized by:
>
>         memset(&ud, 0, sizeof(ud));
>
> Hm, in gssp_accept_sec_context_upcall, there's:
>
>         data->creds =3D *(struct svc_cred *)value->data;
>
> That looks really weird.  I'm not sure what it should be.

Isn't this stuff coming from the proxy upcall? How likely would it be
that it contains a pointer to something that points to the kernel
module? I used to know the svcgss upcall but that was before the
proxy. So I have no idea...


>> Don=E2=80=99t know if this is acceptable or it should be traced to where=
 the uninitialized pointer is coming from.
>>
>> If this approach is ok, I can re-send this as a patch.
>>
>> [120408.542387] general protection fault: 0000 [#1] SMP
>> [120408.544273] Modules linked in: nfsd nfs_acl nfsv4 dns_resolver nfs l=
ockd auth_rpcgss grace fscache sunrpc fuse ip6t_rpfilter ip6t_REJECT nf_rej=
ect_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conn=
track_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack snd_seq_midi snd_seq_mi=
di_event ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables =
ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables i=
ptable_mangle iptable_security iptable_raw rfcomm iptable_filter bnep ip_ta=
bles coretemp crc32_pclmul crc32c_intel ghash_clmulni_intel btusb btrtl btb=
cm btintel bluetooth rfkill snd_ens1371 snd_ac97_codec ppdev ac97_bus snd_s=
eq aesni_intel crypto_simd cryptd glue_helper uvcvideo videobuf2_vmalloc vi=
deobuf2_memops videobuf2_v4l2 videobuf2_core snd_pcm pcspkr serio_raw
>> [120408.558655]  videodev snd_rawmidi snd_timer snd_seq_device snd sound=
core vmw_vmci shpchp i2c_piix4 parport_pc parport acpi_cpufreq uinput xfs l=
ibcrc32c sr_mod sd_mod cdrom ata_generic pata_acpi vmwgfx drm_kms_helper sy=
scopyarea sysfillrect sysimgblt fb_sys_fops ttm drm ata_piix e1000 ahci lib=
ahci libata mptspi scsi_transport_spi mptscsih mptbase i2c_core dm_mirror d=
m_region_hash dm_log dm_mod
>> [120408.565724] CPU: 0 PID: 3601 Comm: nfsd Not tainted 4.10.0-rc3+ #16
>> [120408.567037] Hardware name: VMware, Inc. VMware Virtual Platform/440B=
X Desktop Reference Platform, BIOS 6.00 07/02/2015
>> [120408.569225] task: ffff8800776f95c0 task.stack: ffffc90003d58000
>> [120408.570483] RIP: 0010:gss_mech_put+0xb/0x20 [auth_rpcgss]
>> [120408.571614] RSP: 0018:ffffc90003d5bb78 EFLAGS: 00010206
>> [120408.572731] RAX: ffff880072ecc301 RBX: ffffc90003d5bba8 RCX: 0000000=
0003d0040
>> [120408.574240] RDX: 00000000003d003f RSI: 0000000000000246 RDI: 4f432e4=
553554f48
>> [120408.575685] RBP: ffffc90003d5bb90 R08: 000000000001b2c0 R09: fffffff=
fa0703e0c
>> [120408.577149] R10: ffff88007b61b2c0 R11: ffffea0001cbb300 R12: ffff880=
0730c1500
>> [120408.578592] R13: 00000000ffffffa1 R14: ffff880073a94b40 R15: ffff880=
074e0d600
>> [120408.580058] FS:  0000000000000000(0000) GS:ffff88007b600000(0000) kn=
lGS:0000000000000000
>> [120408.581708] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [120408.582889] CR2: 00007fe3980140b8 CR3: 000000006f063000 CR4: 0000000=
0001406f0
>> [120408.584395] Call Trace:
>> [120408.584946]  ? rsc_free+0x55/0x90 [auth_rpcgss]
>> [120408.585901]  gss_proxy_save_rsc+0xb2/0x2a0 [auth_rpcgss]
>> [120408.587017]  svcauth_gss_proxy_init+0x3cc/0x520 [auth_rpcgss]
>> [120408.588257]  ? __enqueue_entity+0x6c/0x70
>> [120408.589101]  svcauth_gss_accept+0x391/0xb90 [auth_rpcgss]
>> [120408.590212]  ? try_to_wake_up+0x4a/0x360
>> [120408.591036]  ? wake_up_process+0x15/0x20
>> [120408.592093]  ? svc_xprt_do_enqueue+0x12e/0x2d0 [sunrpc]
>> [120408.593177]  svc_authenticate+0xe1/0x100 [sunrpc]
>> [120408.594168]  svc_process_common+0x203/0x710 [sunrpc]
>> [120408.595220]  svc_process+0x105/0x1c0 [sunrpc]
>> [120408.596278]  nfsd+0xe9/0x160 [nfsd]
>> [120408.597060]  kthread+0x101/0x140
>> [120408.597734]  ? nfsd_destroy+0x60/0x60 [nfsd]
>> [120408.598626]  ? kthread_park+0x90/0x90
>> [120408.599448]  ret_from_fork+0x22/0x30
>> [120408.600232] Code: 0f 1f 44 00 00 55 48 89 e5 53 48 89 fb 48 8b 7f 10=
 e8 9a 0a 9f e0 48 89 d8 5b 5d c3 0f 1f 40 00 0f 1f 44 00 00 48 85 ff 74 0e=
 55 <48> 8b 7f 10 48 89 e5 e8 d9 f6 9e e0 5d f3 c3 66 0f 1f 44 00 00
>> [120408.604123] RIP: gss_mech_put+0xb/0x20 [auth_rpcgss] RSP: ffffc90003=
d5bb78
>> [120408.607012] ---[ end trace 473ba7f734debac4 ]---
>> [120408.608027] Kernel panic - not syncing: Fatal exception
>> [120408.609268] Kernel Offset: disabled
>> [120408.610027] ---[ end Kernel panic - not syncing: Fatal exception
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
