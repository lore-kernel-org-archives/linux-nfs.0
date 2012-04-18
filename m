Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:51233 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790Ab2DRRfm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Apr 2012 13:35:42 -0400
Date: Wed, 18 Apr 2012 18:35:37 +0100
From: Luis Henriques <luis.henriques@canonical.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Regretion on NFS in mainline kernel
Message-ID: <20120418173537.GE3979@zeus>
References: <20120418112610.GA3979@zeus>
 <20120418092822.07a4f944@tlielax.poochiereds.net>
 <20120418135738.GB3979@zeus>
 <1334757866.4701.6.camel@lade.trondhjem.org>
 <20120418141313.GC3979@zeus>
 <20120418101554.4aad0849@tlielax.poochiereds.net>
 <1334760105.4701.11.camel@lade.trondhjem.org>
 <20120418105147.2a6f1c55@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120418105147.2a6f1c55@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 18, 2012 at 10:51:47AM -0400, Jeff Layton wrote:
> On Wed, 18 Apr 2012 14:41:45 +0000
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > Right. Random (and wrong!) changes such as the above won't fix the
> > problem. That code is perfectly correct (look at the nfs4_reclaim_locks
> > error cases to see why).
> > 
> 
> Ugh, ok I see and that code is correct even if it's a bit hard to
> follow...
> 
> We clear the state_flag_bit on the first attempt against that lock so
> if it returns 0 (meaning a successful reclaim, we'll skip over it on
> the next pass through the loop.
> 
> > Have you instead looked into what these applications are doing? Are they
> > perhaps opening the file read only, then trying to apply an exclusive
> > BSD lock (something which NFSv4 cannot support)?
> > 
> > IOW: does the problem go away if you mount with 'local_lock=flock'?
> > 
> I suspect that that is the trigger here. Sadly common among userspace
> apps...

Ok, I'll ask some of the guys reporting the bug to try to use that option
to mount.  Is there any other useful information that could be collected
to help sorting this out?

Btw, there was someone reporting that an easy reproducer of this problem
is to just run:

  $ /usr/bin/flock /file/on/nfs echo Fish

Cheers,
--
Luis
