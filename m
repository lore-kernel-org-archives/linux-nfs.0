Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58820 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756500Ab2KHTu1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Nov 2012 14:50:27 -0500
Date: Thu, 8 Nov 2012 14:50:25 -0500
To: pille <pille+kernel.org+mailinglist+linux-nfs@struction.de>
Cc: linux-nfs@vger.kernel.org, 1071733@bugs.launchpad.net
Subject: Re: NFS export of LVM snapshot exports origin instead of snapshot
Message-ID: <20121108195025.GA5042@fieldses.org>
References: <509BDA31.3090904@struction.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <509BDA31.3090904@struction.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 08, 2012 at 05:13:37PM +0100, pille wrote:
> hi,
> 
> [1.] One line summary of the problem:
> NFS export of LVM snapshot exports origin instead of snapshot
> 
> 
> [2.] Full description of the problem/report:
> from https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1071733
> 
> we're using LVM snapshots on our storage server to provide data for our
> live and staging instances.
> there are two mountpoints on the server, one for the origin volume, and
> one for the snapshot that are exported using NFS to our live/staging
> instances (webserver)

The protocol references files on the filesystem using filehandles.  The
linux NFS server generates a filehandle that has a part which identifies
the filesystem and a part which identifies the particular file (usually
an inode and generation number).

The filesystem part in your case is probably a uuid which is part of
what's copied when you snapshot (as are all the inode numbers).  So
you're left with filehandles that are the same for the two filesystems.

You can tell it to instead to use whatever integer you'd like using the
"fsid=" export option (just don't used fsid=0, which has a special
meaning).

Or, probably better--you should be able to be able to modify the uuid...
Looking at the tune2fs man page, I think it should be:

	tune2fs -U random /dev/vg0/nfssnapshot

--b.

