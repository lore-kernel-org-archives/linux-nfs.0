Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42929 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753346Ab0BIWtx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 17:49:53 -0500
Date: Tue, 9 Feb 2010 17:50:18 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Peter Staubach <staubach@redhat.com>
Cc: iisaman@citi.umich.edu, linux-nfs@vger.kernel.org
Subject: Re: [PATCH pynfs] Allow server to reject maximum commit offsets
Message-ID: <20100209225018.GB1645@fieldses.org>
References: <20100209201231.GC30951@fieldses.org> <4B71E1A4.1070604@redhat.com> <20100209224228.GA1645@fieldses.org> <4B71E572.3020401@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B71E572.3020401@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 09, 2010 at 05:45:06PM -0500, Peter Staubach wrote:
> J. Bruce Fields wrote:
> > On Tue, Feb 09, 2010 at 05:28:52PM -0500, Peter Staubach wrote:
> >> J. Bruce Fields wrote:
> >>> From: J. Bruce Fields <bfields@citi.umich.edu>
> >>>
> >>> These two tests insist that a server must accept commits with offset
> >>> 2^64-1 and 2^64-2.  I can find no justification in the spec for this
> >>> requirement.
> >>>
> >>> The linux server was recently changed to reject (with INVAL) offsets
> >>> over 2^63-1, which is the maximum that the vfs commit routine can
> >>> accept.  That behavior is consistent with the NFSv3 commit
> >>> implementation and with the NFSv4 write implementation.
> >>>
> >> I guess that I am missing something.  At least the NFSv3
> >> COMMIT operation takes an unsigned 64 bit quantity.  That
> >> would seem to make the test correct, would it not?
> > 
> > Yes, it's an unsigned 64 bit integer, but so what: there's no rule that
> > says the server has to return NFS4ERR_OK to any operation for which all
> > the arguments are valid xdr.
> > 
> > And just because the protocol allows 64-bit offsets doesn't mean every
> > server and filesystem is going to support the full range.
> > 
> 
> No, that's certainly true.  However, you are tailoring the
> testsuite to a Linux specific implementation, which strikes
> me as vaguely not so good.  What if you just commented out
> the tests, with a comment indicating that the Linux server
> can not handle the full 64 bits of range, instead of
> deleting them completely?

The tests are primarily meant to test protocol conformance.  So they
shouldn't be reporting failures on conforming behavior.

Perhaps it would also be interesting to run the tests in a mode which
probes and summarizes server characteristics (maximum supported offset,
supported features, etc.), but that's a job for another day.

--b.
