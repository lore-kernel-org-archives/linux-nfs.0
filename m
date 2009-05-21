From: "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>
Subject: RE: NFS-CIFS locking
Date: Thu, 21 May 2009 05:24:34 -0700
Message-ID: <A7DEA48C84FD0B48AAAE33F328C02014030F3FBE@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
References: <A7DEA48C84FD0B48AAAE33F328C02014030F3FAA@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca><20090520112233.40e0b905@tlielax.poochiereds.net><A7DEA48C84FD0B48AAAE33F328C02014030F3FAF@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca><20090520122357.43c33fd7@tlielax.poochiereds.net><A7DEA48C84FD0B48AAAE33F328C02014030F3FB1@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca><20090520124723.163172b1@tlielax.poochiereds.net><A7DEA48C84FD0B48AAAE33F328C02014030F3FB4@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca> <20090521075936.60f26c0e@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bby1mta02.pmc-sierra.com ([216.241.235.117]:55371 "EHLO
	bby1mta02.pmc-sierra.bc.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750705AbZEUMYe convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2009 08:24:34 -0400
In-Reply-To: <20090521075936.60f26c0e-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok then keep the things as it is a better idea right?

Thanks
Anoop


> -----Original Message-----
> From: Jeff Layton [mailto:jlayton@redhat.com]
> Sent: Thursday, May 21, 2009 5:30 PM
> To: Anoop P.A.
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: NFS-CIFS locking
> 
> On Thu, 21 May 2009 00:23:30 -0700
> "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org> wrote:
> 
> > That's true. But consider following conditions,
> >
> > 1. Copy one "1 GB" file to nfs share using command "cp". While cp is
> > progressing try deleting that file from CIFS share.
> >
> > 2. Copy one "1 GB" file to CIFS share using "Drag n Drop". While
copy is
> > progressing try deleting that file from NFS share
> >
> > What I would expect in these scenarios is "user should  not be able
to
> > delete the file under copying".
> >
> 
> I'm afraid that expectation is wrong, at least on unix.
> 
> > I assume linux "cp" implementation will not lock a file under
copying
> > (At least I didn't see any fcntl / flock calls on tracing cp).
> >
> 
> With few exceptions, locks under unix are advisory. They're sort of
> like stoplights -- they only work if everyone is paying attention to
> them.
> 
> > So I assume this is quite normal in Linux environment (file in use
at
> > one place can be deleted from another shell). But in a mixed
environment
> > windows client will expect an open file to be protected from being
> > deleted.
> >
> > Is it possible to achieve this?.
> >
> 
> Not really, no. On unix in general, it's completely legitimate and
> common to remove a file that's open. What will happen is that the
> filename will be removed from the namespace. It won't show up in
> directory listings, and isn't reachable by apps that didn't already
> have it open. Its blocks will still exist on disk however and
> applications that have it open will still be able to work with the
> filehandle normally. Eventually when the last close happens on the
file
> it will be "deleted".
> 
> The fact that windows does not do this has more to do with the way
that
> its local filesystems are designed. It's also an endless source of
> headache for administrators. For instance, backup programs on windows
> often cause real problems for running applications that try to delete
> or rename files while in the middle of being backed up.
> 
> --
> Jeff Layton <jlayton@redhat.com>
