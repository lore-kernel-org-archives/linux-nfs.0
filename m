Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46102 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752355AbcJWUO7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 23 Oct 2016 16:14:59 -0400
Date: Sun, 23 Oct 2016 16:14:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: upstream server crash
Message-ID: <20161023201457.GA15697@fieldses.org>
References: <20161023182115.GA14481@fieldses.org>
 <049933C2-AACE-4768-BC1F-B1DA7A9E2B4D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <049933C2-AACE-4768-BC1F-B1DA7A9E2B4D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 23, 2016 at 04:04:47PM -0400, Chuck Lever wrote:
> 
> > On Oct 23, 2016, at 2:21 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > I'm getting an intermittent crash in the nfs server as of
> > 68778945e46f143ed7974b427a8065f69a4ce944 "SUNRPC: Separate buffer
> > pointers for RPC Call and Reply messages".
> > 
> > I haven't tried to understand that commit or why it would be a problem yet, I
> > don't see an obvious connection--I can take a closer look Monday.
> 
> I don't see anything in the backtrace that connects to the
> client. However, if the client was involved indirectly (say,
> with NFSv3 NLM callbacks, maybe?) it could have overwritten
> memory that was in use by the server.

The crashes are consistently happening only over 4.1, so backchannel
code seems more likely.  (There were also v3 tests run earlier on the
same machine.)

> What happens if you enable SLAB debugging?

I have CONFIG_DEBUG_SLAB set.  I haven't seen any warnings.

> > Could even be that I just landed on this commit by chance, the problem is a
> > little hard to reproduce so I don't completely trust my testing.
> 
> Can you describe what your testing does?

I've seen this both in some posix locking tests and in what I believe is
an xfs fsstress run.  I haven't looked more closely than that.

--b.

> 
> 
> > --b.
> > 
> > BUG: unable to handle kernel NULL pointer dereference at           (null)
> > IP: [<ffffffff816937d2>] __memcpy+0x12/0x20
> > PGD 0
> > Oops: 0002 [#1] PREEMPT SMP
> > Modules linked in: rpcsec_gss_krb5 nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc
> > CPU: 0 PID: 4437 Comm: nfsd Not tainted 4.9.0-rc1-00075-gae0340c #766
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.1-1.fc24 04/01/2014
> > task: ffff88006d810d40 task.stack: ffffc90000644000
> > RIP: 0010:[<ffffffff816937d2>]  [<ffffffff816937d2>] __memcpy+0x12/0x20
> > RSP: 0018:ffffc90000647d60  EFLAGS: 00010202
> > RAX: 0000000000000000 RBX: ffff88007b5ca000 RCX: 000000000000000a
> > RDX: 0000000000000004 RSI: ffff88007bab7000 RDI: 0000000000000000
> > RBP: ffffc90000647db8 R08: 0000000000000001 R09: 0000000000000000
> > R10: 0000000000000000 R11: 0000000000000000 R12: ffff880078535000
> > R13: ffff880035d02000 R14: ffff88007b4775b0 R15: ffff88007b477000
> > FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 0000000000000000 CR3: 00000000787de000 CR4: 00000000000406f0
> > Stack:
> > ffffffffa00191ab ffff88006d810d40 ffff880001000000 ffff88007b435a00
> > ffff880078535378 0000000000000004 ffff880078535000 0000000078535000
> > ffff88007b5ca000 0000000000000000 ffffffffa0028626 ffffc90000647e30
> > Call Trace:
> > [<ffffffffa00191ab>] ? svc_tcp_recvfrom+0x6eb/0x820 [sunrpc]
> > [<ffffffffa0028626>] ? svc_recv+0x1e6/0xf00 [sunrpc]
> > [<ffffffffa0029240>] svc_recv+0xe00/0xf00 [sunrpc]
> > [<ffffffffa00b57ff>] nfsd+0x16f/0x280 [nfsd]
> > [<ffffffffa00b5695>] ? nfsd+0x5/0x280 [nfsd]
> > [<ffffffffa00b5690>] ? nfsd_destroy+0x190/0x190 [nfsd]
> > [<ffffffff810a6c00>] kthread+0xf0/0x110
> > [<ffffffff810a6b10>] ? kthread_park+0x60/0x60
> > [<ffffffff81b39607>] ret_from_fork+0x27/0x40
> > Code: c3 e8 53 fb ff ff 48 8b 43 60 48 2b 43 50 88 43 4e 5b 5d eb ea 90 90 90 90 66 66 90 66 90 48 89 f8 48 89 d1 48 c1 e9 03 83 e2 07 <f3> 48 a5 89 d1 f3 a4 c3 66 0f 1f 44 00 00 48 89 f8 48 89 d1 f3
> > RIP  [<ffffffff816937d2>] __memcpy+0x12/0x20
> > RSP <ffffc90000647d60>
> > CR2: 0000000000000000
> > 
> 
> --
> Chuck Lever
> 
> 
