Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:37634 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaICEgX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 00:36:23 -0400
Received: from [64.134.221.109] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XP2Iv-0003bP-NU
	for linux-nfs@vger.kernel.org; Wed, 03 Sep 2014 04:36:22 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: pnfs: add CB_NOTIFY_DEVICEID support
Date: Tue,  2 Sep 2014 21:38:33 -0700
Message-Id: <1409719119-2110-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I know everyone was waiting for more pnfs patches for me, so today we'll have
some special bites that seem way out in crack monkey land but are for real:

 - more kernel code!
 - duplicating existing raid drivers!
 - XDR encoding of previously XDR decoded data!

If you're not scared read on..

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

A git tree is also available at

	git://git.infradead.org/users/hch/pnfs.git notify-deviceid

This work was sponsored by NetApp, Inc.

