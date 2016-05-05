Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:48027 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755919AbcEEOAe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 May 2016 10:00:34 -0400
Date: Thu, 5 May 2016 16:00:31 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] nfsd: handle seqid wraparound in
	nfsd4_preprocess_layout_stateid
Message-ID: <20160505140031.GA14831@lst.de>
References: <1462445627-15093-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1462445627-15093-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>
