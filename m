Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50223 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929Ab3FQOgV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jun 2013 10:36:21 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>, Sandeep Joshi <sanjos100@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: why does nfsd write not use splice
Date: Mon, 17 Jun 2013 14:36:20 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA93F4144ED@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130611195140.GA29634@fieldses.org>
 <51B7DE9C.6080703@talpey.com> <20130612153936.GB32569@fieldses.org>
 <CAEfL3KkdjB7bzvnfiDh024kHjCH0e64iH6GK6y+A+bpH3kUgJg@mail.gmail.com>
 <20130612164637.GA6868@fieldses.org>
 <CAEfL3Km7knMAW1Jx_jHZ0OYBMBpUkvbzk2riBE2C=NA9OMvUQw@mail.gmail.com>
 <20130614152215.1f369a4c@tlielax.poochiereds.net>
 <4FA345DA4F4AE44899BD2B03EEEC2FA93F403977@durexcmbx02-prd.hq.netapp.com>
 <20130617070115.34b2fabb@corrin.poochiereds.net>
 <58D5D77A-B341-4632-A61D-A13462CD40E7@netapp.com>
 <20130617143426.GA27193@fieldses.org>
In-Reply-To: <20130617143426.GA27193@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Monday, June 17, 2013 10:34 AM
> To: Myklebust, Trond
> Cc: Jeff Layton; Sandeep Joshi; linux-nfs@vger.kernel.org
> Subject: Re: why does nfsd write not use splice
> 
> On Mon, Jun 17, 2013 at 11:48:18AM +0000, Myklebust, Trond wrote:
> >
> > On Jun 17, 2013, at 7:01 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > > Encryption certainly can be a problem, but integrity isn't
> > > necessarily one.
> > >
> > > Basically the idea would be to receive the data off the socket into
> > > a set of pages and then splice those into the correct spot in the
> > > local file. In both the privacy and integrity cases, you just have
> > > an extra step in between. Privacy *may* mean an extra copy too
> > > (though some of the crypto routines can decrypt data in place), but
> > > handling integrity shouldn't.
> > >
> > > The tricky parts (I think) are determining how to lay out the
> > > received data into the pages you eventually want to splice into the
> > > file before you receive that data in, and how to deal with it when
> > > the WRITE doesn't cover an entire page.
> >
> > Once you've copied the data one time, most of the advantage of
> > splice() is gone, since a copy will then exist in processor cache
> > memory and can be duplicated quickly.
> 
> Well, worst case you could turn it off in krb5i/krb5p cases and maybe still get
> some benefit in the auth_sys case?
> 

Not if you need to copy in order to realign the data anyway...

Cheers
  Trond

