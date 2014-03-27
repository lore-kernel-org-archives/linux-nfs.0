Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24417 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755170AbaC0ULi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Mar 2014 16:11:38 -0400
Date: Thu, 27 Mar 2014 13:11:32 -0700
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.de>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: nfsd needs "md5", but fips=1 disables it -> hang
Message-ID: <20140327131132.5fe8ea33@ipyr.poochiereds.net>
In-Reply-To: <20140327143024.GA27633@fieldses.org>
References: <20140327205239.2ea29060@notabene.brown>
	<20140327143024.GA27633@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 27 Mar 2014 10:30:24 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Mar 27, 2014 at 08:52:39PM +1100, NeilBrown wrote:
> > 
> > [I sent this 2 days ago but haven't seen it come back on the nfs
> >  list and don't see it in the archives.  Maybe someone we cannot
> > name filtered it because it contains the word 'crypto' ??]
> 
> Huh.
> 
> > Apparently there is a thing called "FIPS" which lists some approved
> > crypto algorithms.  And some sites need to only use those.  So they
> > boot their kernel with
> >     fips=1
> > and anything non-fips-approved stops working.
> > 

Yes. As best I can tell, the primary purpose of FIPS is to render the
machine unusable for any non-trivial purpose. ;)

The story I have heard is that FIPS carves out an exemption for the use
of unapproved crypto as long as it stays "within the
implementation" (whatever that means).

> > "md5" is not fips-approved.
> > 
> > So
> > 
> > 	desc.tfm = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
> > 
> > in
> > 
> > nfs4_make_rec_clidname(char *dname, const struct xdr_netobj *clname)
> > 
> > 
> > always fails when fips=1.  This interferes with efficient NFS
> > service (every 'open' hangs).
> > 
> > s/md5/sha1/
> > 
> > makes this problem go away, because sha1 is fips-approved.
> > 
> > My question is: is this safe, or is the hash value used in some
> > external way (in /var/lib/nfs/v4recovery ??).
> 

The hashes aren't used outside the machine and they're not even
cryptographically significant. The kernel only uses it as a way to
squash the long-form clientid into something that it can use as a
directory name.

In hindsight, the decision to use md5 for that purpose was
unfortunate...

> Right, it's used in v4recovery, so you'd lose client state when you
> rebooted the server to the new (SHA1-using) server.
> 
> Our intention was to migrate people that care about FIPS to the umh
> upcall.  But rhel6 has a hack (a private md5 implementation).
> 
> Cc'ing jlayton (currently traveling) who did that work.
> 

Yep, exactly.

For any newer kernels and nfs-utils, just use nfsdcltrack and don't
bother with the legacy code. Eventually I can forsee us getting rid of
the legacy client tracking.

> > 
> > If changing the hash to sha1 is safe, we should do that and
> > probably add select CRYPTO_SHA1
> > to Kconfig just to be safe.
> > 
> > If we really need to keep it stable, I guess we need to find a way
> > to perform md5 computations that bypasses the fips checks.

For RHEL6 I just made a private md5 implementation. I had considered
switching it to sha1 instead, but the problem is that you'll lose
persistent state if you upgrade the kernel and it switches the hashing
implementation.

-- 
Jeff Layton <jlayton@redhat.com>
