Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:32966 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751466AbdEIT7k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 15:59:40 -0400
Date: Tue, 9 May 2017 12:59:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jason Yan <yanaijie@huawei.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv4: Fix an rcu lock leak
Message-ID: <20170509195934.GD22486@infradead.org>
References: <20170505170702.7226-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170505170702.7226-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
