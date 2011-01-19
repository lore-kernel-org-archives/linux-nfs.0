Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33071 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751644Ab1ASXbu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jan 2011 18:31:50 -0500
Subject: Re: [PATCH] NFS: Fix "BUG at fs/aio.c:554!"
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nick Piggin <npiggin@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wen.gang.wang@oracle.com
In-Reply-To: <AANLkTikRX8nxh-gp=Fdr21dg-DLmUb2FxYXrM2A0hfN0@mail.gmail.com>
References: <20110119223543.30706.10304.stgit@matisse.1015granger.net>
	 <1295479517.22151.16.camel@heimdal.trondhjem.org>
	 <AANLkTikRX8nxh-gp=Fdr21dg-DLmUb2FxYXrM2A0hfN0@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 19 Jan 2011 18:31:40 -0500
Message-ID: <1295479900.22151.19.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-01-20 at 10:26 +1100, Nick Piggin wrote: 
> On Thu, Jan 20, 2011 at 10:25 AM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Wed, 2011-01-19 at 17:36 -0500, Chuck Lever wrote:
> >> Nick Piggin reports:
> >>
> >> > I'm getting use after frees in aio code in NFS
> >> >
> >> > [ 2703.396766] Call Trace:
> >> > [ 2703.396858]  [<ffffffff8100b057>] ? native_sched_clock+0x27/0x80
> >> > [ 2703.396959]  [<ffffffff8108509e>] ? put_lock_stats+0xe/0x40
> >> > [ 2703.397058]  [<ffffffff81088348>] ? lock_release_holdtime+0xa8/0x140
> >> > [ 2703.397159]  [<ffffffff8108a2a5>] lock_acquire+0x95/0x1b0
> >> > [ 2703.397260]  [<ffffffff811627db>] ? aio_put_req+0x2b/0x60
> >> > [ 2703.397361]  [<ffffffff81039701>] ? get_parent_ip+0x11/0x50
> >> > [ 2703.397464]  [<ffffffff81612a31>] _raw_spin_lock_irq+0x41/0x80
> >> > [ 2703.397564]  [<ffffffff811627db>] ? aio_put_req+0x2b/0x60
> >> > [ 2703.397662]  [<ffffffff811627db>] aio_put_req+0x2b/0x60
> >> > [ 2703.397761]  [<ffffffff811647fe>] do_io_submit+0x2be/0x7c0
> >> > [ 2703.397895]  [<ffffffff81164d0b>] sys_io_submit+0xb/0x10
> >> > [ 2703.397995]  [<ffffffff8100307b>] system_call_fastpath+0x16/0x1b
> >> >
> >> > Adding some tracing, it is due to nfs completing the request then
> >> > returning something other than -EIOCBQUEUED, so aio.c
> >> > also completes the request.
> >>
> >> To address this, prevent the NFS direct I/O engine from completing
> >> async iocbs when the forward path returns an error other than
> >> EIOCBQUEUED.
> >>
> >> This appears to survive ^C during both "xfstest no. 208" and "fsx -Z."
> >>
> >> Cc: Stable <stable@kernel.org>
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >>
> >> Here's my take.
> >>
> >>  fs/nfs/direct.c |   32 +++++++++++++++++---------------
> >>  1 files changed, 17 insertions(+), 15 deletions(-)
> >>
> >> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> >> index e6ace0d..c2176f4 100644
> >> --- a/fs/nfs/direct.c
> >> +++ b/fs/nfs/direct.c
> >> @@ -407,15 +407,16 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
> >>               pos += vec->iov_len;
> >>       }
> >>
> >> -     if (put_dreq(dreq))
> >> -             nfs_direct_complete(dreq);
> >> -
> >> -     if (requested_bytes != 0)
> >> -             return 0;
> >> +     /*
> >> +      * If no bytes were started, return the error, and let the
> >> +      * generic layer handle the completion.
> >> +      */
> >> +     if (requested_bytes == 0)
> >> +             return result < 0 ? result : -EIO;
> >>
> >> -     if (result < 0)
> >> -             return result;
> >> -     return -EIO;
> >> +     if (put_dreq(dreq))
> >> +             nfs_direct_write_complete(dreq, dreq->inode);
> >                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > In nfs_direct_read_schedule_iovec()? Shouldn't that be
> >                nfs_direct_complete(dreq);
> >
> > Also, why is EIO the correct reply when no bytes were read/written? Why
> > shouldn't the VFS aio code be able to cope with a zero byte reply?
> 
> What would it do?

Just return that zero byte reply to userland.

zero bytes is a valid reply for ordinary read() and write(), so why
should we have to do anything different for aio_read()/aio_write()?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

