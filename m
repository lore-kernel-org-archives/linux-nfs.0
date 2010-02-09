Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:47153 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259Ab0BIWoL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 17:44:11 -0500
Subject: Re: [PATCH pynfs] Allow server to reject maximum commit offsets
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Peter Staubach <staubach@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, iisaman@citi.umich.edu,
        linux-nfs@vger.kernel.org
In-Reply-To: <4B71E1A4.1070604@redhat.com>
References: <20100209201231.GC30951@fieldses.org>
	 <4B71E1A4.1070604@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 09 Feb 2010 17:44:03 -0500
Message-ID: <1265755443.28562.100.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-02-09 at 17:28 -0500, Peter Staubach wrote: 
> J. Bruce Fields wrote:
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > These two tests insist that a server must accept commits with offset
> > 2^64-1 and 2^64-2.  I can find no justification in the spec for this
> > requirement.
> > 
> > The linux server was recently changed to reject (with INVAL) offsets
> > over 2^63-1, which is the maximum that the vfs commit routine can
> > accept.  That behavior is consistent with the NFSv3 commit
> > implementation and with the NFSv4 write implementation.
> > 
> 
> I guess that I am missing something.  At least the NFSv3
> COMMIT operation takes an unsigned 64 bit quantity.  That
> would seem to make the test correct, would it not?

The server will not allow you to write to an offset > 2^63-1 (it will
return NFS3ERR_INVAL), so it makes zero sense for the client to try to
issue a COMMIT for an offset starting in that range.

Cheers
  Trond

