From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 3/11] nfsd: CHANGE old function calls to new calls
Date: Fri, 24 Apr 2009 21:47:57 +0530
Message-ID: <OFC1241E6B.C4476A61-ON652575A2.00207885-652575A2.00598912@in.ibm.com>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090325133707.16437.66360.sendpatchset@localhost.localdomain> <20090422200553.GH9541@fieldses.org> <OFB63DF5D6.1A77785C-ON652575A1.004F6726-652575A1.00577C61@in.ibm.com> <20090423223909.GF1906@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jlayton@redhat.com, Krishna Kumar <krikku@gmail.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:37982 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054AbZDXQSX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2009 12:18:23 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n3OGIJR9013188
	for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2009 21:48:19 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3OGIVVX2732042
	for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2009 21:48:31 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n3OGIInH016231
	for <linux-nfs@vger.kernel.org>; Sat, 25 Apr 2009 02:18:19 +1000
In-Reply-To: <20090423223909.GF1906@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

"J. Bruce Fields" <bfields@fieldses.org> wrote on 04/24/2009 04:09:09 AM:

> > Keying on the entire filehandle seems reasonable, but I don't think it
is
> > required as auth[3] seems to be allocated memory which is unique in a
> > system,
>
> You lost me.  Where do you see auth[3] getting encoded, and what do you
> mean by saying it's "allocated memory which is unique in a system"?
>
> There are a lot of different filehandle encoding options.  I lose track
> of them myself....

Sorry, I am wrong, I was thinking of &auth[3] and wrote too fast. I am
testing
using your suggestion hashing on the full filehandle, something like:

{
      __u32 a = auth[0], b = auth[1], c = auth[2], d = auth[3];
      hash = jhash_3words(a, b, jhash_2words(c, d, 0), 0xfeedbeef) &
                                    FHPARM_HASH_MASK;
      ...
      /*
       * Matching check uses something like:
       * if (fh->p_auth1 == a && fh->p_auth2 == b && fh->p_auth3 == c &&
fh->p_auth4 == d)
       */
}

Is what you had in mind? I am testing some more with this, so far I get
different values for different files and filesystems.

I am not sure if there is an easier way to do a hash and get the unique
file
associated with the filehandle, this part of the code is very complicated.

> > just that we don't use it for locating the file currently and I was
> > proposing
> > that we do. Please correct me if this is wrong, or whether a better way
is
> > possible.
> >
> > > This patch doesn't change anything--it only adds new lines.  If
you're
> > > trying to make minimal changes, that's admirable, but break up the
> > > patches in such a way that each patch shows that minimal change.
> >
> > To make each revision compile cleanly, I had to add the infrastructure
and
> > then delete the old one. So it looks like new code. The entire function
and
> > data structures are re-written so it is difficult to break into
individual
> > components where each will compile clean.
>
> Breaking up a complex change into logical individual steps, each of
> which compile and run cleanly, is sometimes tricky.  So it may be that
> there *is* some way to do it in this case, but that you just haven't
> found it yet.
>
> That said, it could be, as you say, that this requires just replacing
> everything.  In that case, please just start over from scratch and don't
> feel bound to keep stuff from the old implementation that you don't
> understand.

OK.

thanks,

- KK

