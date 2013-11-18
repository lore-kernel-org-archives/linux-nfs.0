Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39100 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373Ab3KRRra (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Nov 2013 12:47:30 -0500
Date: Mon, 18 Nov 2013 09:47:29 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, Albert Fluegel <af@muc.de>,
        linux-nfs@vger.kernel.org
Subject: Re: Bugs / Patch in nfsd
Message-ID: <20131118174729.GA16577@infradead.org>
References: <20131118124406.GA46678@colin.muc.de>
 <20131118130026.GA4153@infradead.org>
 <20131118170132.GD3203@fieldses.org>
 <20131118172315.GA20339@infradead.org>
 <20131118173731.GF3203@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131118173731.GF3203@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 18, 2013 at 12:37:31PM -0500, J. Bruce Fields wrote:
> One problem he's seeing was RHEL5-specific, the other is the known ext4
> problem that's been discussed before.

Ok, didn't know there was a RHEL bug.

> (Basically, ext4 has a tradeoff between correctness, lookup performance,
> and compatibility with some buggy old clients:
> 
> 	1. turn off dir_index and performance on large directories may
> 	   suffer, but it's correct and any client will be happy.
> 	2. turn on dir_index and return 32-bit cookies: now you get
> 	   directory loops on large directories due to random hash
> 	   collisions.
> 	3. turn on dir_index and return 64-bit cookies: some clients seem
> 	   to then return errors to 32-bit applications doing readdirs.
> 	   Cookies have been 64-bit since NFSv3 and 32-bit Linux clients
> 	   deal with this fine (it fakes up its own small integer offsets
> 	   to return to applications), but apparently some other clients
> 	   return errors on readdir.
> 
> So currently we default to 3 and if people complain, tell them to turn
> off dir_index and complain to their client vendor....)

Or people could use a filesystem taking care of that.  In addition to
taking care of the directory index XFS also has other advantages like
much better support to get the metadata operations to disk a lot more
efficiently.


... working hard on my marketing skills..

