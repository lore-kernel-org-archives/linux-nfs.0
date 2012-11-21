Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58856 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964810Ab2KUUoM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Nov 2012 15:44:12 -0500
Date: Wed, 21 Nov 2012 15:44:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org, devel@openvz.org,
        Trond.Myklebust@netapp.com, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v2 00/15] NFSd state containerization
Message-ID: <20121121204408.GA23097@fieldses.org>
References: <20121114152018.4708.63125.stgit@localhost.localdomain>
 <20121114220036.GD539@fieldses.org>
 <20121115133408.23db9ebb@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121115133408.23db9ebb@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 15, 2012 at 01:34:08PM -0500, Jeff Layton wrote:
> On Wed, 14 Nov 2012 17:00:36 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Nov 14, 2012 at 06:20:59PM +0300, Stanislav Kinsbursky wrote:
> > > This patch set is my first attempt to containerize NFSv4 state - i.e. make it
> > > works in networks namespace context.
> > > I admit, that some of this new code could be partially rewritten during future
> > > NFSd containerization.
> > > But the overall idea look more or less correct to me.
> > > So, the main things here are:
> > > 1) making nfs4_client network namespace aware.
> > > 2) Allocating all hashes (except file_hashtbl and reclaim_str_hashtbl) per
> > > network namespace context on NFSd start (not init) and destroying on NFSd
> > > state shutdown.
> > > 3) Allocating of reclaim_str_hashtbl on legacy tracker start and destroying on
> > > legacy tracker stop.
> > > 4) Moving of client_lru and close_lru lists to per-net data.
> > > 5) Making lundromat network namespace aware.
> > 
> > These look OK and pass my tests.  Jeff, do the revised recovery bits
> > look OK?
> > 
> > Have you done any testing?
> > 
> > It'd be interesting, for example, to know if there are any pynfs that
> > fail against the server in a non-init network namespace, but pass
> > normally.
> > 
> > --b.
> > 
> 
> I looked over the patches and they look sane to me. I move that they go
> into your -next branch to soak for a bit.

Stanislav, actually, I'm unclear, since you labeled these "RFC": do you
consider these patches ready?

--b.
