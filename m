Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:39492 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751321AbaFEQVl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 12:21:41 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <tom@opengridcomputing.com>
References: <20140605145429.14347.22150.stgit@build.ogc.int> <20140605161353.GH8362@fieldses.org>
In-Reply-To: <20140605161353.GH8362@fieldses.org>
Subject: RE: [PATCH V2] svcrdma: Fence LOCAL_INV work requests
Date: Thu, 5 Jun 2014 11:21:47 -0500
Message-ID: <007301cf80da$3f5b07f0$be1117d0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Thursday, June 05, 2014 11:14 AM
> To: Steve Wise
> Cc: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org; tom@opengridcomputing.com
> Subject: Re: [PATCH V2] svcrdma: Fence LOCAL_INV work requests
> 
> On Thu, Jun 05, 2014 at 09:54:31AM -0500, Steve Wise wrote:
> > This applies on top of:
> >
> > 	commit e5a070216356dbcb03607cb264cc3104e17339b3
> > 	Author: Steve Wise <swise@opengridcomputing.com>
> > 	Date:   Wed May 28 15:12:01 2014 -0500
> >
> > 	    svcrdma: refactor marshalling logic
> 
> Sorry, I lost track--was there another revision of that patch coming
> too?
> 

No. 



