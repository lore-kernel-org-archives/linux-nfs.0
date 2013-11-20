Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39277 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754610Ab3KTQpj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 11:45:39 -0500
Date: Wed, 20 Nov 2013 11:45:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Albert Fluegel <af@muc.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: Bugs / Patch in nfsd
Message-ID: <20131120164532.GB5380@fieldses.org>
References: <20131118124406.GA46678@colin.muc.de>
 <20131118130026.GA4153@infradead.org>
 <20131118170132.GD3203@fieldses.org>
 <20131118172315.GA20339@infradead.org>
 <20131118173731.GF3203@fieldses.org>
 <20131120162810.GA25173@colin.muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131120162810.GA25173@colin.muc.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 20, 2013 at 05:28:10PM +0100, Albert Fluegel wrote:
> On Mon, Nov 18, 2013 at 12:37:31PM -0500, J. Bruce Fields wrote:
> > > > Anyway, absent objections my default is to queue this up for 3.14 (using
> > > > S_IALLUGO).
> This is great ! Thank you.
> 
> > > > ...
> > One problem he's seeing was RHEL5-specific, the other is the known ext4
> > problem that's been discussed before.
> > 
> > (Basically, ext4 has a tradeoff between correctness, lookup performance,
> > and compatibility with some buggy old clients:
> > 
> > 	1. turn off dir_index and performance on large directories may
> > 	   suffer, but it's correct and any client will be happy.
> > 	2. turn on dir_index and return 32-bit cookies: now you get
> > 	   directory loops on large directories due to random hash
> > 	   collisions.
> > 	3. turn on dir_index and return 64-bit cookies: some clients seem
> > 	   to then return errors to 32-bit applications doing readdirs.
> > 	   Cookies have been 64-bit since NFSv3 and 32-bit Linux clients
> > 	   deal with this fine (it fakes up its own small integer offsets
> > 	   to return to applications), but apparently some other clients
> > 	   return errors on readdir.
> > 
> > So currently we default to 3 and if people complain, tell them to turn
> > off dir_index and complain to their client vendor....)
> I agree with that. Did some "research" in the meantime. It's a real abyss.
> I think it does not make much sense to continue this thread. Thanks to
> all contributors bringing more light into this.
> 
> So this is for the records:
> With current RHEL5/6 + ext3 there is no problem over NFS. With ext4 + dir_index
> Solaris-8 fails with EOVERFLOW on a directory read. Solaris-2.5.1 complains
> (RPC: Can't decode result). There are 2 differences when turning off dir_index:
> The cookies have very low values then (in contrast to using all 64 bits with
> dir_index on) and the order returned by readdir is different (does not start
> with . and ..) Don't know, which one makes which Solaris fail.
> HP-UX fails differently on a ext4, even with dir_index turned off, but not
> always. If in the reply of a getattr the nanoseconds are not 0, HPUX fails
> with "stale file handle".

This is in the ctime/mtime/atime fields?

> Could it be, it mixes some of these bytes into the handle ?

More likely some sort of bug when they try to fill their attribute cache
for the new file.

Anyway, sounds like a pretty egregious client bug if that's accurate.  I
don't know if there's any easy way to force ext4 to truncate those
times.  Probably the only workaround is to stick to ext3.

--b.

> If in the reply the nanoseconds are all 0, HPUX works even
> with 64 bit cookies (dir_index on) on an ext4. On a xfs they all work.
> In the NFS replies on an xfs i've seen all nanoseconds set to 0, so this is
> consistent and the faulty behaviour seems definitely on the client side.
