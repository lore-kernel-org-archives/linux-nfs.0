Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.7 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0D79C43461
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Apr 2021 14:55:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id BDAC061130
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Apr 2021 14:55:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231826AbhDHOzh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Apr 2021 10:55:37 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57898 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231480AbhDHOzg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Apr 2021 10:55:36 -0400
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BA528C061760;
        Thu,  8 Apr 2021 07:55:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=9ngPzXydGHBjskx5cUB/06uGvBv1ng+f09FOLsWljv8=; b=JmqiGWaoPyP0M/wyjvEambr2hQ
        Pqfhp0rW3/YWQSEW67k7BqrjIQoQAHIbjqS/Ov+4EVqS9oYAxYFObB143hXed3ldwgU9EPF4Xw5Xs
        mOMGA4NF7eOLQt/RM4MdXGRqBa7Iy7T8wJSU+ghg3wes7SBZ/XEtD8y6cInb1UTB/pwAY0K6mlReR
        N96yrQ0ZtYi4KD9lCpm1g76pst1pbgLT4KckVkbUWxGFC97tUtXN6puarzldUCUYnQRyRVYLYP5yh
        yKV5ashBhese4KOWcF6ZJNu7cCKhHd/6ZbA5ZK/v9CFVDq4ZVFs9SerOLlEUccOAaEejb6sfUGfh2
        9TrgBE/g==;
Received: from willy by casper.infradead.org with local (Exim 4.94 #2 (Red Hat Linux))
        id 1lUW3g-00GNjJ-Br; Thu, 08 Apr 2021 14:55:03 +0000
Date:   Thu, 8 Apr 2021 15:55:00 +0100
From:   Matthew Wilcox <willy@infradead.org>
To:     David Howells <dhowells@redhat.com>
Cc:     linux-fsdevel@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>,
        Mike Marshall <hubcap@omnibond.com>, linux-mm@kvack.org,
        linux-cachefs@redhat.com, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        ceph-devel@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Steve French <sfrench@samba.org>,
        Dominique Martinet <asmadeus@codewreck.org>,
        Jeff Layton <jlayton@redhat.com>,
        David Wysochanski <dwysocha@redhat.com>,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v6 05/30] mm: Implement readahead_control pageset
 expansion
Message-ID: <20210408145500.GO2531743@casper.infradead.org>
References: <161789062190.6155.12711584466338493050.stgit@warthog.procyon.org.uk>
 <161789069829.6155.4295672417565512161.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <161789069829.6155.4295672417565512161.stgit@warthog.procyon.org.uk>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 08, 2021 at 03:04:58PM +0100, David Howells wrote:
> Suggested-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> Signed-off-by: David Howells <dhowells@redhat.com>

Reviewed-by: Matthew Wilcox (Oracle) <willy@infradead.org>
