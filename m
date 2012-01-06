Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54395 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163Ab2AFHYb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 02:24:31 -0500
Message-ID: <4F06A18E.4010706@panasas.com>
Date: Fri, 6 Jan 2012 09:23:58 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Benny Halevy <bhalevy@tonian.com>, Fred Isaman <iisaman@netapp.com>
Subject: [PATCHSET 0/2] pnfs-obj: Important BUG fixing also for @Stable
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond

I'm sending in two patches that fixes a bad hung, memory leak, a WARN_ON
and plain wrong protocol handling. In regard to objlayout error handling.
These are also aimed at Stable@ for the 3.2 Kernel.
(Actually these bugs are in since 3.0, I might produce another version
 for 3.[1,0] after these go in)

I have simulated errors at various layers, reads and writes, in combination
of different tests, and they work as I expect. .i.e IO continues to MDS and
oblayout is returned on error.

Please include these patches for 3.3 and they can go to Stable@ for 3.2
has well.

list of patches:
[PATCH 1/2] pnfs-obj: pNFS errors are communicated on iodata->pnfs_error

	This is just a stupidity and neglect. Benny can you understand
	what happened here?

[PATCH 2/2] pnfs-obj: Must return layout on IO error

	This patch is mainly for pnfs.c but I think it is very simple
	and totally not affecting anybody but objlayout. So it should
	be safe, and does fixes my main problem.
	Fred please review?

Please Review

Thanks
Boaz