> 
> today i noticed, that writes on our staging-webserver don't go to the
> snapshot as expected, but are hitting the origin volume, messing up all
> of our live data.
> 
> i checked the NFS-mounts and -exports and they look perfectly valid
> (staging mounts snapshot-mountpoint, live mounts origin-mountpoint)
> on the storage-server itself looking at the mountpoints, everything
> looks valid, too. i wrote some identifying test-files in each mountpoint
> in order to track them. no problem as long, as we look on the NFS-server
> itself.
> 
> but looking in the mountpoints of a NFS-client, it shows that the origin
> data was mounted.
> i found no way to mount the snapshot again.
> 
> i'm not entirely sure, what component causes the problem. since the
> mountpoints look valid on the server itself, i would rule out LVM. i
> also would rule out the NFS-client, since it should not be able to see
> what the server hasn't exported. all clients can see the problem (lucid,
> maverick, precise).
> 
> 
> [3.] Keywords (i.e., modules, networking, kernel):
> 
> 
> [4.] Kernel version (from /proc/version):
> Linux version 3.7.0-030700rc4-generic (apw@gomeisa) (gcc version 4.6.3
> (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #201211041435 SMP Sun Nov 4 19:35:50
> UTC 2012
> 
> 
> [5.] Output of Oops.. message (if applicable) with symbolic information
> resolved (see Documentation/oops-tracing.txt)
> 
> 
> [6.] A small shell script or example program which triggers the problem
> (if possible)
> # prepare
> if [ ! -e /dev/vg0/nfsorigin ]; then
>     lvcreate --size=10M --name=nfsorigin vg0
>     mkfs.ext3 /dev/vg0/nfsorigin
>     mount /dev/vg0/nfsorigin /mnt/nfsorigin
>     touch /mnt/nfsorigin/NFSORIGIN
>     umount /mnt/nfsorigin
> fi
> 
> if [ ! -e /dev/vg0/nfssnapshot ]; then
>     lvcreate --snapshot --size=1M --name=nfssnapshot vg0/nfsorigin
>     mount /dev/vg0/nfssnapshot /mnt/nfssnapshot
>     rm /mnt/nfssnapshot/NFSORIGIN
>     touch /mnt/nfssnapshot/NFSSNAPSHOT
>     umount /mnt/nfssnapshot
> fi
> 
> # mount local
> mount /dev/vg0/nfssnapshot /mnt/nfssnapshot
> mount /dev/vg0/nfsorigin /mnt/nfsorigin
> 
> ls -lR /mnt/*
> 
> # export /mnt via NFS in /etc/exports:
> #   /mnt 127.0.0.1(rw,async,no_subtree_check,crossmnt)
> /etc/init.d/nfs-kernel-server restart
> 
> # mount remote
> mount localhost:/mnt /mnt2
> 
> ls -lR /mnt2/*
> 
> # clean up
> umount /mnt2
> umount -l /mnt/nfssnapshot
> umount -l /mnt/nfsorigin
> 
> 
> [7.] Environment
> Description:    Ubuntu 12.04.1 LTS
> Release:        12.04
> 
> [7.1.] Software (add the output of the ver_linux script here)
> Linux nfs2 3.7.0-030700rc4-generic #201211041435 SMP Sun Nov 4 19:35:50
> UTC 2012 x86_64 x86_64 x86_64 GNU/Linux
> 
> Gnu C                  4.6
> Gnu make               3.81
> binutils               2.22
> util-linux             2.20.1
> mount                  support
> module-init-tools      3.16
> e2fsprogs              1.42
> reiserfsprogs          3.6.21
> xfsprogs               3.1.7
> Linux C Library        2.15
> Dynamic linker (ldd)   2.15
> Procps                 3.2.8
> Net-tools              1.60
> Kbd                    1.15.2
> Sh-utils               8.13
> Modules Loaded         nfsv3 nfsv4 xfs vhost_net macvtap macvlan
> ip6table_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE
> iptable_nat nf_nat_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_state
> ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc
> nfsd nfs_acl auth_rpcgss nfs fscache lockd sunrpc ext2 coretemp
> kvm_intel i915 kvm ghash_clmulni_intel aesni_intel ablk_helper cryptd
> lrw drm_kms_helper aes_x86_64 xts drm gf128mul eeepc_wmi asus_wmi nf_nat
> nf_conntrack dm_multipath sparse_keymap i2c_algo_bit serio_raw scsi_dh
> mei video lp mac_hid wmi lpc_ich parport microcode reiserfs dm_snapshot
> multipath linear aacraid 3w_9xxx 3w_xxxx raid10 raid456 async_pq
> async_xor xor async_memcpy async_raid6_recov ses enclosure firewire_ohci
> raid6_pq firewire_core async_tx crc_itu_t e1000e raid1 megaraid_sas
> raid0 sata_nv sata_sil sata_via
> 
> 
> [7.2.] Processor information (from /proc/cpuinfo):
> i doubt this provides useful information for this issue and just bloats
> this report, so i've skipped all processors except for the last one.
> feel free to request the others...
> 
> processor       : 7
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 42
> model name      : Intel(R) Xeon(R) CPU E31245 @ 3.30GHz
> stepping        : 7
> microcode       : 0x28
> cpu MHz         : 1600.000
> cache size      : 8192 KB
> physical id     : 0
> siblings        : 8
> core id         : 3
> cpu cores       : 4
> apicid          : 7
> initial apicid  : 7
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 13
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
> syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl
> xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor
> ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic
> popcnt tsc_deadline_timer aes xsave avx lahf_lm ida arat epb xsaveopt
> pln pts dtherm tpr_shadow vnmi flexpriority ept vpid
> bogomips        : 6600.25
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 36 bits physical, 48 bits virtual
> power management:
> 
> 
> [7.3.] Module information (from /proc/modules):
> nfsv3 34775 0 - Live 0xffffffffa05a6000
> nfsv4 150145 0 - Live 0xffffffffa05d6000
> xfs 852629 0 - Live 0xffffffffa04d4000
> vhost_net 32439 1 - Live 0xffffffffa04cb000
> macvtap 18528 1 vhost_net, Live 0xffffffffa04c5000
> macvlan 19002 1 macvtap, Live 0xffffffffa04bb000
> ip6table_filter 12815 0 - Live 0xffffffffa04b6000
> ip6_tables 27685 1 ip6table_filter, Live 0xffffffffa04aa000
> ebtable_nat 12807 0 - Live 0xffffffffa04a5000
> ebtables 31023 1 ebtable_nat, Live 0xffffffffa036d000
> ipt_MASQUERADE 12759 3 - Live 0xffffffffa0368000
> iptable_nat 12909 1 - Live 0xffffffffa0363000
> nf_nat_ipv4 13316 1 iptable_nat, Live 0xffffffffa030e000
> nf_conntrack_ipv4 14538 2 - Live 0xffffffffa0305000
> nf_defrag_ipv4 12729 1 nf_conntrack_ipv4, Live 0xffffffffa02f8000
> xt_state 12578 1 - Live 0xffffffffa02f3000
> ipt_REJECT 12576 2 - Live 0xffffffffa02bf000
> xt_tcpudp 12603 4 - Live 0xffffffffa02ba000
> iptable_filter 12810 1 - Live 0xffffffffa02b5000
> ip_tables 27473 2 iptable_nat,iptable_filter, Live 0xffffffffa0243000
> x_tables 29846 9
> ip6table_filter,ip6_tables,ebtables,ipt_MASQUERADE,xt_state,ipt_REJECT,xt_tcpudp,iptable_filter,ip_tables,
> Live 0xffffffffa0261000
> bridge 91579 0 - Live 0xffffffffa02db000
> stp 12931 1 bridge, Live 0xffffffffa023e000
> llc 14597 2 bridge,stp, Live 0xffffffffa01c3000
> nfsd 263389 13 - Live 0xffffffffa045f000
> nfs_acl 12883 2 nfsv3,nfsd, Live 0xffffffffa01e0000
> auth_rpcgss 41008 2 nfsv4,nfsd, Live 0xffffffffa0219000
> nfs 165972 2 nfsv3,nfsv4, Live 0xffffffffa0435000
> fscache 61534 1 nfs, Live 0xffffffffa02ca000
> lockd 77514 3 nfsv3,nfsd,nfs, Live 0xffffffffa029b000
> sunrpc 236558 115 nfsv3,nfsv4,nfsd,nfs_acl,auth_rpcgss,nfs,lockd, Live
> 0xffffffffa03fa000
> ext2 73872 1 - Live 0xffffffffa0287000
> coretemp 13554 0 - Live 0xffffffffa0227000
> kvm_intel 137786 4 - Live 0xffffffffa01a0000
> i915 588249 0 - Live 0xffffffffa07af000
> kvm 441558 1 kvm_intel, Live 0xffffffffa038d000
> ghash_clmulni_intel 13219 0 - Live 0xffffffffa02b0000
> aesni_intel 55495 0 - Live 0xffffffffa0252000
> ablk_helper 13597 1 aesni_intel, Live 0xffffffffa024d000
> cryptd 20530 3 ghash_clmulni_intel,aesni_intel,ablk_helper, Live
> 0xffffffffa018d000
> lrw 13323 1 aesni_intel, Live 0xffffffffa0239000
> drm_kms_helper 46933 1 i915, Live 0xffffffffa01d3000
> aes_x86_64 17208 1 aesni_intel, Live 0xffffffffa01ca000
> xts 12917 1 aesni_intel, Live 0xffffffffa0188000
> drm 286485 2 i915,drm_kms_helper, Live 0xffffffffa031c000
> gf128mul 14951 2 lrw,xts, Live 0xffffffffa019b000
> eeepc_wmi 13151 0 - Live 0xffffffffa0380000
> asus_wmi 24581 1 eeepc_wmi, Live 0xffffffffa0385000
> nf_nat 26215 3 ipt_MASQUERADE,iptable_nat,nf_nat_ipv4, Live
> 0xffffffffa0378000
> nf_conntrack 84166 6
> ipt_MASQUERADE,iptable_nat,nf_nat_ipv4,nf_conntrack_ipv4,xt_state,nf_nat, Live
> 0xffffffffa026d000
> dm_multipath 23260 0 - Live 0xffffffffa0212000
> sparse_keymap 13890 1 asus_wmi, Live 0xffffffffa0317000
> i2c_algo_bit 13564 1 i915, Live 0xffffffffa0300000
> serio_raw 13215 0 - Live 0xffffffffa02c5000
> scsi_dh 14791 1 dm_multipath, Live 0xffffffffa0201000
> mei 41467 0 - Live 0xffffffffa022d000
> video 19412 2 i915,asus_wmi, Live 0xffffffffa020c000
> lp 17799 0 - Live 0xffffffffa0206000
> mac_hid 13253 0 - Live 0xffffffffa0145000
> wmi 19256 1 asus_wmi, Live 0xffffffffa01f5000
> lpc_ich 17144 0 - Live 0xffffffffa01fb000
> parport 46562 1 lp, Live 0xffffffffa01e8000
> microcode 23075 0 - Live 0xffffffffa0194000
> reiserfs 249114 2 - Live 0xffffffffa014a000
> dm_snapshot 39036 23 - Live 0xffffffffa013a000
> multipath 13145 0 - Live 0xffffffffa0105000
> linear 12894 0 - Live 0xffffffffa00f3000
> aacraid 96661 0 - Live 0xffffffffa0121000
> 3w_9xxx 43472 0 - Live 0xffffffffa0115000
> 3w_xxxx 39171 0 - Live 0xffffffffa010a000
> raid10 48658 0 - Live 0xffffffffa00f8000
> raid456 66945 0 - Live 0xffffffffa00e1000
> async_pq 13187 1 raid456, Live 0xffffffffa0083000
> async_xor 12879 2 raid456,async_pq, Live 0xffffffffa007e000
> xor 17116 1 async_xor, Live 0xffffffffa00db000
> async_memcpy 12529 1 raid456, Live 0xffffffffa00d6000
> async_raid6_recov 12776 1 raid456, Live 0xffffffffa00d1000
> ses 17417 0 - Live 0xffffffffa003c000
> enclosure 15269 1 ses, Live 0xffffffffa009f000
> firewire_ohci 45129 0 - Live 0xffffffffa00c4000
> raid6_pq 97181 2 async_pq,async_raid6_recov, Live 0xffffffffa00a7000
> firewire_core 64894 1 firewire_ohci, Live 0xffffffffa008e000
> async_tx 13349 5
> raid456,async_pq,async_xor,async_memcpy,async_raid6_recov, Live
> 0xffffffffa0089000
> crc_itu_t 12707 1 firewire_core, Live 0xffffffffa001b000
> e1000e 198519 0 - Live 0xffffffffa004c000
> raid1 35702 0 - Live 0xffffffffa0042000
> megaraid_sas 83093 2 - Live 0xffffffffa0026000
> raid0 17315 0 - Live 0xffffffffa0020000
> sata_nv 32297 0 - Live 0xffffffffa0012000
> sata_sil 13550 0 - Live 0xffffffffa0009000
> sata_via 13810 0 - Live 0xffffffffa0000000
> 
> 
> [7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
> 0000-0cf7 : PCI Bus 0000:00
>   0000-001f : dma1
>   0020-0021 : pic1
>   0040-0043 : timer0
>   0050-0053 : timer1
>   0060-0060 : keyboard
>   0064-0064 : keyboard
>   0070-0077 : rtc0
>   0080-008f : dma page reg
>   00a0-00a1 : pic2
>   00c0-00df : dma2
>   00f0-00ff : fpu
>   0200-020f : pnp 00:05
>   0290-029f : pnp 00:08
>   03c0-03df : vga+
>   0400-0453 : pnp 00:05
>     0400-0403 : ACPI PM1a_EVT_BLK
>     0404-0405 : ACPI PM1a_CNT_BLK
>     0408-040b : ACPI PM_TMR
>     0410-0415 : ACPI CPU throttle
>     0420-042f : ACPI GPE0_BLK
>     0430-0433 : iTCO_wdt
>     0450-0450 : ACPI PM2_CNT_BLK
>   0454-0457 : pnp 00:07
>   0458-047f : pnp 00:05
>     0460-047f : iTCO_wdt
>   04d0-04d1 : pnp 00:09
>   0500-057f : pnp 00:05
>   0680-069f : pnp 00:05
> 0cf8-0cff : PCI conf1
> 0d00-ffff : PCI Bus 0000:00
>   164e-164f : pnp 00:05
>   2000-2fff : PCI Bus 0000:03
>   b000-bfff : PCI Bus 0000:07
>     b000-b07f : 0000:07:03.0
>   c000-cfff : PCI Bus 0000:05
>     c000-c01f : 0000:05:00.0
>   d000-dfff : PCI Bus 0000:04
>     d000-d01f : 0000:04:00.0
>   e000-efff : PCI Bus 0000:01
>     e000-e0ff : 0000:01:00.0
>       e000-e0ff : megasas: LSI
>   f000-f03f : 0000:00:02.0
>   f040-f05f : 0000:00:1f.3
>   f060-f07f : 0000:00:1f.2
>     f060-f07f : ahci
>   f080-f083 : 0000:00:1f.2
>     f080-f083 : ahci
>   f090-f097 : 0000:00:1f.2
>     f090-f097 : ahci
>   f0a0-f0a3 : 0000:00:1f.2
>     f0a0-f0a3 : ahci
>   f0b0-f0b7 : 0000:00:1f.2
>     f0b0-f0b7 : ahci
>   ffff-ffff : pnp 00:05
>     ffff-ffff : pnp 00:05
> 
> 00000000-0000ffff : reserved
> 00010000-0009dbff : System RAM
> 0009dc00-0009ffff : reserved
> 000a0000-000bffff : PCI Bus 0000:00
> 000c0000-000ce3ff : Video ROM
> 000ce800-000d4bff : Adapter ROM
> 000d5000-000d5fff : Adapter ROM
> 000d8000-000dbfff : PCI Bus 0000:00
> 000dc000-000dffff : PCI Bus 0000:00
> 000e0000-000fffff : reserved
>   000e0000-000e3fff : PCI Bus 0000:00
>   000e4000-000e7fff : PCI Bus 0000:00
>   000f0000-000fffff : System ROM
> 00100000-1fffffff : System RAM
>   01000000-016d73c0 : Kernel code
>   016d73c1-01ce6abf : Kernel data
>   01de7000-01f46fff : Kernel bss
> 20000000-201fffff : reserved
>   20000000-201fffff : pnp 00:0d
> 20200000-3fffffff : System RAM
> 40000000-401fffff : reserved
>   40000000-401fffff : pnp 00:0d
> 40200000-da38dfff : System RAM
> da38e000-da93bfff : reserved
> da93c000-dab8efff : ACPI Non-volatile Storage
> dab8f000-dab9bfff : ACPI Tables
> dab9c000-dabbbfff : ACPI Non-volatile Storage
> dabbc000-dabc0fff : ACPI Tables
> dabc1000-dac03fff : ACPI Non-volatile Storage
> dac04000-daffffff : System RAM
> db000000-db7fffff : RAM buffer
> db800000-df9fffff : reserved
> dfa00000-feafffff : PCI Bus 0000:00
>   dfa00000-dfa00fff : pnp 00:0c
>   dfb00000-dfcfffff : PCI Bus 0000:03
>   dfd00000-dfefffff : PCI Bus 0000:03
>   e0000000-efffffff : 0000:00:02.0
>   f7400000-f77fffff : 0000:00:02.0
>   f7800000-f78fffff : PCI Bus 0000:07
>     f7800000-f78007ff : 0000:07:03.0
>       f7800000-f78007ff : firewire_ohci
>   f7900000-f79fffff : PCI Bus 0000:06
>     f7900000-f7907fff : 0000:06:00.0
>       f7900000-f7907fff : xhci_hcd
>   f7a00000-f7afffff : PCI Bus 0000:05
>     f7a00000-f7a1ffff : 0000:05:00.0
>       f7a00000-f7a1ffff : e1000e
>     f7a20000-f7a23fff : 0000:05:00.0
>       f7a20000-f7a23fff : e1000e
>   f7b00000-f7bfffff : PCI Bus 0000:04
>     f7b00000-f7b1ffff : 0000:04:00.0
>       f7b00000-f7b1ffff : e1000e
>     f7b20000-f7b23fff : 0000:04:00.0
>       f7b20000-f7b23fff : e1000e
>   f7c00000-f7cfffff : PCI Bus 0000:01
>     f7c00000-f7c3ffff : 0000:01:00.0
>     f7c40000-f7c5ffff : 0000:01:00.0
>     f7c60000-f7c63fff : 0000:01:00.0
>   f7d01000-f7d010ff : 0000:00:1f.3
>   f7d02000-f7d027ff : 0000:00:1f.2
>     f7d02000-f7d027ff : ahci
>   f7d03000-f7d033ff : 0000:00:1d.0
>     f7d03000-f7d033ff : ehci_hcd
>   f7d04000-f7d043ff : 0000:00:1a.0
>     f7d04000-f7d043ff : ehci_hcd
>   f7d07000-f7d0700f : 0000:00:16.0
>     f7d07000-f7d0700f : mei
>   f8000000-fbffffff : PCI MMCONFIG 0000 [bus 00-3f]
>     f8000000-fbffffff : reserved
>       f8000000-fbffffff : pnp 00:0c
> fec00000-fec00fff : reserved
>   fec00000-fec003ff : IOAPIC 0
> fed00000-fed03fff : reserved
>   fed00000-fed003ff : HPET 0
> fed10000-fed17fff : pnp 00:0c
> fed18000-fed18fff : pnp 00:0c
> fed19000-fed19fff : pnp 00:0c
> fed1c000-fed1ffff : reserved
>   fed1c000-fed1ffff : pnp 00:0c
>     fed1f410-fed1f414 : iTCO_wdt
> fed20000-fed3ffff : pnp 00:0c
> fed40000-fed44fff : pnp 00:01
> fed45000-fed8ffff : pnp 00:0c
> fed90000-fed90fff : dmar0
> fed91000-fed91fff : dmar1
> fee00000-fee00fff : Local APIC
>   fee00000-fee00fff : reserved
> ff000000-ffffffff : reserved
>   ff000000-ffffffff : pnp 00:0c
> 100000000-81f5fffff : System RAM
> 81f600000-81fffffff : RAM buffer
> 
> 
> [7.5.] PCI information ('lspci -vvv' as root)
> Execute the following via a terminal, and paste the results:
> sudo lspci -vvv
> 
> 00:00.0 Host bridge: Intel Corporation Xeon E3-1200 Processor Family
> DRAM Controller (rev 09)
>         Subsystem: ASUSTeK Computer Inc. Device 844d
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort+ >SERR- <PERR- INTx-
>         Latency: 0
>         Capabilities: [e0] Vendor Specific Information: Len=0c <?>
> 
> 00:01.0 PCI bridge: Intel Corporation Xeon E3-1200/2nd Generation Core
> Processor Family PCI Express Root Port (rev 09) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
>         I/O behind bridge: 0000e000-0000efff
>         Memory behind bridge: f7c00000-f7cfffff
>         Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [88] Subsystem: ASUSTeK Computer Inc. Device 844d
>         Capabilities: [80] Power Management version 3
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
>                 Address: fee002f8  Data: 0000
>         Capabilities: [a0] Express (v2) Root Port (Slot+), MSI 00
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
> <64ns, L1 <1us
>                         ExtTag- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
> Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr-
> TransPend-
>                 LnkCap: Port #2, Speed 5GT/s, Width x16, ASPM L0s L1,
> Latency L0 <256ns, L1 <4us
>                         ClockPM- Surprise- LLActRep- BwNot+
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> CommClk+
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+
> DLActive- BWMgmt+ ABWMgmt-
>                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug-
> Surprise-
>                         Slot #1, PowerLimit 75.000W; Interlock- NoCompl+
>                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt-
> HPIrq- LinkChg-
>                         Control: AttnInd Unknown, PwrInd Unknown, Power-
> Interlock-
>                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt-
> PresDet+ Interlock-
>                         Changed: MRL- PresDet- LinkState-
>                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
> PMEIntEna- CRSVisible-
>                 RootCap: CRSVisible-
>                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>                 DevCap2: Completion Timeout: Not Supported, TimeoutDis-
> ARIFwd-
>                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> ARIFwd-
>                 LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance-
> SpeedDis-, Selectable De-emphasis: -3.5dB
>                          Transmit Margin: Normal Operating Range,
> EnterModifiedCompliance- ComplianceSOS-
>                          Compliance De-emphasis: -6dB
>                 LnkSta2: Current De-emphasis Level: -3.5dB
>         Capabilities: [100 v1] Virtual Channel
>                 Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
>                 Arb:    Fixed- WRR32- WRR64- WRR128-
>                 Ctrl:   ArbSelect=Fixed
>                 Status: InProgress-
>                 VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>                         Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128-
> WRR256-
>                         Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=01
>                         Status: NegoPending- InProgress-
>         Capabilities: [140 v1] Root Complex Link
>                 Desc:   PortNumber=02 ComponentID=01 EltType=Config
>                 Link0:  Desc:   TargetPort=00 TargetComponent=01
> AssocRCRB- LinkType=MemMapped LinkValid+
>                         Addr:   00000000fed19000
>         Kernel driver in use: pcieport
>         Kernel modules: shpchp
> 
> 00:02.0 VGA compatible controller: Intel Corporation Xeon E3-1200
> Processor Family Integrated Graphics Controller (rev 09) (prog-if 00
> [VGA controller])
>         Subsystem: ASUSTeK Computer Inc. Device 844d
>         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Interrupt: pin A routed to IRQ 16
>         Region 0: Memory at f7400000 (64-bit, non-prefetchable) [size=4M]
>         Region 2: Memory at e0000000 (64-bit, prefetchable) [size=256M]
>         Region 4: I/O ports at f000 [size=64]
>         Expansion ROM at <unassigned> [disabled]
>         Capabilities: [90] MSI: Enable- Count=1/1 Maskable- 64bit-
>                 Address: 00000000  Data: 0000
>         Capabilities: [d0] Power Management version 2
>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [a4] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel modules: i915
> 
> 00:06.0 PCI bridge: Intel Corporation Xeon E3-1200/2nd Generation Core
> Processor Family PCI Express Root Port (rev 09) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
>         I/O behind bridge: 0000f000-00000fff
>         Memory behind bridge: fff00000-000fffff
>         Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [88] Subsystem: ASUSTeK Computer Inc. Device 844d
>         Capabilities: [80] Power Management version 3
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
>                 Address: fee00318  Data: 0000
>         Capabilities: [a0] Express (v2) Root Port (Slot+), MSI 00
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
> <64ns, L1 <1us
>                         ExtTag- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
> Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr-
> TransPend-
>                 LnkCap: Port #5, Speed 5GT/s, Width x4, ASPM L0s L1,
> Latency L0 <1us, L1 <4us
>                         ClockPM- Surprise- LLActRep- BwNot+
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> CommClk-
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+
> DLActive- BWMgmt- ABWMgmt-
>                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug-
> Surprise-
>                         Slot #4, PowerLimit 75.000W; Interlock- NoCompl+
>                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt-
> HPIrq- LinkChg-
>                         Control: AttnInd Unknown, PwrInd Unknown, Power-
> Interlock-
>                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt-
> PresDet- Interlock-
>                         Changed: MRL- PresDet- LinkState-
>                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
> PMEIntEna- CRSVisible-
>                 RootCap: CRSVisible-
>                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>                 DevCap2: Completion Timeout: Not Supported, TimeoutDis-
> ARIFwd-
>                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> ARIFwd-
>                 LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance-
> SpeedDis-, Selectable De-emphasis: -6dB
>                          Transmit Margin: Normal Operating Range,
> EnterModifiedCompliance- ComplianceSOS-
>                          Compliance De-emphasis: -6dB
>                 LnkSta2: Current De-emphasis Level: -6dB
>         Capabilities: [100 v1] Virtual Channel
>                 Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
>                 Arb:    Fixed- WRR32- WRR64- WRR128-
>                 Ctrl:   ArbSelect=Fixed
>                 Status: InProgress-
>                 VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>                         Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128-
> WRR256-
>                         Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
>                         Status: NegoPending- InProgress-
>         Capabilities: [140 v1] Root Complex Link
>                 Desc:   PortNumber=05 ComponentID=01 EltType=Config
>                 Link0:  Desc:   TargetPort=00 TargetComponent=01
> AssocRCRB- LinkType=MemMapped LinkValid+
>                         Addr:   00000000fed19000
>         Kernel driver in use: pcieport
>         Kernel modules: shpchp
> 
> 00:16.0 Communication controller: Intel Corporation 6 Series/C200 Series
> Chipset Family MEI Controller #1 (rev 04)
>         Subsystem: ASUSTeK Computer Inc. P8P67 Deluxe Motherboard
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 60
>         Region 0: Memory at f7d07000 (64-bit, non-prefetchable) [size=16]
>         Capabilities: [50] Power Management version 3
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [8c] MSI: Enable+ Count=1/1 Maskable- 64bit+
>                 Address: 00000000fee00378  Data: 0000
>         Kernel driver in use: mei
>         Kernel modules: mei
> 
> 00:1a.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset
> Family USB Enhanced Host Controller #2 (rev 05) (prog-if 20 [EHCI])
>         Subsystem: ASUSTeK Computer Inc. P8P67 Deluxe Motherboard
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 16
>         Region 0: Memory at f7d04000 (32-bit, non-prefetchable) [size=1K]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [58] Debug port: BAR=1 offset=00a0
>         Capabilities: [98] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel driver in use: ehci_hcd
> 
> 00:1c.0 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset
> Family PCI Express Root Port 1 (rev b5) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
>         I/O behind bridge: 00002000-00002fff
>         Memory behind bridge: dfb00000-dfcfffff
>         Prefetchable memory behind bridge: 00000000dfd00000-00000000dfefffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
> <64ns, L1 <1us
>                         ExtTag- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
> Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+
> TransPend-
>                 LnkCap: Port #1, Speed 5GT/s, Width x4, ASPM L0s L1,
> Latency L0 <1us, L1 <4us
>                         ClockPM- Surprise- LLActRep+ BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> CommClk-
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+
> DLActive- BWMgmt- ABWMgmt-
>                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+
> Surprise+
>                         Slot #0, PowerLimit 0.000W; Interlock- NoCompl+
>                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt-
> HPIrq- LinkChg-
>                         Control: AttnInd Unknown, PwrInd Unknown, Power-
> Interlock-
>                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt-
> PresDet- Interlock-
>                         Changed: MRL- PresDet- LinkState-
>                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
> PMEIntEna- CRSVisible-
>                 RootCap: CRSVisible-
>                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>                 DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
>                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> ARIFwd-
>                 LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance-
> SpeedDis-, Selectable De-emphasis: -6dB
>                          Transmit Margin: Normal Operating Range,
> EnterModifiedCompliance- ComplianceSOS-
>                          Compliance De-emphasis: -6dB
>                 LnkSta2: Current De-emphasis Level: -3.5dB
>         Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
>                 Address: 00000000  Data: 0000
>         Capabilities: [90] Subsystem: ASUSTeK Computer Inc. Device 844d
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: pcieport
>         Kernel modules: shpchp
> 
> 00:1c.5 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset
> Family PCI Express Root Port 6 (rev b5) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
>         I/O behind bridge: 0000d000-0000dfff
>         Memory behind bridge: f7b00000-f7bfffff
>         Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
> <64ns, L1 <1us
>                         ExtTag- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
> Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+
> TransPend-
>                 LnkCap: Port #6, Speed 5GT/s, Width x1, ASPM L0s L1,
> Latency L0 <512ns, L1 <4us
>                         ClockPM- Surprise- LLActRep+ BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> CommClk+
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
> DLActive+ BWMgmt+ ABWMgmt-
>                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug-
> Surprise-
>                         Slot #5, PowerLimit 10.000W; Interlock- NoCompl+
>                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt-
> HPIrq- LinkChg-
>                         Control: AttnInd Unknown, PwrInd Unknown, Power-
> Interlock-
>                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt-
> PresDet+ Interlock-
>                         Changed: MRL- PresDet- LinkState-
>                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
> PMEIntEna- CRSVisible-
>                 RootCap: CRSVisible-
>                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>                 DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
>                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> ARIFwd-
>                 LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance-
> SpeedDis-, Selectable De-emphasis: -6dB
>                          Transmit Margin: Normal Operating Range,
> EnterModifiedCompliance- ComplianceSOS-
>                          Compliance De-emphasis: -6dB
>                 LnkSta2: Current De-emphasis Level: -3.5dB
>         Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
>                 Address: 00000000  Data: 0000
>         Capabilities: [90] Subsystem: ASUSTeK Computer Inc. Device 844d
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: pcieport
>         Kernel modules: shpchp
> 
> 00:1c.6 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset
> Family PCI Express Root Port 7 (rev b5) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
>         I/O behind bridge: 0000c000-0000cfff
>         Memory behind bridge: f7a00000-f7afffff
>         Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
> <64ns, L1 <1us
>                         ExtTag- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
> Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+
> TransPend-
>                 LnkCap: Port #7, Speed 5GT/s, Width x1, ASPM L0s L1,
> Latency L0 <512ns, L1 <4us
>                         ClockPM- Surprise- LLActRep+ BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> CommClk+
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
> DLActive+ BWMgmt+ ABWMgmt-
>                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug-
> Surprise-
>                         Slot #6, PowerLimit 10.000W; Interlock- NoCompl+
>                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt-
> HPIrq- LinkChg-
>                         Control: AttnInd Unknown, PwrInd Unknown, Power-
> Interlock-
>                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt-
> PresDet+ Interlock-
>                         Changed: MRL- PresDet- LinkState-
>                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
> PMEIntEna- CRSVisible-
>                 RootCap: CRSVisible-
>                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>                 DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
>                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> ARIFwd-
>                 LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance-
> SpeedDis-, Selectable De-emphasis: -6dB
>                          Transmit Margin: Normal Operating Range,
> EnterModifiedCompliance- ComplianceSOS-
>                          Compliance De-emphasis: -6dB
>                 LnkSta2: Current De-emphasis Level: -3.5dB
>         Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
>                 Address: 00000000  Data: 0000
>         Capabilities: [90] Subsystem: ASUSTeK Computer Inc. Device 844d
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: pcieport
>         Kernel modules: shpchp
> 
> 00:1c.7 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset
> Family PCI Express Root Port 8 (rev b5) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Bus: primary=00, secondary=06, subordinate=06, sec-latency=0
>         I/O behind bridge: 0000f000-00000fff
>         Memory behind bridge: f7900000-f79fffff
>         Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort+ <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
> <64ns, L1 <1us
>                         ExtTag- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
> Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+
> TransPend-
>                 LnkCap: Port #8, Speed 5GT/s, Width x1, ASPM L0s L1,
> Latency L0 <512ns, L1 <4us
>                         ClockPM- Surprise- LLActRep+ BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> CommClk+
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 5GT/s, Width x1, TrErr- Train- SlotClk+
> DLActive+ BWMgmt+ ABWMgmt-
>                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug-
> Surprise-
>                         Slot #7, PowerLimit 10.000W; Interlock- NoCompl+
>                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt-
> HPIrq- LinkChg-
>                         Control: AttnInd Unknown, PwrInd Unknown, Power-
> Interlock-
>                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt-
> PresDet+ Interlock-
>                         Changed: MRL- PresDet- LinkState-
>                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal-
> PMEIntEna- CRSVisible-
>                 RootCap: CRSVisible-
>                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>                 DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
>                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> ARIFwd-
>                 LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance-
> SpeedDis-, Selectable De-emphasis: -6dB
>                          Transmit Margin: Normal Operating Range,
> EnterModifiedCompliance- ComplianceSOS-
>                          Compliance De-emphasis: -6dB
>                 LnkSta2: Current De-emphasis Level: -6dB
>         Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
>                 Address: 00000000  Data: 0000
>         Capabilities: [90] Subsystem: ASUSTeK Computer Inc. Device 844d
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: pcieport
>         Kernel modules: shpchp
> 
> 00:1d.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset
> Family USB Enhanced Host Controller #1 (rev 05) (prog-if 20 [EHCI])
>         Subsystem: ASUSTeK Computer Inc. P8P67 Deluxe Motherboard
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 23
>         Region 0: Memory at f7d03000 (32-bit, non-prefetchable) [size=1K]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [58] Debug port: BAR=1 offset=00a0
>         Capabilities: [98] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel driver in use: ehci_hcd
> 
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev a5) (prog-if
> 01 [Subtractive decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Bus: primary=00, secondary=07, subordinate=07, sec-latency=32
>         I/O behind bridge: 0000b000-0000bfff
>         Memory behind bridge: f7800000-f78fffff
>         Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
>         Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort+ <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [50] Subsystem: ASUSTeK Computer Inc. Device 844d
> 
> 00:1f.0 ISA bridge: Intel Corporation C206 Chipset Family LPC Controller
> (rev 05)
>         Subsystem: ASUSTeK Computer Inc. Device 844d
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Capabilities: [e0] Vendor Specific Information: Len=0c <?>
>         Kernel driver in use: lpc_ich
>         Kernel modules: lpc_ich
> 
> 00:1f.2 SATA controller: Intel Corporation 6 Series/C200 Series Chipset
> Family SATA AHCI Controller (rev 05) (prog-if 01 [AHCI 1.0])
>         Subsystem: ASUSTeK Computer Inc. P8P67 Deluxe Motherboard
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin B routed to IRQ 44
>         Region 0: I/O ports at f0b0 [size=8]
>         Region 1: I/O ports at f0a0 [size=4]
>         Region 2: I/O ports at f090 [size=8]
>         Region 3: I/O ports at f080 [size=4]
>         Region 4: I/O ports at f060 [size=32]
>         Region 5: Memory at f7d02000 (32-bit, non-prefetchable) [size=2K]
>         Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
>                 Address: fee00338  Data: 0000
>         Capabilities: [70] Power Management version 3
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot+,D3cold-)
>                 Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [a8] SATA HBA v1.0 BAR4 Offset=00000004
>         Capabilities: [b0] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel driver in use: ahci
> 
> 00:1f.3 SMBus: Intel Corporation 6 Series/C200 Series Chipset Family
> SMBus Controller (rev 05)
>         Subsystem: ASUSTeK Computer Inc. P8P67 Deluxe Motherboard
>         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Interrupt: pin C routed to IRQ 5
>         Region 0: Memory at f7d01000 (64-bit, non-prefetchable) [size=256]
>         Region 4: I/O ports at f040 [size=32]
>         Kernel modules: i2c-i801
> 
> 01:00.0 RAID bus controller: LSI Logic / Symbios Logic MegaRAID SAS 2108
> [Liberator] (rev 05)
>         Subsystem: LSI Logic / Symbios Logic MR9260-16i
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Interrupt: pin A routed to IRQ 16
>         Region 0: I/O ports at e000 [size=256]
>         Region 1: Memory at f7c60000 (64-bit, non-prefetchable) [size=16K]
>         Region 3: Memory at f7c00000 (64-bit, non-prefetchable) [size=256K]
>         Expansion ROM at f7c40000 [disabled] [size=128K]
>         Capabilities: [50] Power Management version 3
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [68] Express (v2) Endpoint, MSI 00
>                 DevCap: MaxPayload 4096 bytes, PhantFunc 0, Latency L0s
> <64ns, L1 <1us
>                         ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
> Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
> FLReset-
>                         MaxPayload 128 bytes, MaxReadReq 512 bytes
>                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr-
> TransPend-
>                 LnkCap: Port #0, Speed 5GT/s, Width x8, ASPM L0s,
> Latency L0 <64ns, L1 <1us
>                         ClockPM- Surprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> CommClk+
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+
> DLActive- BWMgmt- ABWMgmt-
>                 DevCap2: Completion Timeout: Range BC, TimeoutDis+
>                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
>                 LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance-
> SpeedDis-, Selectable De-emphasis: -6dB
>                          Transmit Margin: Normal Operating Range,
> EnterModifiedCompliance- ComplianceSOS-
>                          Compliance De-emphasis: -6dB
>                 LnkSta2: Current De-emphasis Level: -6dB
>         Capabilities: [d0] Vital Product Data
>                 Unknown small resource type 00, will not decode more.
>         Capabilities: [a8] MSI: Enable- Count=1/1 Maskable- 64bit+
>                 Address: 0000000000000000  Data: 0000
>         Capabilities: [c0] MSI-X: Enable+ Count=15 Masked-
>                 Vector table: BAR=1 offset=00002000
>                 PBA: BAR=1 offset=00003800
>         Capabilities: [100 v1] Advanced Error Reporting
>                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                 UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
>                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-
> NonFatalErr+
>                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-
> NonFatalErr+
>                 AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+
> ChkEn-
>         Capabilities: [138 v1] Power Budgeting <?>
>         Kernel driver in use: megaraid_sas
>         Kernel modules: megaraid_sas
> 
> 04:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network
> Connection
>         Subsystem: ASUSTeK Computer Inc. Device 8369
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Interrupt: pin A routed to IRQ 17
>         Region 0: Memory at f7b00000 (32-bit, non-prefetchable) [size=128K]
>         Region 2: I/O ports at d000 [size=32]
>         Region 3: Memory at f7b20000 (32-bit, non-prefetchable) [size=16K]
>         Capabilities: [c8] Power Management version 2
>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
>         Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
>                 Address: 0000000000000000  Data: 0000
>         Capabilities: [e0] Express (v1) Endpoint, MSI 00
>                 DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
> <512ns, L1 <64us
>                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+
> Unsupported+
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
>                         MaxPayload 128 bytes, MaxReadReq 512 bytes
>                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+
> TransPend-
>                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
> Latency L0 <128ns, L1 <64us
>                         ClockPM- Surprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> CommClk+
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
> DLActive- BWMgmt- ABWMgmt-
>         Capabilities: [a0] MSI-X: Enable+ Count=5 Masked-
>                 Vector table: BAR=3 offset=00000000
>                 PBA: BAR=3 offset=00002000
>         Capabilities: [100 v1] Advanced Error Reporting
>                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                 UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
>                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-
> NonFatalErr+
>                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-
> NonFatalErr+
>                 AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap-
> ChkEn-
>         Capabilities: [140 v1] Device Serial Number 10-bf-48-ff-ff-4e-12-5f
>         Kernel driver in use: e1000e
>         Kernel modules: e1000e
> 
> 05:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network
> Connection
>         Subsystem: ASUSTeK Computer Inc. Device 8369
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Interrupt: pin A routed to IRQ 18
>         Region 0: Memory at f7a00000 (32-bit, non-prefetchable) [size=128K]
>         Region 2: I/O ports at c000 [size=32]
>         Region 3: Memory at f7a20000 (32-bit, non-prefetchable) [size=16K]
>         Capabilities: [c8] Power Management version 2
>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
>         Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
>                 Address: 0000000000000000  Data: 0000
>         Capabilities: [e0] Express (v1) Endpoint, MSI 00
>                 DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
> <512ns, L1 <64us
>                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+
> Unsupported+
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
>                         MaxPayload 128 bytes, MaxReadReq 512 bytes
>                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+
> TransPend-
>                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
> Latency L0 <128ns, L1 <64us
>                         ClockPM- Surprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> CommClk+
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
> DLActive- BWMgmt- ABWMgmt-
>         Capabilities: [a0] MSI-X: Enable+ Count=5 Masked-
>                 Vector table: BAR=3 offset=00000000
>                 PBA: BAR=3 offset=00002000
>         Capabilities: [100 v1] Advanced Error Reporting
>                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                 UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt-
> UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
>                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-
> NonFatalErr+
>                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-
> NonFatalErr+
>                 AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap-
> ChkEn-
>         Capabilities: [140 v1] Device Serial Number 10-bf-48-ff-ff-4e-0f-9b
>         Kernel driver in use: e1000e
>         Kernel modules: e1000e
> 
> 06:00.0 USB controller: ASMedia Technology Inc. ASM1042 SuperSpeed USB
> Host Controller (prog-if 30 [XHCI])
>         Subsystem: ASUSTeK Computer Inc. Device 8488
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Interrupt: pin A routed to IRQ 19
>         Region 0: Memory at f7900000 (64-bit, non-prefetchable) [size=32K]
>         Capabilities: [50] MSI: Enable- Count=1/8 Maskable- 64bit+
>                 Address: 0000000000000000  Data: 0000
>         Capabilities: [68] MSI-X: Enable+ Count=8 Masked-
>                 Vector table: BAR=0 offset=00002000
>                 PBA: BAR=0 offset=00002080
>         Capabilities: [78] Power Management version 3
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA
> PME(D0-,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [80] Express (v2) Legacy Endpoint, MSI 00
>                 DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s
> <64ns, L1 <2us
>                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
> Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
>                         MaxPayload 128 bytes, MaxReadReq 512 bytes
>                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr-
> TransPend-
>                 LnkCap: Port #1, Speed 5GT/s, Width x1, ASPM L0s L1,
> Latency L0 unlimited, L1 unlimited
>                         ClockPM- Surprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> CommClk+
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 5GT/s, Width x1, TrErr- Train- SlotClk+
> DLActive- BWMgmt- ABWMgmt-
>                 DevCap2: Completion Timeout: Not Supported, TimeoutDis-
>                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
>                 LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance-
> SpeedDis-, Selectable De-emphasis: -6dB
>                          Transmit Margin: Normal Operating Range,
> EnterModifiedCompliance- ComplianceSOS-
>                          Compliance De-emphasis: -6dB
>                 LnkSta2: Current De-emphasis Level: -6dB
>         Capabilities: [100 v1] Virtual Channel
>                 Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
>                 Arb:    Fixed- WRR32- WRR64- WRR128-
>                 Ctrl:   ArbSelect=Fixed
>                 Status: InProgress-
>                 VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>                         Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128-
> WRR256-
>                         Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=01
>                         Status: NegoPending- InProgress-
>         Kernel driver in use: xhci_hcd
> 
> 07:03.0 FireWire (IEEE 1394): VIA Technologies, Inc. VT6306/7/8 [Fire
> II(M)] IEEE 1394 OHCI Controller (rev c0) (prog-if 10 [OHCI])
>         Subsystem: ASUSTeK Computer Inc. Device 82eb
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 32 (8000ns max), Cache Line Size: 64 bytes
>         Interrupt: pin A routed to IRQ 19
>         Region 0: Memory at f7800000 (32-bit, non-prefetchable) [size=2K]
>         Region 1: I/O ports at b000 [size=128]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2+ AuxCurrent=0mA
> PME(D0-,D1-,D2+,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: firewire_ohci
>         Kernel modules: firewire-ohci
> 
> 
> [7.6.] SCSI information (from /proc/scsi/scsi)
> Attached devices:
> Host: scsi6 Channel: 01 Id: 117 Lun: 00
>   Vendor: LSI CORP Model: Bobcat           Rev: 0504
>   Type:   Enclosure                        ANSI  SCSI revision: 05
> Host: scsi6 Channel: 02 Id: 00 Lun: 00
>   Vendor: LSI      Model: MR9260-16i       Rev: 2.13
>   Type:   Direct-Access                    ANSI  SCSI revision: 05
> 
> 
> [7.7.] Other information that might be relevant to the problem (please
> look in /proc and include all information that you think to be relevant):
> please feel free to request additional information from:
> 
> acpi
> buddyinfo
> bus
> cgroups
> cmdline
> consoles
> cpuinfo
> crypto
> devices
> diskstats
> dma
> dri
> driver
> execdomains
> fb
> filesystems
> fs
> interrupts
> iomem
> ioports
> irq
> kallsyms
> kcore
> key-users
> kmsg
> kpagecount
> kpageflags
> latency_stats
> loadavg
> locks
> mdstat
> meminfo
> misc
> modules
> mounts
> mtrr
> net
> pagetypeinfo
> partitions
> sched_debug
> schedstat
> scsi
> self
> slabinfo
> softirqs
> stat
> swaps
> sys
> sysrq-trigger
> sysvipc
> timer_list
> timer_stats
> tty
> uptime
> version
> vmallocinfo
> vmstat
> zoneinfo
> 
> 
> [8.] Other notes, patches, fixes, workarounds:
> 
> whether the nfsorigin or nfssnapshot is exported seems to be dependent
> on the local mount order (first one wins)
> 
> similar symptoms: https://bugzilla.kernel.org/show_bug.cgi?id=13011
> (fsid advice not working, reordering without effect)
> this one is mentioning a fix in kernel (2.6.29).
> 
> [8.1] output of my script provided at [6.] shows that snapshot is
> exported instead of origin
> snapshot mountpoint itself is inaccessible
> 
> File descriptor 4 (/dev/pts/2) leaked on lvcreate invocation. Parent PID
> 22685: /bin/sh
>                                                           [45/709]
> File descriptor 8 (pipe:[30338]) leaked on lvcreate invocation. Parent
> PID 22685: /bin/sh
>   Rounding up size to full physical extent 12.00 MiB
>   Logical volume "nfsorigin" created
> mke2fs 1.42 (29-Nov-2011)
> Filesystem label=
> OS type: Linux
> Block size=1024 (log=0)
> Fragment size=1024 (log=0)
> Stride=4 blocks, Stripe width=4 blocks
> 3072 inodes, 12288 blocks
> 614 blocks (5.00%) reserved for the super user
> First data block=1
> Maximum filesystem blocks=12582912
> 2 block groups
> 8192 blocks per group, 8192 fragments per group
> 1536 inodes per group
> Superblock backups stored on blocks:
>         8193
> 
> Allocating group tables: done
> Writing inode tables: done
> Creating journal (1024 blocks): done
> Writing superblocks and filesystem accounting information: done
> 
> File descriptor 4 (/dev/pts/2) leaked on lvcreate invocation. Parent PID
> 22685: /bin/sh
> File descriptor 8 (pipe:[30338]) leaked on lvcreate invocation. Parent
> PID 22685: /bin/sh
>   Rounding up size to full physical extent 4.00 MiB
>   Logical volume "nfssnapshot" created
> /mnt/nfsorigin:
> total 12
> drwx------ 2 root root 12288 Nov  8 10:40 lost+found
> -rw-r--r-- 1 root root     0 Nov  8 10:40 NFSORIGIN
> 
> /mnt/nfsorigin/lost+found:
> total 0
> 
> /mnt/nfssnapshot:
> total 12
> drwx------ 2 root root 12288 Nov  8 10:40 lost+found
> -rw-r--r-- 1 root root     0 Nov  8 10:40 NFSSNAPSHOT
> 
> /mnt/nfssnapshot/lost+found:
> total 0
>  * Stopping NFS kernel daemon
>    ...done.
>  * Unexporting directories for NFS kernel daemon...
>    ...done.
>  * Exporting directories for NFS kernel daemon...
>    ...done.
>  * Starting NFS kernel daemon
>    ...done.
> /mnt2/nfsorigin:
> total 12
> drwx------ 2 root root 12288 Nov  8 10:40 lost+found
> -rw-r--r-- 1 root root     0 Nov  8 10:40 NFSSNAPSHOT
> ls: cannot open directory /mnt2/nfsorigin/lost+found: Permission denied
> ls: cannot open directory /mnt2/nfssnapshot: Device or resource busy
> 
> [8.3] output of my script provided at [6.] shows that origin is
> exported, if mounted first locally
> snapshot mountpoint itself is inaccessible
> 
> /mnt/nfsorigin:
> total 12
> drwx------ 2 root root 12288 Nov  8 10:40 lost+found
> -rw-r--r-- 1 root root     0 Nov  8 10:40 NFSORIGIN
> 
> /mnt/nfsorigin/lost+found:
> total 0
> 
> /mnt/nfssnapshot:
> total 12
> drwx------ 2 root root 12288 Nov  8 10:40 lost+found
> -rw-r--r-- 1 root root     0 Nov  8 10:40 NFSSNAPSHOT
> 
> /mnt/nfssnapshot/lost+found:
> total 0
>  * Stopping NFS kernel daemon
>    ...done.
>  * Unexporting directories for NFS kernel daemon...
>    ...done.
>  * Exporting directories for NFS kernel daemon...
>    ...done.
>  * Starting NFS kernel daemon
>    ...done.
> /mnt2/nfsorigin:
> total 12
> drwx------ 2 root root 12288 Nov  8 10:40 lost+found
> -rw-r--r-- 1 root root     0 Nov  8 10:40 NFSORIGIN
> ls: cannot open directory /mnt2/nfsorigin/lost+found: Permission denied
> ls: cannot open directory /mnt2/nfssnapshot: Device or resource busy
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
