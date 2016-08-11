Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:36241 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbcHKQGq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2016 12:06:46 -0400
Received: by mail-qk0-f176.google.com with SMTP id l2so8994753qkf.3
        for <linux-nfs@vger.kernel.org>; Thu, 11 Aug 2016 09:06:45 -0700 (PDT)
Message-ID: <1470931603.30238.25.camel@redhat.com>
Subject: Re: CB_LAYOUTRECALL "deadlock" with in-kernel flexfiles server and
 XFS
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Thomas Haynes <loghyr@primarydata.com>, hch <hch@lst.de>,
        Fields Bruce James <bfields@fieldses.org>
Date: Thu, 11 Aug 2016 12:06:43 -0400
In-Reply-To: <CA55873C-4CF9-42F8-A35E-07C9CB685800@primarydata.com>
References: <1470929036.30238.14.camel@redhat.com>
	 <CA55873C-4CF9-42F8-A35E-07C9CB685800@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-08-11 at 15:55 +0000, Trond Myklebust wrote:
> > 
> > On Aug 11, 2016, at 11:23, Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > I was playing around with the in-kernel flexfiles server today, and
> > I
> > seem to be hitting a deadlock when using it on an XFS-exported
> > filesystem. Here's the stack trace of how the CB_LAYOUTRECALL
> > occurs:
> > 
> > [  928.736139] CPU: 0 PID: 846 Comm: nfsd Tainted:
> > G           OE   4.8.0-rc1+ #3
> > [  928.737040] Hardware name: QEMU Standard PC (i440FX + PIIX,
> > 1996), BIOS 1.9.1-1.fc24 04/01/2014
> > [  928.738009]  0000000000000286 000000006125f50e ffff91153845b878
> > ffffffff8f463853
> > [  928.738906]  ffff91152ec194d0 ffff91152d31d9c0 ffff91153845b8a8
> > ffffffffc045936f
> > [  928.739788]  ffff91152c051980 ffff91152d31d9c0 ffff91152c051540
> > ffff9115361b8a58
> > [  928.740697] Call Trace:
> > [  928.740998]  [<ffffffff8f463853>] dump_stack+0x86/0xc3
> > [  928.741570]  [<ffffffffc045936f>]
> > nfsd4_recall_file_layout+0x17f/0x190 [nfsd]
> > [  928.742380]  [<ffffffffc045939d>]
> > nfsd4_layout_lm_break+0x1d/0x30 [nfsd]
> > [  928.743115]  [<ffffffff8f3056d8>] __break_lease+0x118/0x6a0
> > [  928.743759]  [<ffffffffc02dea69>] xfs_break_layouts+0x79/0x120
> > [xfs]
> > [  928.744462]  [<ffffffffc029ea04>]
> > xfs_file_aio_write_checks+0x94/0x1f0 [xfs]
> > [  928.745251]  [<ffffffffc029f36b>]
> > xfs_file_buffered_aio_write+0x7b/0x330 [xfs]
> > [  928.746063]  [<ffffffffc029f70c>] xfs_file_write_iter+0xec/0x140
> > [xfs]
> > [  928.746803]  [<ffffffff8f2a0599>]
> > do_iter_readv_writev+0xb9/0x140
> > [  928.747478]  [<ffffffff8f2a126b>] do_readv_writev+0x19b/0x240
> > [  928.748146]  [<ffffffffc029f620>] ?
> > xfs_file_buffered_aio_write+0x330/0x330 [xfs]
> > [  928.748956]  [<ffffffff8f29e02b>] ? do_dentry_open+0x28b/0x310
> > [  928.749614]  [<ffffffffc029c800>] ?
> > xfs_extent_busy_ag_cmp+0x20/0x20 [xfs]
> > [  928.750367]  [<ffffffff8f2a156f>] vfs_writev+0x3f/0x50
> > [  928.750934]  [<ffffffffc04276ca>] nfsd_vfs_write+0xca/0x3a0
> > [nfsd]
> > [  928.751608]  [<ffffffffc0429ec5>] nfsd_write+0x485/0x780 [nfsd]
> > [  928.752263]  [<ffffffffc043144c>] nfsd3_proc_write+0xbc/0x150
> > [nfsd]
> > [  928.752973]  [<ffffffffc0421388>] nfsd_dispatch+0xb8/0x1f0
> > [nfsd]
> > [  928.753642]  [<ffffffffc036d78f>] svc_process_common+0x42f/0x690
> > [sunrpc]
> > [  928.754395]  [<ffffffffc036e8e8>] svc_process+0x118/0x330
> > [sunrpc]
> > [  928.755080]  [<ffffffffc04208ac>] nfsd+0x19c/0x2b0 [nfsd]
> > [  928.755681]  [<ffffffffc0420715>] ? nfsd+0x5/0x2b0 [nfsd]
> > [  928.756274]  [<ffffffffc0420710>] ? nfsd_destroy+0x190/0x190
> > [nfsd]
> > [  928.756991]  [<ffffffff8f0d5891>] kthread+0x101/0x120
> > [  928.757563]  [<ffffffff8f10dcc5>] ?
> > trace_hardirqs_on_caller+0xf5/0x1b0
> > [  928.758282]  [<ffffffff8f8f2fef>] ret_from_fork+0x1f/0x40
> > [  928.758875]  [<ffffffff8f0d5790>] ?
> > kthread_create_on_node+0x250/0x250
> > 
> > 
> > So the client gets a flexfiles layout, and then tries to issue a v3
> > WRITE against the file. XFS then recalls the layout, but the client
> > can't return the layout until the v3 WRITE completes. Eventually
> > this
> > should resolve itself after 2 lease periods, but that's quite a
> > long
> > time.
> 
> What’s the sequence of operations here? If the client has outstanding
> I/O, I should now be returning NFS_OK, and then completing the recall
> with a LAYOUTRETURN as soon as the outstanding I/O (and layoutcommit,
> if one is due) is done.
> 
> The server is expected to return NFS4ERR_RECALLCONFLICT to any
> LAYOUTGET attempts that occur before the LAYOUTRETURN.
> 

