From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Mon, 12 Jan 2009 09:46:04 +0000
Message-ID: <1231753564.27350.83.camel@zakaz.uk.xensource.com>
References: <1227737539.31008.2.camel@localhost.localdomain>
	 <1228090631.7112.11.camel@heimdal.trondhjem.org>
	 <1228169383.20370.3.camel@localhost.localdomain>
	 <1228565812.10856.30.camel@localhost.localdomain>
	 <1229279045.3721.1.camel@localhost.localdomain>
	 <20081216175503.GG16388@fieldses.org>
	 <1229452775.3721.25.camel@localhost.localdomain>
	 <20090107222115.GI965@fieldses.org> <20090108182003.GB17623@fieldses.org>
	 <1231449753.21688.12.camel@localhost.localdomain>
	 <20090108212605.GG19312@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>,
	linux-kernel@vger.kernel.org, gcosta@redhat.com,
	Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:43979 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751411AbZALJq0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jan 2009 04:46:26 -0500
In-Reply-To: <20090108212605.GG19312@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-01-08 at 16:26 -0500, J. Bruce Fields wrote:
> On Thu, Jan 08, 2009 at 09:22:33PM +0000, Ian Campbell wrote:

> > These two look like the relevant ones to me but I'm not sure:
> > 22945e4a1c7454c97f5d8aee1ef526c83fef3223 svc: Clean up deferred requests on transport destruction
> > 69b6ba3712b796a66595cfaf0a5ab4dfe1cf964a SUNRPC: Ensure the server closes sockets in a timely fashion
> > 
> > I think 69b6 was in the set of three I tested previously and the other
> > two turned into 2294?
> 
> Yep, exactly.--b.

OK, I have patched my 2.6.26 kernel with these and it is now running.
It'll be about a week before I can say with any certainty that the issue
hasn't recurred.

Ian.
-- 
Ian Campbell
Current Noise: Pitchshifter - Subject To Status

Do I have a lifestyle yet?

