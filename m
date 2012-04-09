Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47560 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886Ab2DIQjF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 12:39:05 -0400
Date: Mon, 9 Apr 2012 12:39:02 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Grace period
Message-ID: <20120409163902.GD6482@fieldses.org>
References: <20120406234039.GA20940@fieldses.org>
 <4F82C6E3.3030009@parallels.com>
 <20120409094743.56932677@tlielax.poochiereds.net>
 <4F82F16C.7030303@parallels.com>
 <20120409112739.6a823d6f@corrin.poochiereds.net>
 <4F830999.5000504@parallels.com>
 <20120409161114.GB6482@fieldses.org>
 <1333988226.2688.76.camel@lade.trondhjem.org>
 <20120409162107.GC6482@fieldses.org>
 <1333989216.2688.87.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1333989216.2688.87.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 09, 2012 at 04:33:36PM +0000, Myklebust, Trond wrote:
> On Mon, 2012-04-09 at 12:21 -0400, bfields@fieldses.org wrote:
> > On Mon, Apr 09, 2012 at 04:17:06PM +0000, Myklebust, Trond wrote:
> > > On Mon, 2012-04-09 at 12:11 -0400, bfields@fieldses.org wrote:
> > > > On Mon, Apr 09, 2012 at 08:08:57PM +0400, Stanislav Kinsbursky wrote:
> > > > > 09.04.2012 19:27, Jeff Layton пишет:
> > > > > >
> > > > > >If you allow one container to hand out conflicting locks while another
> > > > > >container is allowing reclaims, then you can end up with some very
> > > > > >difficult to debug silent data corruption. That's the worst possible
> > > > > >outcome, IMO. We really need to actively keep people from shooting
> > > > > >themselves in the foot here.
> > > > > >
> > > > > >One possibility might be to only allow filesystems to be exported from
> > > > > >a single container at a time (and allow that to be overridable somehow
> > > > > >once we have a working active/active serving solution). With that, you
> > > > > >may be able limp along with a per-container grace period handling
> > > > > >scheme like you're proposing.
> > > > > >
> > > > > 
> > > > > Ok then. Keeping people from shooting themselves here sounds reasonable.
> > > > > And I like the idea of exporting a filesystem only from once per
> > > > > network namespace.
> > > > 
> > > > Unfortunately that's not going to get us very far, especially not in the
> > > > v4 case where we've got the common read-only pseudoroot that everyone
> > > > has to share.
> > > 
> > > I don't see how that can work in cases where each container has its own
> > > private mount namespace. You're going to have to tie that pseudoroot to
> > > the mount namespace somehow.
> > 
> > Sure, but in typical cases it'll still be shared; requiring that they
> > not be sounds like a severe limitation.
> 
> I'd expect the typical case to be the non-shared namespace: the whole
> point of containers is to provide for complete isolation of processes.
> Usually that implies that you don't want them to be able to communicate
> via a shared filesystem.

If it's just a file server, then you may want to be able to bring up and
down service on individual server ip's individually, and possibly
advertise different exports; but requiring complete isolation to do that
seems like overkill.

--b.
