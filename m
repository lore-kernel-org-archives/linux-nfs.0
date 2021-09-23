Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCF69C433FE
	for <linux-nfs@archiver.kernel.org>; Thu, 23 Sep 2021 01:47:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A3B3F60FC1
	for <linux-nfs@archiver.kernel.org>; Thu, 23 Sep 2021 01:47:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S238825AbhIWBtF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 Sep 2021 21:49:05 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43794 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S238177AbhIWBtF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Sep 2021 21:49:05 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6186EC061574;
        Wed, 22 Sep 2021 18:47:34 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 8627D6CCF; Wed, 22 Sep 2021 21:47:33 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 8627D6CCF
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1632361653;
        bh=KoRcspGU/sFE5nwHK/TAQOmXc1o3qWFUtiuoew3ScrY=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=nAmqYv9aV6lK1QO0o+Kg3sMbNI01MZdVdp/gk5f6zskNaegPLaVqL562c2Sim8LOV
         XCtteuRwm4/IxB78JRi/gr63Y6qaaYXPa73UEqpHrqqyB7khvsggfIVywJWTMfDCjd
         EqG4yKLo38P09quMRgMC2wqUHCaw1RRrO6HxuMs4=
Date:   Wed, 22 Sep 2021 21:47:33 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Dai Ngo <dai.ngo@oracle.com>
Cc:     chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH RFC v3 0/2] nfsd: Initial implementation of NFSv4
 Courteous Server
Message-ID: <20210923014733.GF22937@fieldses.org>
References: <20210916182212.81608-1-dai.ngo@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210916182212.81608-1-dai.ngo@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I haven't tried to figure out why, but I notice after these patches that
pynfs tests RENEW3, LKU10, CLOSE9, and CLOSE8 are failing with
unexpected share denied errors.

--b.
