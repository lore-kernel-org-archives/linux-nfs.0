Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35533 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751317AbaKEVzn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 16:55:43 -0500
Date: Wed, 5 Nov 2014 16:55:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
Message-ID: <20141105215541.GJ6513@fieldses.org>
References: <61eb00$5dituo@dgate20u.abg.fsc.net>
 <20141105210546.GH6513@fieldses.org>
 <8B06D1E6480A6747B23FEC34909D2B5EA81B95F24C@ABGEX70E.FSC.NET>
 <20141106084741.40980d12@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20141106084741.40980d12@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 06, 2014 at 08:47:41AM +1100, NeilBrown wrote:
> On Wed, 5 Nov 2014 22:25:26 +0100 "Strösser, Bodo"
> <bodo.stroesser@ts.fujitsu.com> wrote:
> 
> > > -----Original Message-----
> > > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > > Sent: Wednesday, November 05, 2014 10:06 PM
> > > To: Strösser, Bodo
> > > Cc: neilb@suse.de; linux-nfs@vger.kernel.org
> > > Subject: Re: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
> > > 
> > > On Wed, Nov 05, 2014 at 09:21:37PM +0100, bstroesser@ts.fujitsu.com wrote:
> > > > Hello,
> > > >
> > > > I'm sending a small set of 3 patches for a problem, that I have
> > > > reported a few weeks ago.
> > > > rpc.mountd can be blocked by a bad client, that sends lots of
> > > > RPC requests, but never reads the replies from the socket either
> > > > intentionally or e.g. caused by a wrong configured MTU.
> > > >
> > > > While looking for a possible solution, I found another weakness
> > > > in rpc.mountd if it is used "multithreaded" (-t nn).
> > > >
> > > > The first two patches fix that weakness in the case of !HAVE_LIBTIRPC
> > > > and HAVE_LIBTIRPC.
> > > 
> > > They look fine to me.
> > > 
> > > > The third patch more a kind of suggestion how the main problem could
> > > > be fixed.
> > > 
> > > Sounds reasonable to me.
> > > 
> > > > I don't know whether we can set MAXREC without causing
> > > > new troubles. When this patch is used, a  further patch for libtirpc
> > > > also should be used. You can find it here:
> > > >     http://sourceforge.net/p/libtirpc/mailman/libtirpc-devel/?viewmonth=201409
> > > 
> > > So applying this last patch and then building against an unpatched
> > > libtirpc would expose us to a serious bug?  Do we need to do something
> > > to make that less likely to happen?
> > 
> > The bug in libtirpc is triggered, if the write() to the socket returns -EAGAIN
> > but one of the many retries in the following 2 seconds succeeds. Then the
> > normal reply is sent with a prefix of (maybe many) bytes from rpc.mountd's
> > memory space before the reply buffer. That means, that some data from memory is
> > sent (authentication data?) or rpc.mountd might get SIGSEGV, I don't know.
> > 
> > But I think it won't be easy to trigger this. rpcbind uses the nonblocking mode
> > of libtirpc and no one complains about the bug in libtirpc.
> > 
> > Anyway, it of course would be better to use a fixed libtirpc, as I can't see a
> > way to have a work around in rpc.mountd for the libtirpc bug.
> > 
> 
> I agree that hitting the bug is fairly unlikely.  If there is something easy
> we can do to help avoid it, it might be worth it.
> 
> Once the fix gets into a libtirpc release, we could put a hard dependency on
> that release number in configure for nfs-utils.  Is that too harsh??

Yeah, that's more what I was wondering about.

If building new mountd against an old libtirpc meant suddenly mountd was
crashing all the time then it'd seem worth something like that.

If it's an unusual corner case that people have been exposed to in other
ways for a while anyway, then maybe we just trust to distros to get
their libtirpc's fixed and don't worry so much.

--b.
> 
> Steve: you are maintainer for both (?).  Would you be able to make a
> libtirpc release soonish with the mentioned fix, then would you be happy for
> future nfs-utils to require at least that version?
