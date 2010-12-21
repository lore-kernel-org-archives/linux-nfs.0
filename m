Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27773 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933425Ab0LUCUz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 21:20:55 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/14] pnfs wave 2 submission
Date: Mon, 20 Dec 2010 21:20:32 -0500
Message-Id: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These patches implement wave 2 of the pnfs submission, which
encompasses CB_LAYOUTRECALL and its serialization with LAYOUTGET,
as well as the "forgetful model" in which LAYOUTRETURNs are never
sent, but instead merely discarded by the client.

They apply on top of Andy's recent 11 patch series.

They are based on Benny's current pnfs-submit branch
(commit f5219ae8 pnfs-submit: Turn off layoutcommits) with commits
f2591e12..ccf5e6f8 rearranged into a more coherent series (see
tag pnfs-submit-wave2-v0.05-submission from my tree at
linux-nfs.org/~iisaman/linux-pnfs.git), then rebased on Andy's
most recent patches placed on Trond's nfs-for-next.

Fred

[PATCH 01/14] pnfs: wave 2: fix incorrect comment in destroy_lseg
[PATCH 02/14] pnfs: wave 2: remove unnecessary field lgp->status
[PATCH 03/14] pnfs: wave 2: rename lo->state to lo->plh_flags
[PATCH 04/14] pnfs: wave 2: change layout state seqlock to a spinlock
[PATCH 05/14] pnfs: wave 2: change how lsegs are removed from layout list
[PATCH 06/14] pnfs: wave 2: layoutget rpc code cleanup
[PATCH 07/14] pnfs: wave 2: serialize LAYOUTGET(openstateid)
[PATCH 08/14] pnfs: wave 2: Add layout to client list before sending rpc
[PATCH 09/14] pnfs: wave 2: check that partial LAYOUTGET return is ignored
[PATCH 10/14] pnfs: wave 2: change lo refcounting to atomic_t
[PATCH 11/14] pnfs: wave 2: CB_LAYOUTRECALL xdr code
[PATCH 12/14] pnfs: wave 2: add CB_LAYOUTRECALL handling
[PATCH 13/14] pnfs: wave 2: update nfs4_callback_recallany to handle layouts
[PATCH 14/14] pnfs: wave 2: layout roc code
