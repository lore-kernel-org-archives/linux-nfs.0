Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52211 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597Ab3KRRhg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Nov 2013 12:37:36 -0500
Date: Mon, 18 Nov 2013 12:37:31 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Albert Fluegel <af@muc.de>, linux-nfs@vger.kernel.org
Subject: Re: Bugs / Patch in nfsd
Message-ID: <20131118173731.GF3203@fieldses.org>
References: <20131118124406.GA46678@colin.muc.de>
 <20131118130026.GA4153@infradead.org>
 <20131118170132.GD3203@fieldses.org>
 <20131118172315.GA20339@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131118172315.GA20339@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 18, 2013 at 09:23:15AM -0800, Christoph Hellwig wrote:
> On Mon, Nov 18, 2013 at 12:01:32PM -0500, J. Bruce Fields wrote:
> > Just tracing a v3 mount I can confirm that S_IFDIR (0x4000, 040000)
> > gets set in GETATTR replies.
> 
> Oh. got it.  We set the stat file type, nothing related to the 32-bit
> readdir cookie.
> 
> > Anyway, absent objections my default is to queue this up for 3.14 (using
> > S_IALLUGO).
> 
> Yeah, that part looks good to me.  But it seem Albert still has an issue
> with the directory offsets.  Might be worth to get the ext4 developes
> in the loop for that, as I doubt it's an issue with the nfsd code.

One problem he's seeing was RHEL5-specific, the other is the known ext4
problem that's been discussed before.

(Basically, ext4 has a tradeoff between correctness, lookup performance,
and compatibility with some buggy old clients:

	1. turn off dir_index and performance on large directories may
	   suffer, but it's correct and any client will be happy.
	2. turn on dir_index and return 32-bit cookies: now you get
	   directory loops on large directories due to random hash
	   collisions.
	3. turn on dir_index and return 64-bit cookies: some clients seem
	   to then return errors to 32-bit applications doing readdirs.
	   Cookies have been 64-bit since NFSv3 and 32-bit Linux clients
	   deal with this fine (it fakes up its own small integer offsets
	   to return to applications), but apparently some other clients
	   return errors on readdir.

So currently we default to 3 and if people complain, tell them to turn
off dir_index and complain to their client vendor....)

--b.
