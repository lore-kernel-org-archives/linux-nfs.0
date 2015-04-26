Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47098 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbbDZPtN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Apr 2015 11:49:13 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: two pNFS server fixes for 4.1
Date: Sun, 26 Apr 2015 17:48:05 +0200
Message-Id: <1430063287-13621-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first one is a workaround for a regression introduced in the Linux
client in the current pull requesdt.  The second is standards compliance
fix to comply with the latest rfc5661 errata on return on close semantics.

