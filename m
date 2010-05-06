Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19082 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756899Ab0EFTUT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 15:20:19 -0400
Message-ID: <4BE3166F.7060800@panasas.com>
Date: Thu, 06 May 2010 22:20:15 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/7] pnfs-submit api touch ups
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

After rebasing everything on top of Andy and Fred patchsets I propose the following:

[PATCH 1/2] SQUASHME: pnfs-submit: have initialize_mountpoint return status
[PATCH 2/2] SQUASHME: pnfs-submit: pass struct nfs_server * to getdeviceinfo
[PATCH 3/5] pnfs-post-submit: pass struct nfs_server * to getdevicelist
[PATCH 4/5] pnfs-post-submit: pass mntfh down the init_pnfs path
[PATCH 5/5] FIXME: pnfs-post-submit: per mount layout driver private data
[PATCH 6/6] SQUASHME: pnfs-block: convert APIs pnfs-post-submit
[PATCH 7/7] SQUASHME: pnfs-obj: convert APIs pnfs-post-submit
