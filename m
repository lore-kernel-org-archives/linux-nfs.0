From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 12:15:40 -0500
Message-ID: <20080104171540.GC17112@fieldses.org>
References: <200801041548.KAA18953@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org, jeff@garzik.org, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Rick Macklem <rick-bYVALtacgsT800Iu1Vt84J3p9npsUQCG@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49271 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752129AbYADRPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 12:15:48 -0500
In-Reply-To: <200801041548.KAA18953-bYVALtacgsT800Iu1Vt84J3p9npsUQCG@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 04, 2008 at 10:48:39AM -0500, Rick Macklem wrote:
> Sounds like a server implementor's perspective. From a client implementor's
> point of view, a T-stable file handle is a wonderful thing. I have no idea
> how to correctly implement client side support for the volatile file
> handles allowed in NFSv4. My client doesn't support them.

As long as they persist while you have an open (or a delegation), it
shouldn't be so hard to implement, should it?  If a filehandle expires,
then you throw away any cache associated with it, but as long as no
applications hold file descriptors for it, that's not a catastrophe.

But I'm a little confused whether rfc 3530's 4.2.3 gives a way for the
server to express that guarantee.

--b.
