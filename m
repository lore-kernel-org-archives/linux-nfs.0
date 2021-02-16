Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48343C433E6
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Feb 2021 02:12:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 157D964D9D
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Feb 2021 02:12:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229721AbhBPCMB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 Feb 2021 21:12:01 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34748 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229662AbhBPCMA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2021 21:12:00 -0500
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 73693C061574;
        Mon, 15 Feb 2021 18:11:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=s6M77qqPUyP6vrb0lQFb/awPS8W4Khs2jpQ6ixqkTJU=; b=u1urISE6rLh5rcNq2O6tANgHCo
        Gu04LHkFcKO2Z4OIXabD32OeS/AgjxvHE6dvNfhMsXBDDjHOoJZwAIamvqRKXi1Pitg4dZIJz06Lt
        83KURXnWXanrmcals7PoXVLIQoZR64IcKD67/HRLxouSjXNGDiOWGrcRbcXQDcrGlKoDlORQOKa5e
        htETGkCxXa104EyamUhm6yw9mYpOd+rjK42OnOJr77DFHwJaMrNnp6k0bKPaWoN3lK2jpiogsmZm5
        ImbmqPEOd56K3jktMNKIvRh5O0Mmv8keAlevLfepeixppXXeXWpQQ0SyZjfnV2NdIGfPKLQdVLFUZ
        lZUay/Zw==;
Received: from willy by casper.infradead.org with local (Exim 4.94 #2 (Red Hat Linux))
        id 1lBpod-00GL6i-EP; Tue, 16 Feb 2021 02:10:18 +0000
Date:   Tue, 16 Feb 2021 02:10:15 +0000
From:   Matthew Wilcox <willy@infradead.org>
To:     Steve French <smfrench@gmail.com>
Cc:     Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Steve French <sfrench@samba.org>,
        Dominique Martinet <asmadeus@codewreck.org>,
        CIFS <linux-cifs@vger.kernel.org>, ceph-devel@vger.kernel.org,
        linux-cachefs@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-mm <linux-mm@kvack.org>, linux-afs@lists.infradead.org,
        v9fs-developer@lists.sourceforge.net,
        Christoph Hellwig <hch@lst.de>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        David Wysochanski <dwysocha@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH 00/33] Network fs helper library & fscache kiocb API [ver
 #3]
Message-ID: <20210216021015.GH2858050@casper.infradead.org>
References: <161340385320.1303470.2392622971006879777.stgit@warthog.procyon.org.uk>
 <9e49f96cd80eaf9c8ed267a7fbbcb4c6467ee790.camel@redhat.com>
 <CAH2r5mvPLivjuE=cbijzGSHOvx-hkWSWbcxpoBnJX-BR9pBskQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH2r5mvPLivjuE=cbijzGSHOvx-hkWSWbcxpoBnJX-BR9pBskQ@mail.gmail.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Feb 15, 2021 at 06:40:27PM -0600, Steve French wrote:
> It could be good if netfs simplifies the problem experienced by
> network filesystems on Linux with readahead on large sequential reads
> - where we don't get as much parallelism due to only having one
> readahead request at a time (thus in many cases there is 'dead time'
> on either the network or the file server while waiting for the next
> readpages request to be issued).   This can be a significant
> performance problem for current readpages when network latency is long
> (or e.g. in cases when network encryption is enabled, and hardware
> offload not available so time consuming on the server or client to
> encrypt the packet).
> 
> Do you see netfs much faster than currentreadpages for ceph?
> 
> Have you been able to get much benefit from throttling readahead with
> ceph from the current netfs approach for clamping i/o?

The switch from readpages to readahead does help in a couple of corner
cases.  For example, if you have two processes reading the same file at
the same time, one will now block on the other (due to the page lock)
rather than submitting a mess of overlapping and partial reads.

We're not there yet on having multiple outstanding reads.  Bill and I
had a chat recently about how to make the readahead code detect that
it is in a "long fat pipe" situation (as opposed to just dealing with
a slow device), and submit extra readahead requests to make best use of
the bandwidth and minimise blocking of the application.

That's not something for the netfs code to do though; we can get into
that situation with highly parallel SSDs.

