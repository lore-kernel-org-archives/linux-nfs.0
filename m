From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] All Arch: remove linkage for sys_nfsservctl system call
Date: Sun, 28 Aug 2011 17:12:07 -0400 (EDT)
Message-ID: <20110828.171207.2184384269364960247.davem@davemloft.net>
References: <20110808155538.GB904@fieldses.org>
	<20110808180658.GC29924@decadent.org.uk>
	<20110826220311.GA18140@fieldses.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, ben@decadent.org.uk, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20110826220311.GA18140@fieldses.org>
Sender: linux-arch-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 26 Aug 2011 18:03:11 -0400

> From: NeilBrown <neilb@suse.de>
> 
> The nfsservctl system call is now gone, so we should remove all
> linkage for it.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Acked-by: David S. Miller <davem@davemloft.net>
