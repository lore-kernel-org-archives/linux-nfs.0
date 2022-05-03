Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6118CC433EF
	for <linux-nfs@archiver.kernel.org>; Tue,  3 May 2022 14:21:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235688AbiECOZQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 3 May 2022 10:25:16 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52972 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S236890AbiECOZP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2022 10:25:15 -0400
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:e::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id AD25B2DA96;
        Tue,  3 May 2022 07:21:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=CGAmq2buQ/fYxQwOonrx5m9HPjC2FfICCxpYpt6nExw=; b=Kv9wW9wqwNa9bKa7eoRidA7yMX
        Twha4hq+kYA+LB0uHJd/X7TjvKaAj8AsknrzvlA5QQadrqu3FPjNXGytFycvP9ys03B60GmOqoxO4
        TUTyE0Res8cq0kO92+z7EaJdPzz+CKafROLlcwem5EHlutLYnB/SulmL4oFzeO2szNMdySYYUsDCl
        l7uwqs5WWqWE6O3+TzwNJAS5DqKRosmM3k18IMJ9gxZQ5+dlL/cDhUdBQ9E5cisXCyroPHsvEWhV5
        5rRSLhA74A1vDn72FugMwISl3cgD0TCvBQkjFwS3ChOgG47xioNy5xqg4s/zjvqNvKB3uELEoqroL
        GEengPzw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1nltPL-006ETz-4e; Tue, 03 May 2022 14:21:43 +0000
Date:   Tue, 3 May 2022 07:21:43 -0700
From:   Christoph Hellwig <hch@infradead.org>
To:     "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc:     linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] nfs: Pass the file pointer to nfs_symlink_filler()
Message-ID: <YnE6d2WvWRuxbk3j@infradead.org>
References: <20220502054159.3471078-1-willy@infradead.org>
 <20220502054159.3471078-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220502054159.3471078-3-willy@infradead.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, May 02, 2022 at 06:41:58AM +0100, Matthew Wilcox (Oracle) wrote:
> In preparation for unifying the read_cache_page() and read_folio()
> implementations, make nfs_symlink_filler() get the inode
> from the page instead of passing it in from read_cache_page().
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
