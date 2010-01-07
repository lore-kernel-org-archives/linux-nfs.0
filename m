From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS Server Not Responding after hw change (svc: transport
	busy, not enqueued)
Date: Thu, 7 Jan 2010 09:35:58 -0500
Message-ID: <20100107143557.GA24418@fieldses.org>
References: <alpine.DEB.1.10.1001052221550.22025@asgard.binrock.net> <20100106204017.GN6612@fieldses.org> <alpine.DEB.1.10.1001061958560.22025@asgard.binrock.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, netdev@kernel.org
To: Scott Sturdivant <scott-ILTxhEaIe5LR7s880joybQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38543 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893Ab0AGOfJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 09:35:09 -0500
In-Reply-To: <alpine.DEB.1.10.1001061958560.22025-GVPuzBPOE2JdLJ4KwZ+rgqxOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 06, 2010 at 08:02:14PM -0500, Scott Sturdivant wrote:
> On Wed, 6 Jan 2010, J. Bruce Fields wrote:
>> On a quick skim I don't see an obvious reason; one approach (if you're
>> *positive* there weren't also any software changes) might be just to try
>> swapping the hardware back (starting with the LAN?) and see if you can
>> reliably turn the problem on/off with just one hardware change.
>>
>> --b.
>
> Thank you for the good suggestion! I have done this and have verified 
> that indeed the onboard LAN is the root of the problem.

Woo-hoo!

> However, as the  
> onboard LAN is able to handle Samba / scp but fails with NFS, I'm curious 
> if this is an actual hardware problem or a driver issue?  Does anyone 
> know where the appropriate place for this problem would be?  Is there an 
> atl1c list?

Adding netdev-u79uwXL29TaiAVqoAR/hOOOyGI2DFzLe@public.gmane.org  Could you repeat any details about
the exact models of the network interfaces?

--b.
