Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.agmk.net ([91.192.224.71]:55052 "EHLO mail.agmk.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754786Ab3ADPUy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2013 10:20:54 -0500
From: =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>
To: linux-nfs@vger.kernel.org
Cc: fanchaoting <fanchaoting@cn.fujitsu.com>,
        Steve Dickson <SteveD@redhat.com>, baggins@pld-linux.org,
        Trond.Myklebust@netapp.com
Subject: Re: mount.nfs: cannot allocate memory.
Date: Fri, 04 Jan 2013 16:20:47 +0100
Message-ID: <2145273.E615D1G9Cg@pawels>
In-Reply-To: <50E670C8.6050400@cn.fujitsu.com>
References: <2891788.0SBnrhN2VX@pawels> <14289664.zy0he5HnEB@localhost> <50E670C8.6050400@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday 04 of January 2013 14:03:52 fanchaoting wrote:
> Paweł Sikora 写道:
> > On Thursday 03 of January 2013 09:42:01 Steve Dickson wrote:
> >> On 03/01/13 04:27, Paweł Sikora wrote:
> >>> Hi,
> >>>
> >>> with the latest nfs-1.2.7/kernel-3.7.1 tools i've noticed an error during autofs mounting.
> >>> reduced testcase shows that mount.nfs with 'vers=4' has a problem:
> >>>
> >>> [root@chufu ~]# mount.nfs -v -o vers=4 192.168.2.100:/home/atest/farm-local /mnt
> >>> mount.nfs: timeout set for Thu Jan  3 10:22:00 2013
> >>> mount.nfs: trying text-based options 'vers=4,addr=192.168.2.100,clientaddr=192.168.2.103'
> >>> mount.nfs: mount(2): Cannot allocate memory
> >>> mount.nfs: Cannot allocate memory
> >>>
> >>> while the vers=3 works fine:
> >>>
> >>> [root@chufu ~]# mount.nfs -v -o vers=3 192.168.2.100:/home/atest/farm-local /mnt
> >>> mount.nfs: timeout set for Thu Jan  3 10:22:04 2013
> >>> mount.nfs: trying text-based options 'vers=3,addr=192.168.2.100'
> >>> mount.nfs: prog 100003, trying vers=3, prot=6
> >>> mount.nfs: trying 192.168.2.100 prog 100003 vers 3 prot TCP port 2049
> >>> mount.nfs: prog 100005, trying vers=3, prot=17
> >>> mount.nfs: trying 192.168.2.100 prog 100005 vers 3 prot UDP port 42412
> >>>
> >>> no obvious errors in logs on nfs server/client side :(
> >>> i can provide more info if you need to diagnose this issue.
> >> Please set the kernel debugging with 'rpcdebug -m nfs -s mount' then post the out put found in /var/log/messages.
> >>
> > 
> > rpcdebug can't find the /proc/sys/sunrpc/nfs_debug file in my system. how can i enable it?
> > 
> Hi, I found that the upstream kernel didn't create /proc/sys/sunrpc/nfs_debug default,
> if you want to debug rpc,you should set CONFIG_SUNRPC_DEBUG = y.
> 
> #cat .config
> .............................
> CONFIG_SUNRPC_BACKCHANNEL=y
> CONFIG_SUNRPC_XPRT_RDMA=m
> CONFIG_RPCSEC_GSS_KRB5=m
> CONFIG_SUNRPC_DEBUG=y <-----CONFIG_SUNRPC_DEBUG = y
> CONFIG_CEPH_FS=m
> CONFIG_CIFS=m
> 
> .......................

ok, i'll rebuild kernel from .src.rpm and post results.

btw. i've noticed an oops few moments ago:


[190621.337772] ------------[ cut here ]------------
[190621.337884] kernel BUG at /tmp/B.022a7882-ed62-4d8c-bd20-9208f32f5df6/BUILD/kernel-3.7.1/linux-3.7/net/sunrpc/svc.c:559!
[190621.338026] invalid opcode: 0000 [#1] SMP
[190621.338228] Modules linked in: nfsv3 nfsv4 nfs dns_resolver fscache fuse nfsd auth_rpcgss nfs_acl lockd sunrpc ipmi_si ipmi_devintf ipmi_msghandler sch_sfq xt_nat iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter xt_TCPMSS xt_tcpudp iptable_mangle ip_tables ip6table_filter ip6_tables x_tables quota_v2 quota_tree ext4 crc16 jbd2 raid10 raid0 dm_mod autofs4 dummy ide_cd_mod cdrom ata_generic pata_acpi pata_atiixp ide_pci_generic kvm_amd kvm igb sp5100_tco ptp pps_core dca psmouse atiixp joydev hid_generic amd64_edac_mod edac_core k10temp i2c_piix4 ide_core serio_raw i2c_core evdev pcspkr microcode hwmon edac_mce_amd processor button ext3 mbcache jbd sd_mod crc_t10dif raid1 md_mod ahci libahci libata scsi_mod usbhid hid ohci_hcd ehci_hcd usbcore usb_common
[190621.343769] CPU 5
[190621.343834] Pid: 11360, xid: #0, comm: mount.nfs Not tainted 3.7.1-2 #1 Supermicro H8DGU/H8DGU
[190621.344046] RIP: 0010:[<ffffffffa04d8df2>]  [<ffffffffa04d8df2>] svc_destroy+0x102/0x110 [sunrpc]
[190621.344260] RSP: 0018:ffff880461201898  EFLAGS: 00010202
[190621.344359] RAX: ffff8803c7158c38 RBX: ffff8803c7158c00 RCX: 00000000000000c3
[190621.344492] RDX: ffff88080a0b16c8 RSI: 0000000000000286 RDI: 0000000000000286
[190621.344623] RBP: ffff8804612018a8 R08: 00000000000168c0 R09: ffff88080fc568c0
[190621.344755] R10: ffffea000ccf0e00 R11: ffffffffa04d8eb6 R12: ffff880333c3e000
[190621.344884] R13: ffff8807dc8e3f80 R14: ffff8803c7158c00 R15: ffff880461201ae0
[190621.345014] FS:  00007fc0e6d71800(0000) GS:ffff88080fc40000(0000) knlGS:00000000f75b76c0
[190621.345183] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[190621.345326] CR2: 00000000021cc000 CR3: 00000007db49c000 CR4: 00000000000007e0
[190621.345468] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[190621.345598] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[190621.345732] Process mount.nfs (pid: 11360, threadinfo ffff880461200000, task ffff88080914e120)
[190621.345866] Stack:
[190621.345952]  ffff880333c3e000 ffff8807dc8e3f84 ffff8804612018d8 ffffffffa04d8ec3
[190621.346300]  0000000000000000 0000000000000000 ffffffff81865400 ffff88021a444400
[190621.346665]  ffff880461201908 ffffffffa058b275 0000000000000000 ffff88021a444400
[190621.347011] Call Trace:
[190621.348601]  [<ffffffffa04d8ec3>] svc_exit_thread+0xc3/0xd0 [sunrpc]
[190621.348714]  [<ffffffffa058b275>] nfs_callback_down+0x65/0xa0 [nfsv4]
[190621.348821]  [<ffffffffa058cbe7>] nfs4_free_client+0x37/0xa0 [nfsv4]
[190621.348935]  [<ffffffffa054337e>] nfs_put_client+0xfe/0x110 [nfs]
[190621.349039]  [<ffffffffa058cd88>] nfs4_init_client+0x138/0x1c0 [nfsv4]
[190621.349148]  [<ffffffff8127f7bf>] ? idr_get_new_above_int+0x3f/0x50
[190621.349257]  [<ffffffffa04d67ff>] ? rpc_init_wait_queue+0x5f/0x90 [sunrpc]
[190621.349364]  [<ffffffffa058cae4>] ? nfs4_alloc_client+0xf4/0x1c0 [nfsv4]
[190621.349471]  [<ffffffffa0543969>] nfs_get_client+0x269/0x2b0 [nfs]
[190621.349576]  [<ffffffffa058c9c9>] nfs4_set_client.isra.10+0x69/0x90 [nfsv4]
[190621.349684]  [<ffffffffa058d1d3>] nfs4_create_server+0xc3/0x2f0 [nfsv4]
[190621.349790]  [<ffffffffa05886d4>] nfs4_remote_mount+0x34/0x70 [nfsv4]
[190621.349894]  [<ffffffff8117e51f>] mount_fs+0x3f/0x230
[190621.349992]  [<ffffffff8113afbb>] ? __alloc_percpu+0xb/0x10
[190621.350093]  [<ffffffff81198842>] vfs_kern_mount+0xd2/0x170
[190621.350195]  [<ffffffffa058865c>] nfs_do_root_mount+0x8c/0xd0 [nfsv4]
[190621.350301]  [<ffffffffa058897b>] nfs4_try_mount+0x3b/0x60 [nfsv4]
[190621.350409]  [<ffffffffa054dfa9>] nfs_fs_mount+0x499/0xa20 [nfs]
[190621.350516]  [<ffffffffa054b730>] ? nfs_clone_super+0x140/0x140 [nfs]
[190621.350622]  [<ffffffffa054b5d0>] ? nfs_clone_sb_security+0x60/0x60 [nfs]
[190621.350726]  [<ffffffff8117e51f>] mount_fs+0x3f/0x230
[190621.350823]  [<ffffffff8113afbb>] ? __alloc_percpu+0xb/0x10
[190621.350922]  [<ffffffff81198842>] vfs_kern_mount+0xd2/0x170
[190621.351021]  [<ffffffff81198d5f>] do_kern_mount+0x4f/0x100
[190621.351120]  [<ffffffff8119a807>] do_mount+0x2e7/0xa10
[190621.351218]  [<ffffffff8119a395>] ? copy_mount_options+0x35/0x180
[190621.351319]  [<ffffffff8119afb9>] sys_mount+0x89/0xd0
[190621.351418]  [<ffffffff814e8229>] system_call_fastpath+0x16/0x1b
[190621.351518] Code: 00 eb 97 66 0f 1f 44 00 00 e8 8b 14 00 00 48 83 c4 08 5b 5d c3 48 89 fe 31 c0 48 c7 c7 38 be 4e a0 e8 8a eb ff e0 e9 23 ff ff ff <0f> 0b 0f 0b 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 41 56 41
[190621.355336] RIP  [<ffffffffa04d8df2>] svc_destroy+0x102/0x110 [sunrpc]
[190621.355517]  RSP <ffff880461201898>
[190621.355630] ---[ end trace c243ff3a21205483 ]---


(...)
        /*
         * The last user is gone and thus all sockets have to be destroyed to
         * the point. Check this.
         */
                  BUG_ON(!list_empty(&serv->sv_permsocks));
svc.c:559:        BUG_ON(!list_empty(&serv->sv_tempsocks));
(...)

