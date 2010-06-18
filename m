Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19639 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750971Ab0FRU7n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jun 2010 16:59:43 -0400
Message-ID: <4C1BDE45.6020806@panasas.com>
Date: Fri, 18 Jun 2010 16:59:49 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] pnfs callback fixes
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

A small crop of fixes for pnfs callbacks.

[PATCH 1/3] SQUASHME: pnfsd: move kfree of the cb_layout rpc_args to release time
[PATCH 2/3] SQUASHME: pnfsd: move kfree of the cb_device rpc_args to release time
[PATCH 3/3] pnfsd: reset status on NFS4ERR_NOMATCHING_LAYOUT

All of these patches, plus
bc210d8 pnfs: Fix num_ds bug in nfsd4_set_pnfs_dlm_device()
3baf7bf SQUASHME: pnfs-obj: use NFSDBG_PNFS_LD also in pnfs_osd_xdr_cli.c

are in pnfs-all-latest at pnfs-all-2.6.35-rc3-2010-06-18

I'll rebase them onto their respective branches after the Bakethon...

Benny
