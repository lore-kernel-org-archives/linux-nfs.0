Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:44220 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019Ab2HBMcz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2012 08:32:55 -0400
Message-ID: <501A7369.6090808@panasas.com>
Date: Thu, 2 Aug 2012 15:32:41 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
CC: Peng Tao <tao.peng@emc.com>
Subject: [PATCHSET 0/3] pnfs-obj: Fixes left-out from 3.5 for the 3.6 merge
 window
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond

These fixes where for the 3.5 Kernel, Sorry I forgot about them. In any
way they should be pushed for 3.6 fixes.
(Should we pursue Stable@ for them)

This is a re-post, except the 3rd one which is a new BUG fix.

list of patches:
[PATCH 1/3] NFS41: add pg_layout_private to nfs_pageio_descriptor
[PATCH 2/3] pnfs-obj: Better IO pattern in case of unaligned offset
[PATCH 3/3] pnfs: Don't BUG on info received from Server

Thanks
Boaz
