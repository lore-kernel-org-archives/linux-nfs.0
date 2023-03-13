Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F64FC6FD19
	for <linux-nfs@archiver.kernel.org>; Mon, 13 Mar 2023 15:31:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229583AbjCMPbe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 13 Mar 2023 11:31:34 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43986 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229568AbjCMPbd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Mar 2023 11:31:33 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id D31DF5DC8A;
        Mon, 13 Mar 2023 08:31:32 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 6F5E061345;
        Mon, 13 Mar 2023 15:31:32 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B5EBDC433EF;
        Mon, 13 Mar 2023 15:31:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1678721491;
        bh=xCqhP5ltlbqmeYajpzLHhIMsGiLRX6bLjrlSho6mwNY=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=fzYoYFN+smCU3vW8J2XdKsUbkYkD8KxlH4nNjb5M/7Ev24ithnhG2c5DiVGs1cr1a
         Iba3tzw2aI5jMFts0o6O2nKvzhriwIKBWBUNvaDP18OvoDN51fjlSiAIpOzPFbE0k2
         fNs2TQCTl0bsP9xOTTm4s7vl2w8LdXm4GrDVl6OnT3RM9wBfDvKjPgk1C7z9xrbGt3
         YvvTakNA14eathZiGjXwcL0yOxEgKHPxg275rA7NcKDS+Ti9+nvABnRRKZ9fudbhsS
         BMd1+ncfiqgMBGaKwLaEk5vNXxsWePvvahHZM7c64AjVH6fh0vKJern+JTvUNLs7yq
         +vDxsgdFBUEaA==
Date:   Mon, 13 Mar 2023 16:31:26 +0100
From:   Christian Brauner <brauner@kernel.org>
To:     Christoph Hellwig <hch@infradead.org>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfs: use vfs setgid helper
Message-ID: <20230313153126.nu5hwxb6lwpad6qp@wittgenstein>
References: <20230313-fs-nfs-setgid-v1-1-5b1fa599f186@kernel.org>
 <ZA9ABbNzoxScYpzI@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <ZA9ABbNzoxScYpzI@infradead.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Mar 13, 2023 at 08:23:49AM -0700, Christoph Hellwig wrote:
> On Mon, Mar 13, 2023 at 02:25:34PM +0100, Christian Brauner wrote:
> > +#include "../internal.h"
> 
> > +		if (setattr_should_drop_sgid(&nop_mnt_idmap, inode))
> 
> It setattr_should_drop_sgid is used by file systems, it should not be in
> internal.h.

Good catch. I accidently didn't move it into include/linux/fs.h
with setattr_should_drop_suidgid(). Let me resend. Thanks for
catching this...
