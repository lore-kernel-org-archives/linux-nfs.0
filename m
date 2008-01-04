From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 12:42:16 -0500
Message-ID: <20080104174216.GG17112@fieldses.org>
References: <200801041728.MAA19743@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org, jeff@garzik.org, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Rick Macklem <rick-bYVALtacgsT800Iu1Vt84J3p9npsUQCG@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36432 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035AbYADRmW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 12:42:22 -0500
In-Reply-To: <200801041728.MAA19743-bYVALtacgsT800Iu1Vt84J3p9npsUQCG@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 04, 2008 at 12:28:26PM -0500, Rick Macklem wrote:
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

I was hoping that FH4_VOL_NOEXPIRE_WITH_OPEN might also cover opens over
server reboot, but that's a question for the ietf list.  And perhaps the
requirement to keep that filehandle->inode mapping in persistant storage
would negate the advantage to the server of volatile filehandles.

> Even if there is a "don't expire while Open" guarantee, it's still a pita
> for the client to hang onto pathnames for directories and such, so that
> they can re-lookup the fh. (And if that re-lookup happens to fail or end
> up in a different place?)

I'm confused--can't you just throw away your lookup/readdir cache for
that directory and not use it again until an application actually does a
new lookup?

Oh, but I guess the client can hold references to the directory itself
in the form of filehandles or current working directories.  So I guess
you'd need some kind of open/close (or get/put) operations for
directories as well to get agreed-on lifetimes for directory
filehandles.  Does it still seem worth it after all that?

--b.
