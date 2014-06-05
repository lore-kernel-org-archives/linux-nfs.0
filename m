Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:39085 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750742AbaFENz0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:55:26 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Bart Van Assche'" <bvanassche@acm.org>, <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <tom@opengridcomputing.com>
References: <20140602171433.31076.5634.stgit@build.ogc.int> <53901ADB.9020405@acm.org>
In-Reply-To: <53901ADB.9020405@acm.org>
Subject: RE: [PATCH] svcrdma: Fence LOCAL_INV work requests
Date: Thu, 5 Jun 2014 08:55:31 -0500
Message-ID: <002901cf80c5$d0b577e0$722067a0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Bart Van Assche [mailto:bvanassche@acm.org]
> Sent: Thursday, June 05, 2014 2:23 AM
> To: Steve Wise; bfields@fieldses.org
> Cc: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org; tom@opengridcomputing.com
> Subject: Re: [PATCH] svcrdma: Fence LOCAL_INV work requests
> 
> On 06/02/14 19:14, Steve Wise wrote:
> > Fencing forces the invalidate to only happen after all subsequent send
> > work requests have been completed.
> 
> Shouldn't that read "prior" instead of "subsequent" ?
>

Yes.  
 

