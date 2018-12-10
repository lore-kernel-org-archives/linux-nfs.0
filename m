Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D1C8C5CFFE
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 21:26:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ED79E20821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 21:26:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED79E20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728058AbeLJV0z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 16:26:55 -0500
Received: from mx1.redhat.com ([209.132.183.28]:42564 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727304AbeLJV0y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Dec 2018 16:26:54 -0500
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DD35481DE9;
        Mon, 10 Dec 2018 21:26:54 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-117-64.phx2.redhat.com [10.3.117.64])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9160960C62;
        Mon, 10 Dec 2018 21:26:54 +0000 (UTC)
Subject: Re: [PATCH 0/3] Three little nfs-utils fixes.
To:     NeilBrown <neilb@suse.com>
Cc:     linux-nfs@vger.kernel.org
References: <154379862296.3215.11174339731963464375.stgit@noble>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <cc86d565-04b9-7778-4b5d-33ef00dd0528@RedHat.com>
Date:   Mon, 10 Dec 2018 16:26:54 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <154379862296.3215.11174339731963464375.stgit@noble>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Mon, 10 Dec 2018 21:26:54 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 12/2/18 7:58 PM, NeilBrown wrote:
> First fixes a regression I found when importing the latest upstream at
> SUSE.
> 
> Others are related to ensuring systemd starts thing properly in cases
> that hadn't been tested before.
> 
> Thanks,
> NeilBrown
Committed... 

steved.

> 
> 
> ---
> 
> NeilBrown (3):
>       nfs.conf: allow empty assignments.
>       Let systemd know when rpc.statd is needed.
>       systemd: run statd-notify even when nfs-client isn't enabled.
> 
> 
>  support/nfs/conffile.c      |    5 -----
>  systemd/rpc-statd.service   |    1 +
>  tests/nfsconf/01-errors.exp |    1 -
>  utils/statd/start-statd     |    7 ++++++-
>  4 files changed, 7 insertions(+), 7 deletions(-)
> 
> --
> Signature
> 
