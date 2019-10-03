Return-Path: <SRS0=z6tu=X4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0C2BC4CED1
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Oct 2019 17:03:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D1CEF2070B
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Oct 2019 17:03:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392628AbfJCQmS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Oct 2019 12:42:18 -0400
Received: from fieldses.org ([173.255.197.46]:41728 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2392623AbfJCQmS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Oct 2019 12:42:18 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id B2CA41C8C; Thu,  3 Oct 2019 12:42:17 -0400 (EDT)
Date:   Thu, 3 Oct 2019 12:42:17 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Randy Dunlap <rdunlap@infradead.org>
Cc:     Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: fs/nfsd/nfs4state.c use of "\%s"
Message-ID: <20191003164217.GA25406@fieldses.org>
References: <b76bde04-7970-c870-5af7-359141958c4f@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b76bde04-7970-c870-5af7-359141958c4f@infradead.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Oct 02, 2019 at 05:17:27PM -0700, Randy Dunlap wrote:
> Hi Bruce,
> 
> In commit 78599c42ae3c70300a38b0d1271a85bc9f2d704a
> (nfsd4: add file to display list of client's opens), some of the %s printk
> specifiers are \-escaped:
> 
> +       seq_printf(s, "access: \%s\%s, ",
> +               access & NFS4_SHARE_ACCESS_READ ? "r" : "-",
> +               access & NFS4_SHARE_ACCESS_WRITE ? "w" : "-");
> +       seq_printf(s, "deny: \%s\%s, ",
> +               deny & NFS4_SHARE_ACCESS_READ ? "r" : "-",
> +               deny & NFS4_SHARE_ACCESS_WRITE ? "w" : "-");
> 
> 
> sparse complains about these, as does gcc when used with --pedantic.
> sparse says:
> 
> ../fs/nfsd/nfs4state.c:2385:23: warning: unknown escape sequence: '\%'
> ../fs/nfsd/nfs4state.c:2385:23: warning: unknown escape sequence: '\%'
> ../fs/nfsd/nfs4state.c:2388:23: warning: unknown escape sequence: '\%'
> ../fs/nfsd/nfs4state.c:2388:23: warning: unknown escape sequence: '\%'
> 
> Is this just a typo?

Yes, weird, I wonder how that crept in.

Patch queued up for 5.5, thanks.

--b.
