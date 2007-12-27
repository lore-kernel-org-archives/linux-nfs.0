From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: new transport switch BUG_ON in svc_xprt.c
Date: Thu, 27 Dec 2007 15:38:16 -0600
Message-ID: <1198791496.17199.30.camel@trinity.ogc.int>
References: <1198788205.17199.26.camel@trinity.ogc.int>
	 <20071227204041.GB646@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:57841 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751949AbXL0VcX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Dec 2007 16:32:23 -0500
In-Reply-To: <20071227204041.GB646@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2007-12-27 at 15:40 -0500, J. Bruce Fields wrote:
> On Thu, Dec 27, 2007 at 02:43:25PM -0600, Tom Tucker wrote:
> > I see that you are back.
> 
> Actually, all that happens was I got a wireless router installed in my
> in-laws' house.  I'm still mostly goofing off.

Ah, the family IT guy -- nice.

> 
> > I have now been able to reproduce the BUG_ON
> > that Aime saw on the new code. I ran it over the holidays and when let
> > run long enough it eventually hit it.
> > 
> > I am testing what I think is the fix (left over XPT_BUSY clear in the
> > close path). If this works, then I'm ready with a new version of the
> > patchset based on your comments plus this bug fix. 
> 
> Awesome, thanks!
> 
> > Are you ready for the next round?
> 
> Feel free if you want, but I probably won't do anything with it till
> late next week.
> 

Ok. I'll send it out after more testing. BTW, I'll be skiing for the 1st
week of Jan, but will be semi-available via e-mail. 

> --b.

