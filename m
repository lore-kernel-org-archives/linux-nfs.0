Return-Path: <SRS0=+BBy=TN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FC63C04AA7
	for <linux-nfs@archiver.kernel.org>; Mon, 13 May 2019 13:36:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D6E1E214C6
	for <linux-nfs@archiver.kernel.org>; Mon, 13 May 2019 13:36:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557754585;
	bh=KvQDNwu3bULD+Ywks8ZVEWJR/s9gauUg+Iqux0u6+Nc=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=XmfTkSBNy+LGDz68U+2QdLatmU1xy0bLcAKUb6vVCsyVvCacJief065ThxOI8JQ6i
	 VsAQUXK1IrhPFRy11YMIvLTHOHcCExr9mWdW7rz4ItD87gSE4/e2WILEliy9+Sw3Nf
	 wpW+1BFR1Sq7pLeWF/Hhl3ow7GhK7wEFmq97HtbY=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729516AbfEMNgY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 13 May 2019 09:36:24 -0400
Received: from mail.kernel.org ([198.145.29.99]:59384 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727202AbfEMNgY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 13 May 2019 09:36:24 -0400
Received: from vulcan.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 0F183208C2;
        Mon, 13 May 2019 13:36:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1557754583;
        bh=KvQDNwu3bULD+Ywks8ZVEWJR/s9gauUg+Iqux0u6+Nc=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=r8AIQNmm1hKdp3IMk/Do7SlsNWzd6EdiSIZWPezRYQZNGDoOOy/kkOcxwzHFR6jj2
         p8aTRCxU/xLif/TvDG/P9up5MRy3u1ytXpTeloaPNU6gO47vu97WEyvoi2orLwtrrb
         pj7znLXDqTcmRKPmkEHeUcUWq3CuaB2uxirDZdhY=
Message-ID: <0d422bbcce15e44a4608cced0a569585c75ccd9a.camel@kernel.org>
Subject: Re: [PATCH v2 0/2] Fix two bugs CB_NOTIFY_LOCK failing to wake a
 water
From:   Jeff Layton <jlayton@kernel.org>
To:     Yihao Wu <wuyihao@linux.alibaba.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Joseph Qi <joseph.qi@linux.alibaba.com>, caspar@linux.alibaba.com
Date:   Mon, 13 May 2019 09:36:21 -0400
In-Reply-To: <346806ac-2018-b780-4939-87f29648017c@linux.alibaba.com>
References: <346806ac-2018-b780-4939-87f29648017c@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.1 (3.32.1-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2019-05-13 at 14:49 +0800, Yihao Wu wrote:
> This patch set fix bugs related to CB_NOTIFY_LOCK. These bugs cause
> poor performance in locking operation. And this patchset should also fix
> the failure when running xfstests generic/089 on a NFSv4.1 filesystem.
> 
> Yihao Wu (2):
>   NFSv4.1: Again fix a race where CB_NOTIFY_LOCK fails to wake a waiter
>   NFSv4.1: Fix bug only first CB_NOTIFY_LOCK is handled
> 
>  fs/nfs/nfs4proc.c | 31 ++++++++++++-------------------
>  1 file changed, 12 insertions(+), 19 deletions(-)
> 

Looks good to me. Nice catch, btw!

Reviewed-by: Jeff Layton <jlayton@kernel.org>

