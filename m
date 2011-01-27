Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47584 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752677Ab1A0OLs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jan 2011 09:11:48 -0500
Subject: Re: kernel BUG while mv files onto an nfs mount with Linus'
 linux-2.6 git tree
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Douglas Leeder <douglas.leeder@sophos.com>
Cc: linux-nfs@vger.kernel.org, Tvrtko Ursulin <tvrtko.ursulin@sophos.com>,
        douglas.leeder@gmail.com, linux-kernel@vger.kernel.org
In-Reply-To: <1c30423a-57bf-44bb-aa2e-4d658f829474@uk-exch1.green.sophos>
References: <1c30423a-57bf-44bb-aa2e-4d658f829474@uk-exch1.green.sophos>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 27 Jan 2011 09:11:46 -0500
Message-ID: <1296137506.2965.4.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-01-27 at 14:06 +0000, Douglas Leeder wrote: 
> Hi,
> 
> I got the following kernel BUG while moving files onto an nfs mount,
> while running Linus' linux-2.6 git tree (2.6.38-rc2) under VirtualBox.
> 
> The mv command is now stuck in the D+ state.
> 
> Attempting to ls the mount results in ls being stuck in the D+ state.
> 
> The nfs server is an Ubuntu 10.04 box running Ubuntu kernel.
> (2.6.32-28-generic-pae #55-Ubuntu SMP Mon Jan 10 22:34:08 UTC 2011)
> 
> I would be happy to provide any more information that is required.
> 
> kernel BUG at fs/nfs/nfs3xdr.c:1338!
> invalid opcode: 0000 [#1] SMP
> last sysfs file: /sys/devices/virtual/bdi/0:21/uevent
> Modules linked in: nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss
> sunrpc psmouse i2c_piix4 serio_raw sr_mod pcnet32 mii
> 476034]
> Pid: 3214, comm: mv Not tainted 2.6.38-rc2-custom3dlcl #3 /VirtualBox
> EIP: 0060:[<d8a0d9e8>] EFLAGS: 00010282 CPU: 0
> EIP is at nfs3_xdr_enc_setacl3args+0xb8/0xc0 [nfs]
> EAX: ffffffea EBX: d623bd90 ECX: 00000000 EDX: d623bbd8
> ESI: d623bcac EDI: 00000084 EBP: d623bc88 ESP: d623bc70
>   DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> Process mv (pid: 3214, ti=d623a000 task=d7770ca0 task.ti=d623a000)
> Stack:
>   d6d651a0 00000001 00000000 d623bcac d5ea8000 d8a0d930 d623bcd4 d88d8f16
>   d1828820 d623bcb0 d88d9be7 d1828824 d182884c d7553880 00000000 d1828888
>   d5ea8004 d18289d4 d5ea8004 d623bd10 d5d8d000 d5d8d35c d7553880 d5ea8000
> Call Trace:
>   [<d8a0d930>] ? nfs3_xdr_enc_setacl3args+0x0/0xc0 [nfs]
>   [<d88d8f16>] rpcauth_wrap_req+0x76/0xb0 [sunrpc]
>   [<d88d9be7>] ? unx_marshal+0x47/0xc0 [sunrpc]
>   [<d88d0f7f>] call_transmit+0x14f/0x250 [sunrpc]
>   [<d88d8227>] __rpc_execute+0x67/0x200 [sunrpc]
>   [<c0166d6e>] ? wake_up_bit+0x5e/0x70
>   [<d88d7b92>] ? rpc_make_runnable+0x72/0xa0 [sunrpc]
>   [<d88d83f8>] rpc_execute+0x38/0x40 [sunrpc]
>   [<d88d1d04>] rpc_run_task+0xa4/0xe0 [sunrpc]
>   [<d88d1e3e>] rpc_call_sync+0x3e/0x60 [sunrpc]
>   [<d8a0f4c0>] nfs3_proc_setacls+0x150/0x2e0 [nfs]
>   [<c016ae01>] ? __run_hrtimer+0xa1/0x1c0
>   [<c025c317>] ? posix_acl_alloc+0x17/0x30
>   [<d8a0fdaf>] nfs3_proc_setacl+0x5f/0x100 [nfs]
>   [<c025c48c>] ? posix_acl_from_xattr+0x6c/0x100
>   [<d8a0ff02>] nfs3_setxattr+0x52/0xa0 [nfs]
>   [<d8a0feb0>] ? nfs3_setxattr+0x0/0xa0 [nfs]
>   [<c0237ef1>] __vfs_setxattr_noperm+0x41/0x120
>   [<c030a67c>] ? cap_inode_setxattr+0x2c/0x60
>   [<c0238061>] vfs_setxattr+0x91/0xa0
>   [<c0238128>] setxattr+0xb8/0x110
>   [<c01f8695>] ? handle_pte_fault+0x85/0x920
>   [<c01307cc>] ? kmap_atomic_prot+0x4c/0x100
>   [<c01f8fdc>] ? handle_mm_fault+0xac/0x140
>   [<c05bc772>] ? do_page_fault+0x1b2/0x450
>   [<c02d0500>] ? ext4_listxattr+0x0/0x240
>   [<c023783a>] ? vfs_listxattr+0x3a/0x70
>   [<c0238218>] sys_fsetxattr+0x98/0xb0
>   [<c010301f>] sysenter_do_call+0x12/0x28
> Code: 59 f2 ff 85 c0 78 20 83 c4 0c 5b 5e 5f 5d c3 8d 74 26 00 8b 43 10
> 31 c9 8b 53 18 89 04 24 89 f0 e8 0e 38 ed ff eb 80 0f 0b eb fe <0f> 0b
> eb fe 8d 74 26 00 55 89 e5 83 ec 08 89 1c 24 89 74 24 04
> EIP: [<d8a0d9e8>] nfs3_xdr_enc_setacl3args+0xb8/0xc0 [nfs] SS:ESP
> 0068:d623bc70
> ---[ end trace 69c4fc2ce1ae740d ]---

This bug has already been reported to the list. The following patch
should fix it:

http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git;a=commitdiff;h=ee5dc7732bd557bae6d10873a0aac606d2c551fb

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

