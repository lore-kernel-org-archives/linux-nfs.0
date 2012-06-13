Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38091 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324Ab2FMP4w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jun 2012 11:56:52 -0400
Date: Wed, 13 Jun 2012 11:56:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: RPC: fragment too large with transition to 3.4
Message-ID: <20120613155651.GB1178@fieldses.org>
References: <20120610090342.GA5076@cucamonga.audible.transient.net>
 <20120611161425.GF31109@pad.fieldses.org>
 <20120612101339.GB30293@cucamonga.audible.transient.net>
 <20120612111802.GI31109@pad.fieldses.org>
 <20120612123644.GA16430@fieldses.org>
 <20120613060627.GA11421@cucamonga.audible.transient.net>
 <20120613092703.GA4701@cucamonga.audible.transient.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120613092703.GA4701@cucamonga.audible.transient.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 13, 2012 at 09:27:03AM +0000, Jamie Heilman wrote:
> Jamie Heilman wrote:
> > It's looking like my issues with "RPC: fragment too large" may be
> > something else entirely at this point, I've noticed other weird
> > network behavior that I'm gonna have to try to isolate before I keep
> > blaming nfs changes.  Though for some reason my
> > /proc/fs/nfsd/max_block_size ends up only 128KiB w/3.4 where it was
> > 512KiB w/3.3.
> 
> OK, I get it now.  32-bit PAE system w/4G of RAM (minus a chunk for
> the IGP video etc.) for my NFS server, and the max_block_size
> calculation changed significantly in commit
> 508f92275624fc755104b17945bdc822936f1918 to account for rpc buffers
> only being in low memory.  That means whereas in 3.3 the math came out
> to having a target size of roughly 843241 my new target size in 3.4 is
> only 219959-ish, so choosing 128KiB is understandable.  The problem
> was that all my clients had negotiated their nfs mounts against the
> v3.3 value of 512KiB, and when I rebooted into 3.4... they hit the
> wall attempting larger transfers and become uselessly stuck at that
> point.  If I remount everything before doing any large transfers, then
> it negotiates a lower wsize and things work fine.  So everything is
> working as planned I suppose... the transition between 3.3 and 3.4 is
> just a bit rough.

Oh, got it, thanks.  Yes, now I remember I've seen that problem before.

Perhaps we should be more careful about tweaks to that calculation that
may result in a decreased r/wsize.  You could also get into the same
situation if you took the server down to change the amount of RAM, but
only if you were *removing* memory, which is probably unusual.

Best might be if distributions set max_block_size--it should be easier
for userspace to remember the value across reboots.

While we're at it we also want to create an /etc/nfsd.conf that rpc.nfsd
could read, for setting this, and number of threads, and a few other
things.  The systemd people would prefer that to the current practice of
sourcing a shell script in /etc/sysconfig or /etc/default.

We could warn about this problem ("don't decrease max_block_size on a
server without unmounting clients first") next to that variable in the
config file.

I think we can do the same calculation as nfsd_create_serv() does from
userspace to set an initial default.  I don't know if that should happen
on package install or on first run of rpc.nfsd.

For now that's a project looking for a volunteer, though.

--b.
