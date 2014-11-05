Return-Path: linux-nfs-owner@vger.kernel.org
Received: from dgate10.ts.fujitsu.com ([80.70.172.49]:50237 "EHLO
	dgate10.ts.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaKEVZe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2014 16:25:34 -0500
From: =?Windows-1252?Q?Str=F6sser=2C_Bodo?=
	<bodo.stroesser@ts.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "neilb@suse.de" <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 5 Nov 2014 22:25:26 +0100
Subject: RE: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
Message-ID: <8B06D1E6480A6747B23FEC34909D2B5EA81B95F24C@ABGEX70E.FSC.NET>
References: <61eb00$5dituo@dgate20u.abg.fsc.net>
 <20141105210546.GH6513@fieldses.org>
In-Reply-To: <20141105210546.GH6513@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Wednesday, November 05, 2014 10:06 PM
> To: Strösser, Bodo
> Cc: neilb@suse.de; linux-nfs@vger.kernel.org
> Subject: Re: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
> 
> On Wed, Nov 05, 2014 at 09:21:37PM +0100, bstroesser@ts.fujitsu.com wrote:
> > Hello,
> >
> > I'm sending a small set of 3 patches for a problem, that I have
> > reported a few weeks ago.
> > rpc.mountd can be blocked by a bad client, that sends lots of
> > RPC requests, but never reads the replies from the socket either
> > intentionally or e.g. caused by a wrong configured MTU.
> >
> > While looking for a possible solution, I found another weakness
> > in rpc.mountd if it is used "multithreaded" (-t nn).
> >
> > The first two patches fix that weakness in the case of !HAVE_LIBTIRPC
> > and HAVE_LIBTIRPC.
> 
> They look fine to me.
> 
> > The third patch more a kind of suggestion how the main problem could
> > be fixed.
> 
> Sounds reasonable to me.
> 
> > I don't know whether we can set MAXREC without causing
> > new troubles. When this patch is used, a  further patch for libtirpc
> > also should be used. You can find it here:
> >     http://sourceforge.net/p/libtirpc/mailman/libtirpc-devel/?viewmonth=201409
> 
> So applying this last patch and then building against an unpatched
> libtirpc would expose us to a serious bug?  Do we need to do something
> to make that less likely to happen?

The bug in libtirpc is triggered, if the write() to the socket returns -EAGAIN
but one of the many retries in the following 2 seconds succeeds. Then the
normal reply is sent with a prefix of (maybe many) bytes from rpc.mountd's
memory space before the reply buffer. That means, that some data from memory is
sent (authentication data?) or rpc.mountd might get SIGSEGV, I don't know.

But I think it won't be easy to trigger this. rpcbind uses the nonblocking mode
of libtirpc and no one complains about the bug in libtirpc.

Anyway, it of course would be better to use a fixed libtirpc, as I can't see a
way to have a work around in rpc.mountd for the libtirpc bug.

Bodo

> 
> --b.
> 
> >
> > Best regards,
> > Bodo
