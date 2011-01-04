Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35167 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750994Ab1ADVKj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 16:10:39 -0500
Date: Wed, 5 Jan 2011 08:10:31 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrpc: modifying positive sunrpc cache entries is racy
Message-ID: <20110105081031.220bfbc9@notabene.brown>
In-Reply-To: <20110104192350.GE2308@fieldses.org>
References: <20101229204752.GC12218@fieldses.org>
	<20101229205942.GD12218@fieldses.org>
	<20101230121940.3f48223a@notabene.brown>
	<20101230015719.GA27614@fieldses.org>
	<20110103205514.GB18056@fieldses.org>
	<20110104160152.602a3c44@notabene.brown>
	<20110104152231.GA27889@fieldses.org>
	<20110104192350.GE2308@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 4 Jan 2011 14:23:51 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> So, that being the real problem, perhaps it's clearer to use explicit
> memory barriers instead of more locking, and add some comments.  Also
> split this into a separate patch, as in the following.

Me likie.

Two separate patches is good, and nice comments next to the memory barriers
is good.
Reviewed-by: NeilBrown <neilb@suse.de>

Thanks!

NeilBrown
