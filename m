Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFCACC433EF
	for <linux-nfs@archiver.kernel.org>; Tue, 22 Feb 2022 21:12:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235244AbiBVVMN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 22 Feb 2022 16:12:13 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58218 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231310AbiBVVMM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2022 16:12:12 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BD796E3899;
        Tue, 22 Feb 2022 13:11:45 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id C8850367; Tue, 22 Feb 2022 16:11:44 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org C8850367
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1645564304;
        bh=24F60Mxq8bXyajAUTkbo/8nEXGynyHkKsBt7JoeyAw0=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=gxBaRuo2oaZcl2t8Xiwot3W3tBTJDE4smNfbE/5LOOPl9d7iA7x5gk4nKWjwqKVpH
         Xp+VFbDYLJyWXLNNtAmM7LKGYlsBc5hMhla+i5LAhXUtfwFRjXiivDkg3bGbBA31W/
         lTEzV4YIn6bJVEZDvpDNDG5Q8WHFhGdxPkkULW7g=
Date:   Tue, 22 Feb 2022 16:11:44 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     NeilBrown <neilb@suse.de>
Cc:     Al Viro <viro@zeniv.linux.org.uk>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        Daire Byrne <daire@dneg.com>,
        Andreas Dilger <adilger.kernel@dilger.ca>
Subject: Re: [PATCH/RFC] VFS: support parallel updates in the one directory.
Message-ID: <20220222211144.GA9541@fieldses.org>
References: <164549669043.5153.2021348013072574365@noble.neil.brown.name>
 <20220222190751.GA7766@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220222190751.GA7766@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 22, 2022 at 02:07:51PM -0500, bfields wrote:
> For what it's worth, I applied this to recent upstream (038101e6b2cd)
> and fed it through my usual scripts--tests all passed, but I did see
> this lockdep warning.
> 
> I'm not actually sure what was running at the time--probably just cthon.

Yeah, reproduceable just by running "cthon -b -f" over an NFS mount.

--b.
