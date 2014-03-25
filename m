Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51665 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754483AbaCYR1H convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Mar 2014 13:27:07 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: <trond.myklebust@primarydata.com>, <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <tom@opengridcomputing.com>,
        "Chuck Lever" <chuck.lever@oracle.com>
References: <20140325145044.3559.95141.stgit@build.ogc.int>
In-Reply-To: <20140325145044.3559.95141.stgit@build.ogc.int>
Subject: RE: [PATCH] Fix regression errors in NFSRDMA
Date: Tue, 25 Mar 2014 12:27:10 -0500
Message-ID: <004e01cf484f$73f1b3b0$5bd51b10$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> The client regression was due to additional XDR sanity checking
> (64bd577ea0021f5903505de061b3b7d8a785ee94) that exposed a latent bug in
> the NFSRDMA client. The bug is that if there were inline data, then the
> rpcrdma_fixup_inline function would would incorrectly set the XDR page_len
> to zero. Since the decode_read3resok logic previously computed this
> value from the reported len - header len, the bug was not symptomatic.

Oops: The client bug has already been fixed by Chuck's patch which is already 
in Trond's nfs-for-next branch:

----
commit 2b7bbc963da8d076f263574af4138b5df2e1581f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 12 12:51:30 2014 -0400

    SUNRPC: Fix large reads on NFS/RDMA
----

So I'll repost Tom's server-side fix, after applying it on nfs-for-next and verifying things 
still work.


Steve.

