Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72A33C43603
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Mar 2021 18:55:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 51E3865296
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Mar 2021 18:55:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231359AbhCHSym (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Mar 2021 13:54:42 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58044 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230517AbhCHSyL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Mar 2021 13:54:11 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 83C23C06175F;
        Mon,  8 Mar 2021 10:54:11 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id B366F35BD; Mon,  8 Mar 2021 13:54:10 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org B366F35BD
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1615229650;
        bh=xDgC7LlBmjqCSWF7ziP8dFyfWdwiA7a0Sh7MAb3vsSg=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=ij/YmN4ZebdMPqxxrBDuGYwtre8S0qs40MfCHLhqodetYSoxXMe9aE04WgC/4Q1DR
         20zcySXbv0GKk83IdR8F8zJJRdgLSvUXs5DXB8A6ipkmjqtANNIA8X5KWjQ7wad9Xl
         DoQOtJQEB0D4j4ThsTeLw2m/ax39UkOlyflJq14o=
Date:   Mon, 8 Mar 2021 13:54:10 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     David Howells <dhowells@redhat.com>
Cc:     Amir Goldstein <amir73il@gmail.com>, linux-cachefs@redhat.com,
        Jeff Layton <jlayton@redhat.com>,
        David Wysochanski <dwysocha@redhat.com>,
        "Matthew Wilcox (Oracle)" <willy@infradead.org>,
        Christoph Hellwig <hch@infradead.org>,
        Dave Chinner <dchinner@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-afs@lists.infradead.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        CIFS <linux-cifs@vger.kernel.org>,
        ceph-devel <ceph-devel@vger.kernel.org>,
        v9fs-developer@lists.sourceforge.net,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: fscache: Redesigning the on-disk cache
Message-ID: <20210308185410.GE7284@fieldses.org>
References: <CAOQ4uxhxwKHLT559f8v5aFTheKgPUndzGufg0E58rkEqa9oQ3Q@mail.gmail.com>
 <2653261.1614813611@warthog.procyon.org.uk>
 <517184.1615194835@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <517184.1615194835@warthog.procyon.org.uk>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Mar 08, 2021 at 09:13:55AM +0000, David Howells wrote:
> Amir Goldstein <amir73il@gmail.com> wrote:
> > With ->fiemap() you can at least make the distinction between a non existing
> > and an UNWRITTEN extent.
> 
> I can't use that for XFS, Ext4 or btrfs, I suspect.  Christoph and Dave's
> assertion is that the cache can't rely on the backing filesystem's metadata
> because these can arbitrarily insert or remove blocks of zeros to bridge or
> split extents.

Could you instead make some sort of explicit contract with the
filesystem?  Maybe you'd flag it at mkfs time and query for it before
allowing a filesystem to be used for fscache.  You don't need every
filesystem to support fscache, right, just one acceptable one?

--b.
