Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:54103 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbaGUWwD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 18:52:03 -0400
Received: by mail-vc0-f179.google.com with SMTP id hq11so12065164vcb.10
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 15:52:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140721184254.7e0467ad@tlielax.poochiereds.net>
References: <1405949706-27757-1-git-send-email-jlayton@primarydata.com>
	<1405949706-27757-4-git-send-email-jlayton@primarydata.com>
	<20140721213056.GM8438@fieldses.org>
	<20140721184254.7e0467ad@tlielax.poochiereds.net>
Date: Mon, 21 Jul 2014 18:52:01 -0400
Message-ID: <CAHQdGtTFhYQQbq2hs6JmqYXHygL2UsMR98Qus3moUYt5SVVdTA@mail.gmail.com>
Subject: Re: [PATCH v5 03/10] nfsd: simplify stateid allocation and file handling
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 21, 2014 at 6:42 PM, Jeff Layton
<jeff.layton@primarydata.com> wrote:
> On Mon, 21 Jul 2014 17:30:56 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>
>> On Mon, Jul 21, 2014 at 09:34:59AM -0400, Jeff Layton wrote:
>> > From: Trond Myklebust <trond.myklebust@primarydata.com>
>> >
>> > Don't allow stateids to clear the open file pointer until they are
>> > being destroyed. In a later patch we'll want to move the putting of
>> > the nfs4_file into generic stateid handling code and this will help
>> > facilitate that change.
>> >
>> > Also, move to allocating stateids with kzalloc and get rid of the
>> > explicit zeroing of fields.
>>
>> There's a regression here: we end up holding an unnecessary reference to
>> the inode a long time just because some client isn't responding to a
>> recall.
>>
>
> I must have missed that exchange...
>
> So that's because we're putting the file reference when we put the
> last delegation reference instead of when we unhash the
> delegation...ok, good point.
>
> I don't see any real harm right offhand of putting the file reference
> early when we unhash, so I think that'll work. We do that already for
> v4.0 open stateids when they are closed, so we might as well do it for
> delegations too. I'll double check that we never use the file after
> unhashing and send up a patch to change that unless I see a problem.
>
>> When I complained about this before Trond said something about replacing
>> fi_inode by a filehandle?  But I can't remember if we've seen code to do
>> that.
>>
>
> No I don't think we have. That sounds like a bit of an overhaul of the
> nfs4_file code.

Nah... Let me send out those patches. They're still a little rough
around the edges, but really not that large.

> Personally, I think that hashing on the filehandle makes a lot of
> sense, and I don't see a reason to pin down the inode except by virtue
> of the fi_fds file references. That said, I'd prefer to defer that sort
> of change until after this series is merged.

Sure. I was planning on doing the same. Just a little disorganised right now.

Cheers
  Trond

>> >
>> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
>> > Reviewed-by: Christoph Hellwig <hch@lst.de>
>> > ---
>> >  fs/nfsd/nfs4state.c | 22 ++++++++++------------
>> >  1 file changed, 10 insertions(+), 12 deletions(-)
>> >
>> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> > index a47c97586c76..8ff5c97a2c5a 100644
>> > --- a/fs/nfsd/nfs4state.c
>> > +++ b/fs/nfsd/nfs4state.c
>> > @@ -459,7 +459,7 @@ kmem_cache *slab)
>> >     struct nfs4_stid *stid;
>> >     int new_id;
>> >
>> > -   stid = kmem_cache_alloc(slab, GFP_KERNEL);
>> > +   stid = kmem_cache_zalloc(slab, GFP_KERNEL);
>> >     if (!stid)
>> >             return NULL;
>> >
>> > @@ -467,11 +467,9 @@ kmem_cache *slab)
>> >     if (new_id < 0)
>> >             goto out_free;
>> >     stid->sc_client = cl;
>> > -   stid->sc_type = 0;
>> >     stid->sc_stateid.si_opaque.so_id = new_id;
>> >     stid->sc_stateid.si_opaque.so_clid = cl->cl_clientid;
>> >     /* Will be incremented before return to client: */
>> > -   stid->sc_stateid.si_generation = 0;
>> >     atomic_set(&stid->sc_count, 1);
>> >
>> >     /*
>> > @@ -592,10 +590,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
>> >     INIT_LIST_HEAD(&dp->dl_perfile);
>> >     INIT_LIST_HEAD(&dp->dl_perclnt);
>> >     INIT_LIST_HEAD(&dp->dl_recall_lru);
>> > -   dp->dl_file = NULL;
>> >     dp->dl_type = NFS4_OPEN_DELEGATE_READ;
>> >     fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
>> > -   dp->dl_time = 0;
>> >     INIT_WORK(&dp->dl_recall.cb_work, nfsd4_run_cb_recall);
>> >     return dp;
>> >  }
>> > @@ -616,6 +612,8 @@ void
>> >  nfs4_put_delegation(struct nfs4_delegation *dp)
>> >  {
>> >     if (atomic_dec_and_test(&dp->dl_stid.sc_count)) {
>> > +           if (dp->dl_file)
>> > +                   put_nfs4_file(dp->dl_file);
>> >             remove_stid(&dp->dl_stid);
>> >             nfs4_free_stid(deleg_slab, &dp->dl_stid);
>> >             num_delegations--;
>> > @@ -665,13 +663,9 @@ unhash_delegation(struct nfs4_delegation *dp)
>> >     list_del_init(&dp->dl_recall_lru);
>> >     list_del_init(&dp->dl_perfile);
>> >     spin_unlock(&fp->fi_lock);
>> > -   if (fp) {
>> > +   if (fp)
>> >             nfs4_put_deleg_lease(fp);
>> > -           dp->dl_file = NULL;
>> > -   }
>> >     spin_unlock(&state_lock);
>> > -   if (fp)
>> > -           put_nfs4_file(fp);
>> >  }
>> >
>> >  static void destroy_revoked_delegation(struct nfs4_delegation *dp)
>> > @@ -879,12 +873,12 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
>> >  static void close_generic_stateid(struct nfs4_ol_stateid *stp)
>> >  {
>> >     release_all_access(stp);
>> > -   put_nfs4_file(stp->st_file);
>> > -   stp->st_file = NULL;
>> >  }
>> >
>> >  static void free_generic_stateid(struct nfs4_ol_stateid *stp)
>> >  {
>> > +   if (stp->st_file)
>> > +           put_nfs4_file(stp->st_file);
>> >     remove_stid(&stp->st_stid);
>> >     nfs4_free_stid(stateid_slab, &stp->st_stid);
>> >  }
>> > @@ -4462,6 +4456,10 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
>> >             if (list_empty(&oo->oo_owner.so_stateids))
>> >                     release_openowner(oo);
>> >     } else {
>> > +           if (s->st_file) {
>> > +                   put_nfs4_file(s->st_file);
>> > +                   s->st_file = NULL;
>> > +           }
>> >             oo->oo_last_closed_stid = s;
>> >             /*
>> >              * In the 4.0 case we need to keep the owners around a
>> > --
>> > 1.9.3
>> >
>
>
> --
> Jeff Layton <jlayton@primarydata.com>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
