Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41861 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152AbbFROq4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 10:46:56 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: stateid handling improvements
Date: Thu, 18 Jun 2015 16:44:57 +0200
Message-Id: <1434638702-353-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we allocate a file structure in nfs4_preprocess_stateid_op
for all callers that as for it to consolidate code and fix the handling
of ALLOCATE, DEALLOCATE and SEEK to match the latest NFSv4.2 drafts.

