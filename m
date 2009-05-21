From: "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>
Subject: RE: NFS-CIFS locking
Date: Thu, 21 May 2009 00:23:30 -0700
Message-ID: <A7DEA48C84FD0B48AAAE33F328C02014030F3FB4@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
References: <A7DEA48C84FD0B48AAAE33F328C02014030F3FAA@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca><20090520112233.40e0b905@tlielax.poochiereds.net><A7DEA48C84FD0B48AAAE33F328C02014030F3FAF@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca><20090520122357.43c33fd7@tlielax.poochiereds.net><A7DEA48C84FD0B48AAAE33F328C02014030F3FB1@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca> <20090520124723.163172b1@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bby1mta02.pmc-sierra.com ([216.241.235.117]:34494 "EHLO
	bby1mta02.pmc-sierra.bc.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750794AbZEUHXd convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2009 03:23:33 -0400
In-Reply-To: <20090520124723.163172b1-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That's true. But consider following conditions,

1. Copy one "1 GB" file to nfs share using command "cp". While cp is
progressing try deleting that file from CIFS share. 

2. Copy one "1 GB" file to CIFS share using "Drag n Drop". While copy is
progressing try deleting that file from NFS share

What I would expect in these scenarios is "user should  not be able to
delete the file under copying".

I assume linux "cp" implementation will not lock a file under copying
(At least I didn't see any fcntl / flock calls on tracing cp).

So I assume this is quite normal in Linux environment (file in use at
one place can be deleted from another shell). But in a mixed environment
windows client will expect an open file to be protected from being
deleted.

Is it possible to achieve this?.

Thanks
Anoop
 
> -----Original Message-----
> From: Jeff Layton [mailto:jlayton@redhat.com]
> Sent: Wednesday, May 20, 2009 10:17 PM
> To: Anoop P.A.
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: NFS-CIFS locking
> 
> On Wed, 20 May 2009 09:38:21 -0700
> "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org> wrote:
> 
> > Hi Jeff,
> >
> > Thanks much for your inputs.
> >
> > I have tried to get some info from samba list but no luck.
> >
> > My proposed system is a fileserver which is supposed to be share
point
> > for both windows and Linux ( CIFS and NFS). So I can't point one
> > particular application. Basically I want to rule out file corruption
> > while sharing single file across multiple protocols.
> >
> 
> That's a very different situation than what you originally asked. You
> asked about cross-protocol locking. That's achievable, but it depends
> on using applications that actually do lock the files and some
> understanding about what you get when you lock the files in this way.
> 
> If you don't have well-behaved apps that lock files to guard against
> concurrent access, then you'll have problems even if you're not using
> NFS and samba together.
> 
> --
> Jeff Layton <jlayton@redhat.com>
