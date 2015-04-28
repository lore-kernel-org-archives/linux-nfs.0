Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:44449 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965440AbbD1MBz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 08:01:55 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>,
        Sachin Bhamare <sachin.bhamare@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: two odstate optimizations
Date: Tue, 28 Apr 2015 14:00:47 +0200
Message-Id: <1430222449-3921-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two small optimizations for the odstate handling.  Feel free to squash them
into "nfsd: fix pNFS return on close semantics" if you need to rebase anyway.