Basically, I'm just doing this on the client:

    $ echo "foo" > /mnt/knfsdsrv/testfile


The client does:

OPEN
LAYOUTGET (for RW)
GETDEVICEINFO

...and then a v3 WRITE under the aegis of the layout it got.

The server then issues a CB_LAYOUTRECALL (because XFS wants to do that
whenever there is a local write, apparently). The client returns
NFS_OK, but it can't return the layout until the v3 WRITE completes.
The v3 write is hung though because it's waiting for the layout to be
returned.

> > 
> > 
> > I guess XFS requires recalling block and SCSI layouts when the
> > server
> > wants to issue a write (or someone writes to it locally), but that
> > seems like it shouldn't be happening when the layout is a flexfiles
> > layout.
> > 
> > Any thoughts on what the right fix is here?
> > 
> > On a related note, knfsd will spam the heck out of the client with
> > CB_LAYOUTRECALLs during this time. I think we ought to consider
> > fixing
> > the server not to treat an NFS_OK return from the client like
> > NFS4ERR_DELAY there, but that would mean a different mechanism for
> > timing out a CB_LAYOUTRECALL.
> 
> There is a big difference between NFS_OK and NFS4ERR_DELAY as far as
> the server is concerned:
> 
> - NFS_OK means that the client has now seen the stateid with the
> updated sequence id that was sent in CB_LAYOUTRECALL, and is
> processing it. No resend of the CB_LAYOUTRECALL is required.
> - OTOH, NFS4ERR_DELAY means the same thing in the back channel as it
> does in the forward channel: I’m busy and cannot process your
> request, please resend it later.

Right. The current code basically just treats them the same as a
mechanism to handle eventually timing out the layoutrecall. The extra
CB_LAYOUTRECALLs are entirely superfluous. It's probably not too hard
to fix, but we'd need to come up with some other mechanism for timing
out the layoutrecall.

-- 
Jeff Layton <jlayton@redhat.com>
