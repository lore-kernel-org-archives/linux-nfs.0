From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 0/14] Updates to nfs41 client backchannel for 2.6.31
Date: Thu, 11 Jun 2009 22:54:06 -0700
Message-ID: <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55147 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751346AbZFLF6J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 01:58:09 -0400
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond,

Here's a set of patches that address the comments received so far on the
"nfs41 client backchannel for 2.6.31" series.  We'll squash these into
Benny's tree, but I wanted to first submit them as stand alone patches for
your review.

Benny,

Each patch indicates the patch it should in turn be squased with.
Note that patch 10 simply backs out the changes of the original patch. 
We'll also need to manually move the removal of the 'xprt_free_bc_request'
export symbol into the correct patch through git-rebase.  We can do that
next week during bakeathon.


[PATCH 01/14] SQUASHME: Type check arguments of nfs_callback_up
[PATCH 02/14] SQUASHME: Update copyright notice and explain page allocation
[PATCH 03/14] SQUASHME: Update Copyright notice and fix formatting
[PATCH 04/14] SQUASHME: rpc_count_iostats incorrectly exits early
[PATCH 05/14] SQUASHME: Convert rpc_reply_expected() to inline function
[PATCH 06/14] SQUASHME: Remove unnecessary BUG_ON()
[PATCH 07/14] SQUASHME: Rename variable
[PATCH 08/14] SQUASHME: Removal of ugly #ifdefs
[PATCH 09/14] SQUASHME: nfs41: sunrpc: Add RPC direction back into the XDR buffer
[PATCH 10/14] SQUASHME: nfs41: sunrpc: Don't skip past the RPC call direction
[PATCH 11/14] SQUASHME: Moves embedded #ifdefs into #ifdef function blocks
[PATCH 12/14] SQUASHME: Removes bc_svc_process() declaration
[PATCH 13/14] SQUASHME: Move bc_svc_process() declaration to correct patch
[PATCH 14/14] SQUASHME: Update copyright

Thanks,

- ricardo
