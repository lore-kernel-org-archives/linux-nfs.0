Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AB2EC64E7B
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Dec 2020 21:36:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A071B2085B
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Dec 2020 21:36:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="w8HISBv5"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728578AbgLAVge (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 1 Dec 2020 16:36:34 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56030 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727686AbgLAVge (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Dec 2020 16:36:34 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 913D5C0613D4
        for <linux-nfs@vger.kernel.org>; Tue,  1 Dec 2020 13:35:54 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id B9C036F4B; Tue,  1 Dec 2020 16:35:53 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org B9C036F4B
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1606858553;
        bh=rd57DXaZn/tD27RvgUT/8STAltzimjUbbZa5jPhiM6Q=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=w8HISBv5iWzaohfrEMfwhzxwXDo6ZTUhKJoX8YIufhjr7J8ox4vWmXcammOxPTQQy
         6Tilkddt8gtZRXpQnkt09K4WwCPgPOoQvGL8ViRWkmZUBAEcBr8IKDk7OXX4cduTfd
         bIU/Dm0Z0FLHJlTcmqWJtI+POiQ58TlteAsGCyUg=
Date:   Tue, 1 Dec 2020 16:35:53 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH 1/5] nfsd: only call inode_query_iversion in the
 I_VERSION case
Message-ID: <20201201213553.GF21355@fieldses.org>
References: <1606776378-22381-1-git-send-email-bfields@fieldses.org>
 <01bad6aa8aa05bb9bafd010575866125f89c5f08.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01bad6aa8aa05bb9bafd010575866125f89c5f08.camel@kernel.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 01, 2020 at 11:43:31AM -0500, Jeff Layton wrote:
> Are you planning to follow up with the series to add the fetch_iversion
> op, or have you decided not to do that for now?

I'm still interested.  I just figured it's not urgent, and it'll be
easier to ask for fs-devel review after this other stuff is in, so it
may as well wait till after the merge window.

--b.
