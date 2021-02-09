Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8BDCC433E0
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Feb 2021 23:52:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 34C8664DB3
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Feb 2021 23:52:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233999AbhBIXvx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Feb 2021 18:51:53 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57262 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234129AbhBIWOx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Feb 2021 17:14:53 -0500
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id CDA2FC08EC44
        for <linux-nfs@vger.kernel.org>; Tue,  9 Feb 2021 14:01:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=iz8v7WB8rAGB4dR54Ek5r1ashQ2mtNeQY3DSOI1ePbM=; b=VcBQA8MMzx3QcTXwVmuTEW1jsd
        wYKfAMFZkSCiFIifea10qRixkxsFSHXIcCtHkkHR4Kea0GwOYmaDVzH0m7zDTNEmrrYSRbhgCLeyw
        u7IUcthEKP+N+V4ipaz22OBI1NMCZaquvSHvgClYMRbHW3kgNHxxqqMua1tRjwAGxNyMYkQoQ6Nnd
        iJ+d+SAUYVrP/fSMMo+cdTbOV7tkvoDR1lnPlsFRGQ1csKopW+5Ms6MCVSSwdjZ2Gp82C7WyoniGU
        ngKPbn9Q3J53KJ1u2gd34evnq9D13S1aMa0/o8wfePbebAub2Efvx3RwT1vRtCJjC5XEwh2MYpGfx
        TQx03e2w==;
Received: from willy by casper.infradead.org with local (Exim 4.94 #2 (Red Hat Linux))
        id 1l9b4Z-0080z9-0n; Tue, 09 Feb 2021 22:01:28 +0000
Date:   Tue, 9 Feb 2021 22:01:27 +0000
From:   Matthew Wilcox <willy@infradead.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     "mgorman@suse.de" <mgorman@suse.de>,
        "brouer@redhat.com" <brouer@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: Fwd: alloc_pages_bulk()
Message-ID: <20210209220127.GB308988@casper.infradead.org>
References: <2A0C36E7-8CB0-486F-A8DB-463CA28C5C5D@oracle.com>
 <EEB0B974-6E63-41A0-9C01-F0DEA39FC4BF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <EEB0B974-6E63-41A0-9C01-F0DEA39FC4BF@oracle.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Feb 08, 2021 at 05:50:51PM +0000, Chuck Lever wrote:
> > We've been discussing how NFSD can more efficiently refill its
> > receive buffers (currently alloc_page() in a loop; see
> > net/sunrpc/svc_xprt.c::svc_alloc_arg()).

I'm not familiar with the sunrpc architecture, but this feels like you're
trying to optimise something that shouldn't exist.  Ideally a write
would ask the page cache for the pages that correspond to the portion
of the file which is being written to.  I appreciate that doesn't work
well for, eg, NFS-over-TCP, but for NFS over any kind of RDMA, that
should be possible, right?

