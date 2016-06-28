Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:36122 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098AbcF1NJ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2016 09:09:57 -0400
Received: by mail-qk0-f176.google.com with SMTP id z142so2956344qkb.3
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2016 06:09:56 -0700 (PDT)
Message-ID: <1467119394.32374.11.camel@poochiereds.net>
Subject: Re: [PATCH v4 12/13] pnfs: rework LAYOUTGET retry handling
From: Jeff Layton <jlayton@poochiereds.net>
To: Andrew W Elble <aweits@rit.edu>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Thomas Haynes <loghyr@primarydata.com>, linux-nfs@vger.kernel.org,
        hch@lst.de
Date: Tue, 28 Jun 2016 09:09:54 -0400
In-Reply-To: <m2d1n1tqxk.fsf@discipline.rit.edu>
References: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
	 <1463502528-11519-13-git-send-email-jeff.layton@primarydata.com>
	 <m260stv7hp.fsf@discipline.rit.edu>
	 <1467116540.32374.5.camel@poochiereds.net>
	 <m2d1n1tqxk.fsf@discipline.rit.edu>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-06-28 at 08:53 -0400, Andrew W Elble wrote:
> > 
> > > 
> > > > 
> > > > +		default:
> > > > +			if
> > > > (!nfs_error_is_fatal(PTR_ERR(lseg))) {
> > > > +				pnfs_layout_clear_fail_bit(lo,
> > > > pnfs_iomode_to_fail_bit(iomode));
> > > > +				lseg = NULL;
> > > > +			}
> > > Seems like in the past, a non-fatal-error used to trigger the
> > > opposite
> > > behavior, where this would set the fail_bit? Shouldn't that be
> > > the
> > > behavior for -NFS4ERR_LAYOUTUNAVAILABLE (which is mapped to
> > > -ENODATA)
> > > etc...?
> > > 
> > Yes, and I think that was a bug. See commit
> > d03ab29dbbe905c6c7c5abd78e02547fa954ec07 for where that actually
> > changed.
> I think you mean:
> 0bcbf039f6b2bcefe4f5dada76079080edf9ecd0
> 
> ?
> 
> ...and I was looking at this one:
> d600ad1f2bdbf97c4818dcc85b174f72c90c21bd
> 

No, d03ab29dbbe905c6c7c5abd78e02547fa954ec07 is where that bug was
fixed. Basically, we were clearing the fail bit on fatal errors, when
what we really wanted to do was clear it on non-fatal errors.

> > 
> > You do have a good point about LAYOUTUNAVAILABLE though. That
> > probably
> > should stop further attempts to get a layout. That said, the error
> > mapping here is fiendishly complex. I always have to wonder whether
> > there other errors that get turned into ENODATA? It may be safest
> > to
> > change the error mapping there to something more specific.
> If setting the fail_bit is the right way to go, that could be done
> with less confusion in nfs4_layoutget_handle_exception()...?
> 

Hmm...Trond's response just says "it's not", which I'm not sure how to
interpret here. Trond, do you mean that we should be retrying on
LAYOUTUNAVAILABLE, or that we should be indicating that using some
means other than the fail bit?

-- 
Jeff Layton <jlayton@poochiereds.net>

