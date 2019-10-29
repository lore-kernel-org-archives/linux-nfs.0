Return-Path: <SRS0=5qc3=YW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFAA9CA9EAE
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Oct 2019 21:47:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7F9F421721
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Oct 2019 21:47:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728464AbfJ2VrF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 29 Oct 2019 17:47:05 -0400
Received: from fieldses.org ([173.255.197.46]:35912 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726364AbfJ2VrF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Oct 2019 17:47:05 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 4D1A01508; Tue, 29 Oct 2019 17:47:05 -0400 (EDT)
Date:   Tue, 29 Oct 2019 17:47:05 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfsd: Fix races between nfsd4_cb_release() and
 nfsd4_shutdown_callback()
Message-ID: <20191029214705.GA29280@fieldses.org>
References: <20191023214318.9350-1-trond.myklebust@hammerspace.com>
 <20191025145147.GA16053@pick.fieldses.org>
 <97f56de86f0aeafb56998023d0561bb4a6233eb8.camel@hammerspace.com>
 <20191025152119.GC16053@pick.fieldses.org>
 <20191025153336.GA20283@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191025153336.GA20283@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 25, 2019 at 11:33:36AM -0400, bfields wrote:
> On Fri, Oct 25, 2019 at 11:21:19AM -0400, J. Bruce Fields wrote:
> > I thought I was running v2, let me double-check....
> 
> Yes, with v2 I'm getting a hang on generic/013.
> 
> I checked quickly and didn't see anything interesting in the logs,
> otherwise I haven't done any digging.

Reproduceable just with ./check -nfs generic/013.  The last thing I see
in wireshark is an asynchronous COPY call and reply.  Which means it's
probably trying to do a CB_OFFLOAD.  Hm.

--b.
