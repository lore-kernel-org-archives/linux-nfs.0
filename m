Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([209.166.131.148]:38642 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbaANPLK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jan 2014 10:11:10 -0500
Message-ID: <52D55382.6090502@panasas.com>
Date: Tue, 14 Jan 2014 17:10:58 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Stable Tree <stable@kernel.org>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Fwd: [PATCH] pnfs-obj: Proper delay for NFS4ERR_RECALLCONFLICT
 in layout_get_done
References: <52D54D87.7010100@panasas.com> <52D550AA.6030304@panasas.com>
In-Reply-To: <52D550AA.6030304@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/14/2014 04:58 PM, Boaz Harrosh wrote:
> Sorry forgot to CC Stable Tree <stable@kernel.org>
> 
> Greg hi
> 
> In Linux v3.9 there is a conflict around this area exactly do to change:
> 	[30005121] NFSv4.1: LAYOUTGET EDELAY loops timeout to the MDS
> 
> If there are stables below 3.9 please tell me I will send you a patch
> for these.
> 
> Thanks
> Boaz
> 
<>
> Subject: [PATCH] pnfs-obj: Proper delay for NFS4ERR_RECALLCONFLICT in layout_get_done
> 
> 
> An NFS4ERR_RECALLCONFLICT is returned by server from a GET_LAYOUT
> only when a Server Sent a RECALL do to that GET_LAYOUT, or
> the RECALL and GET_LAYOUT crossed on the wire.
> In any way this means we want to wait at most until in-flight IO
> is finished and the RECALL can be satisfied.
> 
> So a proper wait here is more like 1/10 of a second, not 15 seconds
> like we have now. (We use NFS4_POLL_RETRY_MIN here)
> 
> Current code totally craps out performance of very large files on
> most pnfs-objects layouts, because of how the map changes when the
> file has grown and spills into the next raid group.
> 
> CC: Stable Tree <stable@kernel.org>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Trond hi

I'm sitting on this bug for over 6 month now. I completely forgot about
it until QA moved to new Fedora and a vanila Kernel which is missing this
fix.

This is a real bummer for objects, in the case of large clusters for example
a Panasas cluster with two shelves and up. So on big clusters where performance
should be better, but with out this fix it is miserably unacceptedly slow.

Thanks
Boaz

