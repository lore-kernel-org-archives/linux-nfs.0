Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f181.google.com ([209.85.192.181]:43386 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbaHCOPh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 10:15:37 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so8083729pdj.26
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 07:15:36 -0700 (PDT)
Message-ID: <53DE43E9.9030704@gmail.com>
Date: Sun, 03 Aug 2014 22:15:05 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Jeffrey Layton <jeff.layton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 31/38] nfsd: Move the open owner hash table into struct
 nfs4_client
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>	<1406684083-19736-32-git-send-email-jlayton@primarydata.com>	<53DCBFDB.5060808@gmail.com>	<CAHQdGtTGNZsqZTCQhUboG1kE+bzb7p3K+5BxmusFG+qWMrVJzg@mail.gmail.com>	<53DCEAE8.70707@gmail.com>	<CAHQdGtT4qb_KkLYcM64z8=YY-J3pheKBb_-pvVQvpVmpWFh=1A@mail.gmail.com>	<53DCF3C0.6050201@gmail.com>	<CAHQdGtRNwSbhKkfbop-8NFq6WTS_EmrojC2HyLmkKki94oxSHw@mail.gmail.com>	<20140802185933.64ba0b15@tlielax.poochiereds.net>	<CAHQdGtS+X1KABsr5buxKqC5VNpyWBrJYMD74HzWtF=fDOs19bg@mail.gmail.com> <CAPakX04ctGujqpJ48WqT1-r5=q0T8D1Ji=q1P5UTuwdw_hTsGg@mail.gmail.com>
In-Reply-To: <CAPakX04ctGujqpJ48WqT1-r5=q0T8D1Ji=q1P5UTuwdw_hTsGg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/3/2014 19:35, Jeffrey Layton wrote:
> On Sat, Aug 2, 2014 at 9:59 PM, Trond Myklebust <trond.myklebust@primarydata.com <mailto:trond.myklebust@primarydata.com>> wrote:
> 
>     On Sat, Aug 2, 2014 at 6:59 PM, Jeff Layton <jeff.layton@primarydata.com <mailto:jeff.layton@primarydata.com>> wrote:
>     > On Sat, 2 Aug 2014 10:47:27 -0400
>     > Trond Myklebust <trond.myklebust@primarydata.com <mailto:trond.myklebust@primarydata.com>> wrote:
>     >
>     >> On Sat, Aug 2, 2014 at 10:20 AM, Kinglong Mee <kinglongmee@gmail.com <mailto:kinglongmee@gmail.com>> wrote:
>     >> > On 8/2/2014 22:05, Trond Myklebust wrote:
>     >> >> On Sat, Aug 2, 2014 at 9:43 AM, Kinglong Mee <kinglongmee@gmail.com <mailto:kinglongmee@gmail.com>> wrote:
>     >> >>> On 8/2/2014 21:11, Trond Myklebust wrote:
>     >> >>>> On Sat, Aug 2, 2014 at 6:39 AM, Kinglong Mee <kinglongmee@gmail.com <mailto:kinglongmee@gmail.com>> wrote:
>     >> >>>>> On 7/30/2014 09:34, Jeff Layton wrote:
>     >> >>>>>> From: Trond Myklebust <trond.myklebust@primarydata.com <mailto:trond.myklebust@primarydata.com>>
>     >> >>>>>>
>     >> >>>>>> Preparation for removing the client_mutex.
>     >> >>>>>>
>     >> >>>>>> Convert the open owner hash table into a per-client table and protect it
>     >> >>>>>> using the nfs4_client->cl_lock spin lock.
>     >> >>>>>>
>     >> >>>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com <mailto:trond.myklebust@primarydata.com>>
>     >> >>>>>> ---
>     >> >>>>>>  fs/nfsd/netns.h     |   1 -
>     >> >>>>>>  fs/nfsd/nfs4state.c | 187 ++++++++++++++++++++++++----------------------------
>     >> >>>>>>  fs/nfsd/state.h     |   1 +
>     >> >>>>>>  3 files changed, 86 insertions(+), 103 deletions(-)
>     >> >>>>>>
>     >> >>>>>> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
>     >> >>>>>> index a71d14413d39..e1f479c162b5 100644
>     >> >>>>>> --- a/fs/nfsd/netns.h
>     >> >>>>>> +++ b/fs/nfsd/netns.h
>     >> >>>>>> @@ -63,7 +63,6 @@ struct nfsd_net {
>     >> >>>>>>       struct rb_root conf_name_tree;
>     >> >>>>>>       struct list_head *unconf_id_hashtbl;
>     >> >>>>>>       struct rb_root unconf_name_tree;
>     >> >>>>>> -     struct list_head *ownerstr_hashtbl;
>     >> >>>>>
>     >> >>>>> I send a patch "NFSD: Rervert "knfsd: locks: flag NFSv4-owned locks"" before,
>     >> >>>>> http://comments.gmane.org/gmane.linux.nfs/64382
>     >> >>>>>
>     >> >>>>> nfsd needs the hashtbl to find the lockowner for locking by owner from
>     >> >>>>> fl->fl_owner stored in struct file_lock, but without nfs_client.
>     >> >>>>
>     >> >>>> Why? We're not currently doing that.
>     >> >>>
>     >> >>> Although not doing that right now, but there is a bug for getting the right ld_owner
>     >> >>> in nfs4_set_lock_denied.
>     >> >>>
>     >> >>> If denying locks, vfs don't copy fl->fl_lmops to the returned file_lock, so that,
>     >> >>> fl->fl_lmops always be NULL, nfsd never return the owner who holds the conflock.
>     >> >>>
>     >> >>> If we want fix this problem, needs finding the lockowner from struct file_lock.
>     >> >>
>     >> >> Do we really care enough about fixing nfs4_set_lock_denied enough to
>     >> >> do so at the cost of reducing overall scalability of locking state?
>     >> >
>     >> > I just report this problem, don't think enough about the scalability.
>     >> >
>     >> >> We will always be faking up the clientid etc for local locks. Are
>     >> >> there any clients out there that actually inspect the clientid on a
>     >> >> result of NFS4ERR_DENIED and that will break if we give them a fake
>     >> >> for non-local locks?
>     >> >
>     >> > Jeff has point the same problem of a non-nfs4_lockowner.
>     >> > Maybe we should copy fl_lmops to conflock as before, nfsd can distinguish
>     >> > the lockowner stored in struct file_lock by checking fl_lmops.
>     >> >
>     >>
>     >> Alternatively, set a flag in fl_flags. Back in the days, we used to
>     >> have a FL_NFSD, perhaps it is time to resurrect that?
>     >>
>     >
>     > Would we need a similar flag for lockd too?
>     >
>     > I'm not sure a flag is the correct approach for this. A "fl_lmtype" field
>     > or something similar might make sense, but I'm not sure that really
>     > adds much over just ensuring that fl_lmops is set properly for these locks.
> 
>     It avoids adding an extra copy of fl_lmops that would only be useful
>     to knfsd as a flag.
> 
>     > That said, we definitely will need to ensure that there are no harmful
>     > effects from setting fl_lmops on a conflock container. I don't see any
>     > right offhand, but it's probably reasonable to put something like that
>     > in -next for a bit of soak time...
> 
>     The real problem here is that you are copying the lock, and then
>     trying to dereference the copied pointer without ensuring that the
>     thing the pointer is referencing still exists. Given that we're
>     removing the global state mutex, then it is now perfectly possible for
>     a competing knfsd thread to free the conflicting lock and the
>     lockowner pointed to by fl->fl_owner before your thread hits
>     nfs4_set_lock_denied.
>     The check for fl_lmtype does nothing to fix that race (nor does FL_NFSD).
> 
>     Cheers
>       Trond
> 
> 
> Agreed. That's a significant bit of nastiness, and I think you're correct that the
> client_mutex removal will exacerbate the problem. The only way I can see to
> properly fix that would be to make it so that the conflock holds a reference to the
> lockowner, and then put it when the conflock is freed.
> 

I will check the reference to lockowner in nfsd, and try to simulate client-id expire.

> That will require some new fl_ops or fl_lmops. It would also be good to clean up
> conflock generation a bit, and turn it into a more explicit process.
> __locks_copy_lock doesn't really fully describe what's going on there, IMO...

I will have a try.

thanks,
Kinglong Mee
