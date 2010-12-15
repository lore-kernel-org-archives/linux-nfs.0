Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47109 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693Ab0LOS3P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 13:29:15 -0500
Message-ID: <4D0908F9.4060208@panasas.com>
Date: Wed, 15 Dec 2010 20:29:13 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/9] pnfs post wave2 changes
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here are the list of patches I'd like to reintroduce into the post-submit pnfs
branch, after Fred's wave2 patches to bring layoutreturn and layoutcommit
and "forgetless" cb_layoutrecall functionality back into the pnfs branch:

[PATCH 1/9] Revert "pnfs-submit: wave2: remove forgotten layoutreturn struct definitions"
[PATCH 2/9] Revert "pnfs-submit: Turn off layoutcommits"
[PATCH 3/9] Revert "pnfs-submit: wave2: remove all LAYOUTRETURN code"
[PATCH 4/9] Revert "pnfs-submit: wave2: Remove LAYOUTRETURN from return on close"
[PATCH 5/9] FIXME: roc should return layout on last close
[PATCH 6/9] Revert "pnfs-submit: wave2: remove cl_layoutrecalls list"
[PATCH 7/9] Revert "pnfs-submit: wave2: Pull out all recall initiated LAYOUTRETURNS"
[PATCH 8/9] Revert "pnfs-submit: wave2: Don't wait in layoutget"
[PATCH 9/9] Revert "pnfs-submit: wave2: check that partial LAYOUTGET return is ignored"

Benny
