From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [Patch 0/4] RECLAIM_COMPLETE functionality
Date: Sat, 05 Dec 2009 15:51:01 -0500
Message-ID: <1260046261.29208.10.camel@localhost>
References: <>
	 <1260044428-16341-1-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752273AbZLEUvV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Dec 2009 15:51:21 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB5KpSsj008065
	for <linux-nfs@vger.kernel.org>; Sat, 5 Dec 2009 12:51:28 -0800 (PST)
In-Reply-To: <1260044428-16341-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-12-05 at 12:20 -0800, Ricardo Labiaga wrote: 
> The following patches implement RECLAIM_COMPLETE functionality to
> indicate completion of _global_ reclaims for the client.  They do
> not yet implement RECLAIM_COMPLETE for file system migration.
> 
> [PATCH 1/4] Cleanup some NFSv4 XDR decode comments
> [PATCH 2/4] nfs41: RECLAIM_COMPLETE XDR functionality
> [PATCH 3/4] nfs41: RECLAIM_COMPLETE functionality
> [PATCH 4/4] nfs41: Invoke RECLAIM_COMPLETE
> 
> A separate patch will be mailed to Bruce to integrate skeleton
> functionality on the server side.  
> 
> The patches apply to Trond's master branch.  They were tested on
> top of an old version of Andy's session draining patches, and
> the previous state reclaim bug fix series.

Applied. Thanks Ricardo...


