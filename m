Return-Path: linux-nfs-owner@vger.kernel.org
Received: from chicago.messinet.com ([50.196.241.75]:53320 "EHLO
	chicago.messinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068AbbBUC4C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Feb 2015 21:56:02 -0500
From: Anthony Messina <amessina@messinet.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: soft lockup in the laundromat
Date: Fri, 20 Feb 2015 20:55:53 -0600
Message-ID: <1524803.SbAy9NQUHI@ws1.m.messinet.com>
In-Reply-To: <2527473.XPWgOc24eg@linux-ws1.messinet.com>
References: <alpine.OSX.2.19.9992.1502181132520.80359@planck.local> <2527473.XPWgOc24eg@linux-ws1.messinet.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2042422.lsbJN8hOMj"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart2042422.lsbJN8hOMj
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

On Wednesday, February 18, 2015 19:26:51 Anthony Messina wrote:
> On Wednesday, February 18, 2015 11:36:06 AM Benjamin Coddington wrote=
:
> > While playing with callback channel failures, I ran into this on th=
e
> >
> > server yesterday:
> >=20
> >
> > [  372.020003] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s=
!
> > [kworker/u4:0:6] [  372.020003] Modules linked in: cts rpcsec_gss_k=
rb5
> > nfnetlink_queue nfnetlink_log nfnetlink nf_conntrack_netbios_ns
> > nf_conntrack_broadcast ip6t_rpfilter ip6t_REJECT xt_conntrack ebtab=
le_nat
> > ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat
> > nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle
> > ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_n=
at
> > nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
> > iptable_mangle iptable_security iptable_raw ppdev crct10dif_pclmul
> > crc32_pclmul crc32c_intel ghash_clmulni_intel serio_raw virtio_cons=
ole
> > virtio_balloon parport_pc pvpanic parport i2c_piix4 nfsd auth_rpcgs=
s
> > nfs_acl lockd sunrpc virtio_net virtio_blk cirrus drm_kms_helper tt=
m drm
> > virtio_pci virtio_ring virtio ata_generic pata_acpi [  372.020003] =
CPU: 1
> > PID: 6 Comm: kworker/u4:0 Not tainted 3.17.4-301.fc21.x86_64 #1
> > [  372.020003] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996=
), BIOS
> > 1.7.5-20140709_153950- 04/01/2014 [  372.020003] Workqueue: nfsd4
> > laundromat_main [nfsd]
> > [  372.020003] task: ffff88007c7bb110 ti: ffff88007c04c000 task.ti:=

> > ffff88007c04c000 [  372.020003] RIP:
> > 0010:[<ffffffff81746162>]  [<ffffffff81746162>]
> > _raw_spin_unlock_irqrestore+0x12/0x20 [  372.020003] RSP:
> > 0018:ffff88007c04fcd8  EFLAGS: 00000246
> > [  372.020003] RAX: ffffffffa01876f0 RBX: 0000000000000000 RCX:
> > 0000000000000000 [  372.020003] RDX: ffffffffa0187708 RSI:
> > 0000000000000246
> > RDI: 0000000000000246 [  372.020003] RBP: ffff88007c04fcd8 R08:
> > 0000000000000000 R09: 0000000000017a40 [  372.020003] R10:
> > ffffffffa017b4ed
> > R11: 00000000000003a5 R12: ffffffffa01815ba [  372.020003] R13:
> > ffff88007c04fc98 R14: ffffffff81f0cc80 R15: 0000000000000000
> > [  372.020003]
> > FS:  0000000000000000(0000) GS:ffff88007fd00000(0000)
> > knlGS:0000000000000000 [  372.020003] CS:  0010 DS: 0000 ES: 0000 C=
R0:
> > 0000000080050033
> > [  372.020003] CR2: 00007fccadbe03b8 CR3: 000000007b89e000 CR4:
> > 00000000000406e0 [  372.020003] Stack:
> > [  372.020003]  ffff88007c04fd10 ffffffff810d6ac4 ffff88007c04fcf8
> > ffff88007c04fd38 [  372.020003]  ffffffffa016f69d ffff88007a21a878
> > ffff88007a21a888 ffff88007c04fd38 [  372.020003]  ffffffffa016f69d
> > ffff88007c04fd48 ffff88007a21a800 ffff88007c04fcf8 [  372.020003] C=
all
> > Trace:
> > [  372.020003]  [<ffffffff810d6ac4>] __wake_up+0x44/0x50
> > [  372.020003]  [<ffffffffa016f69d>] ? nfs4_put_stid+0xcd/0xe0 [nfs=
d]
> > [  372.020003]  [<ffffffffa016f69d>] nfs4_put_stid+0xcd/0xe0 [nfsd]=

