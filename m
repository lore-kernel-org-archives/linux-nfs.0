Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48591 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754164Ab1LNWi4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 17:38:56 -0500
Date: Wed, 14 Dec 2011 17:38:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Casey Bodley <cbodley@citi.umich.edu>
Cc: bjschuma@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: forget_delegations should use
 list_for_each_entry_safe
Message-ID: <20111214223854.GE7623@fieldses.org>
References: <1323891596-30914-1-git-send-email-bjschuma@netapp.com>
 <CAMeBU_0bcXWNBWsJ8Sv2n-53fr8jCSQSs_guOnw8WYHgBFQz4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAMeBU_0bcXWNBWsJ8Sv2n-53fr8jCSQSs_guOnw8WYHgBFQz4A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 14, 2011 at 03:50:53PM -0500, Casey Bodley wrote:
> On Wed, Dec 14, 2011 at 2:39 PM,  <bjschuma@netapp.com> wrote:
> > From: Bryan Schumaker <bjschuma@netapp.com>
> >
> > Otherwise the for loop could try to use a file recently removed from the
> > file_hashtbl list and oops.
> >
> > Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> > ---
> >  fs/nfsd/nfs4state.c |    9 +++++----
> >  1 files changed, 5 insertions(+), 4 deletions(-)
> >
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 19ca9b5..7355fe4 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -4505,18 +4505,19 @@ void nfsd_forget_openowners(u64 num)
> >  int nfsd_process_n_delegations(u64 num, void (*deleg_func)(struct nfs4_delegation *))
> >  {
> >        int i, count = 0;
> > -       struct nfs4_file *fp;
> > -       struct nfs4_delegation *dp, *next;
> > +       struct nfs4_file *fp, *fnext;
> > +       struct nfs4_delegation *dp, *dnext;
> >
> >        for (i = 0; i < FILE_HASH_SIZE; i++) {
> > -               list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
> > -                       list_for_each_entry_safe(dp, next, &fp->fi_delegations, dl_perfile) {
> > +               list_for_each_entry_safe(fp, fnext, &file_hashtbl[i], fi_hash) {
> > +                       list_for_each_entry_safe(dp, dnext, &fp->fi_delegations, dl_perfile) {
> >                                deleg_func(dp);
> >                                if (++count == num)
> >                                        return count;
> >                        }
> >                }
> >        }
> > +
> >        return count;
> >  }
> >
> > --
> > 1.7.8
> >
> 
> Confirmed to fix the oops I was getting with fault injection. (tested
> without the previous patch, NFSD: Only reinitilize the recall_lru list
> under the recall lock)

Ah-hah.  Thanks Bryan, and Casey--committed.

--b.
