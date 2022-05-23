Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05845C433F5
	for <linux-nfs@archiver.kernel.org>; Mon, 23 May 2022 14:29:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237020AbiEWO3x (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 23 May 2022 10:29:53 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47356 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S237018AbiEWO3w (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2022 10:29:52 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1FCF32B242
        for <linux-nfs@vger.kernel.org>; Mon, 23 May 2022 07:29:52 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 2B09C64A6; Mon, 23 May 2022 10:29:51 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 2B09C64A6
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1653316191;
        bh=/d5lBOq9mhb/TxDx+BXFCbD9p9kz5z/zAJW+rzZovEM=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=TqnkjjDaVaWcA5GIIgwyqJbNsNrWjKoqAXIjbuTodAE1H0E4x6/6vpGzkOrOTbJaD
         TTzY2Hl3FxVjzn3/18Io4IepbpR9zTd0PXUduT0wDuHK48MPxArb3/NLbR/zkUwyWE
         LjbSZsvPiUXCfuYiIVQqtmYTVZLxIsEgbomkJUFk=
Date:   Mon, 23 May 2022 10:29:51 -0400
From:   bfields <bfields@fieldses.org>
To:     Richard Weinberger <richard@nod.at>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>, david <david@sigma-star.at>,
        luis turcitu <luis.turcitu@appsbroker.com>,
        david young <david.young@appsbroker.com>,
        david oberhollenzer <david.oberhollenzer@sigma-star.at>,
        trond myklebust <trond.myklebust@hammerspace.com>,
        anna schumaker <anna.schumaker@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        chris chilvers <chris.chilvers@appsbroker.com>
Subject: Re: [PATCH 0/5] nfs-utils: Improving NFS re-exports
Message-ID: <20220523142951.GB24163@fieldses.org>
References: <20220502085045.13038-1-richard@nod.at>
 <20220502161713.GI30550@fieldses.org>
 <1149772405.87856.1653292425664.JavaMail.zimbra@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1149772405.87856.1653292425664.JavaMail.zimbra@nod.at>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, May 23, 2022 at 09:53:45AM +0200, Richard Weinberger wrote:
> Please also don't forget the kernel side of this work. It is small but
> still needed.  See:
> https://lore.kernel.org/linux-nfs/20220110184419.27665-1-richard@nod.at/
> or
> https://git.kernel.org/pub/scm/linux/kernel/git/rw/misc.git/log/?h=nfs_reexport_clean

The follow_down() code, at least, needs vfs review, maybe resend with a
cc to Al Viro and linux-fsdevel.

I'm not really familiar with how the vfs automounting code works.

> Since the kernel changes don't change the ABI, it should not really
> matter which part is merged first. Kernel or userspace. The only
> important part is stating the right kernel version in the nfs-utils
> manpages.

OK, as long as we make sure nothing annoying happens in the
old-kernel/new-nfs-utils case.  (Looks to me like it should be OK.)

--b.
