Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42435 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753206Ab1HBC3s convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2011 22:29:48 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH v4 00/27] add block layout driver to pnfs client
Date: Mon, 1 Aug 2011 19:29:30 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778575@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20110802022144.GA18157@merit.edu>
References: <1311874276-1386-1-git-send-email-rees@umich.edu> <20110729155136.GB28306@infradead.org> <20110729185415.GA23061@merit.edu> <20110729190133.GA10946@infradead.org> <20110729191341.GC23061@merit.edu> <1311988172.16078.15.camel@lade.trondhjem.org> <20110730032621.GB25188@merit.edu> <CA+a=Yy5rmvrUHaDewLb_EbeaDYMKL_xv_E_MmzTvR_55SmYkqA@mail.gmail.com> <1312233006.23392.17.camel@lade.trondhjem.org> <1312238117.23392.19.camel@lade.trondhjem.org> <20110802022144.GA18157@merit.edu>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Jim Rees" <rees@umich.edu>
Cc: "Peng Tao" <bergwolf@gmail.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "Christoph Hellwig" <hch@infradead.org>, <linux-nfs@vger.kernel.org>,
        "peter honeyman" <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Jim Rees [mailto:rees@umich.edu]
> Sent: Monday, August 01, 2011 10:22 PM
> To: Myklebust, Trond
> Cc: Peng Tao; Adamson, Andy; Christoph Hellwig; linux-
> nfs@vger.kernel.org; peter honeyman
> Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
> 
> Trond Myklebust wrote:
> 
>   On Mon, 2011-08-01 at 17:10 -0400, Trond Myklebust wrote:
>   > Looking at the callback code, I see that if tbl-
> >highest_used_slotid !=
>   > 0, then we BUG() while holding the backchannel's
tbl->slot_tbl_lock
>   > spinlock. That seems a likely candidate for the above hang.
>   >
>   > Andy, how we are guaranteed that tbl->highest_used_slotid won't
> take
>   > values other than 0, and why do we commit suicide when it does? As
> far
>   > as I can see, there is no guarantee that we call
> nfs4_cb_take_slot() in
>   > nfs4_callback_compound(), however we appear to unconditionally
call
>   > nfs4_cb_free_slot() provided there is a session.
>   >
>   > The other strangeness would be the fact that there is nothing
> enforcing
>   > the NFS4_SESSION_DRAINING flag. If the session is draining, then
> the
>   > back-channel simply ignores that and goes ahead with processing
the
>   > callback. Is this to avoid deadlocks with the server returning
>   > NFS4ERR_BACK_CHAN_BUSY when the client does a DESTROY_SESSION?
> 
>   How about something like the following?
> 
> I applied this patch, along with Andy's htonl correction.  It now
fails
> in a
> different way, with a deadlock.  The test runs several processes in
> parallel.
> 
> INFO: task t_mtab:1767 blocked for more than 10 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
> message.
> t_mtab          D 0000000000000000     0  1767   1634 0x00000080
>  ffff8800376afd48 0000000000000086 ffff8800376afcd8 ffffffff00000000
>  ffff8800376ae010 ffff880037ef4500 0000000000012c80 ffff8800376affd8
>  ffff8800376affd8 0000000000012c80 ffffffff81a0c020 ffff880037ef4500
> Call Trace:
>  [<ffffffff8145411a>] __mutex_lock_common+0x110/0x171
>  [<ffffffff81454191>] __mutex_lock_slowpath+0x16/0x18
>  [<ffffffff81454257>] mutex_lock+0x1e/0x32
>  [<ffffffff811169a2>] kern_path_create+0x75/0x11e
>  [<ffffffff810fe836>] ? kmem_cache_alloc+0x5f/0xf1
>  [<ffffffff812127d9>] ? strncpy_from_user+0x43/0x72
>  [<ffffffff81114077>] ? getname_flags+0x158/0x1d2
>  [<ffffffff81116a86>] user_path_create+0x3b/0x52
>  [<ffffffff81117466>] sys_linkat+0x9a/0x120
>  [<ffffffff8109932e>] ? audit_syscall_entry+0x119/0x145
>  [<ffffffff81117505>] sys_link+0x19/0x1c
>  [<ffffffff8145b612>] system_call_fastpath+0x16/0x1b

That's a different issue. If you do an 'echo t >/proc/sysrq-trigger',
then do you see any other process that is stuck in the nfs layer and
that might be holding the inode->i_mutex?


