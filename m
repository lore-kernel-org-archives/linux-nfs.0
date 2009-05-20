From: "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>
Subject: RE: NFS-CIFS locking
Date: Wed, 20 May 2009 09:38:21 -0700
Message-ID: <A7DEA48C84FD0B48AAAE33F328C02014030F3FB1@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
References: <A7DEA48C84FD0B48AAAE33F328C02014030F3FAA@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca><20090520112233.40e0b905@tlielax.poochiereds.net><A7DEA48C84FD0B48AAAE33F328C02014030F3FAF@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca> <20090520122357.43c33fd7@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bby1mta02.pmc-sierra.com ([216.241.235.117]:52433 "EHLO
	bby1mta02.pmc-sierra.bc.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753412AbZETQiZ convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 May 2009 12:38:25 -0400
In-Reply-To: <20090520122357.43c33fd7-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

Thanks much for your inputs.

I have tried to get some info from samba list but no luck.

My proposed system is a fileserver which is supposed to be share point
for both windows and Linux ( CIFS and NFS). So I can't point one
particular application. Basically I want to rule out file corruption
while sharing single file across multiple protocols.

Thanks
Anoop

> -----Original Message-----
> From: Jeff Layton [mailto:jlayton@redhat.com]
> Sent: Wednesday, May 20, 2009 9:54 PM
> To: Anoop P.A.
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: NFS-CIFS locking
> 
> On Wed, 20 May 2009 09:12:24 -0700
> "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org> wrote:
> 
> > Hi Jeff,
> >
> > Thanks for your reply. Basically what I want is "the file which is
used
> under CIFS share should not get overwritten from  a nfs share and vice
> versa." . I might be looking for mandatory file locking in nfs share.
> >
> 
> That may be tricky.
> 
> Mandatory locking under unix is rather rare. Most unix apps use
> advisory locking. Windows however uses mandatory locking pretty much
> exclusively. The semantics of windows locks are quite different --
they
> don't necessarily map 1:1, particularly when you get into how
> overlapping byte ranges are handled and such.
> 
> The best advice I can offer is to understand how your apps use locking
> and to do some testing to simulate those use cases. That should help
> outline where the differences are.
> 
> Again, the samba lists are probably a better forum for this
discussion.
> The developers that lurk on those lists generally have a good
> understanding of the subtleties involved in mapping file locks between
> the two platforms.
> 
> With more specific questions you may be able to get more helpful
> answers as well.
> 
> --
> Jeff Layton <jlayton@redhat.com>
