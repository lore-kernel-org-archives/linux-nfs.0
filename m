Return-Path: <SRS0=IyJC=6T=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC46DC47259
	for <linux-nfs@archiver.kernel.org>; Tue,  5 May 2020 06:06:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A2993206A5
	for <linux-nfs@archiver.kernel.org>; Tue,  5 May 2020 06:06:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EiP4PXZ4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725833AbgEEGGJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 May 2020 02:06:09 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57116 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725320AbgEEGGJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2020 02:06:09 -0400
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:e::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 426DBC061A0F;
        Mon,  4 May 2020 23:06:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=W6C7+sFxYr0ur7PC5u5+OOcAwhCl6Vzl87BbtQFuCrs=; b=EiP4PXZ4qQ3SB1dEzQAYvsRXqn
        5DuBWaZJw9AcbpUijjtnw3vUUZp0zwEpIRUFeWy8aGVbroEt6AvOgvcWsclj27dVf11l3ujEraXPR
        LLQ7etcVhgIKviyf2zqXqECHu77FCvgRXXk8xFJUxUuBhLxmOec0RJnHGqYW7cDH+FJGFi3+EbhGy
        ZMNCpDDd3edEP7nIO+Tv6JfKXEo86cqHRvS+NTqVbf5IkalaJWn2dM4MrUnagg7ZIh7mVShZxt9uP
        3kLOLyp0JyZXNf7dOaqixgInznPrUbmWsfTGMDMWvzAOS8J1GdXSCpBcxLpkH1kYNU6cwrXAbplXX
        mdeti6WQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92.3 #3 (Red Hat Linux))
        id 1jVqi4-0001hM-KU; Tue, 05 May 2020 06:05:40 +0000
Date:   Mon, 4 May 2020 23:05:40 -0700
From:   Christoph Hellwig <hch@infradead.org>
To:     David Howells <dhowells@redhat.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Steve French <sfrench@samba.org>,
        Jeff Layton <jlayton@redhat.com>,
        Matthew Wilcox <willy@infradead.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, ceph-devel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 00/61] fscache, cachefiles: Rewrite the I/O interface
 in terms of kiocb/iov_iter
Message-ID: <20200505060540.GA28929@infradead.org>
References: <158861203563.340223.7585359869938129395.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <158861203563.340223.7585359869938129395.stgit@warthog.procyon.org.uk>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Can you split this into a few smaller series?  > 60 patches is beyond
reviewer comprehension.
