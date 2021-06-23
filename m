Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AA96C48BC2
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jun 2021 22:26:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 339A761185
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jun 2021 22:26:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229755AbhFWW2T (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Jun 2021 18:28:19 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54118 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229688AbhFWW2S (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2021 18:28:18 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9AE1FC061574
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jun 2021 15:26:00 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 7F6606208; Wed, 23 Jun 2021 18:25:59 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 7F6606208
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1624487159;
        bh=kMthWwssOekEzNY61b/ueZGP3SI0YUwBMrI3pSXrS7Q=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=HV/bvskSZG1aDpcHW0LPQZzdVETLdoZHbLpk5/BsNHTn7APtXJH405aD42B2uHlD0
         o269bVO2sE5y68JRcdvDhhGNAyFfQ/+O4IEivmgrxOF65KbssNQF9ha/DRDg2OhCpk
         2Wb1iN51XszxSkO1dW69VSm0d+YDZXHEMjWxeWZc=
Date:   Wed, 23 Jun 2021 18:25:59 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     NeilBrown <neilb@suse.de>
Cc:     Wang Yugui <wangyugui@e16-tech.com>, linux-nfs@vger.kernel.org
Subject: Re: any idea about auto export multiple btrfs snapshots?
Message-ID: <20210623222559.GI20232@fieldses.org>
References: <162432531379.17441.15110145423567943074@noble.neil.brown.name>
 <20210622112253.DAEE.409509F4@e16-tech.com>
 <20210622151407.C002.409509F4@e16-tech.com>
 <162440994038.28671.7338874000115610814@noble.neil.brown.name>
 <20210623153548.GF20232@fieldses.org>
 <162448589701.28671.8402117125966499268@noble.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <162448589701.28671.8402117125966499268@noble.neil.brown.name>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Jun 24, 2021 at 08:04:57AM +1000, NeilBrown wrote:
> On Thu, 24 Jun 2021, J. Bruce Fields wrote:
> > Is there any hope of solving this problem within btrfs?
> > 
> > It doesn't seem like it should have been that difficult for it to give
> > subvolumes separate superblocks and vfsmounts.
> > 
> > But this has come up before, and I think the answer may have been that
> > it's just too late to fix.
> 
> It is never too late to do the right thing!
> 
> Probably the best approach to fixing this completely on the btrfs side
> would be to copy the auto-mount approach used in NFS.  NFS sees multiple
> different volumes on the server and transparently creates new vfsmounts,
> using the automount infrastructure to mount and unmount them.  BTRFS
> effective sees multiple volumes on the block device and could do the
> same thing.

Yes, that makes sense to me.

> I can only think of one change to the user-space API (other than
> /proc/mounts contents) that this would cause and I suspect it could be
> resolved if needed.
> 
> Currently when you 'stat' the mountpoint of a btrfs subvol you see the
> root of that subvol.  However when you 'stat' the mountpoint of an NFS
> sub-filesystem (before any access below there) you see the mountpoint
> (s_dev matches the parent).  This is how automounts are expected to work
> and if btrfs were switched to use automounts for subvols, stating the
> mountpoint would initially show the mountpoint, not the subvol root.
> 
> If this were seen to be a problem I doubt it would be hard to add
> optional functionality to automount so that 'stat' triggers the mount.

One other thing I'm not sure about: how do cold cache lookups of
filehandles for (possibly not-yet-mounted) subvolumes work?

> All we really need is:
> 1/ someone to write the code
> 2/ someone to review the code
> 3/ someone to accept the code

Hah.  Still, the special exceptions for btrfs seem to be accumulating.
I wonder if that's happening outside nfs as well.

--b.
