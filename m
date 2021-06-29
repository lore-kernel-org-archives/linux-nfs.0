Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B816DC11F64
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jun 2021 01:12:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 81F2A6187E
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jun 2021 01:12:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230097AbhF2BO2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 28 Jun 2021 21:14:28 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:38108 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230032AbhF2BO2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jun 2021 21:14:28 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id D6D47C061574;
        Mon, 28 Jun 2021 18:12:01 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 801386482; Mon, 28 Jun 2021 21:12:00 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 801386482
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1624929120;
        bh=VsmVcKBBek3PAKIGFzpjojEP5KogsMJmDBW29zBCo68=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=dhKMzg+AybQoUviGUEhQ4YwQJOYcLvectjK49RqiAOFjfbAKzwOz6YFTUMnLi3n1Z
         n7RNjJevaeNQMEeVEEa8Wfs3omMK0ipH+BWuEc9XoEgz6y+bLnq/BW972j5Fchulk8
         JYZty4eKgPyt5q1XH8KrhGk8mr4MwZywPMeMJv/g=
Date:   Mon, 28 Jun 2021 21:12:00 -0400
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "dai.ngo@oracle.com" <dai.ngo@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: automatic freeing of space on ENOSPC
Message-ID: <20210629011200.GA14733@fieldses.org>
References: <20210628194908.GB6776@fieldses.org>
 <9f1263b46d5c38b9590db1e2a04133a83772bc50.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9f1263b46d5c38b9590db1e2a04133a83772bc50.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Jun 29, 2021 at 12:43:14AM +0000, Trond Myklebust wrote:
> How about just setting up a notification for unlink on those files, the
> same way we set up notifications for close with the NFSv3 filecache in
> nfsd?

Yes, that'd probably work.  It'd be better if we didn't have to throw
away unlinked files when the client expires, but it'd still be an
incremental improvement over what we do now.

--b.
