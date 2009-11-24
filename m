From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Tue, 24 Nov 2009 17:58:24 -0500
Message-ID: <1259103504.7672.47.camel@localhost>
References: <19211.7054.291514.185591@notabene.brown>
	 <4B0BEDDB.1010203@RedHat.com> <20091124205616.GB29856@fieldses.org>
	 <20091125085122.316f4eb3@notabene.brown> <4B0C5705.6030608@redhat.com>
	 <20091125092227.77735d5a@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Peter Staubach <staubach@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:34325 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934057AbZKXW6Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 17:58:24 -0500
In-Reply-To: <20091125092227.77735d5a-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-11-25 at 09:22 +1100, Neil Brown wrote: 
> On Tue, 24 Nov 2009 16:58:29 -0500
> Peter Staubach <staubach@redhat.com> wrote:
> 
> > I think that we might be better off in the long run by taking a
> > step back and getting all of the plumbing right, instead of
> > cluttering up things to have knowledge which they have no
> > business knowing or worrying about.
> 
> In principle, I completely agree.
> 
> 
> > 
> > If the NFSv4 server gets a request which involves the root file
> > handle and one has not been defined, then it should return the
> > error that is defined by the protocol.  What the client chooses
> > to do with the error is up to it.
> 
> There is no error for "root file handle has not been defined".
> 
> The only errors available for PUTROOTFH are:
>  NFS4ERR_RESOURCE - which means "I'm exchausted after all the other
>                     work you made me do" and shouldn't be returned for
>                     the first op in a compound (that is an implied
>                     restriction, not explicit).
>  NFS4ERR_SERVERFAULT which means something strange went wrong.  This is
>                     probably the closest, hence Bruce's recent patch to
>                     use this error code.
>  NFS4ERR_WRONGSEC   which means the security mechanism used by the
>                     client isn't acceptable to the server.  This is
>                     certainly not usable in this context.
> 
> So NFS4ERR_SERVERFAULT would be OK simply because it is a wildcard.
> But RPC_PROG_MISMATCH, which means "I don't support that version of the
> protocol" would also be correct in this case and it trivial for the
> client to interpret.

One response that the spec allows is to accept the PUTROOTFH, but to
return either NFS4ERR_BADHANDLE or NFS4ERR_SERVERFAULT on any operation
that attempts to use the resulting filehandle.

Cheers
  Trond

