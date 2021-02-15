Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CDC7C433E0
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Feb 2021 21:23:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 06F9964DF0
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Feb 2021 21:23:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229660AbhBOVXS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 Feb 2021 16:23:18 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57860 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229662AbhBOVXR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2021 16:23:17 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E8B4EC0613D6
        for <linux-nfs@vger.kernel.org>; Mon, 15 Feb 2021 13:22:36 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id A63432501; Mon, 15 Feb 2021 16:22:35 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org A63432501
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1613424155;
        bh=3l1zBob6E6m+c5RehIWxIZHIHj+m8qkhNuLla0rSVpA=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=kzPNsLNBsokRGLP+6GTFFw0Bqm7W145tAv3TLIrGqD0M1K60pObFGXqdV8ou+S9qP
         ccDZ0XiAzGY/o0JNSz4oAatfRD+BlmOChIj2YNEcv69ZgiLvj0OsKnpAakK1kB+zSc
         KFrLLlEZxovoeQcZN8O3kxgnFYbAZy2JksMc5P5E=
Date:   Mon, 15 Feb 2021 16:22:35 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Subject: Re: pynfs breakage
Message-ID: <20210215212235.GD30742@fieldses.org>
References: <804830ba7fdd91cbf9348050b07f9922801d20f0.camel@kernel.org>
 <20210215201728.GC30742@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210215201728.GC30742@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Feb 15, 2021 at 03:17:28PM -0500, Bruce Fields wrote:
> On Mon, Feb 15, 2021 at 03:15:08PM -0500, Jeff Layton wrote:
> > Hi Bruce!
> > 
> > The latest HEAD in pynfs doesn't run for me:
> > 
> > $ ./nfs4.1/testserver.py --help
> > Traceback (most recent call last):
> >   File "/home/jlayton/git/pynfs/nfs4.1/./testserver.py", line 38, in <module>
> >     import server41tests.environment as environment
> >   File "/home/jlayton/git/pynfs/nfs4.1/server41tests/environment.py", line 593
> >     def write_file(sess, file, data, offset=0 stateid=stateid4(0, b''),
> >                                               ^
> > SyntaxError: invalid syntax
> > 
> > If I revert this commit, then it works:
> 
> Yeah, sorry about that, I pushed out quickly thinking I'd tested it, but
> in fact it has a bunch of mistakes.  Fixing....

Should be fixed, apologies again.--b.
