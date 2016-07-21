Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41713 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbcGUISC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jul 2016 04:18:02 -0400
Date: Thu, 21 Jul 2016 01:18:02 -0700
From: Christoph Hellwig <hch@infradead.org>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: xfstests generic/285 fails reliably on Trond's linux-next branch
Message-ID: <20160721081802.GA14413@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that 207 is fixed the next test starts failing..  285 is
the SEEK_HOLE/DATA sanity check, which might help with figuring out
which of the recent changes introduced it.  
