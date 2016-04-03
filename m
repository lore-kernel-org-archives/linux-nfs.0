Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54278 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751120AbcDCANV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Apr 2016 20:13:21 -0400
Date: Sat, 2 Apr 2016 20:13:19 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-nfs@vger.kernel.org, linux-crypto@vger.kernel.org
Subject: nfs/krb5 crash on 4.6-rc1
Message-ID: <20160403001319.GB12588@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As of 3b5cf20c "sunrpc: Use skcipher and ahash/shash", I get a NULL
dereference in krb5_encrypt on an NFS server when a client attempts to
mount using krb5.  I haven't tried to figure out what's going on beyond
that....

--b.


[   97.781559] IP: [<ffffffffa011d108>] krb5_encrypt+0x138/0x1f0 [rpcsec_gss_krb5]
[   97.782100] PGD 0 
[   97.782257] Oops: 0000 [#1] PREEMPT SMP 
[   97.782646] Modules linked in: rpcsec_gss_krb5 nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc
[   97.783709] CPU: 0 PID: 4415 Comm: nfsd Not tainted 4.6.0-rc1-00029-gc05c2ec #489
[   97.784015] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150714_191134- 04/01/2014
[   97.784015] task: ffff8800783b85c0 ti: ffff8800783bc000 task.ti: ffff8800783bc000
[   97.784015] RIP: 0010:[<ffffffffa011d108>]  [<ffffffffa011d108>] krb5_encrypt+0x138/0x1f0 [rpcsec_gss_krb5]
[   97.784015] RSP: 0018:ffff8800783bf898  EFLAGS: 00010282
[   97.784015] RAX: 0000000000000246 RBX: 1ffff1000f077f13 RCX: 0000000000000000
[   97.784015] RDX: 00000000000000a0 RSI: ffffea0001af0502 RDI: ffff8800783bf898
[   97.784015] RBP: ffff8800783bf950 R08: 0000000000000010 R09: ffff8800783bf908
[   97.784015] R10: 0000000000000028 R11: ffff88007a53c000 R12: ffff8800783bf8f8
[   97.784015] R13: ffff8800783bf898 R14: ffff8800783bf908 R15: ffff88007b2600a0
[   97.784015] FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[   97.784015] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   97.784015] CR2: 0000000000000226 CR3: 0000000002006000 CR4: 00000000000406f0
[   97.784015] Stack:
[   97.784015]  ffff880000000010 ffff8800783bf8f8 ffff8800783bf908 ffff8800783bf908
[   97.784015]  0000000000000246 00000000024000c0 0000000000000000 0000000000000000
[   97.784015]  0000000000000246 ffff880000000000 ffff88007c22e700 00000010783bf900
[   97.784015] Call Trace:
[   97.784015]  [<ffffffffa011e93f>] krb5_derive_key+0x27f/0x360 [rpcsec_gss_krb5]
[   97.784015]  [<ffffffffa011aa02>] gss_import_sec_context_kerberos+0x852/0xd50 [rpcsec_gss_krb5]
[   97.784015]  [<ffffffffa00a12ad>] gss_import_sec_context+0x7d/0xa0 [auth_rpcgss]
[   97.784015]  [<ffffffffa00a211f>] gss_proxy_save_rsc+0x19f/0x230 [auth_rpcgss]
[   97.784015]  [<ffffffffa00a2853>] svcauth_gss_proxy_init+0x4d3/0x630 [auth_rpcgss]
[   97.784015]  [<ffffffffa00a2385>] ? svcauth_gss_proxy_init+0x5/0x630 [auth_rpcgss]
[   97.784015]  [<ffffffffa00a4874>] svcauth_gss_accept+0x584/0xd40 [auth_rpcgss]
[   97.784015]  [<ffffffffa00a47a4>] ? svcauth_gss_accept+0x4b4/0xd40 [auth_rpcgss]
[   97.784015]  [<ffffffffa0019257>] svc_authenticate+0xf7/0x100 [sunrpc]
[   97.784015]  [<ffffffffa001514d>] svc_process_common+0x1ed/0x630 [sunrpc]
[   97.784015]  [<ffffffffa00156c5>] svc_process+0x135/0x390 [sunrpc]
[   97.784015]  [<ffffffffa00b4811>] nfsd+0x181/0x280 [nfsd]
[   97.784015]  [<ffffffffa00b4695>] ? nfsd+0x5/0x280 [nfsd]
[   97.784015]  [<ffffffffa00b4690>] ? nfsd_destroy+0x190/0x190 [nfsd]
[   97.784015]  [<ffffffff810a186f>] kthread+0xef/0x110
[   97.784015]  [<ffffffff81ae00c2>] ret_from_fork+0x22/0x40
[   97.784015]  [<ffffffff810a1780>] ?  kthread_create_on_node+0x200/0x200
[   97.784015] Code: 38 00 00 00 00 00 00 00 c7 04 dd 48 00 00 00 00 00 00 00 44 89 04 dd 00 00 00 00 4c 89 34 dd 10 00 00 00 4c 89 34 dd 18 00 00 00 <ff> 50 e0 41 89 c4 48 8b 04 dd 40 00 00 00 4c 89 ef 8b 70 f4 48 
[   97.784015] RIP  [<ffffffffa011d108>] krb5_encrypt+0x138/0x1f0 [rpcsec_gss_krb5]
[   97.784015]  RSP <ffff8800783bf898>
[   97.784015] CR2: 0000000000000226

