Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og111.obsmtp.com ([64.18.0.22]:54105 "HELO
	exprod5og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754206Ab0J0SVN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 14:21:13 -0400
Message-ID: <4CC86D96.8020803@panasas.com>
Date: Wed, 27 Oct 2010 20:21:10 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/4] pnfs fixes
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here are some pnfs fixes for 2.6.36 since the bakeathon:

[PATCH 1/1] SQUASHME: pnfsd-files: update layout stateid properly

[PATCH 1/1] pnfs: do not change layout stateid when dropping layouts.
[PATCH 2/3] pnfs: mark page with error in readpage_async_filler when crossing lsegs
[PATCH 3/3] SQUASHME: pnfs: filelayout: print_ds should use dprintk
