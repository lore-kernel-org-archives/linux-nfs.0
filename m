From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH REPOST2] svcrdma: Limit ORD based on client's
  advertised IRD
Date: Tue, 20 May 2008 22:02:27 -0400
Message-ID: <RTPCLUEXC1-PRDRM7s30000013b@RTPMVEXC1-PRD.hq.netapp.com>
References: <1211242295.31725.95.camel@trinity.ogc.int>
 <20080520212434.GF8177@fieldses.org>
 <1211322408.12428.34.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57147 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932689AbYEUCC0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 22:02:26 -0400
In-Reply-To: <1211322408.12428.34.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
References: <1211242295.31725.95.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
 <20080520212434.GF8177@fieldses.org>
 <1211322408.12428.34.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 06:26 PM 5/20/2008, Tom Tucker wrote:
>
>On Tue, 2008-05-20 at 17:24 -0400, J. Bruce Fields wrote:
>> On Mon, May 19, 2008 at 07:11:35PM -0500, Tom Tucker wrote:
>> > When adapters have differing IRD limits, the RDMA transport will fail to
>> > connect properly.
>>  
>> How will this look to the user?  Are they going to get some sort of
>> mysterious failure when they try to mount, and then have to go echo
>> lower values into /proc/sys/sunrpc/svc_rdma/max_outbound_read_requests
>> until it works?
>> 
>
>Yes, the mount will fail with a connection error. It's disgusting.

The client error is ECONNREFUSED, which mount.nfs ever-so-helpfully
reports as "mount: internal error". Chuck and I went over some options
at cthon to make this more useful, I'm fishing around, it's  a simple
error code choice.

Tom.

