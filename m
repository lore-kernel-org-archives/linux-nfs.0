Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50094 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751519AbdEIT6U (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 15:58:20 -0400
Date: Tue, 9 May 2017 12:58:19 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Ari Kauppi <Ari.Kauppi@synopsys.com>
Subject: Re: [PATCH] nfsd: encoders mustn't use unitialized values in error
 cases
Message-ID: <20170509195819.GC22486@infradead.org>
References: <20170508155741.GC2644@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170508155741.GC2644@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>
