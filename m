Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46893 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089AbbCWJPL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Mar 2015 05:15:11 -0400
Date: Mon, 23 Mar 2015 05:15:07 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Recovery after BAD_SEQID
In-Reply-To: <CAHQdGtSRUdNmx8dhDJ0gPbBuukX4ggUQJ638NMMqjN32Y3uXJg@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1503230455120.779@planck.local>
References: <alpine.OSX.2.19.9992.1503190633310.947@planck.local> <CAHQdGtSRUdNmx8dhDJ0gPbBuukX4ggUQJ638NMMqjN32Y3uXJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 22 Mar 2015, Trond Myklebust wrote:

> On Thu, Mar 19, 2015 at 6:48 AM, Benjamin Coddington
> <bcodding@redhat.com> wrote:
> > I wrote yesterday about a RHEL6 bug, but I'd gotten some details wrong about
> > the problem, so I'm starting new thread.
> >
> > It looks like getting BAD_SEQID back from an OPEN operation drops the state_owner
> > which means that the state machine can't find or recover any other objects
> > for that state_owner.  That can get the client into unrecoverable loops.  I
> > can produce one of them with:
> >
> > 1) OPEN file1, OPEN file2
> > 2) break the network for longer than the lease period
> > 3) during recovery, have the server return BAD_SEQID for one of the OPENS
> > 4) break the network again for longer than the lease period
> > 5) WRITE to the file that recovered properly in #3
> >
> > This gets stuck in WRITE,NFS4ERR_EXPIRED.
> >
> > It looks like some cleanup is needed if we have to drop the whole
> > state_owner.  Alternatively, does it make sense to just drop the objects in
> > that sequence?
> >
> >
>
> Ummm... Why are you seeing BAD_SEQID in the first place? That specific
> error means that the client and server disagree on the sequencing of
> the OPENs, which means there is a bug either on the client or on the
> server.

It definitely needs a server bug to get here, and unfortunately that server
bug is out there.  I'd like to have the client not get stuck when
encountering this bug.  Recovery here would mean that we return
EIO instead of getting stuck endlessly trying to complete a write for
another open file.

I wonder now what should be the position of the client upon "discovering"
there's a bug somewhere.  That bug could be client or server.  Should the
client blacklist the server at that point, or can other sequences continue?

Ben
