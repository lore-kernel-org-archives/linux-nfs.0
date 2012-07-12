Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39740 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225Ab2GLMjR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jul 2012 08:39:17 -0400
Date: Thu, 12 Jul 2012 08:39:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
Message-ID: <20120712123916.GB16822@fieldses.org>
References: <1337983796-26476-1-git-send-email-simo@redhat.com>
 <20120710204913.GA6038@fieldses.org>
 <20120710210511.GB6038@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120710210511.GB6038@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 10, 2012 at 05:05:11PM -0400, J. Bruce Fields wrote:
> On Tue, Jul 10, 2012 at 04:49:13PM -0400, bfields wrote:
> > On Fri, May 25, 2012 at 06:09:52PM -0400, Simo Sorce wrote:
> > > This patchset implements a new upcall mechanism that uses the sunrpc
> > > client to talk to gssproxy[1], a new userspace daemon that handles gssapi
> > > operations on behalf of other processes on the system.
> > > 
> > > The main driver for this new mechanism is to overcome limitations with
> > > the current daemon and upcall. The current code cannot handle tickets
> > > larger than approximatively 2k and cannot handle sending back large user
> > > credential sets to the kernel.
> > > 
> > > These patches have been tested against the development version of gssproxy
> > > tagged as kernel_v0.1 in the master repo[2].
> > > 
> > > I have tested walking into mountpoints using tickets artificially pumped
> > > up to 64k and the user is properly authorized, after the accept_se_context
> > > call is performed through the new upcall mechanism and gssproxy.
> > > 
> > > The gssproxy has the potential of handling also init_sec_context calls,
> > > but at the moment the only targeted system is nfsd.
> > 
> > OK, absent objections from anyone else I'm commiting these for 3.6 and
> > pushing them out soon pending some regression testing.  Thanks!
> 
> Whoops, I spoke too soon.  I'll take a quick look tomorrow, but if you
> have an idea that would be great....
> 
> The code I'm running is in
> 
> 	git://linux-nfs.org/~bfields/linux-topics.git for-3.6-incoming
> 
> Looks like the BUG() case in gss_get_mic_kerberos(), so ctx->enctype is
> bogus--maybe a context isn't getting initialized right?

And this is reproduceable after applying the first patch ("conditionally
return endtime...") but not before.  The patch seems obviously innocent,
but maybe my eyes are playing tricks on me.

--b.

> 
> --b.
> 
> kernel BUG at net/sunrpc/auth_gss/gss_krb5_seal.c:213!
> invalid opcode: 0000 [#1] PREEMPT SMP 
> CPU 1 
> Modules linked in: rpcsec_gss_krb5 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi nfsd lockd nfs_acl auth_rpcgss sunrpc [last unloaded: scsi_wait_scan]
> 
> Pid: 4924, comm: nfsd Not tainted 3.5.0-rc3-00104-g3521b3f #14 Bochs Bochs
> RIP: 0010:[<ffffffffa00e4076>]  [<ffffffffa00e4076>] gss_get_mic_kerberos+0x26/0x310 [rpcsec_gss_krb5]
> RSP: 0018:ffff880035ed9aa0  EFLAGS: 00010202
> RAX: ffffffffa00e7e20 RBX: ffff8800392398f8 RCX: ffff880032c53000
> RDX: ffff880035ed9ba0 RSI: ffff880035ed9b50 RDI: ffff880036ffd8b8
> RBP: ffff880035ed9b30 R08: 0000000000000000 R09: ffff8800391afb20
> R10: 0000000000000000 R11: 0000000000000001 R12: ffff880032c53014
> R13: ffff880035ed9ba0 R14: ffff880035ed9b50 R15: ffff880036ffd8b8
> FS:  0000000000000000(0000) GS:ffff88003fc80000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007f0a38b45000 CR3: 0000000032cc8000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process nfsd (pid: 4924, threadinfo ffff880035ed8000, task ffff88003b326040)
> Stack:
>  ffff880035ed9b10 ffffffffa001c163 0000000000000004 ffff880035f365b0
>  0000000000015240 00000000000000c0 000000004ffc95c7 0000000000000000
>  ffff880035e8adf0 ffff880035ed9b20 ffff88003beecda8 ffff880035f36590
> Call Trace:
>  [<ffffffffa001c163>] ? cache_check+0x73/0x380 [sunrpc]
>  [<ffffffffa0056bd3>] gss_get_mic+0x13/0x20 [auth_rpcgss]
>  [<ffffffffa0058255>] gss_write_verf+0x95/0x110 [auth_rpcgss]
>  [<ffffffffa00593bb>] svcauth_gss_legacy_init+0x24b/0x5f0 [auth_rpcgss]
>  [<ffffffffa0059170>] ? svcauth_gss_register_pseudoflavor+0xc0/0xc0 [auth_rpcgss]
>  [<ffffffffa005a1f1>] svcauth_gss_accept+0x501/0xa90 [auth_rpcgss]
>  [<ffffffffa0059cf0>] ? svcauth_gss_proxy_init+0x590/0x590 [auth_rpcgss]
>  [<ffffffffa0013aca>] ? svc_authenticate+0x5a/0xe0 [sunrpc]
>  [<ffffffffa0013aca>] ? svc_authenticate+0x5a/0xe0 [sunrpc]
>  [<ffffffffa0013b36>] svc_authenticate+0xc6/0xe0 [sunrpc]
>  [<ffffffffa000f57d>] svc_process_common+0x20d/0x690 [sunrpc]
>  [<ffffffff81079750>] ? try_to_wake_up+0x330/0x330
>  [<ffffffffa0087bd0>] ? nfsd_svc+0x230/0x230 [nfsd]
>  [<ffffffffa000fd50>] svc_process+0x110/0x160 [sunrpc]
>  [<ffffffffa0087c8d>] nfsd+0xbd/0x1a0 [nfsd]
>  [<ffffffffa0087bd0>] ? nfsd_svc+0x230/0x230 [nfsd]
>  [<ffffffff8106675e>] kthread+0x9e/0xb0
>  [<ffffffff819af494>] kernel_thread_helper+0x4/0x10
>  [<ffffffff819a735d>] ? retint_restore_args+0xe/0xe
>  [<ffffffff810666c0>] ? __init_kthread_worker+0x70/0x70
>  [<ffffffff819af490>] ? gs_change+0xb/0xb
> Code: fe ff ff 90 90 55 48 89 e5 41 57 41 56 41 55 41 54 53 48 83 ec 68 66 66 66 66 90 48 8b 5f 08 49 89 f6 49 89 d5 83 7b 04 17 76 04 <0f> 0b eb fe 48 63 4b 04 b8 01 00 00 00 48 d3 e0 a9 50 00 80 00 
> RIP  [<ffffffffa00e4076>] gss_get_mic_kerberos+0x26/0x310 [rpcsec_gss_krb5]
>  RSP <ffff880035ed9aa0>
> ---[ end trace 797c56ca0aa53457 ]---
