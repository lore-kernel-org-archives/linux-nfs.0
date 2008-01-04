From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 12:45:05 -0500
Message-ID: <1199468705.8968.11.camel@heimdal.trondhjem.org>
References: <200801041728.MAA19743@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org, gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org
To: Rick Macklem <rick-bYVALtacgsT800Iu1Vt84J3p9npsUQCG@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:38361 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128AbYADRpR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 12:45:17 -0500
In-Reply-To: <200801041728.MAA19743-bYVALtacgsT800Iu1Vt84J3p9npsUQCG@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-01-04 at 12:28 -0500, Rick Macklem wrote:
> > As long as they persist while you have an open (or a delegation), it
> > shouldn't be so hard to implement, should it?  If a filehandle expires,
> > then you throw away any cache associated with it, but as long as no
> > applications hold file descriptors for it, that's not a catastrophe.
> > 
> > But I'm a little confused whether rfc 3530's 4.2.3 gives a way for the
> > server to express that guarantee.
> 
> Agreed, but I've always assumed the server can return NFS4ERR_FHEXPIRED
> at any time. (It's listed as a error for many Ops, such as Read and Write.)
> Also, what does a client do after a server reboot. It can't use
> Open/Claim_previous for recovery.

You need to check the fh_expire_type attribute in order to figure out
what the rules are. If the bits FH4_VOLATILE_ANY and
FH4_NO_EXPIRE_WITH_OPEN are set, then the rule is that the filehandle
will not expire on OPEN as Bruce said.

On server reboot, the client gets the additional task of recovering
filehandles before it can recover opens. It can't do an OPEN by
pathname, since the server may have imposed a grace period, which will
not allow this.
Yes, this is all very silly...

> Even if there is a "don't expire while Open" guarantee, it's still a pita
> for the client to hang onto pathnames for directories and such, so that
> they can re-lookup the fh. (And if that re-lookup happens to fail or end
> up in a different place?)

Worse: if the server doesn't support fileids (which are non-mandatory
'cos NTFS & co don't have them) then you have no way to figure out if
the directory you just looked up is the same as the one you have cached.

So, while volatile filehandles may seem like a boon to server
implementations, they can still make life hell for the clients.

Trond

