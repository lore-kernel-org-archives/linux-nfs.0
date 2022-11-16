Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3AC7C433FE
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Nov 2022 16:08:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233207AbiKPQIk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Nov 2022 11:08:40 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47442 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230204AbiKPQIk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Nov 2022 11:08:40 -0500
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:3::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DBE1A2AE7;
        Wed, 16 Nov 2022 08:08:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=MkALmH4XzOeEQFfjeCdhiQfItADg4fLsnbQ9RHdaOPg=; b=mRKwU1kkn/9LgKr8+RnldYHXjp
        VZrOOfPwE5uXiGCdMF7jyYGwNtB4uFnvLDpGcy08ESRR50VOU7+6APQwYf2RNpPsWIddI/vvbUAPh
        QdZSTAp56N/1LO4hYhM8GpP19HHaHT0Dy5MOYn97HGBqNmJ/8+8Pv+laMHyUuO9mrndlxJI6DjG2L
        o3zr9tpa3GYyn+4Goj2+fC8P9m8gboFXyLdqVCelkXNtlp1nvY4NzMkkuD9PH1A/0ijqG0m/28Cd/
        SmQmRDbLJzuaPiKtWWDl3kd+9tKUShI8TQqZt1k3HJAWSlUvEoUW06FNhfA80QcfBqKNhEG1rGYZL
        T8rxw/Gg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1ovKxp-005i96-22; Wed, 16 Nov 2022 16:08:37 +0000
Date:   Wed, 16 Nov 2022 08:08:37 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        chuck.lever@oracle.com, viro@zeniv.linux.org.uk, hch@lst.de
Subject: Re: [PATCH 1/7] filelock: add a new locks_inode_context accessor
 function
Message-ID: <Y3ULBXgnUvt4amrc@infradead.org>
References: <20221116151726.129217-1-jlayton@kernel.org>
 <20221116151726.129217-2-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20221116151726.129217-2-jlayton@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Nov 16, 2022 at 10:17:20AM -0500, Jeff Layton wrote:
> -	ctx =  smp_load_acquire(&inode->i_flctx);
> +	ctx =  locks_inode_context(inode);

Nit: this might be a good time to drop the weird double space here.

Otherwise looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
