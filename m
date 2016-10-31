Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:53194 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751438AbcJaP4Z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2016 11:56:25 -0400
Date: Mon, 31 Oct 2016 16:56:16 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        List Linux Kernel Mailing <linux-kernel@vger.kernel.org>,
        "tglx@linutronix.de" <tglx@linutronix.de>
Subject: Re: [PATCH v3] NFSv4: replace seqcount_t with a rw_semaphore
Message-ID: <20161031155616.fqbqy53bwpanufhn@linutronix.de>
References: <20161021164727.24485-1-bigeasy@linutronix.de>
 <20161028210511.k7hrsfxovti7gqtu@linutronix.de>
 <747E2CCB-3D83-40FD-8B31-46AB5A5E8592@primarydata.com>
 <20161031131958.mrrez5t7sow75p6v@linutronix.de>
 <51E3F753-2D1F-4370-BFEB-BD8356D622A1@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <51E3F753-2D1F-4370-BFEB-BD8356D622A1@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2016-10-31 15:30:02 [+0000], Trond Myklebust wrote:
> > On Oct 31, 2016, at 09:19, Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:
> > The list_for_each_entry() in nfs4_reclaim_open_state:
> > It seems that this lock protects the ->so_states list among other
> > atomic_t & flags members. So at the begin of the loop we inc ->count
> > ensuring that this field is not removed while we use it. So we drop the
> > ->so_lock loc during the loop it seems. And after nfs4_reclaim_locks()
> > invocation we nfs4_put_open_state() and grab the ->so_lock again. So if
> > we were the last user of this struct and we remove it, then the
> > following list_next_entry() invocation is a use-after-free. Even if we
> > use list_for_each_entry_safe() there is no guarantee that the following
> > member is still valid because it might have been removed by someone
> > invoking nfs4_put_open_state() on it, right?
> > So there is this.
> > 
> > However to address my initial problem I have here a patch :) So it uses
> > a rw_semaphore which ensures that there is only one writer at a time or
> > multiple reader. So it should be basically what is happening now plus a
> > tiny tiny tiny lock plus lockdep coverage. I tried to this myself but I
> > don't manage to get into this code path at all so I might be doing
> > something wrong.
> > 
> > Could you please check if this patch is working for you and whether my
> > list_for_each_entry() observation is correct or not?
> > 
> > v2…v3: replace the seqlock with a RW semaphore.
> > 
> 
> NACK. That will deadlock. The reason why we use a seqlock there is precisely because we cannot allow ordinary RPC calls to lock out the recovery thread. 
Hmmm. So this is getting invoked if I reboot the server? A restart of
nfs-kernel-server is the same thing?
Is the list_for_each_entry() observation I made correct?

>If the server reboots, then ordinary RPC calls will fail until the recovery thread has had a chance to re-establish the state.

This means that the ordinary RPC call won't return and fail but wait
with the lock held until the recovery thread did its thing?

Sebastian
