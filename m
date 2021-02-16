Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BBBCC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Feb 2021 09:31:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 0608E64DCF
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Feb 2021 09:31:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230026AbhBPJbj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Feb 2021 04:31:39 -0500
Received: from verein.lst.de ([213.95.11.211]:40555 "EHLO verein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229916AbhBPJb3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Feb 2021 04:31:29 -0500
Received: by verein.lst.de (Postfix, from userid 2407)
        id B13C56736F; Tue, 16 Feb 2021 10:30:44 +0100 (CET)
Date:   Tue, 16 Feb 2021 10:30:44 +0100
From:   Christoph Hellwig <hch@lst.de>
To:     David Howells <dhowells@redhat.com>
Cc:     Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Marc Dionne <marc.dionne@auristor.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Steve French <sfrench@samba.org>,
        Dominique Martinet <asmadeus@codewreck.org>,
        linux-cifs@vger.kernel.org, ceph-devel@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        Matthew Wilcox <willy@infradead.org>, linux-cachefs@redhat.com,
        Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org,
        linux-afs@lists.infradead.org,
        v9fs-developer@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@kernel.org>,
        David Wysochanski <dwysocha@redhat.com>,
        linux-kernel@vger.kernel.org,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 34/33] netfs: Use in_interrupt() not in_softirq()
Message-ID: <20210216093044.GA24615@lst.de>
References: <20210216084230.GA23669@lst.de> <161340385320.1303470.2392622971006879777.stgit@warthog.procyon.org.uk> <1376938.1613429183@warthog.procyon.org.uk> <1419965.1613467771@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1419965.1613467771@warthog.procyon.org.uk>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 16, 2021 at 09:29:31AM +0000, David Howells wrote:
> Is there a better way to do it?  The intent is to process the assessment phase
> in the calling thread's context if possible rather than bumping over to a
> worker thread.  For synchronous I/O, for example, that's done in the caller's
> thread.  Maybe that's the answer - if it's known to be asynchronous, I have to
> punt, but otherwise don't have to.

Yes, i think you want an explicit flag instead.
