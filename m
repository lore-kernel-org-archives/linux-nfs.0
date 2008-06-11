From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 0/1] SUNRPC: Add sysctl variables for server TCP
  snd/rcv buffer values
Date: Wed, 11 Jun 2008 17:01:09 -0400
Message-ID: <RTPCLUEXC1-PRDjkO22000001f0@RTPMVEXC1-PRD.hq.netapp.com>
References: <484ECDE4.6030108@gmail.com>
 <7F44A14A-F811-4D41-BAFF-E019E9904B6A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Dean Hildebrand <seattleplus@gmail.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbYFKVBc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jun 2008 17:01:32 -0400
In-Reply-To: <7F44A14A-F811-4D41-BAFF-E019E9904B6A@oracle.com>
References: <484ECDE4.6030108@gmail.com>
 <7F44A14A-F811-4D41-BAFF-E019E9904B6A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 03:48 PM 6/11/2008, Chuck Lever wrote:
>There are also fairly unsophisticated ways to add longer delays on  
>your test network, and turning up the latency knob would be a useful  
>test.

IPFW can be used to limit effective bandwidth and insert latencies in
strange, wonderful and easy-to-configure ways. I think there's preconfigured
profile for an earth-moon link, for instance. Using a pair of virtual client/
server instances on a single machine would be a great way to prototype
this (no wire bottlenecks - pure simulation), too.

Just an idea!

Tom.

