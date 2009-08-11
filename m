From: Simon Kirby <sim@hostway.ca>
Subject: Re: kernel NULL pointer dereference in rpcb_getport_done (2.6.29.4)
Date: Tue, 11 Aug 2009 10:17:45 -0700
Message-ID: <20090811171745.GA31854@hostway.ca>
References: <20090619225437.GA8472@hostway.ca> <1245527855.5182.33.camel@heimdal.trondhjem.org> <20090621050941.GA17059@hostway.ca> <20090622211126.GA564@hostway.ca> <20090709172739.GG13617@hostway.ca> <20090710223408.GR10700@fieldses.org> <20090810235536.GA11617@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:57497 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752986AbZHKRRr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Aug 2009 13:17:47 -0400
In-Reply-To: <20090810235536.GA11617@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 10, 2009 at 07:55:36PM -0400, J. Bruce Fields wrote:

> Looking back at that commit--I'm now confused about how it was meant to
> work.  In the case where the woken-up thread is waiting inside of
> svc_recv(), ->nwaking doesn't get decremented at all until the request
> is processed and svc_recv() is called again--effectively limiting the
> number of concurrent requests to 5 per pool, so, if I read the code
> correctly, likely to cause problems if your workload would benefit from
> lots of requests being able to wait on io simultaneously (e.g. if you
> have a large working set and more than 5 spindles per pool).

Yes, this box is serving about 50 TB of storage space, so there are more
than 5 spindles. :)

I can't believe others aren't all complaining about the same problem, but
I guess the loads are different.

> I'm inclined to revert the patch and take another look at Greg's
> original problem.

I'm inclined to be totally happy with that! :)

Simon-
