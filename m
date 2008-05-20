From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 01/05] svcrdma: Verify read-list fits within
  RPCSVC_MAXPAGES
Date: Tue, 20 May 2008 10:14:24 -0400
Message-ID: <RTPCLUEXC1-PRDS7hx20000012b@RTPMVEXC1-PRD.hq.netapp.com>
References: <12111560011694-git-send-email-tom@opengridcomputing.com>
 <12111560022506-git-send-email-tom@opengridcomputing.com>
 <20080519182003.GC11993@fieldses.org>
 <1211245672.31725.111.camel@trinity.ogc.int>
 <RTPCLUEXC1-PRDh133t00000127@RTPMVEXC1-PRD.hq.netapp.com>
 <20080520135651.GB2373@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31834 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756024AbYETOOv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 10:14:51 -0400
In-Reply-To: <20080520135651.GB2373@fieldses.org>
References: <12111560011694-git-send-email-tom@opengridcomputing.com>
 <12111560022506-git-send-email-tom@opengridcomputing.com>
 <20080519182003.GC11993@fieldses.org>
 <1211245672.31725.111.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
 <RTPCLUEXC1-PRDh133t00000127-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <20080520135651.GB2373@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 09:56 AM 5/20/2008, J. Bruce Fields wrote:
>> MHO is that it's important but not urgent, and it should be part of a later
>> change. At Connectathon, no clients were sending any problematic requests,
>> so I think it's unlikely this will affect us in the wild, for now. 
>
>Somewhere in the documentation, a really clear warning about the
>security assumptions would be useful.  It could also help if the howto
>(on the web and in Documentation/filesystems/nfs-rdma.txt) included any
>instructions on necessary firewalling, etc.

Agreed. The kernel (/proc) parameters are part of this, and it's time to
spell them all out as well.

The protocol hardening we're talking about above isn't a security issue,
of course. It's just basic and part of the implementation. The client, btw,
has some fairly strict checking.

>By the way, the Kconfig help text for SUNRPC_XPRT_RDMA looks like it
>needs an update to mention the server?

You're right - it only mentions the client. I thought we added that text when
we simplified/collapsed the config.

Tom.

