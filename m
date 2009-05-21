From: Jeff Layton <jlayton@redhat.com>
Subject: Re: NFS-CIFS locking
Date: Thu, 21 May 2009 07:59:36 -0400
Message-ID: <20090521075936.60f26c0e@barsoom.rdu.redhat.com>
References: <A7DEA48C84FD0B48AAAE33F328C02014030F3FAA@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
	<20090520112233.40e0b905@tlielax.poochiereds.net>
	<A7DEA48C84FD0B48AAAE33F328C02014030F3FAF@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
	<20090520122357.43c33fd7@tlielax.poochiereds.net>
	<A7DEA48C84FD0B48AAAE33F328C02014030F3FB1@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
	<20090520124723.163172b1@tlielax.poochiereds.net>
	<A7DEA48C84FD0B48AAAE33F328C02014030F3FB4@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <linux-nfs@vger.kernel.org>
To: "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33152 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752771AbZEUL7z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2009 07:59:55 -0400
In-Reply-To: <A7DEA48C84FD0B48AAAE33F328C02014030F3FB4-WnaG5mLaJUsadWZoJ9kThg@public.gmane.org_nt.nt.pmc-sierra.bc.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 21 May 2009 00:23:30 -0700
"Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org> wrote:

> That's true. But consider following conditions,
> 
> 1. Copy one "1 GB" file to nfs share using command "cp". While cp is
> progressing try deleting that file from CIFS share. 
> 
> 2. Copy one "1 GB" file to CIFS share using "Drag n Drop". While copy is
> progressing try deleting that file from NFS share
> 
> What I would expect in these scenarios is "user should  not be able to
> delete the file under copying".
> 

I'm afraid that expectation is wrong, at least on unix.

> I assume linux "cp" implementation will not lock a file under copying
> (At least I didn't see any fcntl / flock calls on tracing cp).
> 

With few exceptions, locks under unix are advisory. They're sort of
like stoplights -- they only work if everyone is paying attention to
them.

> So I assume this is quite normal in Linux environment (file in use at
> one place can be deleted from another shell). But in a mixed environment
> windows client will expect an open file to be protected from being
> deleted.
> 
> Is it possible to achieve this?.
> 

Not really, no. On unix in general, it's completely legitimate and
common to remove a file that's open. What will happen is that the
filename will be removed from the namespace. It won't show up in
directory listings, and isn't reachable by apps that didn't already
have it open. Its blocks will still exist on disk however and
applications that have it open will still be able to work with the
filehandle normally. Eventually when the last close happens on the file
it will be "deleted".

The fact that windows does not do this has more to do with the way that
its local filesystems are designed. It's also an endless source of
headache for administrators. For instance, backup programs on windows
often cause real problems for running applications that try to delete
or rename files while in the middle of being backed up.

-- 
Jeff Layton <jlayton@redhat.com>
