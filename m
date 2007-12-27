From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: new transport switch BUG_ON in svc_xprt.c
Date: Thu, 27 Dec 2007 15:40:41 -0500
Message-ID: <20071227204041.GB646@fieldses.org>
References: <1198788205.17199.26.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38879 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752437AbXL0Ukm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Dec 2007 15:40:42 -0500
In-Reply-To: <1198788205.17199.26.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 27, 2007 at 02:43:25PM -0600, Tom Tucker wrote:
> I see that you are back.

Actually, all that happens was I got a wireless router installed in my
in-laws' house.  I'm still mostly goofing off.

> I have now been able to reproduce the BUG_ON
> that Aime saw on the new code. I ran it over the holidays and when let
> run long enough it eventually hit it.
> 
> I am testing what I think is the fix (left over XPT_BUSY clear in the
> close path). If this works, then I'm ready with a new version of the
> patchset based on your comments plus this bug fix. 

Awesome, thanks!

> Are you ready for the next round?

Feel free if you want, but I probably won't do anything with it till
late next week.

--b.
