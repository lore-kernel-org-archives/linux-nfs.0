Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56394
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753632Ab0IHUFd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Sep 2010 16:05:33 -0400
Date: Wed, 08 Sep 2010 13:05:50 -0700 (PDT)
Message-Id: <20100908.130550.115952209.davem@davemloft.net>
To: bhutchings@solarflare.com
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: NFS writes broken in net-next-2.6
From: David Miller <davem@davemloft.net>
In-Reply-To: <1283976068.2237.8.camel@achroite.uk.solarflarecom.com>
References: <1283976068.2237.8.camel@achroite.uk.solarflarecom.com>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 08 Sep 2010 21:01:08 +0100

> In net-next-2.6, close() of a file after writing tends to return 1.
> This causes e.g. gcc to abort.
> 
> This appears to have been fixed in 2.6.36-rc2:
> 
> commit 0702099bd86c33c2dcdbd3963433a61f3f503901
> Author: J. R. Okajima <hooanon05@yahoo.co.jp>
> Date:   Wed Aug 11 13:10:16 2010 -0400
> 
>     NFS: fix the return value of nfs_file_fsync()
> 
> Please consider merging this fix in some way.

Ben, and please I've told you this before, if you need a specific
upstream fix do your testing on a branch that pulls in Linus's tree
or, alternatively, apply the fix you need by hand using "git stash" or
similar.

All of this is in your own hands.  You do not need me to merge in
every single upstream fix you might need.

I have this issue myself when testing both the sparc tree and the
various net trees all the time.
