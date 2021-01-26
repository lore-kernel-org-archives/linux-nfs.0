Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4D8EC433E6
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Jan 2021 05:07:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 8068322B3B
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Jan 2021 05:07:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728983AbhAZFHX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Jan 2021 00:07:23 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51096 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1732055AbhAZECB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2021 23:02:01 -0500
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 95C3FC061573;
        Mon, 25 Jan 2021 20:01:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=hD2dihblVyt6KB5ToLRdOaDt4RozgYV/Q1Wqm2r3jOY=; b=szZsJUgSPGV0So2PjEzFyqt/aC
        GyEdr/UfGs5HvOaNfsGT7dgq77B941sKj9PgjAiBVacsv+FjgHkISHdLslYmTYf1TJpPBI4v4n8VN
        tCoGlH5IE+nObbCOW5VcGClxU5HrmAcNo6QfAyI2RNielNHDjb5Ua55lwdfhnweC/J6+4y17D+wK9
        HJx9AvKZcyAojIUH1mGBcP1Om+RT61Mn2SwfXusPhV5FNUh35gRES0yVHZrB37n89RJbSt+otpvLV
        I/8+MuqVC1vrReyVomu9bSFbG476zcpu3zwgqFXRU4fMPPp0xzdZk2918xuvVp2TtHUVwnsIA4aXb
        ohW+E04Q==;
Received: from willy by casper.infradead.org with local (Exim 4.94 #2 (Red Hat Linux))
        id 1l4FVp-0052nr-00; Tue, 26 Jan 2021 03:59:44 +0000
Date:   Tue, 26 Jan 2021 03:59:28 +0000
From:   Matthew Wilcox <willy@infradead.org>
To:     David Howells <dhowells@redhat.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Steve French <sfrench@samba.org>,
        Dominique Martinet <asmadeus@codewreck.org>,
        Dave Wysochanski <dwysocha@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-cachefs@redhat.com, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        ceph-devel@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 25/32] NFS: Clean up nfs_readpage() and nfs_readpages()
Message-ID: <20210126035928.GJ308988@casper.infradead.org>
References: <161161025063.2537118.2009249444682241405.stgit@warthog.procyon.org.uk>
 <161161054970.2537118.5401048451896267742.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <161161054970.2537118.5401048451896267742.stgit@warthog.procyon.org.uk>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Jan 25, 2021 at 09:35:49PM +0000, David Howells wrote:
> -int nfs_readpage(struct file *file, struct page *page)
> +int nfs_readpage(struct file *filp, struct page *page)

I appreciate we're inconsistent between file and filp, but we're actually
moving more towards file than filp.

