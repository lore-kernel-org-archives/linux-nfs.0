From: David Teigland <teigland@redhat.com>
Subject: Re: [PATCH 10/10] gfs2: nfs lock support for gfs2
Date: Wed, 6 Dec 2006 15:42:31 -0600
Message-ID: <20061206214231.GC25322@redhat.com>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu> <70549752c06e54117024429649fd7aa813f21bec.1165380893.git.bfields@citi.umich.edu> <20061206154951.GB16378@redhat.com> <20061206195722.GH1714@fieldses.org> <20061206205822.GB25322@redhat.com> <20061206212347.GA25465@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20061206212347.GA25465@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Dec 06, 2006 at 04:23:47PM -0500, J. Bruce Fields wrote:
> On Wed, Dec 06, 2006 at 02:58:22PM -0600, David Teigland wrote:
> > On Wed, Dec 06, 2006 at 02:57:22PM -0500, J. Bruce Fields wrote:
> > > The more annoying problem is the need to cancel the GFS lock when
> > > fl_notify fails; is that something that it's possible for GFS to do?
> > > 
> > > It can fail because lockd has a timeout--it waits a few seconds for the
> > > callback, then gives up and returns a failure to the user.  If that
> > > happens after your userspace posix lock manager acquires the lock (but
> > > before fl_notify is called) then you've got to cancel it somehow.
> > 
> > I'd think we could just send an unlock for it at that point.  Set up an op
> > with GDLM_PLOCK_OP_UNLOCK and the same fields as the lock you're removing
> > and call send_op().  We probably need to flag this internal-unlock op so
> > that when the result arrives, device_write() delists and frees it itself.
> > 
> > (I wouldn't call this "canceling", I think of cancel as trying to force a
> > blocked request to return/fail prematurely.)
> 
> I call it a cancel because it should leave us in the same state we were
> in if we hadn't done the lock.  An unlock doesn't do that, because the
> original lock may have coalesced and/or downgraded existing locks.

Oh yeah, that's painful, I knew it sounded too easy.

Dave

