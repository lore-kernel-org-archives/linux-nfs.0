Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62541 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751599Ab2LEPWX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Dec 2012 10:22:23 -0500
Date: Wed, 5 Dec 2012 10:22:19 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Bernd Schubert <bernd.schubert@fastmail.fm>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 3.5.3: NULL pointer dereference in svc_destroy()
Message-ID: <20121205102219.46b22869@corrin.poochiereds.net>
In-Reply-To: <504F380D.3040408@fastmail.fm>
References: <504F380D.3040408@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 11 Sep 2012 15:09:33 +0200
Bernd Schubert <bernd.schubert@fastmail.fm> wrote:

> Somehow one of my test VMs decided to start nfsd, which didn't work as 
> it was not configured properly for that VM at all.
> But that resulted in a NULL pointer dereference:
> 
> >   203.319525] svc: failed to register nfsdv2 RPC service (errno 111).
> > [  203.320396] nfsd: last server has exited, flushing export cache
> > [  203.320666] BUG: unable to handle kernel NULL pointer dereference at 0000000000000058
> > [  203.321132] IP: [<ffffffffa017c06e>] svc_destroy+0xe/0x120 [sunrpc]
> > [  203.321430] PGD cfa0067 PUD 33ad1067 PMD 0
> > [  203.321776] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> > [  203.322129] CPU 0
> > [  203.322203] Modules linked in: ipv6 nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc pcspkr 8250_pnp ext4 mbcache jbd2 crc16 crypto_hash crypto_algapi virtio_blk virtio_net ata_generic pata_acpi libata virtio_pci virtio_ring virtio scsi_mod unix [last unloaded: fhgfs_client_opentk]
> > [  203.324013]
> > [  203.324013] Pid: 1357, comm: rpc.nfsd Tainted: G           O 3.5.3-debug #25 Bochs Bochs
> > [  203.324013] RIP: 0010:[<ffffffffa017c06e>]  [<ffffffffa017c06e>] svc_destroy+0xe/0x120 [sunrpc]
> > [  203.324013] RSP: 0018:ffff880026ad3e08  EFLAGS: 00010292
> > [  203.324013] RAX: 00000000ffffff91 RBX: ffff880026ae2008 RCX: 0000000000000100
> > [  203.324013] RDX: 000000000000007f RSI: 0000000000000001 RDI: 0000000000000000
> > [  203.324013] RBP: ffff880026ad3e18 R08: 0000000000000000 R09: 0000000000000000
> > [  203.324013] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000004
> > [  203.324013] R13: 0000000000000002 R14: ffff880028842680 R15: 00007fff03c6562c
> > [  203.324013] FS:  00007f25f7dbe700(0000) GS:ffff88003de00000(0000) knlGS:0000000000000000
> > [  203.324013] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [  203.324013] CR2: 0000000000000058 CR3: 0000000026b32000 CR4: 00000000000406f0
> > [  203.324013] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > [  203.324013] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > [  203.324013] Process rpc.nfsd (pid: 1357, threadinfo ffff880026ad2000, task ffff8800347f0000)
> > [  203.324013] Stack:
> > [  203.324013]  ffff880026ae2008 ffff880026ae2008 ffff880026ad3e98 ffffffffa0272e3a
> > [  203.324013]  2222222222222222 22222222ffffff91 2222222222220034 2222222222222222
> > [  203.324013]  ffff880026ad3e78 ffffffffa029c000 0000000000000000 0000000000000002
> > [  203.324013] Call Trace:
> > [  203.324013]  [<ffffffffa0272e3a>] __write_ports+0xfa/0x260 [nfsd]
> > [  203.324013]  [<ffffffffa0272fde>] write_ports+0x3e/0x60 [nfsd]
> > [  203.324013]  [<ffffffffa0272fa0>] ? __write_ports+0x260/0x260 [nfsd]
> > [  203.324013]  [<ffffffffa02726f7>] nfsctl_transaction_write+0x57/0x90 [nfsd]
> > [  203.324013]  [<ffffffff811944fa>] vfs_write+0xca/0x170
> > [  203.324013]  [<ffffffff81194684>] sys_write+0x54/0x90
> > [  203.324013]  [<ffffffff814195a9>] system_call_fastpath+0x16/0x1b
> > [  203.324013] Code: 03 83 10 01 00 00 4c 8b 64 24 08 48 8b 1c 24 c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 53 48 83 ec 08 66 66 66 66 90 <8b> 47 58 48 89 fb 85 c0 74 14 83 e8 01 85 c0 89 47 58 74 1e e8
> > [  203.324013] RIP  [<ffffffffa017c06e>] svc_destroy+0xe/0x120 [sunrpc]
> > [  203.324013]  RSP <ffff880026ad3e08>
> > [  203.324013] CR2: 0000000000000058
> > [  203.337749] ---[ end trace 254f20c7dc1cafb9 ]---
> 
> 
> (gdb) l *(svc_destroy+0xe)
> 0xe06e is in svc_destroy (net/sunrpc/svc.c:544).
> 539     {
> 540             dprintk("svc: svc_destroy(%s, %d)\n",
> 541                                     serv->sv_program->pg_name,
> 542                                     serv->sv_nrthreads);
> 543
> 544             if (serv->sv_nrthreads) {
> 545                     if (--(serv->sv_nrthreads) != 0) {
> 546                             svc_sock_update_bufs(serv);
> 547                             return;
> 548                     }
> 
> 
> So 'serv' given as argument to svc_destroy() is NULL.
> 
> gdb) l *(__write_ports+0xfa)
> 0x1e3a is in __write_ports (fs/nfsd/nfsctl.c:679).
> 674             err = svc_addsock(nfsd_serv, fd, buf, 
> SIMPLE_TRANSACTION_LIMIT);
> 675             if (err < 0) {
> 676                     if (nfsd_serv->sv_nrthreads == 1)
> 677                             svc_shutdown_net(nfsd_serv, net);
> 678                     svc_destroy(nfsd_serv);
> 679                     return err;
> 680             }
> 681
> 682             /* Decrease the count, but don't shut down the service */
> 683             nfsd_serv->sv_nrthreads--;
> 
> (Line 679 is in __write_ports_addfd() ).
> 
> I'm not sure, but is there a svc_get() missing in nfsd_create_serv()?
> 
> 
> Cheers,
> Bernd
> 

Hi Bernd,

Sorry for the late response. I just chased down a similar bug reported
against Fedora and noticed that you reported the same bug here. In
fact, there is not a missing svc_get() there since svc_create_pooled
returns a reference on success. The problem is likely that we're
calling svc_destroy(nfsd_serv) in the above code, but the pointer is
not getting NULL'ed out.

The good news is that I believe this is fixed in 3.6 kernels and up...

I have a bit more analysis here if you're interested:

    https://bugzilla.redhat.com/show_bug.cgi?id=848867#c5

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
