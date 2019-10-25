Return-Path: <SRS0=xsWA=YS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F4119CA9EA0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Oct 2019 15:33:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C3BF421929
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Oct 2019 15:33:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2395429AbfJYPdh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Oct 2019 11:33:37 -0400
Received: from fieldses.org ([173.255.197.46]:40532 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730267AbfJYPdh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Oct 2019 11:33:37 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id B6E1D1C21; Fri, 25 Oct 2019 11:33:36 -0400 (EDT)
Date:   Fri, 25 Oct 2019 11:33:36 -0400
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfsd: Fix races between nfsd4_cb_release() and
 nfsd4_shutdown_callback()
Message-ID: <20191025153336.GA20283@fieldses.org>
References: <20191023214318.9350-1-trond.myklebust@hammerspace.com>
 <20191025145147.GA16053@pick.fieldses.org>
 <97f56de86f0aeafb56998023d0561bb4a6233eb8.camel@hammerspace.com>
 <20191025152119.GC16053@pick.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191025152119.GC16053@pick.fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 25, 2019 at 11:21:19AM -0400, J. Bruce Fields wrote:
> On Fri, Oct 25, 2019 at 02:55:45PM +0000, Trond Myklebust wrote:
> > On Fri, 2019-10-25 at 10:51 -0400, J. Bruce Fields wrote:
> > > On Wed, Oct 23, 2019 at 05:43:18PM -0400, Trond Myklebust wrote:
> > > > When we're destroying the client lease, and we call
> > > > nfsd4_shutdown_callback(), we must ensure that we do not return
> > > > before all outstanding callbacks have terminated and have
> > > > released their payloads.
> > > 
> > > This is great, thanks!  We've seen what I'm fairly sure is the same
> > > bug
> > > from Red Hat users.  I think my blind spot was an assumption that
> > > rpc tasks wouldn't outlive rpc_shutdown_client().
> > > 
> > > However, it's causing xfstests runs to hang, and I haven't worked out
> > > why yet.
> > > 
> > > I'll spend some time on it this afternoon and let you know what I
> > > figure
> > > out.
> > > 
> > 
> > Is that happening with v2 or with v1? With v1 there is definitely a
> > hang in __destroy_client() due to the refcount leak that I believe I
> > fixed in v2.
> 
> I thought I was running v2, let me double-check....

Yes, with v2 I'm getting a hang on generic/013.

I checked quickly and didn't see anything interesting in the logs,
otherwise I haven't done any digging.

--b.
