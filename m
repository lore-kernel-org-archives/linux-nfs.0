Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:36752 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbbHERMQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 13:12:16 -0400
Received: by ykeo23 with SMTP id o23so40781113yke.3
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 10:12:15 -0700 (PDT)
Date: Wed, 5 Aug 2015 13:12:11 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Andrew W Elble <aweits@rit.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>,
        Anna Schumaker <schumakeranna@gmail.com>
Subject: Re: list_del corruption / unhash_ol_stateid()
Message-ID: <20150805131211.64d1834a@tlielax.poochiereds.net>
In-Reply-To: <m2pp31bsqb.fsf@discipline.rit.edu>
References: <m23809zl8z.fsf@discipline.rit.edu>
	<m2zj2hwk4e.fsf@discipline.rit.edu>
	<20150728090206.1331e476@tlielax.poochiereds.net>
	<m2wpxktjfc.fsf@discipline.rit.edu>
	<20150728114933.6f917374@tlielax.poochiereds.net>
	<20150728210434.GC9349@fieldses.org>
	<m24mknq9ga.fsf@discipline.rit.edu>
	<m28u9yoi6z.fsf@discipline.rit.edu>
	<m2bnetnbme.fsf@discipline.rit.edu>
	<20150730085723.0ab8e76c@tlielax.poochiereds.net>
	<m2bnemg64d.fsf@discipline.rit.edu>
	<20150805111132.01a14348@tlielax.poochiereds.net>
	<m2pp31bsqb.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 05 Aug 2015 12:33:16 -0400
Andrew W Elble <aweits@rit.edu> wrote:

> 
> > I'm not sure I'm following your shorthand correctly, but, I'm guessing
> > the above is that you're creating a stateid and then calling
> > init_open_stateid on it to hash it?
> >
> > If you can flesh out the description of the race, it might be more
> > clear.
> 
> Sorry, knew that was a bit terse.
> 
> nfsd4_process_open2                    nfsd4_close
> 
> stp = open->op_stp;
>  nfs4_alloc_stid, refcount is 1
> 
> init_open_stateid(stp, fp, open);
>  is hashed, refcount is 2
> 
>                                  nfs4_preprocess_seqid_op()
> 				 finds the same stateid,
> 				 refcount is 3
> 
>                                  nfsd4_close_open_stateid()
>                                  unhashes stateid,
>                                  put_ol_stateid_locked() drops refcount
>                                  refcount is 2
> nfs4_get_vfs_file() returns
> with status due to:
>  nfsd_open()
>   nfsd_open_break_lease()
>    break_lease() returning
>     -EWOULDBLOCK
> 
> release_open_stateid()
>  calls unhash_open_stateid()
>  attempts to unhash,
>  WARN generated for list_del
> 
>  proceeds to call put_ol_stateid_locked()
>  decrements refcount inappropriately
>  refcount is now 1.
> 
>                                  nfs4_put_stid()
> 				 refcount is 0, memory is freed
> 
>  nfs4_put_stid
>  calls atomic_dec_and_lock()
>  use after free
>  first corrupt byte is 6a
>  because of atomic decrement
>  with slub_debug on
> 
> > Unless...the initial task that created the stateid got _really_
> > stalled, and another OPEN raced in, found that stateid and was able to
> > reply quickly. Then the client could send a CLOSE for that second OPEN
> > before the first opener ever finished.
> 
> Sounds plausible given the environment. Would take more effort to
> directly prove. I have directly observed the same stateid being used in
> the above race.
> 
> > If you had multiple racing OPENs then one could find the stateid that
> > was previously hashed. A simple fix might be to just use list_del_init
> > calls in unhash_ol_stateid. That should make any second list_del's a
> > no-op.
> >
> > Whether that's sufficient to fix the mem corruption, I'm not sure...
> 
> It's sc_count decrementing when the unhashing "fails" or is going to
> fail. For instance, this kind of construct will prevent one of the
> possible use-after-free scenarios.
> 
> static void release_open_stateid(struct nfs4_ol_stateid *stp)
> {
>         LIST_HEAD(reaplist);
> 
>         spin_lock(&stp->st_stid.sc_client->cl_lock);
>         if (stp->st_perfile->next != LIST_POISON1) {
>          unhash_open_stateid(stp, &reaplist);
>          put_ol_stateid_locked(stp, &reaplist);
>         }
>         spin_unlock(&stp->st_stid.sc_client->cl_lock);
>         free_ol_stateid_reaplist(&reaplist);
> }
> 
> Thanks,
> 
> Andy
> 

Ok, I get it now. The real problem then is a dispute over who should
put the "hash reference" for this stateid. We need to ensure that only
one caller dequeues it from the lists, and only that caller puts that
reference.

There are a couple of different ways to do that. The best one in this
case is probably to use list_del_init in unhash_ol_stateid and check
whether one of the list_heads is already empty before attempting to
unhash it and put the final reference.

We still do have the problem (I suspect) with the nfs4_file not being
fully instantiated before allowing other callers to use it, but that's
really a separate problem.

-- 
Jeff Layton <jlayton@poochiereds.net>
