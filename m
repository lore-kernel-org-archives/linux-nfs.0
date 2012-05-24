Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52217 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753939Ab2EXU1X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 May 2012 16:27:23 -0400
Date: Thu, 24 May 2012 16:27:20 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Dave Jones <davej@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: 3.4. sunrpc oops during shutdown
Message-ID: <20120524202720.GB23577@fieldses.org>
References: <20120521171411.GA15562@redhat.com>
 <1337623475.9583.13.camel@lade.trondhjem.org>
 <20120524155531.GA21776@fieldses.org>
 <1337887245.3054.21.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337887245.3054.21.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 24, 2012 at 07:20:41PM +0000, Myklebust, Trond wrote:
> On Thu, 2012-05-24 at 11:55 -0400, bfields@fieldses.org wrote:
> > On Mon, May 21, 2012 at 06:03:43PM +0000, Myklebust, Trond wrote:
> > > On Mon, 2012-05-21 at 13:14 -0400, Dave Jones wrote:
> > > > Tried to shutdown a machine, got this, and a bunch of hung processes.
> > > > There was one NFS mount mounted at the time.
> > > > 
> > > > 	Dave
> > > > 
> > > > BUG: unable to handle kernel NULL pointer dereference at 0000000000000028
> > > > IP: [<ffffffffa01191df>] svc_destroy+0x1f/0x140 [sunrpc]
> > > > PGD 1434c4067 PUD 144964067 PMD 0 
> > > > Oops: 0000 [#1] PREEMPT SMP 
> > > > CPU 4 
> > > > Modules linked in: ip6table_filter(-) ip6_tables nfsd nfs fscache auth_rpcgss nfs_acl lockd ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6
> > > > 
> > > > Pid: 6946, comm: ntpd Not tainted 3.4.0+ #13 
> > > > RIP: 0010:[<ffffffffa01191df>]  [<ffffffffa01191df>] svc_destroy+0x1f/0x140 [sunrpc]
> > > > RSP: 0018:ffff880143c65c48  EFLAGS: 00010286
> > > > RAX: 0000000000000000 RBX: ffff880142cd41a0 RCX: 0000000000000006
> > > > RDX: 0000000000000040 RSI: ffff880143105028 RDI: ffff880142cd41a0
> > > > RBP: ffff880143c65c58 R08: 0000000000000000 R09: 0000000000000001
> > > > R10: 0000000000000000 R11: 0000000000000000 R12: ffff88013bc5a148
> > > > R13: ffff880140981658 R14: ffff880142cd41a0 R15: ffff880146c88000
> > > > FS:  00007fdc0382a740(0000) GS:ffff880149400000(0000) knlGS:0000000000000000
> > > > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > CR2: 0000000000000028 CR3: 0000000036cbb000 CR4: 00000000001407e0
> > > > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > > > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > > > Process ntpd (pid: 6946, threadinfo ffff880143c64000, task ffff880143104940)
> > > > Stack:
> > > >  ffff880140981660 ffff88013bc5a148 ffff880143c65c88 ffffffffa01193a6
> > > >  0000000000000000 ffff88013e566020 ffff88013e565f28 ffff880146ee6ac0
> > > >  ffff880143c65ca8 ffffffffa024f403 ffff880143c65ca8 ffff880143d3a4f8
> > > > Call Trace:
> > > >  [<ffffffffa01193a6>] svc_exit_thread+0xa6/0xb0 [sunrpc]
> > > >  [<ffffffffa024f403>] nfs_callback_down+0x53/0x90 [nfs]
> > > >  [<ffffffffa021642e>] nfs_free_client+0xfe/0x120 [nfs]
> > > >  [<ffffffffa02185df>] nfs_put_client+0x29f/0x420 [nfs]
> > > >  [<ffffffffa02184e0>] ? nfs_put_client+0x1a0/0x420 [nfs]
> > > >  [<ffffffffa021962f>] nfs_free_server+0x16f/0x2e0 [nfs]
> > > >  [<ffffffffa02194e3>] ? nfs_free_server+0x23/0x2e0 [nfs]
> > > >  [<ffffffffa022363c>] nfs4_kill_super+0x3c/0x50 [nfs]
> > > >  [<ffffffff811ad67c>] deactivate_locked_super+0x3c/0xa0
> > > >  [<ffffffff811ae29e>] deactivate_super+0x4e/0x70
> > > >  [<ffffffff811ccba4>] mntput_no_expire+0xb4/0x100
> > > >  [<ffffffff811ccc16>] mntput+0x26/0x40
> > > >  [<ffffffff811cd597>] release_mounts+0x77/0x90
> > > >  [<ffffffff811cefc6>] put_mnt_ns+0x66/0x80
> > > >  [<ffffffff81078dff>] free_nsproxy+0x1f/0xb0
> > > >  [<ffffffff8107905e>] switch_task_namespaces+0x5e/0x70
> > > >  [<ffffffff81079080>] exit_task_namespaces+0x10/0x20
> > > >  [<ffffffff8104e90e>] do_exit+0x4ee/0xb80
> > > >  [<ffffffff81639c0a>] ? retint_swapgs+0xe/0x13
> > > >  [<ffffffff8104f2ef>] do_group_exit+0x4f/0xc0
> > > >  [<ffffffff8104f377>] sys_exit_group+0x17/0x20
> > > >  [<ffffffff81641352>] system_call_fastpath+0x16/0x1b
> > > > Code: 48 8b 5d f0 4c 8b 65 f8 c9 c3 66 90 55 48 89 e5 41 54 53 66 66 66 66 90 65 48 8b 04 25 80 ba 00 00 48 8b 80 50 05 00 00 48 89 fb <4c> 8b 60 28 8b 47 58 85 c0 0f 84 ec 00 00 00 83 e8 01 85 c0 89 
> > > 
> > > Aside from the fact that the current net_namespace is not guaranteed to
> > > exist when we are called from free_nsproxy, svc_destroy() looks
> > > seriously broken:
> > > 
> > >       * On the one hand it is trying to free struct svc_serv (and
> > >         presumably all structures owned by struct svc_serv).
> > >       * On the other hand, it tries to pass a parameter to
> > >         svc_close_net() saying "please don't free structures on my
> > >         sv_tempsocks, or sv_permsocks list unless they match this net
> > >         namespace".
> > > 
> > > Bruce, how is this supposed to be working?
> > 
> > Yeah, I don't know.
> > 
> > For the nfs callback case, it looks like you've just got a single 
> > callback service shared across all namespaces, and all you want to do 
> > is destroy that whole thing on last put; or is it more complicated than
> > that?
> 
> For NFSv4, I need to create sockets for the same net namespace as the
> struct nfs_client is running in. When all the struct nfs_clients on that
> net namespace are destroyed, I would ideally get rid of those sockets.
> 
> For NFSv4.1, all I want to do is create a back channel using the same
> socket as the struct nfs_client.

Thanks, makes sense.

Uh, I meant to cc: Stanislav on that last reply but didn't somehow.

--b.

> 
> > For the other servers at least the per-net and global parts of the 
> > server seem too entangled.
> > 
> > That's unavoidable to some degree since we're sharing threads among the
> > namespaces.  But maybe separate structures for the per-namespace and
> > global pieces would help.
> > 
> > At a minimum the per-namespace piece would keep a count of the users in
> > that namespace.
> > 
> > To make the shutdown race-free I think we also need a way to wait for
> > all threads processing requests in that namespace, which I don't see
> > that we have yet.
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
