Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39206 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031127AbbD1NmY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 09:42:24 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: refactor stateid checking and file allocation
Date: Tue, 28 Apr 2015 15:41:14 +0200
Message-Id: <1430228480-7656-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series refactor various bits of code so that we always get
a proper file structure returned from nfs4_preprocess_stateid_op
if we ask for it.  Note that the first patch is a bugfixe that
should go into 4.1 and -stable.

