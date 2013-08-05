Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48716 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754569Ab3HEVDr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Aug 2013 17:03:47 -0400
Date: Mon, 5 Aug 2013 17:03:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix SP4_MACH_CRED negotiation in EXCHANGE_ID
Message-ID: <20130805210345.GF1583@fieldses.org>
References: <1375732027-4905-1-git-send-email-dros@netapp.com>
 <20130805204200.GE1583@fieldses.org>
 <6BD80745-EA0C-41B9-9C50-9F5FFE06C6C9@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6BD80745-EA0C-41B9-9C50-9F5FFE06C6C9@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 05, 2013 at 08:50:06PM +0000, Adamson, Dros wrote:
> 
> On Aug 5, 2013, at 4:42 PM, "J. Bruce Fields" <bfields@fieldses.org>
>  wrote:
> 
> > On Mon, Aug 05, 2013 at 03:47:07PM -0400, Weston Andros Adamson wrote:
> >> - don't BUG_ON() when not SP4_NONE
> >> - calculate recv and send reserve sizes correctly
> > 
> > Looks good, thanks!  (Ouch to that BUG_ON...).
> > 
> > Could I get the client-side code you're using to test this?
> > 
> > It's fine if it's a mess, I just want to be able to run it once and see
> > a mount work.
> > 
> 
> I just posted a client side patch to the list alongside this patch - it does the basic SP4_MACH_CRED negotiation and nothing else.
> 
> I'll be posting more patches implementing specific SP4_MACH_CRED features shortly, but the already posted patch should work for you.

Oh, I see it.  Thanks!

--b.
