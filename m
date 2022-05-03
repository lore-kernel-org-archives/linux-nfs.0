Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EF4CC4332F
	for <linux-nfs@archiver.kernel.org>; Tue,  3 May 2022 14:18:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236934AbiECOWA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 3 May 2022 10:22:00 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46938 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S236944AbiECOV6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2022 10:21:58 -0400
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:e::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 51D4F24BEC;
        Tue,  3 May 2022 07:18:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=h9JBObbAFlZi8zr7yFPfxrXOUn
        RDFxvQgV/sEz68zQdX3TYH6zTJG5UsF6nVIw2SlMykJlLzkO5JtHKut+Tw3/SmBpCKW7lvjaSp1Ol
        +q5iZsmsYbLekpwkkRyRpwolnNXeFXSGd0rwaRQRJ2lmTTNNtXsRWOQl1aX4VGZB5+dMPiOg5iXts
        Ri/103+ayY+oovn7P0OlqobNm7CzMuJo+5CMqWhdBCY9TL8EmKYTxMwzTyuFaLegdWFq1beHNkQM6
        ZtRG65Qtt+ET/B4LCHNTuXWynxQB9xay9ncd3ARuj6OxBx7OV7zn1JCftfrtfA6+q55sm2g2jZZ3l
        M0bYShIw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1nltM5-006D8f-8U; Tue, 03 May 2022 14:18:21 +0000
Date:   Tue, 3 May 2022 07:18:21 -0700
From:   Christoph Hellwig <hch@infradead.org>
To:     "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc:     linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] jffs2: Pass the file pointer to
 jffs2_do_readpage_unlock()
Message-ID: <YnE5rQZLKNfAE+ea@infradead.org>
References: <20220502054159.3471078-1-willy@infradead.org>
 <20220502054159.3471078-2-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220502054159.3471078-2-willy@infradead.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
