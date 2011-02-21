Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47140 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab1BUW2E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 17:28:04 -0500
Message-ID: <4D62E6F3.8000304@panasas.com>
Date: Mon, 21 Feb 2011 14:28:03 -0800
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/9] fixes for layoutrecall callback pnfs-all-2.6.37 and -latest
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following patches fix bugs on the layout recall callback path both at
the server an client

[PATCH 1/9] pnfsd: Initialize cb_layout clr_recall.cb_work
[PATCH 2/9] pnfsd: add default error case in nfsd4_cb_layout_done

These two are for pnfs-all-2.6.37 only,
The rest are for both 37 and 38 (pnfs-all-latest)

[PATCH 3/9] pnfsd: do not clear rpc_resp in nfsd4_cb_done_sequence
[PATCH 4/9] pnfs: fix missing unlock in nfs_client_return_layouts
[PATCH 5/9] pnfs: return bool status from nfs4_asynch_forget_layouts
[PATCH 6/9] pnfs: return NFS4ERR_DELAY from layoutrecall while waiting on lsegs
[PATCH 7/9] pnfs: fix cl_drain_notification indexing
[PATCH 8/9] pnfs: fix nfs4_asynch_forget_layouts accounting
[PATCH 9/9] pnfs: improve nfs4_layoutget_done debug printouts

I've pushed them to a git tree I set up for the Connectathon:

git://linux-nfs.org/~bhalevy/linux-pnfs-cthon.git
or
ssh://linux-nfs.org/~bhalevy/exports/linux-pnfs-cthon.git
if you don't have git access.

Benny