> > [  372.020003]  [<ffffffffa016f93f>] __destroy_client+0xdf/0x160 [n=
fsd]
> > [  372.020003]  [<ffffffffa016f9e2>] expire_client+0x22/0x30 [nfsd]=

> > [  372.020003]  [<ffffffffa016fd9e>] laundromat_main+0x18e/0x4d0 [n=
fsd]
> > [  372.020003]  [<ffffffff810af88d>] process_one_work+0x14d/0x400
> > [  372.020003]  [<ffffffff810b021b>] worker_thread+0x6b/0x4a0
> > [  372.020003]  [<ffffffff810b01b0>] ? rescuer_thread+0x2a0/0x2a0
> > [  372.020003]  [<ffffffff810b52fa>] kthread+0xea/0x100
> > [  372.020003]  [<ffffffff810b5210>] ? kthread_create_on_node+0x1a0=
/0x1a0
> > [  372.020003]  [<ffffffff81746a3c>] ret_from_fork+0x7c/0xb0
> > [  372.020003]  [<ffffffff810b5210>] ? kthread_create_on_node+0x1a0=
/0x1a0
> > [  372.020003] Code: c3 66 41 83 47 08 01 fb 66 66 90 66 66 90 eb c=
a 31 c0
> > eb ce e8 40 0d 95 ff 66 66 66 66 90 55 48 89 e5 66 83 07 01 48 89 f=
7 57 9d
> > <66> 66 90 66 90 5d c3 0f 1f 80 00 00 00 00 66 66 66 66 90 55 48
> >
> >=20
> >=20
> >
> > I'll see if I can reproduce on 3.18..
>=20
> This looks pretty close to me, on 3.18:=20
> https://bugzilla.redhat.com/show_bug.cgi?id=3D1185519


This is what I get on the *server* end when a client needs be hard rest=
arted--
when the client tries to mount...

kernel: NMI watchdog: BUG: soft lockup - CPU#2 stuck for 23s! [nfsd:170=
8]
kernel: Modules linked in: cts rpcsec_gss_krb5 vhost_net vhost macvtap =
macvlan=20
tun ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ebtable_nat=20=

ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat=20
nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_s=
ecurity=20
ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4=20=

nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_s=
ecurity=20
iptable_raw raid10 intel_rapl x86_pkg_temp_thermal bnx2 coretemp iTCO_w=
dt=20
iTCO_vendor_support lpc_ich dcdbas kvm_intel mfd_core ie31200_edac edac=
_core=20
kvm ipmi_si ipmi_msghandler crct10dif_pclmul crc32_pclmul crc32c_intel=20=

ghash_clmulni_intel wmi shpchp i2c_i801 nfsd auth_rpcgss nfs_acl lockd =
grace=20
sunrpc raid1 mgag200 i2c_algo_bit drm_kms_helper ttm mpt2sas
kernel:  drm raid_class scsi_transport_sas
kernel: CPU: 2 PID: 1708 Comm: nfsd Not tainted 3.18.7-200.fc21.x86_64 =
#1
kernel: Hardware name: Dell Inc. PowerEdge R210 II/09T7VV, BIOS 2.2.3=20=

