Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A20F8C433DB
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Feb 2021 07:47:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5590A64DE9
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Feb 2021 07:47:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230163AbhBRHqh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 Feb 2021 02:46:37 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43886 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229720AbhBRHnZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2021 02:43:25 -0500
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 68565C061756;
        Wed, 17 Feb 2021 23:42:45 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=mZKmyMBoFtbztfFABY/ghh/w9RSwZqEFrZcUD41TwBM=; b=NR2Kuw5GHI8Ltkju70NOS/E+Vc
        GIsUGB16gfua9MjaNDOuKCVgSYghs6gwn9TXap4xA3BjM1nu3TeJ4irbThgbg/uJ0Srp1Ad6plT9E
        Am98qX6QIMqBzRTns7b77v+dRhkUDfPwtRdqIajgIq0PiU/NXt+9eHTkX/un/biM0loOmF54E+GlC
        dqPJ7mhuxfgeSfylc8QeVGyKYWB7fHhq+8uFHaTn/5COe4xRVhYtR3rToFaL4m9mlSv3y4peWyxfy
        GCJ4NU5xAxiJbXel6/4BEcVPM8Aa5j2tkLPQ8JzZgvtynnAfH49jl/QA1xrPBw0e0Vfj4b+gUVYDV
        9GkUN3PA==;
Received: from hch by casper.infradead.org with local (Exim 4.94 #2 (Red Hat Linux))
        id 1lCdwt-001No9-Nr; Thu, 18 Feb 2021 07:42:08 +0000
Date:   Thu, 18 Feb 2021 07:42:07 +0000
From:   Christoph Hellwig <hch@infradead.org>
To:     Luis Henriques <lhenriques@suse.de>
Cc:     Amir Goldstein <amir73il@gmail.com>,
        Jeff Layton <jlayton@kernel.org>,
        Steve French <sfrench@samba.org>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Dave Chinner <dchinner@redhat.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        Nicolas Boichat <drinkcat@chromium.org>,
        Ian Lance Taylor <iant@google.com>,
        Luis Lozano <llozano@chromium.org>, ceph-devel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] vfs: prevent copy_file_range to copy across devices
Message-ID: <20210218074207.GA329605@infradead.org>
References: <CAOQ4uxiFGjdvX2-zh5o46pn7RZhvbGHH0wpzLPuPOom91FwWeQ@mail.gmail.com>
 <20210215154317.8590-1-lhenriques@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210215154317.8590-1-lhenriques@suse.de>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by casper.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

This whole idea of cross-device copie has always been a horrible idea,
and I've been arguing against it since the patches were posted.
