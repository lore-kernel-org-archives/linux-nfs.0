Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:46203 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751322AbaIURIy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Sep 2014 13:08:54 -0400
Date: Sun, 21 Sep 2014 19:08:51 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v2] pnfs/blocklayout: Fix a 64-bit division/remainder
	issue in bl_map_stripe
Message-ID: <20140921170851.GA24400@lst.de>
References: <1411074948-77880-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1411074948-77880-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Works fine and passed QA:

Reviewed-by: Christoph Hellwig <hch@lst.de>
