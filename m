Return-Path: linux-nfs-owner@vger.kernel.org
Received: from audible.transient.net ([216.254.12.79]:55054 "HELO
	audible.transient.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751694Ab2FMJ1H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jun 2012 05:27:07 -0400
Date: Wed, 13 Jun 2012 09:27:03 +0000
From: Jamie Heilman <jamie@audible.transient.net>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: RPC: fragment too large with transition to 3.4
Message-ID: <20120613092703.GA4701@cucamonga.audible.transient.net>
References: <20120610090342.GA5076@cucamonga.audible.transient.net>
 <20120611161425.GF31109@pad.fieldses.org>
 <20120612101339.GB30293@cucamonga.audible.transient.net>
 <20120612111802.GI31109@pad.fieldses.org>
 <20120612123644.GA16430@fieldses.org>
 <20120613060627.GA11421@cucamonga.audible.transient.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120613060627.GA11421@cucamonga.audible.transient.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jamie Heilman wrote:
> It's looking like my issues with "RPC: fragment too large" may be
> something else entirely at this point, I've noticed other weird
> network behavior that I'm gonna have to try to isolate before I keep
> blaming nfs changes.  Though for some reason my
> /proc/fs/nfsd/max_block_size ends up only 128KiB w/3.4 where it was
> 512KiB w/3.3.

OK, I get it now.  32-bit PAE system w/4G of RAM (minus a chunk for
the IGP video etc.) for my NFS server, and the max_block_size
calculation changed significantly in commit
508f92275624fc755104b17945bdc822936f1918 to account for rpc buffers
only being in low memory.  That means whereas in 3.3 the math came out
to having a target size of roughly 843241 my new target size in 3.4 is
only 219959-ish, so choosing 128KiB is understandable.  The problem
was that all my clients had negotiated their nfs mounts against the
v3.3 value of 512KiB, and when I rebooted into 3.4... they hit the
wall attempting larger transfers and become uselessly stuck at that
point.  If I remount everything before doing any large transfers, then
it negotiates a lower wsize and things work fine.  So everything is
working as planned I suppose... the transition between 3.3 and 3.4 is
just a bit rough.

-- 
Jamie Heilman                     http://audible.transient.net/~jamie/
