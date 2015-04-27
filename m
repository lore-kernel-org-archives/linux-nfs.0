Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56340 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932893AbbD0MvS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2015 08:51:18 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: two pNFS server fixes for 4.1, V2
Date: Mon, 27 Apr 2015 14:50:12 +0200
Message-Id: <1430139014-28013-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first one is a workaround for a regression introduced in the Linux
client in the current pull requesdt.  The second is standards compliance
fix to comply with the latest rfc5661 errata on return on close semantics.

Changes since v1:
 - the Linux clients wants to see NOTIFY_DEVICEID4_CHANGE supported
   as well, which is even more broken as there's basically no sensible
   way to actually implement NOTIFY_DEVICEID4_CHANGE..

