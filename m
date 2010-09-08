Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38286 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754086Ab0IHUON (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Sep 2010 16:14:13 -0400
Subject: Re: NFS writes broken in net-next-2.6
From: Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
In-Reply-To: <20100908.130550.115952209.davem@davemloft.net>
References: <1283976068.2237.8.camel@achroite.uk.solarflarecom.com>
	 <20100908.130550.115952209.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 08 Sep 2010 21:14:10 +0100
Message-ID: <1283976850.2237.9.camel@achroite.uk.solarflarecom.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-09-08 at 13:05 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 08 Sep 2010 21:01:08 +0100
> 
> > In net-next-2.6, close() of a file after writing tends to return 1.
> > This causes e.g. gcc to abort.
> > 
> > This appears to have been fixed in 2.6.36-rc2:
> > 
> > commit 0702099bd86c33c2dcdbd3963433a61f3f503901
> > Author: J. R. Okajima <hooanon05@yahoo.co.jp>
> > Date:   Wed Aug 11 13:10:16 2010 -0400
> > 
> >     NFS: fix the return value of nfs_file_fsync()
> > 
> > Please consider merging this fix in some way.
> 
> Ben, and please I've told you this before,

I don't think so.

> if you need a specific
> upstream fix do your testing on a branch that pulls in Linus's tree
> or, alternatively, apply the fix you need by hand using "git stash" or
> similar.
[...]

Sure, that's what I'm doing.  But this is likely to hit more developers
than just me.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

