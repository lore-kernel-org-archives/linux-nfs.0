From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 10/10] svcrdma: Documentation update for the
  FastReg	memory model
Date: Fri, 26 Sep 2008 12:01:01 -0400
Message-ID: <RTPCLUEXC2-PRDGryWt0000003c@RTPMVEXC1-PRD.hq.netapp.com>
References: <1221564879-85046-2-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-3-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-4-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-5-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-6-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-7-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-8-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-9-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-10-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-11-git-send-email-tom@opengridcomputing.com>
 <20080924212102.GD10841@fieldses.org>
 <48DB939E.4090503@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7189 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752557AbYIZQBn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 12:01:43 -0400
In-Reply-To: <48DB939E.4090503@opengridcomputing.com>
References: <1221564879-85046-2-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-3-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-4-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-5-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-6-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-7-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-8-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-9-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-10-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-11-git-send-email-tom@opengridcomputing.com>
 <20080924212102.GD10841@fieldses.org>
 <48DB939E.4090503@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 09:35 AM 9/25/2008, Tom Tucker wrote:
>> This explanation is helpful, thanks.  It would also be helpful if we
>> could boil down the advice to just a sentence or two for the busy admin.
>> Something like:  unless you have card XYZ and kernel 2.6.y, do *not* use
>> rdma on a network where you cannot trust every machine....
>
>
>Would it be better to say, "Do not use RDMA on a network where your 
>policy requires a security model stronger than tcp/auth_unix."

No! This would confuse integrity and privacy concerns (the root of the
RDMA attack you describe) with authentication. While it's true there are
different attacks with a different transport, they do not in any way
contravene the protections in the RPC and NFS layers.

In fact, I believe the text is unfairly protraying a vulnerability in iWARP
as to be residing in NFS/RDMA, which is isn't.

While many of today's adapters allow so-called "type 2" RKEYs, the
protocol does not encourage them, and their use introduces these
risks. The risks are avoidable. The IETF RFCs describe these in detail,
for both RDDP and NFS/RPC/RDMA.

Tom.

