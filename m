Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6F6AC6379D
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Nov 2020 19:31:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3335420B1F
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Nov 2020 19:31:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="Vukxcyco"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728154AbgKYTbk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 25 Nov 2020 14:31:40 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59084 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725776AbgKYTbj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2020 14:31:39 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C2D2BC0613D4
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2020 11:31:39 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id A6EDE6EAE; Wed, 25 Nov 2020 14:31:38 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org A6EDE6EAE
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1606332698;
        bh=xyU4jzmIzeKYkiLfBQpm5G+31V0xWP28KnHvFM5AGeg=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=VukxcycoQhHQJMHQXGvaeyxRNYDHGGwlYl2BFom/k6v+VC0Vd34+CTbJpTH/We6ca
         1TiC6WA6bxhIaxmiNbcavsUhsiELDcAG1uLFXU+he1v2YBIJdjauQKkfJVzL3qCsY7
         Jf4MgIARIeAuoZzFqAIUwZZwNO/WvxTPLDtsIL3g=
Date:   Wed, 25 Nov 2020 14:31:38 -0500
From:   bfields <bfields@fieldses.org>
To:     Daire Byrne <daire@dneg.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        linux-cachefs <linux-cachefs@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Adventures in NFS re-exporting
Message-ID: <20201125193138.GC7049@fieldses.org>
References: <943482310.31162206.1599499860595.JavaMail.zimbra@dneg.com>
 <1188023047.38703514.1600272094778.JavaMail.zimbra@dneg.com>
 <279389889.68934777.1603124383614.JavaMail.zimbra@dneg.com>
 <635679406.70384074.1603272832846.JavaMail.zimbra@dneg.com>
 <20201109160256.GB11144@fieldses.org>
 <1744768451.86186596.1605186084252.JavaMail.zimbra@dneg.com>
 <1055884313.92996091.1606250106656.JavaMail.zimbra@dneg.com>
 <20201124211522.GC7173@fieldses.org>
 <932244432.93596532.1606324491501.JavaMail.zimbra@dneg.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <932244432.93596532.1606324491501.JavaMail.zimbra@dneg.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Nov 25, 2020 at 05:14:51PM +0000, Daire Byrne wrote:
> Cool. I'm glad there are some notes for others to reference - this
> thread is now too long for any human to read. The only things I'd
> consider adding are:

Thanks, done.

> * re-export of NFSv4.0 filesystem can give input/output errors when the cache is dropped

Looking back at that thread....  I suspect that's just unfixable, so all
you can do is either use v4.1+ on the original server or 4.0+ on the
edge clients.  Or I wonder if it would help if there was some way to
tell the 4.0 client just to try special stateids instead of attempting
an open?

> * a weird interaction with nfs client readahead such that all reads
> are limited to the default 128k unless you manually increase it to
> match rsize.
>
> The only other thing I can offer are tips & tricks for doing this kind
> of thing over the WAN (vfs_cache_pressure, actimeo, nocto) and using
> fscache.

OK, I haven't tried to pick that out of the thread yet.

--b.
