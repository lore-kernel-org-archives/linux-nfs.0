Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD8433EE1DB
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 17:03:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790183006; cv=none; b=FMBtITaXneQHwsm0Sj+o8utVsjwYo5KrAvThOczOx0fsmEfJmUwguYvFsYDiYZ6WtNjgXXsTECR4uA1Zl1zQffvc/pXxzHLgpbgV6TgkvGMxtBXQE7obEK3dFGZxtrwBBKPzu/Gq5LCJ3GM15zl2ROk4MYrvpNYzR3/f1aqOyUw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790183006; c=relaxed/simple;
	bh=VNqObjfr0n0f1Cgdzuc61GFC2O5DFMyFwLsnNyVdYi8=;
	h=Date:From:To:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=CgCncANY11VnUHpUMSA8L5E9Uf26XS/iEOuitk1UyLNeF1ijnGKkgJFoWJ/c2y4MqHl3GzLtHUKE9aSI0AYkUdM9G+lFNpV5FkO9nuW9Pi+XGHP7U/uLYGuJDwCIxlmYR/HxPMFzZfukX9A6Fkchc3cIPRR05XGGRjifNreitRc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=k4gzHqs2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="k4gzHqs2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 285C81F000FF
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 17:03:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790183003;
	bh=5udV0yrOSv9HXbt/XfI4i76yInWpeRr4taCc+ojGJk4=;
	h=Date:From:To:Subject;
	b=k4gzHqs2Mj7uze4TEJQtmdn70PBmTZASw2/srk4zGLBdV1w8bobYW5/rPcZT9LCVw
	 6rtfYAZKKfgrm9sSuH4+inSqZn5l1PoMps9xAIWfB6EeQ9gaKHHdGBIR7/bPgVb0Og
	 e2C1pAeegHp/4UC2ylSVWpiVD3oR+BdvhggT/4q36LME1lKuk3pfxP6QSQFFORFKeD
	 QPNTDP9M24Xbj3008bIXUvTmjyJsFSfZPIT3ZDbbfZSJgYoiQmldn80tP1XjsgfpjP
	 6SorTQYuTJsL5BiuUX5QyzUuxkzWW3azO3fhnmjzo/vYGfv+SPnGpV2gl9K0KLgXDK
	 sFwp1hg6I7nKA==
Date: Thu, 24 Sep 2026 01:03:18 +0800
From: Zorro Lang <zlang@kernel.org>
To: linux-nfs@vger.kernel.org
Subject: [Bug][xfstests g/795] NFSv4 hang during drop_caches:
 nfs4_evict_inode waiting on DELEGRETURN
Message-ID: <arQGHW5ZSmp2yBWl@zlang-mailbox>
Mail-Followup-To: linux-nfs@vger.kernel.org
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I always hit a hang while running fstests generic/795 over NFSv4.2 (XFS
underlying) on latest mainline linux kernel (HEAD=f0100363d8c3). Not
sure if it's a known issue.

FSTYP         -- nfs
PLATFORM      -- Linux/x86_64 bogon 7.3.0-rc4-mainline+ #7 SMP PREEMPT_DYNAMIC Tue Sep 22 17:27:21 CST 2026
MKFS_OPTIONS  -- 127.0.0.1:/export/scratch
MOUNT_OPTIONS -- -o context=system_u:object_r:root_t:s0 127.0.0.1:/export/scratch /mnt/scratch

generic/795  126s ... ^C^C

Test steps:
1) mkfs.xfs -f /dev/sdb && mkfs.xfs -f /dev/sdc
meta-data=/dev/sdb               isize=512    agcount=4, agsize=1966080 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=1
         =                       reflink=1    bigtime=1 inobtcount=1 nrext64=1
         =                       exchange=1   metadir=0
data     =                       bsize=4096   blocks=7864320, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1, parent=1
log      =internal log           bsize=4096   blocks=16384, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
         =                       rgcount=0    rgsize=0 extents
         =                       zoned=0      start=0 reserved=0
...
...
2) mount /dev/sdb /export/test && mount /dev/sdc /export/scratch
3) # cat /etc/exports
/export/test    127.0.0.1(rw,no_root_squash,no_subtree_check,fsid=101)
/export/scratch 127.0.0.1(rw,no_root_squash,no_subtree_check,fsid=102)

4) systemctl start nfs-server
5) cat xfstests; make -j8
6) cat nfs.config
export FSTYP=nfs
export TEST_DEV="127.0.0.1:/export/test"
export SCRATCH_DEV="127.0.0.1:/export/scratch"
export TEST_DIR=/mnt/test
export SCRATCH_MNT=/mnt/scratch
7) for (( i=0;i<100;i++ ));do HOST_OPTIONS=nfs.config ./check generic/795;done

My test environment is a VM configured with 4 vCPUs and 8GB RAM. The issue
reproduces for me with roughly a 20% reproduction rate.

More detail:

# rpm -q nfs-utils xfsprogs
nfs-utils-2.9.2-1.rc1.fc46.x86_64
xfsprogs-7.1.1-1.fc45.x86_64

# grep NFS linux/.config
# CONFIG_USB_FUNCTIONFS is not set
CONFIG_XENFS=m
CONFIG_XEN_COMPAT_XENFS=y
CONFIG_KERNFS=y
CONFIG_NFS_FS=m
# CONFIG_NFS_V2 is not set
CONFIG_NFS_V3=m
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=m
CONFIG_NFS_SWAP=y
CONFIG_NFS_V4_0=y
CONFIG_NFS_V4_2=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_PNFS_FLEXFILE_LAYOUT=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
# CONFIG_NFS_V4_1_MIGRATION is not set
CONFIG_NFS_V4_SECURITY_LABEL=y
CONFIG_NFS_FSCACHE=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_DEBUG=y
CONFIG_NFS_DISABLE_UDP_SUPPORT=y
# CONFIG_NFS_V4_2_READ_PLUS is not set
CONFIG_NFSD=m
# CONFIG_NFSD_V2 is not set
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_NFSD_PNFS=y
CONFIG_NFSD_BLOCKLAYOUT=y
CONFIG_NFSD_SCSILAYOUT=y
CONFIG_NFSD_FLEXFILELAYOUT=y
CONFIG_NFSD_V4_2_INTER_SSC=y
CONFIG_NFSD_V4_SECURITY_LABEL=y
# CONFIG_NFSD_LEGACY_CLIENT_TRACKING is not set
# CONFIG_NFSD_V4_POSIX_ACLS is not set
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_NFS_COMMON_LOCALIO_SUPPORT=m
CONFIG_NFS_LOCALIO=y
CONFIG_NFS_V4_2_SSC_HELPER=y

