Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36752 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755088Ab1LMS0p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Dec 2011 13:26:45 -0500
Date: Tue, 13 Dec 2011 13:26:44 -0500
To: Chris J Arges <chris.j.arges@canonical.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
Subject: Re: [PATCH] nfsd4: permit read opens of executable-only files
Message-ID: <20111213182644.GA29809@fieldses.org>
References: <20110825161957.GC1114@fieldses.org>
 <loom.20111207T233110-295@post.gmane.org>
 <20111208212151.GF32505@fieldses.org>
 <loom.20111213T183631-8@post.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <loom.20111213T183631-8@post.gmane.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Could you leave me on the cc: ?

Also, Trond: what did we end up deciding to do about permissions
checking on execute?  Was there a bugfix on the client side?

On Tue, Dec 13, 2011 at 05:38:54PM +0000, Chris J Arges wrote:
> <snip>
> > > 
> > > 
> > > Bruce,
> > > 
> > > I've tested this patch against linux-3.0 and it doesn't allow me to execute 
> > > binaries with permissions of 111.
> > 
> > Hm, I see the same permissions error.  However, looking at the
> > client-server traffic with wireshark, I see no permissions failures from
> > the server: the read-open of cat succeeds.  (Could you check if the same
> > is true in your case?)
> > 
> > So my first inclination is to blame the client.... Does this work with
> > an older client?
> > 
> > --b.
> 
> Bruce,
> 
> Using the above test setup, and trying various clients I see a mismatch:
> 
> Using a newer nfs clients (nfs-common 1:1.2.2-4/1:1.2.4-1), I can read a file 
> with 111 permissions, but cannot execute it.
> With an older nfs client (nfs-common 1:1.2.0-4 / ubuntu lucid), I can read and 
> execute a file with 111 permissions.

It certainly sounds like a client-side error....  (Though if you could
take a look at the traffic in wireshark as suggested above, that would
help--it doesn't require much special expertise, just look for an OPEN
call that mentions the file in question, and see if the server replies
with an error or not.)

Note it's the kernel on the client that matters, not the nfs-utils
version.  And most useful for people on this list may be testing with
the latest upstream kernel.  (We aren't necessarily familiar with Ubuntu
kernel versions.)

--b.
