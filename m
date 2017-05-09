Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:55086 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751087AbdEIT5q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 15:57:46 -0400
Date: Tue, 9 May 2017 12:57:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Colin King <colin.king@canonical.com>
Cc: Ari Kauppi <ari@synopsys.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: avoid out of bounds read on array nfsd4_layout_ops
Message-ID: <20170509195742.GB22486@infradead.org>
References: <20170509133121.26529-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170509133121.26529-1-colin.king@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>
