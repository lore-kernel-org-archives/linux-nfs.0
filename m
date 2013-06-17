Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45397 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750989Ab3FQOsK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Jun 2013 10:48:10 -0400
Date: Mon, 17 Jun 2013 10:48:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, Sandeep Joshi <sanjos100@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: why does nfsd write not use splice
Message-ID: <20130617144807.GB27193@fieldses.org>
References: <20130612153936.GB32569@fieldses.org>
 <CAEfL3KkdjB7bzvnfiDh024kHjCH0e64iH6GK6y+A+bpH3kUgJg@mail.gmail.com>
 <20130612164637.GA6868@fieldses.org>
 <CAEfL3Km7knMAW1Jx_jHZ0OYBMBpUkvbzk2riBE2C=NA9OMvUQw@mail.gmail.com>
 <20130614152215.1f369a4c@tlielax.poochiereds.net>
 <4FA345DA4F4AE44899BD2B03EEEC2FA93F403977@durexcmbx02-prd.hq.netapp.com>
 <20130617070115.34b2fabb@corrin.poochiereds.net>
 <58D5D77A-B341-4632-A61D-A13462CD40E7@netapp.com>
 <20130617143426.GA27193@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA93F4144ED@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA93F4144ED@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 17, 2013 at 02:36:20PM +0000, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > Sent: Monday, June 17, 2013 10:34 AM
> > To: Myklebust, Trond
> > Cc: Jeff Layton; Sandeep Joshi; linux-nfs@vger.kernel.org
> > Subject: Re: why does nfsd write not use splice
> > 
> > On Mon, Jun 17, 2013 at 11:48:18AM +0000, Myklebust, Trond wrote:
> > >
> > > On Jun 17, 2013, at 7:01 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > > > Encryption certainly can be a problem, but integrity isn't
> > > > necessarily one.
> > > >
> > > > Basically the idea would be to receive the data off the socket into
> > > > a set of pages and then splice those into the correct spot in the
> > > > local file. In both the privacy and integrity cases, you just have
> > > > an extra step in between. Privacy *may* mean an extra copy too
> > > > (though some of the crypto routines can decrypt data in place), but
> > > > handling integrity shouldn't.
> > > >
> > > > The tricky parts (I think) are determining how to lay out the
> > > > received data into the pages you eventually want to splice into the
> > > > file before you receive that data in, and how to deal with it when
> > > > the WRITE doesn't cover an entire page.
> > >
> > > Once you've copied the data one time, most of the advantage of
> > > splice() is gone, since a copy will then exist in processor cache
> > > memory and can be duplicated quickly.
> > 
> > Well, worst case you could turn it off in krb5i/krb5p cases and maybe still get
> > some benefit in the auth_sys case?
> > 
> 
> Not if you need to copy in order to realign the data anyway...

Right, so you get to rewrite the xdr code so that it can process at
least some part of the compound as it comes in.  Fun!

That's why I say it could take a lot of work even to get a prototype
sufficient to measure the effect of splice.  Though maybe you could find
some simple heuristic that would predict the offset of write data when
using your particular test setup....

--b.
