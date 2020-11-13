Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60944C388F7
	for <linux-nfs@archiver.kernel.org>; Fri, 13 Nov 2020 14:50:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C027C21D79
	for <linux-nfs@archiver.kernel.org>; Fri, 13 Nov 2020 14:50:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="U9x4G4kA"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726324AbgKMOux (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 13 Nov 2020 09:50:53 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33942 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726278AbgKMOuw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Nov 2020 09:50:52 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id ED18BC0613D1
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2020 06:50:52 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id E4A89BC8; Fri, 13 Nov 2020 09:50:50 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org E4A89BC8
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1605279050;
        bh=fHUo8ksvLkUenWiO+Z3+oXBdqyaq1gC4Ub1AQFepY1k=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=U9x4G4kAcHMVz5ItdkTSXGEmUl+jpSPOALANycA9Ff2suy0Z3M8JKHIWshpXtf9gS
         1J6v9Cwkscx4KtEcJNyaVLw1M/bvsE4S1GNMEaWfi/HpHmP3+nNtsZ7G0hOYOJy23K
         ThbDwGlNJwhW2flKrLxh53w89RgG6Splios2xPqk=
Date:   Fri, 13 Nov 2020 09:50:50 -0500
From:   bfields <bfields@fieldses.org>
To:     Daire Byrne <daire@dneg.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        linux-cachefs <linux-cachefs@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Adventures in NFS re-exporting
Message-ID: <20201113145050.GB1299@fieldses.org>
References: <943482310.31162206.1599499860595.JavaMail.zimbra@dneg.com>
 <279389889.68934777.1603124383614.JavaMail.zimbra@dneg.com>
 <635679406.70384074.1603272832846.JavaMail.zimbra@dneg.com>
 <20201109160256.GB11144@fieldses.org>
 <1744768451.86186596.1605186084252.JavaMail.zimbra@dneg.com>
 <20201112135733.GA9243@fieldses.org>
 <444227972.86442677.1605206025305.JavaMail.zimbra@dneg.com>
 <20201112205524.GI9243@fieldses.org>
 <883314904.86570901.1605222357023.JavaMail.zimbra@dneg.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <883314904.86570901.1605222357023.JavaMail.zimbra@dneg.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 12, 2020 at 11:05:57PM +0000, Daire Byrne wrote:
> So, I can't lay claim to identifying the exact optimisation/hack that
> improves the retention of the re-export server's client cache when
> re-exporting an NFSv3 server (which is then read by many clients). We
> were working with an engineer at the time who showed an interest in
> our use case and after we supplied a reproducer he suggested modifying
> the nfs/inode.c
> 
> -		if (!inode_eq_iversion_raw(inode, fattr->change_attr)) {
> +		if (inode_peek_iversion_raw(inode) < fattr->change_attr)
> {
> 
> His reasoning at the time was:
> 
> "Fixes inode invalidation caused by read access. The least important
> bit is ORed with 1 and causes the inode version to differ from the one
> seen on the NFS share. This in turn causes unnecessary re-download
> impacting the performance significantly. This fix makes it only
> re-fetch file content if inode version seen on the server is newer
> than the one on the client."
> 
> But I've always been puzzled by why this only seems to be the case
> when using knfsd to re-export the (NFSv3) client mount. Using multiple
> processes on a standard client mount never causes any similar
> re-validations. And this happens with a completely read-only share
> which is why I started to think it has something to do with atimes as
> that could perhaps still cause a "write" modification even when
> read-only?

Ah-hah!  So, it's inode_query_iversion() that's modifying a nfs inode's
i_version.  That's a special thing that only nfsd would do.

I think that's totally fixable, we'll just have to think a little about
how....

--b.
