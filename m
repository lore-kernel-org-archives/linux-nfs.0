Return-Path: <SRS0=o69+=33=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55E78C2BA83
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Feb 2020 18:18:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3AD1820726
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Feb 2020 18:18:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727563AbgBGSSS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 7 Feb 2020 13:18:18 -0500
Received: from fieldses.org ([173.255.197.46]:56544 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727804AbgBGSSS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Feb 2020 13:18:18 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 698F1709; Fri,  7 Feb 2020 13:18:17 -0500 (EST)
Date:   Fri, 7 Feb 2020 13:18:17 -0500
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bfields@redhat.com" <bfields@redhat.com>
Subject: Re: [PATCH] SUNRPC/cache: Allow garbage collection of invalid cache
 entries
Message-ID: <20200207181817.GC17036@fieldses.org>
References: <20200114165738.922961-1-trond.myklebust@hammerspace.com>
 <20200206163322.GB2244@fieldses.org>
 <8dc1ed17de98e4b59fb9e408692c152456863a20.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8dc1ed17de98e4b59fb9e408692c152456863a20.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 07, 2020 at 02:25:27PM +0000, Trond Myklebust wrote:
> On Thu, 2020-02-06 at 11:33 -0500, J. Bruce Fields wrote:
> > On Tue, Jan 14, 2020 at 11:57:38AM -0500, Trond Myklebust wrote:
> > > If the cache entry never gets initialised, we want the garbage
> > > collector to be able to evict it. Otherwise if the upcall daemon
> > > fails to initialise the entry, we end up never expiring it.
> > 
> > Could you tell us more about what motivated this?
> > 
> > It's causing failures on pynfs server-reboot tests.  I haven't pinned
> > down the cause yet, but it looks like it could be a regression to the
> > behavior Kinglong Mee describes in detail in his original patch.
> > 
> 
> Can you point me to the tests that are failing?

I'm basically doing

	./nfs4.1/testserver.py myserver:/path reboot
			--serverhelper=examples/server_helper.sh
			--serverhelperarg=myserver

For all I know at this point, the change could be exposing a pynfs-side
bug.

> The motivation here is to allow the garbage collector to do its job of
> evicting cache entries after they are supposed to have timed out.

Understood.  I was curious whether this was found by code inspection or
because you'd run across a case where the leak was causing a practical
problem.

--b.

> The fact that uninitialised cache entries are given an infinite
> lifetime, and are never evicted is a de facto memory leak if, for
> instance, the mountd daemon ignores the cache request, or the downcall
> in expkey_parse() or svc_export_parse() fails without being able to
> update the request.
> 
> The threads that are waiting for the cache replies already have a
> mechanism for dealing with timeouts (with cache_wait_req() and
> deferred requests), so the question is what is so special about
> uninitialised requests that we have to leak them in order to avoid a
> problem with reboot?
