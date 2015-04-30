Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44350 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779AbbD3VgE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2015 17:36:04 -0400
Date: Thu, 30 Apr 2015 17:36:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150430213602.GB9509@fieldses.org>
References: <20150421215417.GE13782@fieldses.org>
 <553781E2.1000900@gmail.com>
 <20150422150703.GA1247@fieldses.org>
 <20150423094431.1a8aa68b@notabene.brown>
 <5538EB18.7080802@gmail.com>
 <20150424130045.6bbdb2f9@notabene.brown>
 <553E2784.6020906@gmail.com>
 <20150429125728.69ddfc6c@notabene.brown>
 <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150430075225.21a71056@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 30, 2015 at 07:52:25AM +1000, NeilBrown wrote:
> On Wed, 29 Apr 2015 15:19:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> > Maybe drop the locking from nfsd_buffered_readdir and *just* take the
> > i_mutex around lookup_one_len(), if that's the only place we need it?
> 
> I think it is the only place needed.  Certainly normal path lookup
> only takes i_mutex very briefly around __lookup_hash().
> 
> One cost would be that we would take the mutex for every name instead
> of once for a whole set of names.  That is generally frowned upon for
> performance reasons.
> 
> An alternative might be to stop using lookup_one_len, and use
> kern_path() instead.  Or kern_path_mountpoint if we don't want to
> cross a mountpoint.
> 
> They would only take the i_mutex if absolutely necessary.
> 
> The draw back is that they don't take a 'len' argument, so we would
> need to make sure the name  is nul terminated (and maybe double-check
> that there is no '/'??).  It would be fairly easy to nul-terminate
> names from readdir - just use a bit more space  in the buffer in
> nfsd_buffered_filldir().

They're also a lot more complicated than lookup_one_len.  Is any of this
extra stuff they do (audit?) going to bite us?

For me understanding that would be harder than writing a variant of
lookup_one_len that took the i_mutex when required.  But I guess that's
my problem, I should try to understand the lookup code better....

> I'm less sure about the locking needed in nfsd_lookup_dentry().  The
> comments suggests that there is good reason to keep the lock for an
> extended period.  But that reasoning might only apply to files, and
> nfsd_mountpoint should  only be true for directories... I hope.

I thought d_mountpoint() could be true for files, but certainly we won't
be doing nfs4 opens on directories.

> A different approach would be to pass NULL for the rqstp to
> nfsd_cross_mnt().  This will ensure it doesn't block, but it might
> fail incorrectly.  If it does fail, we drop the lock, retry with the
> real rqstp, retake the lock and .... no, I think that gets a bit too
> messy.

Yes.

> I think I'm in favour of:
>  - not taking the lock in readdir
>  - maybe not taking it in lookup
>  - using kern_path_mountpoint or kern_path
>  - nul terminating then names, copying the nfsd_lookup name to
>    __getname() if necessary.
> 
> Sound reasonable?

I guess so, though I wish I understood kern_path_mountpoint better.

And nfsd_lookup_dentry looks like work for another day.  No, wait, I
forgot the goal here: you're right, nfsd_lookup_dentry has the same
upcall-under-i_mutex problem, so we need to fix it too.

OK, agreed.

--b.
