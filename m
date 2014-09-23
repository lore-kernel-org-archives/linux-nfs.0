Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:58821 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898AbaIWG42 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 02:56:28 -0400
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@primarydata.com>
Subject: CB_RECALL fixes
Date: Tue, 23 Sep 2014 08:58:47 +0200
Message-Id: <1411455529-11556-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

First one fixes error handling in nfsd4_cb_recall_done, second is a fix from
Benny in the old pnfs tree which applies to restarted delegation recalls
as well.

