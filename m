From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 01/05] svcrdma: Verify read-list fits within
  RPCSVC_MAXPAGES
Date: Tue, 20 May 2008 09:27:13 -0400
Message-ID: <RTPCLUEXC1-PRDh133t00000127@RTPMVEXC1-PRD.hq.netapp.com>
References: <12111560011694-git-send-email-tom@opengridcomputing.com>
 <12111560022506-git-send-email-tom@opengridcomputing.com>
 <20080519182003.GC11993@fieldses.org>
 <1211245672.31725.111.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24433 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758230AbYETN1r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 09:27:47 -0400
In-Reply-To: <1211245672.31725.111.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
References: <12111560011694-git-send-email-tom@opengridcomputing.com>
 <12111560022506-git-send-email-tom@opengridcomputing.com>
 <20080519182003.GC11993@fieldses.org>
 <1211245672.31725.111.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 09:07 PM 5/19/2008, Tom Tucker wrote:
>No we don't and a Byzantine client could crash us.

That can be arranged... :-)

>This kind of check along with a bunch of others should go in
>svc_rdma_xdr_decode_req.  I have these things planned for the 2.6.27
>time-frame (along with Fast NSMR support). 
>
>Do you think it's more urgent?

MHO is that it's important but not urgent, and it should be part of a later
change. At Connectathon, no clients were sending any problematic requests,
so I think it's unlikely this will affect us in the wild, for now. 

Tom.

