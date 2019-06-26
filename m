Return-Path: <SRS0=CxR0=UZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFFEDC48BD3
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Jun 2019 16:21:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BD7802084B
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Jun 2019 16:21:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726227AbfFZQVu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 26 Jun 2019 12:21:50 -0400
Received: from fieldses.org ([173.255.197.46]:35062 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725958AbfFZQVt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Jun 2019 12:21:49 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 597E3C56; Wed, 26 Jun 2019 12:21:49 -0400 (EDT)
Date:   Wed, 26 Jun 2019 12:21:49 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Kees Cook <keescook@chromium.org>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 08/16] nfsd: escape high characters in binary data
Message-ID: <20190626162149.GB4144@fieldses.org>
References: <1561042275-12723-1-git-send-email-bfields@redhat.com>
 <1561042275-12723-9-git-send-email-bfields@redhat.com>
 <20190621174544.GC25590@fieldses.org>
 <201906211431.E6552108@keescook>
 <20190622190058.GD5343@fieldses.org>
 <201906221320.5BFC134713@keescook>
 <20190624210512.GA20331@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624210512.GA20331@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Jun 24, 2019 at 05:05:12PM -0400, J. Bruce Fields wrote:
> On Sat, Jun 22, 2019 at 01:22:56PM -0700, Kees Cook wrote:
> > On Sat, Jun 22, 2019 at 03:00:58PM -0400, J. Bruce Fields wrote:
> > > The logic around ESCAPE_NP and the "only" string is really confusing.  I
> > > started assuming I could just add an ESCAPE_NONASCII flag and stick "
> > > and \ into the "only" string, but it doesn't work that way.
> > 
> > Yeah, if ESCAPE_NP isn't specified, the "only" characters are passed
> > through. It'd be nice to have an "add" or a clearer way to do actual
> > ctype subsets, etc. If there isn't an obviously clear way to refactor
> > it, just skip it for now and I'm happy to ack your original patch. :)
> 
> There may well be some simplification possible here....  There aren't
> really many users of "only", for example.  I'll look into it some more.

The printk users are kind of mysterious to me.  I did a grep for

	git grep '%[0-9.*]pE'

which got 75 hits.  All of them for pE.  I couldn't find any of the
other pE[achnops] variants.  pE is equivalent to ESCAPE_ANY|ESCAPE_NP.
Confusingly, ESCAPE_NP doesn't mean "escape non-printable", it means
"don't escape printable".  So things like carriage returns aren't
escaped.

Of those 57 were in drivers/net/wireless, and from a quick check seemed
mostly to be for SSIDs in debug messages.  I *think* SSIDs can be
arbitrary bytes?  If they really want them escaped then I suspect they
want more than just nonprintable characters escaped.

One of the hits outside wireless code was in drm_dp_cec_adap_status,
which was printing some device ID into a debugfs file with "ID: %*pE\n".
If the ID actually needs escaping, then I suspect the meant to escape \n
too to prevent misparsing that output.

--b.
