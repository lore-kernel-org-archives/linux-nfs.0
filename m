From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/11] nfsd: CHANGE old function calls to new calls
Date: Fri, 24 Apr 2009 15:25:06 -0400
Message-ID: <20090424192506.GQ17365@fieldses.org>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090325133707.16437.66360.sendpatchset@localhost.localdomain> <20090422200553.GH9541@fieldses.org> <OFB63DF5D6.1A77785C-ON652575A1.004F6726-652575A1.00577C61@in.ibm.com> <20090423223909.GF1906@fieldses.org> <OFC1241E6B.C4476A61-ON652575A2.00207885-652575A2.00598912@in.ibm.com> <20090424162321.GB17365@fieldses.org> <OFBB4FF305.DD2B4946-ON652575A2.005CB412-652575A2.005D3AC2@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>, jlayton@redhat.com,
	Krishna Kumar <krikku@gmail.com>, linux-nfs@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:46293 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbZDXTZO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2009 15:25:14 -0400
In-Reply-To: <OFBB4FF305.DD2B4946-ON652575A2.005CB412-652575A2.005D3AC2@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2009 at 10:28:18PM +0530, Krishna Kumar2 wrote:
> Hi Bruce,
> 
> "J. Bruce Fields" <bfields@fieldses.org> wrote on 04/24/2009 09:53:21 PM:
> 
> > > {
> > >       __u32 a = auth[0], b = auth[1], c = auth[2], d = auth[3];
> > >       hash = jhash_3words(a, b, jhash_2words(c, d, 0), 0xfeedbeef) &
> > >                                     FHPARM_HASH_MASK;
> > >       ...
> > >       /*
> > >        * Matching check uses something like:
> > >        * if (fh->p_auth1 == a && fh->p_auth2 == b && fh->p_auth3 == c
> &&
> > > fh->p_auth4 == d)
> > >        */
> > > }
> > >
> > > Is what you had in mind? I am testing some more with this, so far I get
> > > different values for different files and filesystems.
> > >
> > > I am not sure if there is an easier way to do a hash and get the unique
> > > file
> > > associated with the filehandle, this part of the code is very
> complicated.
> >
> > Why not just do a hash on the entire filehandle, however long it may be?
> 
> I am not sure how many numbers to hash on, usually the first 4 numbers are
> the
> ino, inode generation, parent inode, parent inode generation, etc, and is a
> unique match. Or filesystems can have their own encode handlers but store
> similar stuff in these indices. I guess a memcmp could also be done if I
> know
> the length of the auth being used.

Why not use the whole thing?:

	fh1->fh_size == fh2->fh_size
		&& memcmp(fh1->fh_base, fh2->fh_base, fh1->fh_size) == 0

--b.

> 
> > (Cc'ing Greg since he says he had some patches which did something
> > similar, and perhaps he could offer a suggestion.)
> 
> OK, will wait for response from Greg.
> 
> thanks,
> 
> - KK
> 
