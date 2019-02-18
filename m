Return-Path: <SRS0=QdOa=QZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4E1CC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 21:14:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7532721773
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 21:14:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550524480;
	bh=IEEbYHWwY5KRIw2ddOy0FzcymGnsiwkBM34ZTCYunRg=;
	h=Date:From:To:To:To:Cc:Cc:Subject:In-Reply-To:References:List-ID:
	 From;
	b=MQkjk2da0qgW+w2p0hhSZCOrzVKfnQ0ymCJ8PxwsL1g16g+KbdJgucG/vgTti3Nqv
	 ciO32a797QXksNZAPr40W9v8/sp6/fAQ7+p8YubLgiGQvdnqGVrsnoGP3MtahopMKW
	 WGzmo/xIXsxmeAD3nW/Vk1KqygWj03i2RZWOkR3o=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730459AbfBRVOj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 16:14:39 -0500
Received: from mail.kernel.org ([198.145.29.99]:54544 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730456AbfBRVOj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Feb 2019 16:14:39 -0500
Received: from localhost (unknown [23.100.24.84])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id AE7A8218FC;
        Mon, 18 Feb 2019 21:14:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1550524478;
        bh=IEEbYHWwY5KRIw2ddOy0FzcymGnsiwkBM34ZTCYunRg=;
        h=Date:From:To:To:To:Cc:Cc:Subject:In-Reply-To:References:From;
        b=ofmK0bCbfGV34VEQpbuICOSLKHR6DgFaJQ/EcF5tzWfOcxi8vC91dOsX1Nl44P1HL
         hxjBJP/T1FGQoI4BI+5SfhndZzeUhV3OY02bsnsJ2OVkhAym9y36+aUCnjXgkz2PAS
         xDAumtZW2BEIg7D584iI5gi4cA7z67nPKWCTtwPY=
Date:   Mon, 18 Feb 2019 21:14:37 +0000
From:   Sasha Levin <sashal@kernel.org>
To:     Sasha Levin <sashal@kernel.org>
To:     Trond Myklebust <trondmy@gmail.com>
To:     Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Cc:     stable@vger.kernel.org
Subject: Re: [PATCH 1/2] NFS: Fix I/O request leakages
In-Reply-To: <20190213215357.19696-1-trond.myklebust@hammerspace.com>
References: <20190213215357.19696-1-trond.myklebust@hammerspace.com>
Message-Id: <20190218211438.AE7A8218FC@mail.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: a7d42ddb3099 nfs: add mirroring support to pgio layer.

The bot has tested the following trees: v4.20.10, v4.19.23, v4.14.101, v4.9.158, v4.4.174.

v4.20.10: Build OK!
v4.19.23: Build OK!
v4.14.101: Build OK!
v4.9.158: Build OK!
v4.4.174: Failed to apply! Possible dependencies:
    c18b96a1b862 ("nfs: clean up rest of reqs when failing to add one")
    d600ad1f2bdb ("NFS41: pop some layoutget errors to application")


How should we proceed with this patch?

--
Thanks,
Sasha
