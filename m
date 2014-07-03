Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:33640 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754150AbaGCVuT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 17:50:19 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so758908qge.25
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jul 2014 14:50:18 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 3 Jul 2014 17:50:16 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 015/114] nfsd: Allow struct nfsd4_compound_state to
 cache the nfs4_client
Message-ID: <20140703175016.78f6392b@tlielax.poochiereds.net>
In-Reply-To: <20140703213526.GG24322@fieldses.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
	<1404143423-24381-16-git-send-email-jlayton@primarydata.com>
	<20140703203259.GF24322@fieldses.org>
	<20140703213526.GG24322@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 3 Jul 2014 17:35:26 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Jul 03, 2014 at 04:32:59PM -0400, J. Bruce Fields wrote:
> > On Mon, Jun 30, 2014 at 11:48:44AM -0400, Jeff Layton wrote:
> > > We want to use the nfsd4_compound_state to cache the nfs4_client in
> > > order to optimise away extra lookups of the clid.
> > > 
> > > In the v4.0 case, we use this to ensure that we only have to look up the
> > > client at most once per compound for each call into lookup_clientid. For
> > > v4.1+ we set the pointer in the cstate during SEQUENCE processing so we
> > > should never need to do a search for it.
> > 
> > The connectathon locking test is failing for me in the nfsv4/krb5i case
> > as of this commit.
> > 
> > Which makes no sense to me whatsoever, so it's entirely possible this is
> > some unrelated problem on my side.  I'll let you know when I've figured
> > out anything more.
> 
> It's intermittent.
> 
> I've reproduced it on the previous commit so I know at least that this
> one isn't at fault.
> 
> I doubt it's really dependent on krb5i, at most that's probably just
> making it more likely to reproduce.
> 
> --b.

I haven't been able to reproduce it yet, but I suspect you're hitting
this check in lookup_or_create_lock_state:

                /* with an existing lockowner, seqids must be the same */
                status = nfserr_bad_seqid;
                if (!cstate->minorversion &&
                    lock->lk_new_lock_seqid != lo->lo_owner.so_seqid)
                        goto out;

Hmmm...there are some changes that go in in this patch wrt to lock
seqid handling:

    nfsd: clean up lockowner refcounting when finding them

Perhaps those need to go in earlier? Though when I looked at that
originally, I figured that we wouldn't need those until the refcounting
changes went in (which is why I didn't put them in). It might be
interesting to look at traces and see whether they're consistent with
hitting that check (or maybe put some debug printks in)?


-- 
Jeff Layton <jlayton@primarydata.com>
