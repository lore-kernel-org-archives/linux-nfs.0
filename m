Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51132 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756274AbaGORCu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:02:50 -0400
Date: Tue, 15 Jul 2014 10:02:48 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/7] sunrpc: xdr_get_next_encode_buffer can be static
Message-ID: <20140715170248.GA7767@infradead.org>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
 <1405303064-9102-5-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405303064-9102-5-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond just sent a patch for this as well..

Reviewed-by: Christoph Hellwig <hch@lst.de>