# echo w > /proc/sysyrq-trigger
# dmesg
...
[  596.543971] run fstests generic/795 at 2026-09-22 19:46:41
[  601.432607] 795 (175925): drop_caches: 3
[  604.318892] 795 (175925): drop_caches: 3
[  607.321196] 795 (175925): drop_caches: 3
[  826.827706] ohci-pci 0000:00:06.0: frame counter not updating; disabled
[  826.827717] ohci-pci 0000:00:06.0: HC died; cleaning up
[  826.828803] usb 1-1: USB disconnect, device number 2
[17792.723802] sysrq: Show Blocked State
[17792.723845] task:795             state:D stack:0     pid:175925 tgid:175925 ppid:175698 task_flags:0x400040 flags:0x00080000
[17792.723848] Call Trace:
[17792.723849]  <TASK>
[17792.723851]  __schedule+0x42d/0x1ae0
[17792.723859]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.723895]  schedule+0x28/0xa0
[17792.723896]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.723920]  __wait_on_bit+0x92/0xb0
[17792.723921]  out_of_line_wait_on_bit+0x97/0xc0
[17792.723923]  ? __pfx_wake_bit_function+0x10/0x10
[17792.723937]  _nfs4_proc_delegreturn+0x3c7/0x510 [nfsv4]
[17792.723967]  nfs4_proc_delegreturn+0x7f/0x150 [nfsv4]
[17792.723982]  nfs_do_return_delegation+0x86/0xe0 [nfsv4]
[17792.724000]  nfs_inode_evict_delegation+0xb7/0xf0 [nfsv4]
[17792.724017]  nfs4_evict_inode+0x29/0x80 [nfsv4]
[17792.724033]  evict+0x137/0x2b0
[17792.724038]  prune_icache_sb+0x94/0xe0
[17792.724039]  super_cache_scan+0x1ae/0x200
[17792.724043]  do_shrink_slab+0x15b/0x400
[17792.724046]  shrink_slab+0x2ad/0x400
[17792.724048]  drop_slab+0x7c/0x110
[17792.724050]  drop_caches_sysctl_handler+0x9c/0xc0
[17792.724052]  proc_sys_call_handler+0x1d1/0x2e0
[17792.724056]  vfs_write+0x281/0x570
[17792.724058]  ksys_write+0x7b/0x110
[17792.724059]  do_syscall_64+0xbe/0x520
[17792.724062]  ? filp_flush+0x58/0x80
[17792.724063]  ? __handle_mm_fault+0xb13/0xf00
[17792.724065]  ? do_syscall_64+0xbe/0x520
[17792.724067]  ? count_memcg_events+0xdb/0x210
[17792.724069]  ? handle_mm_fault+0x216/0x350
[17792.724071]  ? do_user_addr_fault+0x2c7/0x830
[17792.724075]  ? clear_bhb_loop+0x60/0xb0
[17792.724077]  ? do_syscall_64+0x37/0x520
[17792.724078]  ? clear_bhb_loop+0x60/0xb0
[17792.724079]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.724081] RIP: 0033:0x7ffb28f67638
[17792.724082] RSP: 002b:00007fff8b670d20 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
[17792.724084] RAX: ffffffffffffffda RBX: 00007ffb28ff7580 RCX: 00007ffb28f67638
[17792.724085] RDX: 0000000000000002 RSI: 0000561058ff15f0 RDI: 0000000000000001
[17792.724085] RBP: 00007fff8b670d30 R08: 0000000000000000 R09: 0000000000000000
[17792.724086] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000002
[17792.724086] R13: 0000000000000002 R14: 0000561058ff15f0 R15: 0000000000000000
[17792.724087]  </TASK>
[17792.724088] task:fsstress        state:D stack:0     pid:176021 tgid:176021 ppid:175941 task_flags:0x440140 flags:0x00080002
[17792.724090] Call Trace:
[17792.724090]  <TASK>
[17792.724091]  __schedule+0x42d/0x1ae0
[17792.724093]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.724117]  schedule+0x28/0xa0
[17792.724118]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.724141]  __wait_on_bit+0x92/0xb0
[17792.724142]  ? rpc_sleep_on+0x60/0x90 [sunrpc]
[17792.724165]  out_of_line_wait_on_bit+0x97/0xc0
[17792.724166]  ? __pfx_wake_bit_function+0x10/0x10
[17792.724168]  __rpc_execute+0x142/0x4c0 [sunrpc]
[17792.724192]  rpc_execute+0x134/0x160 [sunrpc]
[17792.724215]  rpc_run_task+0x115/0x180 [sunrpc]
[17792.724259]  nfs4_call_sync+0xd6/0x110 [nfsv4]
[17792.724275]  _nfs4_proc_access+0x137/0x1e0 [nfsv4]
[17792.724294]  ? terminate_walk+0x3a/0xf0
[17792.724296]  nfs4_proc_access+0x6a/0xf0 [nfsv4]
[17792.724310]  nfs_do_access+0x104/0x2c0 [nfs]
[17792.724333]  nfs_permission+0x9b/0x200 [nfs]
[17792.724344]  ? __pfx_nfs_permission+0x10/0x10 [nfs]
[17792.724355]  inode_permission+0xfa/0x180
[17792.724356]  link_path_walk+0x5bf/0x6e0
[17792.724358]  ? do_getname+0x62/0x200
[17792.724358]  path_lookupat+0x40/0x2f0
[17792.724359]  filename_lookup+0x129/0x230
[17792.724362]  vfs_statx+0x8e/0x1b0
[17792.724364]  vfs_fstatat+0x4d/0x90
[17792.724365]  __do_sys_newfstatat+0x5a/0xa0
[17792.724367]  do_syscall_64+0xbe/0x520
[17792.724368]  ? mntput+0x25/0x70
[17792.724370]  ? __x64_sys_chdir+0xa3/0x110
[17792.724371]  ? do_syscall_64+0xbe/0x520
[17792.724373]  ? kvm_sched_clock_read+0x11/0x30
[17792.724374]  ? sched_clock+0x11/0x30
[17792.724376]  ? sched_clock_cpu+0xf/0x230
[17792.724377]  ? sched_clock+0x11/0x30
[17792.724377]  ? irqtime_account_irq+0x33/0xd0
[17792.724379]  ? clear_bhb_loop+0x60/0xb0
[17792.724380]  ? do_syscall_64+0x37/0x520
[17792.724381]  ? clear_bhb_loop+0x60/0xb0
[17792.724382]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.724383] RIP: 0033:0x7f5976161dfe
[17792.724384] RSP: 002b:00007ffc068dd698 EFLAGS: 00000246 ORIG_RAX: 0000000000000106
[17792.724385] RAX: ffffffffffffffda RBX: 0000000000000004 RCX: 00007f5976161dfe
[17792.724385] RDX: 00007ffc068dd6b0 RSI: 0000000000401f08 RDI: 00000000ffffff9c
[17792.724386] RBP: 00000000ffffffff R08: 0000000000000000 R09: 0000000000000000
[17792.724386] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
[17792.724387] R13: 0000000000000001 R14: 0000000000000000 R15: 0000000000418de0
[17792.724388]  </TASK>
[17792.724389] task:fsstress        state:D stack:0     pid:176022 tgid:176022 ppid:175941 task_flags:0x440140 flags:0x00080002
[17792.724390] Call Trace:
[17792.724391]  <TASK>
[17792.724391]  __schedule+0x42d/0x1ae0
[17792.724393]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.724416]  schedule+0x28/0xa0
[17792.724417]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.724440]  __wait_on_bit+0x92/0xb0
[17792.724441]  ? rpc_sleep_on+0x60/0x90 [sunrpc]
[17792.724463]  out_of_line_wait_on_bit+0x97/0xc0
[17792.724465]  ? __pfx_wake_bit_function+0x10/0x10
[17792.724466]  __rpc_execute+0x142/0x4c0 [sunrpc]
[17792.724489]  rpc_execute+0x134/0x160 [sunrpc]
[17792.724511]  rpc_run_task+0x115/0x180 [sunrpc]
[17792.724525]  nfs4_call_sync+0xd6/0x110 [nfsv4]
[17792.724540]  _nfs4_proc_access+0x137/0x1e0 [nfsv4]
[17792.724554]  nfs4_proc_access+0x6a/0xf0 [nfsv4]
[17792.724568]  nfs_do_access+0x104/0x2c0 [nfs]
[17792.724580]  nfs_permission+0x9b/0x200 [nfs]
[17792.724591]  ? __pfx_nfs_permission+0x10/0x10 [nfs]
[17792.724602]  inode_permission+0xfa/0x180
[17792.724603]  link_path_walk+0x5bf/0x6e0
[17792.724604]  path_lookupat+0x40/0x2f0
[17792.724605]  filename_lookup+0x129/0x230
[17792.724607]  ? list_lru_add+0x90/0xf0
[17792.724609]  __x64_sys_chdir+0x5d/0x110
[17792.724611]  do_syscall_64+0xbe/0x520
[17792.724612]  ? kmem_cache_free+0x286/0x480
[17792.724614]  ? __x64_sys_close+0x47/0xa0
[17792.724615]  ? switch_fpu_return+0x5e/0xf0
[17792.724616]  ? do_syscall_64+0x258/0x520
[17792.724618]  ? do_syscall_64+0xbe/0x520
[17792.724619]  ? do_syscall_64+0x258/0x520
[17792.724620]  ? clear_bhb_loop+0x60/0xb0
[17792.724621]  ? do_syscall_64+0x37/0x520
[17792.724622]  ? clear_bhb_loop+0x60/0xb0
[17792.724623]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.724624] RIP: 0033:0x7f5976160e5b
[17792.724624] RSP: 002b:00007ffc068dd7a8 EFLAGS: 00000246 ORIG_RAX: 0000000000000050
[17792.724625] RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 00007f5976160e5b
[17792.724626] RDX: 0000000000000000 RSI: 6534256c3e5c7db4 RDI: 0000000000401f07
[17792.724626] RBP: 0000000000000001 R08: 000000003b5ac1e0 R09: 0000000000000020
[17792.724627] R10: 0000000000000021 R11: 0000000000000246 R12: 0000000000000000
[17792.724627] R13: 0000000000000003 R14: 0000000000000000 R15: 0000000000418de0
[17792.724628]  </TASK>
[17792.724629] task:fsstress        state:D stack:0     pid:176023 tgid:176023 ppid:175941 task_flags:0x400140 flags:0x00080802
[17792.724630] Call Trace:
[17792.724631]  <TASK>
[17792.724631]  __schedule+0x42d/0x1ae0
[17792.724635]  ? psi_task_switch+0x25e/0x3b0
[17792.724636]  ? _raw_spin_unlock+0xe/0x30
[17792.724638]  ? finish_task_switch.isra.0+0xc3/0x400
[17792.724640]  schedule+0x28/0xa0
[17792.724642]  __wait_on_freeing_inode+0x15a/0x190
[17792.724644]  ? __pfx_var_wake_function+0x10/0x10
[17792.724645]  ? __pfx_nfs_find_actor+0x10/0x10 [nfs]
[17792.724657]  find_inode+0xeb/0x140
[17792.724659]  ? __pfx_nfs_find_actor+0x10/0x10 [nfs]
[17792.724671]  ilookup5+0xa7/0x130
[17792.724673]  ? __pfx_nfs_find_actor+0x10/0x10 [nfs]
[17792.724685]  ? __pfx_nfs_init_locked+0x10/0x10 [nfs]
[17792.724697]  iget5_locked+0x2c/0x90
[17792.724698]  nfs_fhget+0x10d/0x820 [nfs]
[17792.724711]  _nfs4_opendata_to_nfs4_state+0x6b/0x240 [nfsv4]
[17792.724725]  nfs4_do_open+0x427/0xe80 [nfsv4]
[17792.724740]  ? xa_load+0x76/0xb0
[17792.724742]  ? __memcg_slab_post_alloc_hook+0x43f/0x640
[17792.724744]  nfs4_atomic_open+0x156/0x180 [nfsv4]
[17792.724757]  nfs_atomic_open+0x252/0x730 [nfs]
[17792.724769]  ? __d_alloc+0x75/0x230
[17792.724771]  atomic_open+0x58/0x1a0
[17792.724773]  lookup_open+0x233/0x8c0
[17792.724774]  ? link_path_walk+0x20c/0x6e0
[17792.724775]  path_openat+0x57c/0xb00
[17792.724777]  ? do_syscall_64+0xbe/0x520
[17792.724778]  do_file_open+0x117/0x1d0
[17792.724780]  ? do_getname+0x62/0x200
[17792.724781]  do_sys_openat2+0x7d/0xe0
[17792.724783]  __x64_sys_openat+0x61/0xa0
[17792.724784]  do_syscall_64+0xbe/0x520
[17792.724785]  ? do_syscall_64+0xbe/0x520
[17792.724787]  ? kvm_sched_clock_read+0x11/0x30
[17792.724788]  ? sched_clock+0x11/0x30
[17792.724789]  ? sched_clock_cpu+0xf/0x230
[17792.724790]  ? sched_clock+0x11/0x30
[17792.724790]  ? irqtime_account_irq+0x33/0xd0
[17792.724791]  ? clear_bhb_loop+0x60/0xb0
[17792.724792]  ? do_syscall_64+0x37/0x520
[17792.724793]  ? clear_bhb_loop+0x60/0xb0
[17792.724794]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.724795] RIP: 0033:0x7f5976165f37
[17792.724796] RSP: 002b:00007ffc068dcff0 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
[17792.724796] RAX: ffffffffffffffda RBX: 0000000016fe73b2 RCX: 00007f5976165f37
[17792.724797] RDX: 0000000000000002 RSI: 000000003b5b0550 RDI: ffffffffffffff9c
[17792.724797] RBP: 00007ffc068dd060 R08: 0000000000000000 R09: 0000000000000000
[17792.724798] R10: 0000000000000000 R11: 0000000000000246 R12: 028f5c28f5c28f5c
[17792.724798] R13: 8f5c28f5c28f5c29 R14: 0000000000000002 R15: 0000000000418de0
[17792.724800]  </TASK>
[17792.724800] task:cmp             state:D stack:0     pid:184308 tgid:184308 ppid:175911 task_flags:0x440000 flags:0x00080000
[17792.724801] Call Trace:
[17792.724802]  <TASK>
[17792.724802]  __schedule+0x42d/0x1ae0
[17792.724804]  ? __pfx_lru_add+0x10/0x10
[17792.724806]  ? folio_batch_move_lru+0x1eb/0x2d0
[17792.724807]  ? mas_store_prealloc+0x1fb/0x550
[17792.724809]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.724832]  schedule+0x28/0xa0
[17792.724834]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.724856]  __wait_on_bit+0x92/0xb0
[17792.724857]  ? rpc_sleep_on+0x60/0x90 [sunrpc]
[17792.724879]  out_of_line_wait_on_bit+0x97/0xc0
[17792.724880]  ? __pfx_wake_bit_function+0x10/0x10
[17792.724882]  __rpc_execute+0x142/0x4c0 [sunrpc]
[17792.724904]  ? timerqueue_linked_add+0x9a/0xf0
[17792.724905]  rpc_execute+0x134/0x160 [sunrpc]
[17792.724927]  rpc_run_task+0x115/0x180 [sunrpc]
[17792.724941]  _nfs4_proc_getattr+0x28d/0x410 [nfsv4]
[17792.724956]  ? schedule_preempt_disabled+0x16/0x30
[17792.724957]  nfs4_proc_getattr+0x97/0x120 [nfsv4]
[17792.724971]  __nfs_revalidate_inode+0xe1/0x370 [nfs]
[17792.724985]  nfs_revalidate_mapping+0x4f/0x80 [nfs]
[17792.724999]  nfs_file_read+0xcd/0x130 [nfs]
[17792.725011]  vfs_read+0x34d/0x490
[17792.725012]  ? asm_exc_page_fault+0x26/0x30
[17792.725013]  ksys_read+0x7b/0x110
[17792.725014]  do_syscall_64+0xbe/0x520
[17792.725016]  ? __account_obj_stock+0x97/0x360
[17792.725018]  ? __memcg_slab_post_alloc_hook+0x43f/0x640
[17792.725019]  ? copy_page_to_iter+0xb6/0x170
[17792.725023]  ? touch_atime+0x2c/0x1b0
[17792.725024]  ? filemap_read+0x43d/0x4a0
[17792.725028]  ? nfs_file_read+0xe0/0x130 [nfs]
[17792.725040]  ? vfs_read+0x34d/0x490
[17792.725041]  ? wakeup_preempt_fair+0x1f2/0x4f0
[17792.725043]  ? switch_fpu_return+0x5e/0xf0
[17792.725044]  ? do_syscall_64+0x258/0x520
[17792.725045]  ? kvm_sched_clock_read+0x11/0x30
[17792.725047]  ? sched_clock+0x11/0x30
[17792.725047]  ? sched_clock_cpu+0xf/0x230
[17792.725048]  ? sched_clock+0x11/0x30
[17792.725049]  ? irqtime_account_irq+0x33/0xd0
[17792.725050]  ? clear_bhb_loop+0x60/0xb0
[17792.725051]  ? do_syscall_64+0x37/0x520
[17792.725052]  ? clear_bhb_loop+0x60/0xb0
[17792.725053]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.725054] RIP: 0033:0x7f57d2966a6d
[17792.725054] RSP: 002b:00007ffc262f8940 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
[17792.725055] RAX: ffffffffffffffda RBX: 0000000000100000 RCX: 00007f57d2966a6d
[17792.725055] RDX: 0000000000100000 RSI: 00007f57d26ff018 RDI: 0000000000000004
[17792.725056] RBP: 00007ffc262f8950 R08: 0000000000000000 R09: 0000000000000000
[17792.725056] R10: 0000000000000000 R11: 0000000000000246 R12: 00007f57d26ff018
[17792.725057] R13: 00007f57d27ff018 R14: 7fffffffffffffff R15: 0000000000000004
[17792.725058]  </TASK>
[17792.725059] task:cmp             state:D stack:0     pid:184316 tgid:184316 ppid:175896 task_flags:0x400000 flags:0x00080000
[17792.725061] Call Trace:
[17792.725061]  <TASK>
[17792.725062]  __schedule+0x42d/0x1ae0
[17792.725063]  ? copy_page_to_iter+0xb6/0x170
[17792.725064]  ? touch_atime+0x2c/0x1b0
[17792.725065]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.725088]  schedule+0x28/0xa0
[17792.725089]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.725112]  __wait_on_bit+0x92/0xb0
[17792.725113]  out_of_line_wait_on_bit+0x97/0xc0
[17792.725115]  ? __pfx_wake_bit_function+0x10/0x10
[17792.725116]  nfs4_do_close+0x2f7/0x3c0 [nfsv4]
[17792.725131]  __put_nfs_open_context+0xf1/0x190 [nfs]
[17792.725144]  nfs_file_release+0x41/0x60 [nfs]
[17792.725157]  __fput+0xf6/0x2d0
[17792.725159]  __x64_sys_close+0x47/0xa0
[17792.725160]  do_syscall_64+0xbe/0x520
[17792.725162]  ? nfs_file_read+0xe0/0x130 [nfs]
[17792.725174]  ? vfs_read+0x34d/0x490
[17792.725175]  ? ksys_read+0x7b/0x110
[17792.725176]  ? do_syscall_64+0xbe/0x520
[17792.725178]  ? do_syscall_64+0xbe/0x520
[17792.725179]  ? ksys_read+0x7b/0x110
[17792.725180]  ? clear_bhb_loop+0x60/0xb0
[17792.725210]  ? do_syscall_64+0x37/0x520
[17792.725212]  ? clear_bhb_loop+0x60/0xb0
[17792.725213]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.725219] RIP: 0033:0x7f3815760f74
[17792.725220] RSP: 002b:00007ffd74ad5698 EFLAGS: 00000246 ORIG_RAX: 0000000000000003
[17792.725221] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f3815760f74
[17792.725222] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000003
[17792.725222] RBP: 00007ffd74ad58b0 R08: 0000000000000000 R09: 0000000000000000
[17792.725223] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000089680
[17792.725223] R13: 00000000000008ac R14: 0000000000089680 R15: 0000000000089680
[17792.725225]  </TASK>
[17792.725227] task:cmp             state:D stack:0     pid:184330 tgid:184330 ppid:175910 task_flags:0x400000 flags:0x00080800
[17792.725228] Call Trace:
[17792.725229]  <TASK>
[17792.725230]  __schedule+0x42d/0x1ae0
[17792.725231]  ? _raw_spin_unlock+0xe/0x30
[17792.725233]  ? finish_task_switch.isra.0+0xc3/0x400
[17792.725234]  schedule+0x28/0xa0
[17792.725236]  __wait_on_freeing_inode+0x15a/0x190
[17792.725237]  ? __pfx_var_wake_function+0x10/0x10
[17792.725239]  ? __pfx_nfs_find_actor+0x10/0x10 [nfs]
[17792.725251]  find_inode+0xeb/0x140
[17792.725253]  ? __pfx_nfs_find_actor+0x10/0x10 [nfs]
[17792.725265]  ilookup5+0xa7/0x130
[17792.725266]  ? __pfx_nfs_find_actor+0x10/0x10 [nfs]
[17792.725278]  ? __pfx_nfs_init_locked+0x10/0x10 [nfs]
[17792.725290]  iget5_locked+0x2c/0x90
[17792.725291]  nfs_fhget+0x10d/0x820 [nfs]
[17792.725304]  _nfs4_opendata_to_nfs4_state+0x6b/0x240 [nfsv4]
[17792.725319]  nfs4_do_open+0x427/0xe80 [nfsv4]
[17792.725333]  ? xa_load+0x76/0xb0
[17792.725334]  ? __memcg_slab_post_alloc_hook+0x43f/0x640
[17792.725336]  nfs4_atomic_open+0x156/0x180 [nfsv4]
[17792.725350]  nfs_atomic_open+0x252/0x730 [nfs]
[17792.725361]  ? __d_alloc+0x75/0x230
[17792.725363]  atomic_open+0x58/0x1a0
[17792.725365]  lookup_open+0x233/0x8c0
[17792.725366]  ? link_path_walk+0x20c/0x6e0
[17792.725367]  path_openat+0x57c/0xb00
[17792.725369]  do_file_open+0x117/0x1d0
[17792.725371]  ? do_getname+0x62/0x200
[17792.725371]  do_sys_openat2+0x7d/0xe0
[17792.725373]  __x64_sys_openat+0x61/0xa0
[17792.725374]  do_syscall_64+0xbe/0x520
[17792.725375]  ? handle_mm_fault+0x216/0x350
[17792.725377]  ? do_user_addr_fault+0x2c7/0x830
[17792.725378]  ? clear_bhb_loop+0x60/0xb0
[17792.725379]  ? do_syscall_64+0x37/0x520
[17792.725381]  ? clear_bhb_loop+0x60/0xb0
[17792.725381]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.725382] RIP: 0033:0x7fadec365f37
[17792.725383] RSP: 002b:00007ffe8cf75a00 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
[17792.725384] RAX: ffffffffffffffda RBX: 000055df223c8410 RCX: 00007fadec365f37
[17792.725384] RDX: 0000000000080000 RSI: 00007ffe8cf77e89 RDI: ffffffffffffff9c
[17792.725385] RBP: 00007ffe8cf75a70 R08: 0000000000000000 R09: 0000000000000000
[17792.725385] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffe8cf77e89
[17792.725386] R13: 000055df223c82e0 R14: 000055df223c8400 R15: 0000000000000000
[17792.725387]  </TASK>
[17792.725388] task:cmp             state:D stack:0     pid:184336 tgid:184336 ppid:175909 task_flags:0x440000 flags:0x00080000
[17792.725389] Call Trace:
[17792.725390]  <TASK>
[17792.725390]  __schedule+0x42d/0x1ae0
[17792.725392]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.725415]  schedule+0x28/0xa0
[17792.725417]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.725439]  __wait_on_bit+0x92/0xb0
[17792.725441]  ? rpc_sleep_on+0x60/0x90 [sunrpc]
[17792.725463]  out_of_line_wait_on_bit+0x97/0xc0
[17792.725464]  ? __pfx_wake_bit_function+0x10/0x10
[17792.725466]  __rpc_execute+0x142/0x4c0 [sunrpc]
[17792.725488]  rpc_execute+0x134/0x160 [sunrpc]
[17792.725511]  rpc_run_task+0x115/0x180 [sunrpc]
[17792.725527]  nfs4_call_sync+0xd6/0x110 [nfsv4]
[17792.725542]  _nfs4_proc_access+0x137/0x1e0 [nfsv4]
[17792.725557]  nfs4_proc_access+0x6a/0xf0 [nfsv4]
[17792.725570]  nfs_do_access+0x104/0x2c0 [nfs]
[17792.725582]  nfs_permission+0x9b/0x200 [nfs]
[17792.725594]  ? __pfx_nfs_permission+0x10/0x10 [nfs]
[17792.725605]  inode_permission+0xfa/0x180
[17792.725606]  link_path_walk+0x5bf/0x6e0
[17792.725607]  path_openat+0x95/0xb00
[17792.725608]  do_file_open+0x117/0x1d0
[17792.725610]  ? do_fcntl+0x7af/0x980
[17792.725611]  ? do_getname+0x62/0x200
[17792.725612]  do_sys_openat2+0x7d/0xe0
[17792.725613]  __x64_sys_openat+0x61/0xa0
[17792.725614]  do_syscall_64+0xbe/0x520
[17792.725616]  ? _raw_spin_unlock+0xe/0x30
[17792.725617]  ? filemap_map_pages+0x398/0x860
[17792.725618]  ? xas_load+0x11/0xf0
[17792.725620]  ? __account_obj_stock+0x97/0x360
[17792.725622]  ? do_fault+0x401/0x650
[17792.725623]  ? __pte_offset_map+0x1b/0x100
[17792.725625]  ? __handle_mm_fault+0x818/0xf00
[17792.725626]  ? __x64_sys_rt_sigaction+0x11a/0x150
[17792.725629]  ? count_memcg_events+0xdb/0x210
[17792.725630]  ? handle_mm_fault+0x216/0x350
[17792.725632]  ? do_user_addr_fault+0x2c7/0x830
[17792.725633]  ? clear_bhb_loop+0x60/0xb0
[17792.725634]  ? do_syscall_64+0x37/0x520
[17792.725635]  ? clear_bhb_loop+0x60/0xb0
[17792.725636]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.725637] RIP: 0033:0x7fd699565f37
[17792.725637] RSP: 002b:00007ffd4a363d20 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
[17792.725638] RAX: ffffffffffffffda RBX: 00005641918d3410 RCX: 00007fd699565f37
[17792.725639] RDX: 0000000000080000 RSI: 00007ffd4a364e89 RDI: ffffffffffffff9c
[17792.725639] RBP: 00007ffd4a363d90 R08: 0000000000000000 R09: 0000000000000000
[17792.725639] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffd4a364e89
[17792.725640] R13: 00005641918d32e0 R14: 00005641918d3400 R15: 0000000000000000
[17792.725641]  </TASK>
[17792.725643] task:cp              state:D stack:0     pid:184342 tgid:184342 ppid:175877 task_flags:0x440000 flags:0x00080000
[17792.725644] Call Trace:
[17792.725645]  <TASK>
[17792.725645]  __schedule+0x42d/0x1ae0
[17792.725647]  ? mas_wr_split+0x680/0x1730
[17792.725649]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.725671]  schedule+0x28/0xa0
[17792.725672]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.725693]  __wait_on_bit+0x92/0xb0
[17792.725695]  ? rpc_sleep_on+0x60/0x90 [sunrpc]
[17792.725716]  out_of_line_wait_on_bit+0x97/0xc0
[17792.725718]  ? __pfx_wake_bit_function+0x10/0x10
[17792.725719]  __rpc_execute+0x142/0x4c0 [sunrpc]
[17792.725742]  rpc_execute+0x134/0x160 [sunrpc]
[17792.725765]  rpc_run_task+0x115/0x180 [sunrpc]
[17792.725779]  nfs4_call_sync+0xd6/0x110 [nfsv4]
[17792.725793]  _nfs4_proc_access+0x137/0x1e0 [nfsv4]
[17792.725817]  nfs4_proc_access+0x6a/0xf0 [nfsv4]
[17792.725830]  nfs_do_access+0x104/0x2c0 [nfs]
[17792.725842]  nfs_permission+0x9b/0x200 [nfs]
[17792.725854]  ? __pfx_nfs_permission+0x10/0x10 [nfs]
[17792.725865]  inode_permission+0xfa/0x180
[17792.725866]  link_path_walk+0x5bf/0x6e0
[17792.725867]  ? security_file_alloc+0xa6/0x150
[17792.725871]  path_lookupat+0x40/0x2f0
[17792.725872]  path_openat+0x73c/0xb00
[17792.725874]  do_file_open+0x117/0x1d0
[17792.725876]  ? do_getname+0x62/0x200
[17792.725876]  do_sys_openat2+0x7d/0xe0
[17792.725878]  __x64_sys_openat+0x61/0xa0
[17792.725879]  do_syscall_64+0xbe/0x520
[17792.725880]  ? clear_bhb_loop+0x60/0xb0
[17792.725881]  ? do_syscall_64+0x37/0x520
[17792.725882]  ? clear_bhb_loop+0x60/0xb0
[17792.725883]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.725884] RIP: 0033:0x7f53beb65f37
[17792.725884] RSP: 002b:00007ffc30c2c430 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
[17792.725885] RAX: ffffffffffffffda RBX: 00007ffc30c2c7e0 RCX: 00007f53beb65f37
[17792.725886] RDX: 0000000000210000 RSI: 00007ffc30c2ee9e RDI: ffffffffffffff9c
[17792.725886] RBP: 00007ffc30c2c4a0 R08: 0000000000000000 R09: 0000000000000000
[17792.725887] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000002
[17792.725887] R13: 00007ffc30c2c600 R14: 0000000000000000 R15: 0000000000000000
[17792.725888]  </TASK>
[17792.725889] task:cmp             state:D stack:0     pid:184343 tgid:184343 ppid:175899 task_flags:0x440000 flags:0x00080000
[17792.725890] Call Trace:
[17792.725891]  <TASK>
[17792.725892]  __schedule+0x42d/0x1ae0
[17792.725893]  ? map_anon_folio_pte_nopf+0xf1/0x1c0
[17792.725895]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.725917]  schedule+0x28/0xa0
[17792.725918]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.725940]  __wait_on_bit+0x92/0xb0
[17792.725942]  ? rpc_sleep_on+0x60/0x90 [sunrpc]
[17792.725964]  out_of_line_wait_on_bit+0x97/0xc0
[17792.725965]  ? __pfx_wake_bit_function+0x10/0x10
[17792.725966]  __rpc_execute+0x142/0x4c0 [sunrpc]
[17792.725989]  rpc_execute+0x134/0x160 [sunrpc]
[17792.726011]  rpc_run_task+0x115/0x180 [sunrpc]
[17792.726025]  nfs4_call_sync+0xd6/0x110 [nfsv4]
[17792.726039]  _nfs4_proc_access+0x137/0x1e0 [nfsv4]
[17792.726053]  nfs4_proc_access+0x6a/0xf0 [nfsv4]
[17792.726090]  nfs_do_access+0x104/0x2c0 [nfs]
[17792.726102]  nfs_permission+0x9b/0x200 [nfs]
[17792.726114]  ? __pfx_nfs_permission+0x10/0x10 [nfs]
[17792.726131]  inode_permission+0xfa/0x180
[17792.726132]  link_path_walk+0x5bf/0x6e0
[17792.726133]  path_openat+0x95/0xb00
[17792.726135]  ? next_uptodate_folio+0x93/0x320
[17792.726136]  do_file_open+0x117/0x1d0
[17792.726138]  ? do_getname+0x62/0x200
[17792.726139]  do_sys_openat2+0x7d/0xe0
[17792.726141]  __x64_sys_openat+0x61/0xa0
[17792.726141]  do_syscall_64+0xbe/0x520
[17792.726143]  ? count_memcg_events+0xdb/0x210
[17792.726144]  ? handle_mm_fault+0x216/0x350
[17792.726146]  ? do_user_addr_fault+0x2c7/0x830
[17792.726147]  ? clear_bhb_loop+0x60/0xb0
[17792.726148]  ? do_syscall_64+0x37/0x520
[17792.726149]  ? clear_bhb_loop+0x60/0xb0
[17792.726150]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.726151] RIP: 0033:0x7f177b165f37
[17792.726151] RSP: 002b:00007ffea9a94920 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
[17792.726152] RAX: ffffffffffffffda RBX: 0000560c173d2410 RCX: 00007f177b165f37
[17792.726153] RDX: 0000000000080000 RSI: 00007ffea9a96e89 RDI: ffffffffffffff9c
[17792.726153] RBP: 00007ffea9a94990 R08: 0000000000000000 R09: 0000000000000000
[17792.726153] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffea9a96e89
[17792.726154] R13: 0000560c173d22e0 R14: 0000560c173d2400 R15: 0000000000000000
[17792.726155]  </TASK>
[17792.726156] task:cmp             state:D stack:0     pid:184344 tgid:184344 ppid:175924 task_flags:0x440000 flags:0x00080000
[17792.726157] Call Trace:
[17792.726158]  <TASK>
[17792.726158]  __schedule+0x42d/0x1ae0
[17792.726160]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.726182]  schedule+0x28/0xa0
[17792.726184]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.726206]  __wait_on_bit+0x92/0xb0
[17792.726207]  ? rpc_sleep_on+0x60/0x90 [sunrpc]
[17792.726230]  out_of_line_wait_on_bit+0x97/0xc0
[17792.726231]  ? __pfx_wake_bit_function+0x10/0x10
[17792.726232]  __rpc_execute+0x142/0x4c0 [sunrpc]
[17792.726254]  ? free_pages_and_swap_cache+0x19f/0x260
[17792.726256]  rpc_execute+0x134/0x160 [sunrpc]
[17792.726278]  rpc_run_task+0x115/0x180 [sunrpc]
[17792.726292]  nfs4_call_sync+0xd6/0x110 [nfsv4]
[17792.726306]  _nfs4_proc_access+0x137/0x1e0 [nfsv4]
[17792.726320]  nfs4_proc_access+0x6a/0xf0 [nfsv4]
[17792.726334]  nfs_do_access+0x104/0x2c0 [nfs]
[17792.726346]  nfs_permission+0x9b/0x200 [nfs]
[17792.726357]  ? __pfx_nfs_permission+0x10/0x10 [nfs]
[17792.726368]  inode_permission+0xfa/0x180
[17792.726369]  link_path_walk+0x5bf/0x6e0
[17792.726370]  path_openat+0x95/0xb00
[17792.726372]  ? filemap_map_pages+0x398/0x860
[17792.726373]  do_file_open+0x117/0x1d0
[17792.726375]  ? do_getname+0x62/0x200
[17792.726376]  do_sys_openat2+0x7d/0xe0
[17792.726377]  __x64_sys_openat+0x61/0xa0
[17792.726378]  do_syscall_64+0xbe/0x520
[17792.726380]  ? handle_mm_fault+0x216/0x350
[17792.726381]  ? do_user_addr_fault+0x2c7/0x830
[17792.726382]  ? clear_bhb_loop+0x60/0xb0
[17792.726383]  ? do_syscall_64+0x37/0x520
[17792.726384]  ? clear_bhb_loop+0x60/0xb0
[17792.726385]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.726386] RIP: 0033:0x7fb736565f37
[17792.726386] RSP: 002b:00007ffd8ce14440 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
[17792.726387] RAX: ffffffffffffffda RBX: 000055d0fccc1410 RCX: 00007fb736565f37
[17792.726387] RDX: 0000000000080000 RSI: 00007ffd8ce15e89 RDI: ffffffffffffff9c
[17792.726388] RBP: 00007ffd8ce144b0 R08: 0000000000000000 R09: 0000000000000000
[17792.726388] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffd8ce15e89
[17792.726389] R13: 000055d0fccc12e0 R14: 000055d0fccc1400 R15: 0000000000000000
[17792.726390]  </TASK>
[17792.726393] task:rm              state:D stack:0     pid:184355 tgid:184355 ppid:175889 task_flags:0x440000 flags:0x00080000
[17792.726394] Call Trace:
[17792.726395]  <TASK>
[17792.726395]  __schedule+0x42d/0x1ae0
[17792.726397]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.726419]  schedule+0x28/0xa0
[17792.726420]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.726442]  __wait_on_bit+0x92/0xb0
[17792.726444]  ? rpc_sleep_on+0x60/0x90 [sunrpc]
[17792.726465]  out_of_line_wait_on_bit+0x97/0xc0
[17792.726466]  ? __pfx_wake_bit_function+0x10/0x10
[17792.726468]  __rpc_execute+0x142/0x4c0 [sunrpc]
[17792.726490]  rpc_execute+0x134/0x160 [sunrpc]
[17792.726512]  rpc_run_task+0x115/0x180 [sunrpc]
[17792.726526]  nfs4_call_sync+0xd6/0x110 [nfsv4]
[17792.726540]  _nfs4_proc_access+0x137/0x1e0 [nfsv4]
[17792.726555]  nfs4_proc_access+0x6a/0xf0 [nfsv4]
[17792.726568]  nfs_do_access+0x104/0x2c0 [nfs]
[17792.726580]  ? post_alloc_hook+0x88/0xe0
[17792.726582]  nfs_permission+0x9b/0x200 [nfs]
[17792.726593]  ? __pfx_nfs_permission+0x10/0x10 [nfs]
[17792.726604]  inode_permission+0xfa/0x180
[17792.726605]  link_path_walk+0x5bf/0x6e0
[17792.726606]  path_lookupat+0x40/0x2f0
[17792.726607]  filename_lookup+0x129/0x230
[17792.726608]  ? __mod_memcg_lruvec_state+0xef/0x230
[17792.726611]  vfs_statx+0x8e/0x1b0
[17792.726612]  vfs_fstatat+0x4d/0x90
[17792.726614]  __do_sys_newfstatat+0x5a/0xa0
[17792.726616]  do_syscall_64+0xbe/0x520
[17792.726617]  ? clear_bhb_loop+0x60/0xb0
[17792.726618]  ? do_syscall_64+0x37/0x520
[17792.726619]  ? clear_bhb_loop+0x60/0xb0
[17792.726620]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.726621] RIP: 0033:0x7f113bb61dfe
[17792.726622] RSP: 002b:00007fff64904bc8 EFLAGS: 00000246 ORIG_RAX: 0000000000000106
[17792.726622] RAX: ffffffffffffffda RBX: 00005578c0e36380 RCX: 00007f113bb61dfe
[17792.726623] RDX: 00005578c0e36380 RSI: 00005578c0e36410 RDI: 00000000ffffff9c
[17792.726623] RBP: 00007fff64904c00 R08: 00007f113bbf6ac0 R09: 0000000000000120
[17792.726624] R10: 0000000000000100 R11: 0000000000000246 R12: 00005578c0e36310
[17792.726624] R13: 00005578c0e35060 R14: 0000000000000000 R15: 00007fff64906e9e
[17792.726625]  </TASK>
[17792.726626] task:rm              state:D stack:0     pid:184356 tgid:184356 ppid:175883 task_flags:0x440000 flags:0x00080000
[17792.726627] Call Trace:
[17792.726628]  <TASK>
[17792.726628]  __schedule+0x42d/0x1ae0
[17792.726630]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.726652]  schedule+0x28/0xa0
[17792.726654]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.726675]  __wait_on_bit+0x92/0xb0
[17792.726677]  ? _raw_spin_unlock+0xe/0x30
[17792.726678]  ? rpc_sleep_on+0x60/0x90 [sunrpc]
[17792.726700]  out_of_line_wait_on_bit+0x97/0xc0
[17792.726701]  ? __pfx_wake_bit_function+0x10/0x10
[17792.726702]  __rpc_execute+0x142/0x4c0 [sunrpc]
[17792.726725]  rpc_execute+0x134/0x160 [sunrpc]
[17792.726747]  rpc_run_task+0x115/0x180 [sunrpc]
[17792.726761]  nfs4_call_sync+0xd6/0x110 [nfsv4]
[17792.726776]  _nfs4_proc_access+0x137/0x1e0 [nfsv4]
[17792.726790]  nfs4_proc_access+0x6a/0xf0 [nfsv4]
[17792.726804]  nfs_do_access+0x104/0x2c0 [nfs]
[17792.726816]  nfs_permission+0x9b/0x200 [nfs]
[17792.726828]  ? __pfx_nfs_permission+0x10/0x10 [nfs]
[17792.726839]  inode_permission+0xfa/0x180
[17792.726840]  link_path_walk+0x5bf/0x6e0
[17792.726841]  path_lookupat+0x40/0x2f0
[17792.726842]  filename_lookup+0x129/0x230
[17792.726844]  vfs_statx+0x8e/0x1b0
[17792.726846]  vfs_fstatat+0x4d/0x90
[17792.726847]  __do_sys_newfstatat+0x5a/0xa0
[17792.726849]  do_syscall_64+0xbe/0x520
[17792.726851]  ? __x64_sys_ioctl+0x98/0x100
[17792.726852]  ? do_syscall_64+0xbe/0x520
[17792.726853]  ? __mod_memcg_state+0xd9/0x1d0
[17792.726855]  ? __mod_memcg_lruvec_state+0xef/0x230
[17792.726856]  ? lruvec_stat_mod_folio+0x7d/0xc0
[17792.726857]  ? __folio_mod_stat+0x2d/0x90
[17792.726858]  ? map_anon_folio_pte_nopf+0xf1/0x1c0
[17792.726860]  ? _raw_spin_unlock+0xe/0x30
[17792.726861]  ? do_anonymous_page+0x331/0x9f0
[17792.726862]  ? __pte_offset_map+0x1b/0x100
[17792.726863]  ? __handle_mm_fault+0xb83/0xf00
[17792.726865]  ? count_memcg_events+0xdb/0x210
[17792.726866]  ? handle_mm_fault+0x216/0x350
[17792.726868]  ? do_user_addr_fault+0x2c7/0x830
[17792.726869]  ? clear_bhb_loop+0x60/0xb0
[17792.726870]  ? do_syscall_64+0x37/0x520
[17792.726871]  ? clear_bhb_loop+0x60/0xb0
[17792.726872]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.726873] RIP: 0033:0x7efe00161dfe
[17792.726873] RSP: 002b:00007fff2eba4198 EFLAGS: 00000246 ORIG_RAX: 0000000000000106
[17792.726874] RAX: ffffffffffffffda RBX: 000055d001658380 RCX: 00007efe00161dfe
[17792.726874] RDX: 000055d001658380 RSI: 000055d001658410 RDI: 00000000ffffff9c
[17792.726875] RBP: 00007fff2eba41d0 R08: 00007efe001f6ac0 R09: 0000000000000120
[17792.726875] R10: 0000000000000100 R11: 0000000000000246 R12: 000055d001658310
[17792.726876] R13: 000055d001657060 R14: 0000000000000000 R15: 00007fff2eba5e9e
[17792.726877]  </TASK>
[17792.726878] task:rm              state:D stack:0     pid:184357 tgid:184357 ppid:175895 task_flags:0x440000 flags:0x00080000
[17792.726879] Call Trace:
[17792.726879]  <TASK>
[17792.726880]  __schedule+0x42d/0x1ae0
[17792.726882]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.726904]  schedule+0x28/0xa0
[17792.726905]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.726927]  __wait_on_bit+0x92/0xb0
[17792.726928]  ? rpc_sleep_on+0x60/0x90 [sunrpc]
[17792.726951]  out_of_line_wait_on_bit+0x97/0xc0
[17792.726953]  ? __pfx_wake_bit_function+0x10/0x10
[17792.726954]  __rpc_execute+0x142/0x4c0 [sunrpc]
[17792.726977]  rpc_execute+0x134/0x160 [sunrpc]
[17792.726999]  rpc_run_task+0x115/0x180 [sunrpc]
[17792.727015]  nfs4_call_sync+0xd6/0x110 [nfsv4]
[17792.727029]  _nfs4_proc_access+0x137/0x1e0 [nfsv4]
[17792.727048]  nfs4_proc_access+0x6a/0xf0 [nfsv4]
[17792.727062]  nfs_do_access+0x104/0x2c0 [nfs]
[17792.727074]  nfs_permission+0x9b/0x200 [nfs]
[17792.727086]  ? __pfx_nfs_permission+0x10/0x10 [nfs]
[17792.727097]  inode_permission+0xfa/0x180
[17792.727098]  link_path_walk+0x5bf/0x6e0
[17792.727099]  path_lookupat+0x40/0x2f0
[17792.727100]  filename_lookup+0x129/0x230
[17792.727103]  vfs_statx+0x8e/0x1b0
[17792.727104]  vfs_fstatat+0x4d/0x90
[17792.727106]  __do_sys_newfstatat+0x5a/0xa0
[17792.727108]  do_syscall_64+0xbe/0x520
[17792.727109]  ? handle_mm_fault+0x216/0x350
[17792.727110]  ? do_user_addr_fault+0x2c7/0x830
[17792.727111]  ? clear_bhb_loop+0x60/0xb0
[17792.727112]  ? do_syscall_64+0x37/0x520
[17792.727113]  ? clear_bhb_loop+0x60/0xb0
[17792.727114]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.727115] RIP: 0033:0x7f1a93561dfe
[17792.727116] RSP: 002b:00007ffd3eabd168 EFLAGS: 00000246 ORIG_RAX: 0000000000000106
[17792.727116] RAX: ffffffffffffffda RBX: 000055aa2e399380 RCX: 00007f1a93561dfe
[17792.727117] RDX: 000055aa2e399380 RSI: 000055aa2e399410 RDI: 00000000ffffff9c
[17792.727117] RBP: 00007ffd3eabd1a0 R08: 00007f1a935f6ac0 R09: 0000000000000120
[17792.727118] R10: 0000000000000100 R11: 0000000000000246 R12: 000055aa2e399310
[17792.727118] R13: 000055aa2e398060 R14: 0000000000000000 R15: 00007ffd3eabee9e
[17792.727119]  </TASK>
[17792.727124] task:updatedb        state:D stack:0     pid:189696 tgid:189696 ppid:1      task_flags:0x440100 flags:0x00080000
[17792.727126] Call Trace:
[17792.727127]  <TASK>
[17792.727127]  __schedule+0x42d/0x1ae0
[17792.727129]  ? xfs_read_icluster+0x97/0xe0 [xfs]
[17792.727309]  ? blk_mq_flush_plug_list+0x51/0x1b0
[17792.727312]  ? __pfx_rpc_wait_bit_killable+0x10/0x10 [sunrpc]
[17792.727339]  schedule+0x28/0xa0
[17792.727341]  rpc_wait_bit_killable+0x11/0x70 [sunrpc]
[17792.727363]  __wait_on_bit+0x92/0xb0
[17792.727364]  ? rpc_sleep_on+0x60/0x90 [sunrpc]
[17792.727386]  out_of_line_wait_on_bit+0x97/0xc0
[17792.727388]  ? __pfx_wake_bit_function+0x10/0x10
[17792.727389]  __rpc_execute+0x142/0x4c0 [sunrpc]
[17792.727412]  ? context_to_sid+0x73/0x110
[17792.727414]  rpc_execute+0x134/0x160 [sunrpc]
[17792.727436]  rpc_run_task+0x115/0x180 [sunrpc]
[17792.727451]  _nfs4_proc_getattr+0x28d/0x410 [nfsv4]
[17792.727471]  ? avc_has_perm_noaudit+0x7e/0x150
[17792.727473]  nfs4_proc_getattr+0x97/0x120 [nfsv4]
[17792.727487]  __nfs_revalidate_inode+0xe1/0x370 [nfs]
[17792.727505]  nfs_lookup_verify_inode+0x87/0xc0 [nfs]
[17792.727516]  nfs_weak_revalidate+0x51/0x90 [nfs]
[17792.727527]  complete_walk+0x77/0xb0
[17792.727528]  path_openat+0x5b9/0xb00
[17792.727529]  do_file_open+0x117/0x1d0
[17792.727531]  ? __list_lru_add.part.0+0x2f/0x90
[17792.727533]  ? do_getname+0x62/0x200
[17792.727534]  do_sys_openat2+0x7d/0xe0
[17792.727536]  __x64_sys_openat+0x61/0xa0
[17792.727537]  do_syscall_64+0xbe/0x520
[17792.727538]  ? list_lru_add+0x90/0xf0
[17792.727540]  ? __memcg_slab_free_hook+0x16d/0x1c0
[17792.727541]  ? list_lru_add_obj+0x87/0xa0
[17792.727542]  ? kmem_cache_free+0x286/0x480
[17792.727544]  ? __x64_sys_close+0x47/0xa0
[17792.727544]  ? __x64_sys_close+0x47/0xa0
[17792.727545]  ? do_syscall_64+0xbe/0x520
[17792.727546]  ? xas_load+0x11/0xf0
[17792.727548]  ? xa_load+0x76/0xb0
[17792.727549]  ? __list_lru_add.part.0+0x2f/0x90
[17792.727550]  ? _raw_spin_unlock+0xe/0x30
[17792.727551]  ? list_lru_add+0x90/0xf0
[17792.727553]  ? __memcg_slab_free_hook+0x16d/0x1c0
[17792.727553]  ? list_lru_add_obj+0x87/0xa0
[17792.727555]  ? kmem_cache_free+0x286/0x480
[17792.727556]  ? __x64_sys_close+0x47/0xa0
[17792.727557]  ? __x64_sys_close+0x47/0xa0
[17792.727557]  ? clear_bhb_loop+0x60/0xb0
[17792.727558]  ? do_syscall_64+0x37/0x520
[17792.727560]  entry_SYSCALL_64_after_hwframe+0x76/0x7e
[17792.727561] RIP: 0033:0x7ff5287660dd
[17792.727562] RSP: 002b:00007fff81bbae60 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
[17792.727563] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007ff5287660dd
[17792.727563] RDX: 0000000000010000 RSI: 000055c376d6a990 RDI: 000000000000000c
[17792.727564] RBP: 00007fff81bbaed0 R08: 0000000000000000 R09: 0000000000000000
[17792.727564] R10: 0000000000000000 R11: 0000000000000246 R12: 00007fff81bbb0f0
[17792.727565] R13: 0000000000000000 R14: 000055c376e97460 R15: 000055c376d6a980
[17792.727566]  </TASK>
...
