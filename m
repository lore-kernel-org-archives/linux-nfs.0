Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49124 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134AbcGHJlv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 05:41:51 -0400
Received: from i60-34-157-115.s41.a006.ap.plala.or.jp ([60.34.157.115] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.85_2 #1 (Red Hat Linux))
	id 1bLSHw-0007ZF-8N
	for linux-nfs@vger.kernel.org; Fri, 08 Jul 2016 09:41:36 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: a few simple scsi-layout fixes
Date: Fri,  8 Jul 2016 18:41:27 +0900
Message-Id: <1467970890-11237-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the proper open mode for the block device (mostly harmless), and
ensure we cope with the magic dm-mpath device names in RHEL and
Fedora.

