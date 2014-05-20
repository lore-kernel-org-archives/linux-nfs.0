Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:40647 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753771AbaETOVW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2014 10:21:22 -0400
Received: by mail-qc0-f170.google.com with SMTP id i8so827732qcq.15
        for <linux-nfs@vger.kernel.org>; Tue, 20 May 2014 07:21:22 -0700 (PDT)
Date: Tue, 20 May 2014 10:21:17 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Cc: linux-nfs@vger.kernel.org,
        Tuomas =?ISO-8859-1?B?UuRz5G5lbg==?= <tuomas.rasanen@opinsys.fi>
Subject: Re: Soft lockups on kerberised NFSv4.0 clients
Message-ID: <20140520102117.2582abac@tlielax.poochiereds.net>
In-Reply-To: <1176115795.34522.1400575248541.JavaMail.zimbra@opinsys.fi>
References: <199810131.34257.1400570367382.JavaMail.zimbra@opinsys.fi>
	<1176115795.34522.1400575248541.JavaMail.zimbra@opinsys.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 20 May 2014 08:40:48 +0000 (UTC)
Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:

> Hello,
> 
> We are seeing soft lockup call traces on kerberised NFSv4.0 clients acting as terminal servers serving multiple thin clients running graphical desktop sessions on NFS home directories. We do not have a simple way to reproduce the problem, but creating artificial load running multiple users running applications like Firefox, LibreOffice, GIMP, etc. usually works. On production systems high load has not been a requirement for soft lockups to happen, though. This happens both on KVM virtual machines and on real hardware.
> 
> NFS server kernels 3.10 - 3.15-rc5 have been tested and on NFS client kernels 3.12 - 3.15-rc5 have been tested.
> 
> The NFS clients do mounts only from a single NFS server and there are two mounts where the first one is done with auth=sys without an existing krb5.keytab. This results in SETCLIENTID being called with auth=sys. The user home directories are mounted with auth=krb5. Machine credentials are available when the krb5 mount is done. The dumps show that callbacks use auth=sys.
> 
> If the NFS mount is replaced with a CIFS mount, no soft lockups happen.
> 
> Turning off leases on NFS server has so far made the NFS clients stable and no soft lockups have happened. The leases were disabled with "echo 0 >/proc/sys/fs/leases-enable" before starting the NFS server.
> 
> Because reproducing the problem takes some time, dumpcap dumps are usually several gigabytes in size. In the dumps there is one consistent sequence that may tell something.
> 
> Shortly (< 1min) before the soft lockups appear, the NFS server responds to RENEW request with NFS4ERR_CB_PATH_DOWN, e.g.:
> 
> 1171171 163.248014 10.249.0.2 -> 10.249.15.254 NFS 174 V4 Call RENEW CID: 0x34d1
> 1171172 163.248112 10.249.15.254 -> 10.249.0.2 NFS 114 V4 Reply (Call In 1171171) RENEW
> 1182967 223.407973 10.249.0.2 -> 10.249.15.254 NFS 174 V4 Call RENEW CID: 0x34d1
> 1182968 223.408059 10.249.15.254 -> 10.249.0.2 NFS 114 V4 Reply (Call In 1182967) RENEW
> 1223198 287.407968 10.249.0.2 -> 10.249.15.254 NFS 174 V4 Call RENEW CID: 0x34d1
> 1223199 287.408024 10.249.15.254 -> 10.249.0.2 NFS 114 V4 Reply (Call In 1223198) RENEW
> 1841475 347.568113 10.249.0.2 -> 10.249.15.254 NFS 174 V4 Call RENEW CID: 0x34d1
> 1841477 347.568139 10.249.15.254 -> 10.249.0.2 NFS 114 V4 Reply (Call In 1841475) RENEW Status: NFS4ERR_CB_PATH_DOWN
> 1841494 347.568913 10.249.0.2 -> 10.249.15.254 NFS 174 V4 Call RENEW CID: 0x34d1
> 1841495 347.568937 10.249.15.254 -> 10.249.0.2 NFS 114 V4 Reply (Call In 1841494) RENEW Status: NFS4ERR_CB_PATH_DOWN
> 
> After this the NFS client returns all the delegations which can mean hundreds of DELEGRETURNS at once. Also a new SETCLIENTID call is done.
> 
> Before the NFS4ERR_CB_PATH_DOWN there seems to be a CB_RECALL where the client responds with NFS4ERR_BADHANDLE. I have seen also cases where the NFS server sends a CB_RECALL for a delegation that was already returned a few seconds before.
> 
> Quick test with Trond's nfsd-devel branch caused a lot of bad sequence id errors, so I could not run the same tests with that branch.
> 
> NFS debugging is not my expertise, so any advice on how to debug this further would be welcome. I'm more than willing to provide more information and do testing on this.
> 
> 
> An example call trace:
> 
> [ 916.100013] BUG: soft lockup - CPU#3 stuck for 23s! [mozStorage #5:15492]
> [ 916.100013] Modules linked in: cts nfsv4 cuse autofs4 deflate ctr twofish_generic twofish_i586 twofish_common camellia_generic serpent_sse2_i586 xts serpent_generic lrw gf128mul glue_helper ablk_helper cryptd blowfish_generic blowfish_common cast5_generic cast_common des_generic cmac xcbc rmd160 sha512_generic crypto_null af_key xfrm_algo i2c_piix4 microcode virtio_balloon serio_raw mac_hid rpcsec_gss_krb5 nfsd auth_rpcgss oid_registry nfs_acl nfs lockd parport_pc sunrpc ppdev fscache lp parport binfmt_misc overlayfs btrfs xor raid6_pq nbd psmouse e1000 floppy
> [ 916.100013] CPU: 3 PID: 15492 Comm: mozStorage #5 Not tainted 3.15.0-rc5 #6
> [ 916.100013] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [ 916.100013] task: e1ad28b0 ti: df6ba000 task.ti: df6ba000
> [ 916.100013] EIP: 0060:[<c109423c>] EFLAGS: 00000282 CPU: 3
> [ 916.100013] EIP is at prepare_to_wait+0x4c/0x80
> [ 916.100013] EAX: 00000282 EBX: e1ad28b0 ECX: 00000082 EDX: 00000282
> [ 916.100013] ESI: e7b4a658 EDI: df6bbe80 EBP: df6bbe64 ESP: df6bbe50
> [ 916.100013] DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> [ 916.100013] CR0: 8005003b CR2: 08d30c30 CR3: 1f505000 CR4: 000006f0
> [ 916.100013] Stack:
> [ 916.100013] 00000082 00000082 df5d6a38 fffffe00 e7b4a658 df6bbe94 f854f167 df5d6a38
> [ 916.100013] 00000000 00000000 e1ad28b0 c1094080 e7b4a65c e7b4a65c e0026540 df5d6a20
> [ 916.100013] e0026540 df6bbeb4 f8545168 0000000d dfc56728 f74beb60 00000000 f74beb60
> [ 916.100013] Call Trace:
> [ 916.100013] [<f854f167>] nfs_iocounter_wait+0x87/0xb0 nfs
> [ 916.100013] [<c1094080>] ? wake_atomic_t_function+0x50/0x50
> [ 916.100013] [<f8545168>] do_unlk+0x48/0xb0 nfs
> [ 916.100013] [<f85454b5>] nfs_lock+0x125/0x1a0 nfs
> [ 916.100013] [<c10b5253>] ? ktime_get+0x53/0x120
> [ 916.100013] [<f8545390>] ? nfs_flock+0xd0/0xd0 nfs
> [ 916.100013] [<c11bcd9f>] vfs_lock_file+0x1f/0x50
> [ 916.100013] [<c11bceb0>] do_lock_file_wait.part.19+0x30/0xb0
> [ 916.100013] [<c164c05f>] ? __do_page_fault+0x21f/0x500
> [ 916.100013] [<c11bdfd7>] fcntl_setlk64+0x107/0x210
> [ 916.100013] [<c11870f2>] SyS_fcntl64+0xd2/0x100
> [ 916.100013] [<c1648b8a>] syscall_call+0x7/0xb
> [ 916.100013] [<c1640000>] ? add_new_disk+0x222/0x44b
> [ 916.100013] Code: e8 4a 44 5b 00 8b 4d ec 3b 7b 0c 74 32 89 4d f0 8b 4d f0 64 8b 1d b4 6f a5 c1 87 0b 89 4d f0 8b 55 f0 89 c2 89 f0 e8 84 45 5b 00 <8b> 5d f4 8b 75 f8 8b 7d fc 89 ec 5d c3 8d b4 26 00 00 00 00 8b
> 


I hit some problems a while back with kerberized NFSv4.0 callbacks. You
may want to try these patches on the client that I posted in early
April:

    [PATCH 0/3] nfs: fix v4.0 callback channel auth failures

AFAIK, Trond hasn't merged those yet, but hopefully they'll make v3.16.

There's also a companion nfs-utils patchset as well that has been
merged into upstream nfs-utils:

    [PATCH v2 0/6] gssd: add the GSSAPI acceptor name to the info passed in downcall

Cheers,
-- 
Jeff Layton <jlayton@poochiereds.net>
