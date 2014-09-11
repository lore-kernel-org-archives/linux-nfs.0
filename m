Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:53138 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbaIKAfJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 20:35:09 -0400
Received: from ip-64-134-224-54.public.wayport.net ([64.134.224.54] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XRsLs-00083r-4K
	for linux-nfs@vger.kernel.org; Thu, 11 Sep 2014 00:35:08 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: pnfs: add CB_NOTIFY_DEVICEID support V2
Date: Wed, 10 Sep 2014 17:37:23 -0700
Message-Id: <1410395848-2437-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series adds support for device change notifications to the pnfs core
and block layout driver.  To properly implement NOTIFY_DEVICEID4_CHANGE I
had to move GETDEVICEINFO decoding into kernel space, and implement my own
trivial striping and concat layers in the pnfs blocklayout client.  Why?
DM and MD are really, really unhappy about multiple raid devices using the
same physical devices.  Which is fairly understandable from their point of
view, given that they normally manage on-disk metadata and would rather do
that exclusively.  But we get all our metadata from the server and couldn't
care less about their problems, we have our own problem called deviceid
management..  Once we get a NOTIFY_DEVICEID4_CHANGE callback we need
to stop new I/O using the existing mapping, so we have to drop it from
the deviceid cache.  At the same time another layout could easily request
the same deviceid again and for some period we'd have multiple volume
structures pointing to the same device.

Note that we do not break userspace compatibility - we still use blkmapd
to translate signatures to device numbers, and to do so we re-encode the
SIMPLE volumes we need translated to XDR and send it up to blkmapd just
for that.

This work was sponsored by NetApp, Inc.

Changes since V1:
 - support CB_NOTIFY_DEVICEID unconditionally

