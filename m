Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56864 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbcF1MMC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2016 08:12:02 -0400
Date: Tue, 28 Jun 2016 05:12:01 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 01/17] NFS: Don't flush caches for a getattr that
 races with writeback
Message-ID: <20160628121201.GA30798@infradead.org>
References: <1466712049-5326-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1466712049-5326-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Something in your testing branch breaks pNFS block/scsi layout
synchronization for sub-block access, as shown by xfstests 130 and 207.

Please try to test these sorts of changes on pNFS as well.

Also it would be nice to have a cover letter for patch series with
some summary information and a changelog vs the previous one.
