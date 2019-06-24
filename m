Return-Path: <SRS0=h8DK=UX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86B13C4646B
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Jun 2019 21:05:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5E69420656
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Jun 2019 21:05:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726730AbfFXVFM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 Jun 2019 17:05:12 -0400
Received: from fieldses.org ([173.255.197.46]:48992 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727436AbfFXVFM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Jun 2019 17:05:12 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 0FD8F1E67; Mon, 24 Jun 2019 17:05:12 -0400 (EDT)
Date:   Mon, 24 Jun 2019 17:05:12 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Kees Cook <keescook@chromium.org>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 08/16] nfsd: escape high characters in binary data
Message-ID: <20190624210512.GA20331@fieldses.org>
References: <1561042275-12723-1-git-send-email-bfields@redhat.com>
 <1561042275-12723-9-git-send-email-bfields@redhat.com>
 <20190621174544.GC25590@fieldses.org>
 <201906211431.E6552108@keescook>
 <20190622190058.GD5343@fieldses.org>
 <201906221320.5BFC134713@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201906221320.5BFC134713@keescook>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Jun 22, 2019 at 01:22:56PM -0700, Kees Cook wrote:
> On Sat, Jun 22, 2019 at 03:00:58PM -0400, J. Bruce Fields wrote:
> > The logic around ESCAPE_NP and the "only" string is really confusing.  I
> > started assuming I could just add an ESCAPE_NONASCII flag and stick "
> > and \ into the "only" string, but it doesn't work that way.
> 
> Yeah, if ESCAPE_NP isn't specified, the "only" characters are passed
> through. It'd be nice to have an "add" or a clearer way to do actual
> ctype subsets, etc. If there isn't an obviously clear way to refactor
> it, just skip it for now and I'm happy to ack your original patch. :)

There may well be some simplification possible here....  There aren't
really many users of "only", for example.  I'll look into it some more.

--b.
