Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:46960
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751562Ab0HRF3h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 01:29:37 -0400
Date: Wed, 18 Aug 2010 07:29:28 +0200
From: Michael Guntsche <mike@it-loops.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Page alloc error on nfs4 via automount
Message-ID: <20100818052928.GA17829@gibson.comsick.at>
References: <20100816061644.GA2401@gibson.comsick.at>
 <1282087292.18385.34.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1282087292.18385.34.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 17 Aug 10 19:21, Trond Myklebust wrote:
> It looks like a regression in the Linux kernel memory management.
> 
> I agree that order 4 allocations are always going to be unreliable, but
> if it was consistently working before, and is now consistently not
> working, then something must have changed, and I know that part of the
> NFS code has not changed...

Hello,

Just to clarify this. The setup with automount adn NFS4 is new so I
while the NFS3 setup is working for years now. I never experience this
with NFS3 so it may be a NFS4 only problem. As you can see from the
mails I am not the only one having the problem with version 4 in this
regard. I think setups with automount and version 3 are much more common
so a regression there would have been noticed a lot faster.

Kind regards,
Michael
