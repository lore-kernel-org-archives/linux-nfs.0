Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15106 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211Ab1HAWfe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2011 18:35:34 -0400
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
Cc: William Andros Adamson <andros@netapp.com>, Jim Rees <rees@umich.edu>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Date: Mon, 01 Aug 2011 18:35:17 -0400
In-Reply-To: <1312233006.23392.17.camel@lade.trondhjem.org>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
	 <20110729155136.GB28306@infradead.org> <20110729185415.GA23061@merit.edu>
	 <20110729190133.GA10946@infradead.org> <20110729191341.GC23061@merit.edu>
	 <1311988172.16078.15.camel@lade.trondhjem.org>
	 <20110730032621.GB25188@merit.edu>
	 <CA+a=Yy5rmvrUHaDewLb_EbeaDYMKL_xv_E_MmzTvR_55SmYkqA@mail.gmail.com>
	 <1312233006.23392.17.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312238117.23392.19.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-08-01 at 17:10 -0400, Trond Myklebust wrote: 
> Looking at the callback code, I see that if tbl->highest_used_slotid !=
> 0, then we BUG() while holding the backchannel's tbl->slot_tbl_lock
> spinlock. That seems a likely candidate for the above hang.
> 
> Andy, how we are guaranteed that tbl->highest_used_slotid won't take
> values other than 0, and why do we commit suicide when it does? As far
> as I can see, there is no guarantee that we call nfs4_cb_take_slot() in
> nfs4_callback_compound(), however we appear to unconditionally call
> nfs4_cb_free_slot() provided there is a session.
> 
> The other strangeness would be the fact that there is nothing enforcing
> the NFS4_SESSION_DRAINING flag. If the session is draining, then the
> back-channel simply ignores that and goes ahead with processing the
> callback. Is this to avoid deadlocks with the server returning
> NFS4ERR_BACK_CHAN_BUSY when the client does a DESTROY_SESSION?

How about something like the following?

8<------------------------------------------------------------------------------- 
