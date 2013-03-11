Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37787 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753313Ab3CKUbO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 16:31:14 -0400
Date: Mon, 11 Mar 2013 16:31:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Frank S Filz <ffilz@us.ibm.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org,
        Pavel Shilovsky <piastry@etersoft.ru>, wine-devel@winehq.org
Subject: Re: [PATCH v3 7/7] NFSD: Pass share reservations flags to VFS
Message-ID: <20130311203110.GF642@fieldses.org>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
 <1362065133-9490-8-git-send-email-piastry@etersoft.ru>
 <20130311150540.119abd63@corrin.poochiereds.net>
 <20130311193638.GB642@fieldses.org>
 <20130311160844.7dedf15a@corrin.poochiereds.net>
 <20130311201108.GE642@fieldses.org>
 <OF1D20435B.D7D7B48E-ON87257B2B.006FB8C9-88257B2B.00702F2E@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF1D20435B.D7D7B48E-ON87257B2B.006FB8C9-88257B2B.00702F2E@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 11, 2013 at 01:25:20PM -0700, Frank S Filz wrote:
> 
> "J. Bruce Fields" <bfields@fieldses.org>  wrote
> > On Mon, Mar 11, 2013 at 04:08:44PM -0400, Jeff Layton wrote:
> > > On Mon, 11 Mar 2013 15:36:38 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > > It doesn't look like this patch removes any of that old code
> though. I
> > > > > think it probably should, or there ought to be some consideration
> of
> > > > > how this new stuff will mesh with it.
> > > > >
> > > > > I think you have 2 choices here:
> > > > >
> > > > > 1/ rip out the old share reservation code altogether and require
> that
> > > > > filesystems mount with -o sharemand or whatever if they want to
> allow
> > > > > their enforcement
> > > > >
> > > > > 2/ make knfsd fall back to using the internal share reservation
> code
> > > > > when the mount option isn't enabled
> > > > >
> > > > > Personally, I think #1 would be fine, but Bruce may want to weigh
> in on
> > > > > what he'd prefer.
> > > >
> > > > #1 sounds good.  Clients that use deny bits are few.  My preference
> > > > would be to return an error to such clients in the case share locks
> > > > aren't available.
> > > >
> > > > (We're a little out of spec there, so I'm not sure which error.  I
> think
> > > > the goal is to notify a human there's a problem with minimal
> collateral
> > > > damange.
> > > >
> > > > NFS4ERR_SERVERFAULT ("I'm a buggy server, sorry about that!") would
> > > > probably result in an IO error to the application.
> > > >
> > > > SHARE_DENIED strikes me as unsafe: an application would be in its
> rights
> > > > not to even check for that e.g. in the case of an exclusive create.
> 
> Hmm, shouldn't the client catch that with a "default" case at least?
> 
> > > > Maybe DELAY?  Kind of ridiculous, but blocking the application
> > > > indefinitely would probably get someone's attention quickly enough
> > > > without doing any damnage.)
> > > >
> > >
> > > I agree that we should return an error, but hadn't considered what
> > > error. Given that hardly any NFS clients use them, I'd probably just go
> > > with NFS4ERR_SERVERFAULT, and maybe throw a printk or something on the
> > > server about enabling share reservations for superblock x:y.
> >
> > Sounds reasonable.
> 
> If I'm understanding, the suggestion is a mount option to enable share
> reservations and if so, they will be mandatory?
> 
> In that case, perhaps we want to keep the existing knfsd code as a
> fallback, someone might want to support them, but not have them be
> mandatory (if nothing else, you may cause consternation from folks running
> pynfs against a default configured knfsd server....).

Understood, but the benefit is slight and the cost (in complexity) is
rather large.  On balance I'd far prefer to get rid of any fallback code
entirely.

> In the Ganesha project, we provide an internal implementation of share
> reservations for when the underlying system can not support them.
> 
> Another bit to consider, does lockd provide share reservations for NLM?

Yes.  I don't know if anyone's tested them in recent memory!  But it
might be interesting to write a few simple tests for them and hook them
up to this on the server side.  (I don't know if they'd be worth
implementing on the client side?)

--b.
