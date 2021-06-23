Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98F6AC4743C
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jun 2021 15:35:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 76F1B611AC
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jun 2021 15:35:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231389AbhFWPiH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Jun 2021 11:38:07 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46608 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231409AbhFWPiH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2021 11:38:07 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9D3B0C061574
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jun 2021 08:35:49 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 20F216208; Wed, 23 Jun 2021 11:35:48 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 20F216208
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1624462548;
        bh=C0ldnnfItrksyzSWEdygG6r+faUPIuD0G9fbM4OzvnI=;
        h=Date:To:Cc:Subject:References:In-Reply-To:From:From;
        b=zS4oqVYhQWRd1DoVFEAW7/+2NIAUk1LUhIz768XezL0j6sWa5rZhevfpla7NhyW3X
         MjGWGYVX8xQOjl4ORp75EMCtIp5hfDpx7EBR1opzMFA6wiU3UL3Q5e9oiT/OOv0vtk
         AN5kUTMumz4Y7ydi1dhQpTZPtgtqk9AskcLuPQD0=
Date:   Wed, 23 Jun 2021 11:35:48 -0400
To:     NeilBrown <neilb@suse.de>
Cc:     Wang Yugui <wangyugui@e16-tech.com>, linux-nfs@vger.kernel.org
Subject: Re: any idea about auto export multiple btrfs snapshots?
Message-ID: <20210623153548.GF20232@fieldses.org>
References: <162432531379.17441.15110145423567943074@noble.neil.brown.name>
 <20210622112253.DAEE.409509F4@e16-tech.com>
 <20210622151407.C002.409509F4@e16-tech.com>
 <162440994038.28671.7338874000115610814@noble.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <162440994038.28671.7338874000115610814@noble.neil.brown.name>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Is there any hope of solving this problem within btrfs?

It doesn't seem like it should have been that difficult for it to give
subvolumes separate superblocks and vfsmounts.

But this has come up before, and I think the answer may have been that
it's just too late to fix.

--b.
