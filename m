Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3139EC43216
	for <linux-nfs@archiver.kernel.org>; Tue, 24 Aug 2021 14:21:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 198FD6124B
	for <linux-nfs@archiver.kernel.org>; Tue, 24 Aug 2021 14:21:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237738AbhHXOWP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 24 Aug 2021 10:22:15 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47296 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S237081AbhHXOWN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Aug 2021 10:22:13 -0400
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5684EC061757;
        Tue, 24 Aug 2021 07:21:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=7Qeavk+n72XmX65Q91vlVjTwlWUzuXidYkHzRt9couI=; b=VrrrM9enpqR3QYJRmgnZbZhOjF
        jbxwGVyosNxLkuA9AjGFTlX9dh0B4VIET9qX8Jd5n41ojPfirC/oNfviBF4DS0d5X70741+6n1Kil
        P61z2oDDgL4SAj/1Bsg7Mf/bgfVkhxxf7P7ybukIsyuntg1mvS67MAH059KCcQTkKc+bMbnRzVBrj
        CUpeP/Ex/uVAnn8USj+tB6I2khPQ/qmuKI2dSJ5ifL24D6cnXDAoAn4sRTQzMJUWK23U24bwCUlXM
        nvRXjR308EnDWd3ye5QqwuChCB8iFcmmqod5arY+ONkgSBx/DzoJLDFmdenFpY4A3Vh2fTDUxeFPN
        5P50Blpg==;
Received: from hch by casper.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1mIXFf-00B9qj-F5; Tue, 24 Aug 2021 14:18:33 +0000
Date:   Tue, 24 Aug 2021 15:18:07 +0100
From:   Christoph Hellwig <hch@infradead.org>
To:     David Howells <dhowells@redhat.com>
Cc:     "Matthew Wilcox (Oracle)" <willy@infradead.org>,
        Jeffrey Altman <jaltman@auristor.com>,
        linux-afs@lists.infradead.org, Jeff Layton <jlayton@kernel.org>,
        Ilya Dryomov <idryomov@gmail.com>,
        linux-fsdevel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        ceph-devel@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        devel@lists.orangefs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/6] afs: Fix afs_launder_page() to set correct start
 file position
Message-ID: <YST/n+gcppuwWCJx@infradead.org>
References: <162981147473.1901565.1455657509200944265.stgit@warthog.procyon.org.uk>
 <162981148752.1901565.3663780601682206026.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <162981148752.1901565.3663780601682206026.stgit@warthog.procyon.org.uk>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by casper.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Aug 24, 2021 at 02:24:47PM +0100, David Howells wrote:
> +		ret = afs_store_data(vnode, &iter,
> +				     (loff_t)page->index * PAGE_SIZE + f, true);

You probably want to use page_offset() here:

		ret = afs_store_data(vnode, &iter, page_offset(page) + f, true);

