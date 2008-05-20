From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/05] svcrdma: Verify read-list fits within
	RPCSVC_MAXPAGES
Date: Tue, 20 May 2008 09:56:51 -0400
Message-ID: <20080520135651.GB2373@fieldses.org>
References: <12111560011694-git-send-email-tom@opengridcomputing.com> <12111560022506-git-send-email-tom@opengridcomputing.com> <20080519182003.GC11993@fieldses.org> <1211245672.31725.111.camel@trinity.ogc.int> <RTPCLUEXC1-PRDh133t00000127@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33649 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754490AbYETN4y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 09:56:54 -0400
In-Reply-To: <RTPCLUEXC1-PRDh133t00000127-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 20, 2008 at 09:27:13AM -0400, Talpey, Thomas wrote:
> At 09:07 PM 5/19/2008, Tom Tucker wrote:
> >No we don't and a Byzantine client could crash us.
> 
> That can be arranged... :-)
> 
> >This kind of check along with a bunch of others should go in
> >svc_rdma_xdr_decode_req.  I have these things planned for the 2.6.27
> >time-frame (along with Fast NSMR support). 
> >
> >Do you think it's more urgent?
> 
> MHO is that it's important but not urgent, and it should be part of a later
> change. At Connectathon, no clients were sending any problematic requests,
> so I think it's unlikely this will affect us in the wild, for now. 

Somewhere in the documentation, a really clear warning about the
security assumptions would be useful.  It could also help if the howto
(on the web and in Documentation/filesystems/nfs-rdma.txt) included any
instructions on necessary firewalling, etc.

By the way, the Kconfig help text for SUNRPC_XPRT_RDMA looks like it
needs an update to mention the server?

--b.
