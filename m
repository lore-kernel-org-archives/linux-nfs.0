Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07C99C43611
	for <linux-nfs@archiver.kernel.org>; Wed, 12 May 2021 15:30:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C522461948
	for <linux-nfs@archiver.kernel.org>; Wed, 12 May 2021 15:30:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231243AbhELPb0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 May 2021 11:31:26 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46118 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233752AbhELP3E (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 May 2021 11:29:04 -0400
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9CF0CC06138E;
        Wed, 12 May 2021 08:14:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Type:MIME-Version:Message-ID:
        Subject:To:From:Date:Sender:Reply-To:Cc:Content-Transfer-Encoding:Content-ID:
        Content-Description:In-Reply-To:References;
        bh=tG3lNaI8LHbA42UxH7tGFop3ks8SKrHdPSgyfd5Fesc=; b=QcTeaAOz5CiwOtBDenL9nlkt4l
        ORNr0twmJaZxegkJO8zBnDDUkDHT/dimoBdIFeSUzwexX7MynidJxoCN9hTg8KX9dJY8KFnC3n2Ga
        vnXlEUXZCUhBpLcAMoD8lsMp9p6qSSyy1uN5HivU1zF+hxUp+wHkM3rYWFsBw3WSnDGm2N6VJ1b0n
        nPlwnctP1dbRNfw+Gd52MzQPJ9lAF9aI1TjQ6YYLY/Iam8C5S2Rdu6mCuARVgYQyOy8QSflOQiMsK
        18L+1xDeaIMOkpUHBAcXpp+U3SAfsWbv0oFEnDKSOEUdsLE3h1RDGvhTkiPAoKCuzKUR8Fc9QzRVh
        pEIa5/gg==;
Received: from willy by casper.infradead.org with local (Exim 4.94 #2 (Red Hat Linux))
        id 1lgqX8-008PA3-9W; Wed, 12 May 2021 15:13:30 +0000
Date:   Wed, 12 May 2021 16:12:22 +0100
From:   Matthew Wilcox <willy@infradead.org>
To:     linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Subject: Removing readpages aop
Message-ID: <YJvwVq3Gl35RQrIe@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In Linus' current tree, there are just three filesystems left using the
readpages address_space_operation:

$ git grep '\.readpages'
fs/9p/vfs_addr.c:       .readpages = v9fs_vfs_readpages,
fs/cifs/file.c: .readpages = cifs_readpages,
fs/nfs/file.c:  .readpages = nfs_readpages,

I'd love to finish getting rid of ->readpages as it would simplify
the VFS.  AFS and Ceph were both converted since 5.12 to use
netfs_readahead().  Is there any chance we might get the remaining three
filesystems converted in the next merge window?

