Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21FADC433B4
	for <linux-nfs@archiver.kernel.org>; Sat, 15 May 2021 07:03:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E718B61406
	for <linux-nfs@archiver.kernel.org>; Sat, 15 May 2021 07:03:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232440AbhEOHES (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 15 May 2021 03:04:18 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:45634 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232435AbhEOHER (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 15 May 2021 03:04:17 -0400
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3AF7BC06174A
        for <linux-nfs@vger.kernel.org>; Sat, 15 May 2021 00:03:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=kT2mULHmwwRIPQ7oDESt9uU8rPoqxHm+nEUtlwqVQwo=; b=nkPUlEKuH4v+6IElgFcFVwqWXg
        RXywjjp2ASBoTODKJOxpL94Zdpn2Q8GqUpcXuUp1o83l+XM7VJWxQ+FtG6w7Qy0htDET7sLDKXnnC
        ts4nWrp8ysrQoln2G5lGc6mZBnNvGOrHezbPiGuwvMwnzKvseHAPl/Dr2sDnZXiOrjOOzBE6w0O0o
        gO1F2GT7vKF8ktpUoP/e9HN0JK/lZHQHhCLbqNYSRo5hynzJX1uZA1RABHLPVoLYrRBgCOAqtAzkD
        U3u6cYGzf0UqaBOi1WeJhyzyYOS68v7PQYoaI2IXjsPqazUevJ1vzenWDNzuMMIRDQHcMQtmW4Gme
        6HWbQp8w==;
Received: from hch by casper.infradead.org with local (Exim 4.94 #2 (Red Hat Linux))
        id 1lhoJr-00B2VI-EU; Sat, 15 May 2021 07:02:39 +0000
Date:   Sat, 15 May 2021 08:02:39 +0100
From:   Christoph Hellwig <hch@infradead.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "nickhuang@synology.com" <nickhuang@synology.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "robbieko@synology.com" <robbieko@synology.com>,
        "bingjingc@synology.com" <bingjingc@synology.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Prevent truncation of an unlinked inode from
 blocking access to its directory
Message-ID: <YJ9yD1S6Yl2m0gOO@infradead.org>
References: <20210514035829.5230-1-nickhuang@synology.com>
 <00195ec8bf1752306f549540eed74c3938c5e312.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00195ec8bf1752306f549540eed74c3938c5e312.camel@hammerspace.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by casper.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, May 14, 2021 at 03:46:57PM +0000, Trond Myklebust wrote:
> Why leave the commit_metadata() call under the lock? If you're
> concerned about latency, then it makes more sense to call fh_unlock()
> before flushing those metadata updates to disk.

Also I'm not sure why the extra inode reference is needed.  What speaks
against just moving the dput out of the locked section?
