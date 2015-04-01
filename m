Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39895 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbbDAIhI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2015 04:37:08 -0400
Date: Wed, 1 Apr 2015 01:37:05 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: add NFSEXP_PNFS to the exflags array
Message-ID: <20150401083705.GA32325@infradead.org>
References: <1427877212-498-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1427877212-498-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ooops, looks like a debug printk sneaked in, here is the proper version:

---
