Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43BAEC8300F
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Dec 2020 20:54:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A6CD121741
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Dec 2020 20:54:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="LnAbbdGq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388517AbgLAUyl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 1 Dec 2020 15:54:41 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49552 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388142AbgLAUyk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Dec 2020 15:54:40 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 73A59C0617A7
        for <linux-nfs@vger.kernel.org>; Tue,  1 Dec 2020 12:54:00 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id 33CA36F4C; Tue,  1 Dec 2020 15:53:59 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 33CA36F4C
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1606856039;
        bh=C0M0M1XMvnPyVuXvoznQh2WET8IHYd9p6mpO9O/PujU=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=LnAbbdGqnAEFlW+9N7DwEyd4Z6HmjqHfoiaSRRx3QoCJMcu9hXLy2oqHnF0xwyHEU
         1eBGQYFAOq+2V2OwJ1LmqxR4V1NXOr+qESBfm1adTDKYemNu50ocyJdF7kzwAfEFK5
         ydLOoWU3it7yovgu2nxfzwsmlm03xuv3t60PQDNI=
Date:   Tue, 1 Dec 2020 15:53:59 -0500
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] nfsd: Record NFSv4 pre/post-op attributes as
 non-atomic
Message-ID: <20201201205359.GC21355@fieldses.org>
References: <20201201041427.756749-1-trondmy@kernel.org>
 <20201201041427.756749-2-trondmy@kernel.org>
 <20201201193521.GA21355@fieldses.org>
 <63eaf3aab8814b2d65998123b6ba2e5b979a48d9.camel@hammerspace.com>
 <7181b1e7290dcfe4f92d9a8b00117a81b30f0cce.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7181b1e7290dcfe4f92d9a8b00117a81b30f0cce.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 01, 2020 at 08:27:38PM +0000, Trond Myklebust wrote:
> As far as I can tell, there is no need for it at all, since both the
> NFSv3 and NFSv4 client can supply atomic struct change_info4 in the
> cases where it is relevant (those cases being recording the changes to
> the parent directory/ies when doing CREATE, OPEN(O_CREAT), LINK, REMOVE
> and RENAME).

I was wondering about that.  We'd need some additional interface to
allow nfs to supply that stuff to nfsd, right?

--b.