10/25/2012
kernel: task: ffff8802212b89d0 ti: ffff8800aee90000 task.ti: ffff8800ae=
e90000
kernel: RIP: 0010:[<ffffffff81764a92>]  [<ffffffff81764a92>]=20
_raw_spin_unlock_irqrestore+0x12/0x20
kernel: RSP: 0018:ffff8800aee93bf8  EFLAGS: 00000292
kernel: RAX: ffffffffa0195710 RBX: 00ff880100000001 RCX: 00000000000000=
00
kernel: RDX: ffffffffa0195728 RSI: 0000000000000292 RDI: 00000000000002=
92
kernel: RBP: ffff8800aee93bf8 R08: 0000000000000000 R09: 00000001802100=
19
kernel: R10: ffff88023fc9ac90 R11: ffff8801c9da1c18 R12: 00ffffff000000=
01
kernel: R13: ffff88011f9542b8 R14: ffffffff811f508d R15: ffff8800aee93c=
08
kernel: FS:  0000000000000000(0000) GS:ffff88023fc80000(0000)=20
knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kernel: CR2: 00007f1f06af0fa8 CR3: 0000000001c11000 CR4: 00000000000427=
e0
kernel: Stack:
kernel:  ffff8800aee93c38 ffffffff810da1c8 0000000000000246 ffff8800aee=
93c30
kernel:  ffffffffa017d556 ffff8800aee93c80 ffff88007bade078 ffff880231c=
44600
kernel:  ffff8800aee93c68 ffffffffa017d2b5 ffffffffa017d557 ffff8800aee=
93c80
kernel: Call Trace:
kernel:  [<ffffffff810da1c8>] __wake_up+0x48/0x60
kernel:  [<ffffffffa017d556>] ? __destroy_client+0xe6/0x160 [nfsd]
kernel:  [<ffffffffa017d2b5>] nfs4_put_stid+0xd5/0xe0 [nfsd]
kernel:  [<ffffffffa017d557>] ? __destroy_client+0xe7/0x160 [nfsd]
kernel:  [<ffffffffa017d557>] __destroy_client+0xe7/0x160 [nfsd]
kernel:  [<ffffffffa017d5f6>] expire_client+0x26/0x30 [nfsd]
kernel:  [<ffffffffa017e908>] nfsd4_create_session+0x778/0x800 [nfsd]
kernel:  [<ffffffffa016f4af>] nfsd4_proc_compound+0x3ef/0x700 [nfsd]
kernel:  [<ffffffffa015beb3>] nfsd_dispatch+0xc3/0x210 [nfsd]
kernel:  [<ffffffffa00f7f32>] ? svc_tcp_adjust_wspace+0x12/0x30 [sunrpc=
]
kernel:  [<ffffffffa00f6e31>] svc_process_common+0x401/0x680 [sunrpc]
kernel:  [<ffffffffa00f71b7>] svc_process+0x107/0x170 [sunrpc]
kernel:  [<ffffffffa015b807>] nfsd+0x117/0x190 [nfsd]
kernel:  [<ffffffffa015b6f0>] ? nfsd_destroy+0x90/0x90 [nfsd]
kernel:  [<ffffffff810b801a>] kthread+0xea/0x100
kernel:  [<ffffffff810b7f30>] ? kthread_create_on_node+0x1b0/0x1b0
kernel:  [<ffffffff8176537c>] ret_from_fork+0x7c/0xb0
kernel:  [<ffffffff810b7f30>] ? kthread_create_on_node+0x1b0/0x1b0
kernel: Code: 41 83 47 08 01 fb 66 66 90 66 66 90 eb cb 31 c0 eb cf e8 =
32 45=20
93 ff 90 90 66 66 66 66 90 55 48 89 e5 66 83 07 01 48 89 f7 57 9d <66> =
66 90=20
66 90 5d c3 0f 1f 80 00 00 00 00 66 66 66 66 90 55 48=20
kernel: INFO: rcu_sched self-detected stall on CPU { 2}  (t=3D60000 jif=
fies=20
g=3D4858111 c=3D4858110 q=3D0)
kernel: Task dump for CPU 2:
kernel: nfsd            R  running task        0  1708      2 0x0000088=
8
kernel:  ffff8802212b89d0 00000000f8ec8e32 ffff88023fc83d58 ffffffff810=
c4f88
kernel:  0000000000000002 ffffffff81c58a80 ffff88023fc83d78 ffffffff810=
c860d
kernel:  ffff88023fc83d78 0000000000000003 ffff88023fc83da8 ffffffff810=
f6a31
kernel: Call Trace:
kernel:  <IRQ>  [<ffffffff810c4f88>] sched_show_task+0xa8/0x110
kernel:  [<ffffffff810c860d>] dump_cpu_task+0x3d/0x50
kernel:  [<ffffffff810f6a31>] rcu_dump_cpu_stacks+0x91/0xd0
kernel:  [<ffffffff810fa727>] rcu_check_callbacks+0x497/0x710
kernel:  [<ffffffff810ffa4b>] update_process_times+0x4b/0x80
kernel:  [<ffffffff8110f595>] tick_sched_handle.isra.19+0x25/0x60
kernel:  [<ffffffff8110f705>] tick_sched_timer+0x45/0x80
kernel:  [<ffffffff81100774>] __run_hrtimer+0x74/0x1d0
kernel:  [<ffffffff8110f6c0>] ? tick_sched_do_timer+0x60/0x60
kernel:  [<ffffffff81100b8f>] hrtimer_interrupt+0x10f/0x260
kernel:  [<ffffffff8104c0ce>] local_apic_timer_interrupt+0x3e/0x70
kernel:  [<ffffffff817681d3>] smp_apic_timer_interrupt+0x43/0x60
kernel:  [<ffffffff817662bd>] apic_timer_interrupt+0x6d/0x80
kernel:  <EOI>  [<ffffffff81764a92>] ? _raw_spin_unlock_irqrestore+0x12=
/0x20
kernel:  [<ffffffff810da1c8>] __wake_up+0x48/0x60
kernel:  [<ffffffffa017d1e4>] ? nfs4_put_stid+0x4/0xe0 [nfsd]
kernel:  [<ffffffffa017d2b5>] nfs4_put_stid+0xd5/0xe0 [nfsd]
kernel:  [<ffffffffa017d1e5>] ? nfs4_put_stid+0x5/0xe0 [nfsd]
kernel:  [<ffffffffa017d557>] __destroy_client+0xe7/0x160 [nfsd]
kernel:  [<ffffffffa017d5f6>] expire_client+0x26/0x30 [nfsd]
kernel:  [<ffffffffa017e908>] nfsd4_create_session+0x778/0x800 [nfsd]
kernel:  [<ffffffffa016f4af>] nfsd4_proc_compound+0x3ef/0x700 [nfsd]
kernel:  [<ffffffffa015beb3>] nfsd_dispatch+0xc3/0x210 [nfsd]
kernel:  [<ffffffffa00f7f32>] ? svc_tcp_adjust_wspace+0x12/0x30 [sunrpc=
]
kernel:  [<ffffffffa00f6e31>] svc_process_common+0x401/0x680 [sunrpc]
kernel:  [<ffffffffa00f71b7>] svc_process+0x107/0x170 [sunrpc]
kernel:  [<ffffffffa015b807>] nfsd+0x117/0x190 [nfsd]
kernel:  [<ffffffffa015b6f0>] ? nfsd_destroy+0x90/0x90 [nfsd]
kernel:  [<ffffffff810b801a>] kthread+0xea/0x100
kernel:  [<ffffffff810b7f30>] ? kthread_create_on_node+0x1b0/0x1b0
kernel:  [<ffffffff8176537c>] ret_from_fork+0x7c/0xb0
kernel:  [<ffffffff810b7f30>] ? kthread_create_on_node+0x1b0/0x1b0

=2D-=20
Anthony - https://messinet.com/ - https://messinet.com/~amessina/galler=
y
8F89 5E72 8DF0 BCF0 10BE 9967 92DC 35DC B001 4A4E

--nextPart2042422.lsbJN8hOMj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEABECAAYFAlTn870ACgkQktw13LABSk4WBwCgnbLkhqsqiYHc3D/grp0Oq+N8
7DkAoKFGkIZ3QiBw+IuaQv/tE/9kDtMs
=BPTu
-----END PGP SIGNATURE-----

--nextPart2042422.lsbJN8hOMj--

