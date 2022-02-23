Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D996C433F5
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Feb 2022 08:06:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233329AbiBWIGB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Feb 2022 03:06:01 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:44896 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233116AbiBWIGA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2022 03:06:00 -0500
Received: from cc-smtpout3.netcologne.de (cc-smtpout3.netcologne.de [89.1.8.213])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id CCAEE7A98F
        for <linux-nfs@vger.kernel.org>; Wed, 23 Feb 2022 00:05:33 -0800 (PST)
Received: from cc-smtpin1.netcologne.de (cc-smtpin1.netcologne.de [89.1.8.201])
        by cc-smtpout3.netcologne.de (Postfix) with ESMTP id C7D311249F;
        Wed, 23 Feb 2022 09:05:31 +0100 (CET)
Received: from nas2.garloff.de (xdsl-89-1-135-140.nc.de [89.1.135.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by cc-smtpin1.netcologne.de (Postfix) with ESMTPSA id 5D04C11D8C;
        Wed, 23 Feb 2022 09:05:28 +0100 (CET)
Received: from [192.168.155.16] (unknown [192.168.155.10])
        by nas2.garloff.de (Postfix) with ESMTPSA id 13622B3B0027;
        Wed, 23 Feb 2022 09:05:18 +0100 (CET)
Message-ID: <6401c5e1-8f05-5644-9bea-207640a21b77@garloff.de>
Date:   Wed, 23 Feb 2022 09:05:26 +0100
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.5.0
Subject: Re: 6f283634 / 1976b2b3 breaks NFS (QNAP/Linux kNFSD)
Content-Language: en-US
From:   Kurt Garloff <kurt@garloff.de>
To:     "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Anna" <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
References: <50bd4b4d-3730-4048-fcce-6c79dfe70acf@garloff.de>
 <8957291b-ecd1-931e-5d0c-7ef20c401e5d@garloff.de>
 <F693AC98-DCB4-4086-AC19-EE1B71DB2551@netapp.com>
 <be851303-b1bb-7d8d-832e-a1a3db529662@garloff.de>
 <10d55787-7b97-8636-9426-73fdeda0a122@garloff.de>
In-Reply-To: <10d55787-7b97-8636-9426-73fdeda0a122@garloff.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-NetCologne-Spam: L
X-Rspamd-Queue-Id: 5D04C11D8C
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Olga,

any updates? Were you able to investigate the traces?

Breaking NFS mounts from Qnap (knfsd with 3.4.6 kernel here,
though Qnap might have patched it),is not something that
should happen with a -stable kernel update, even if the problem
would be on the Qnap side, which would not be completely
surprising.

So I think we should revert this patch at least for -stable,
unless we understand what's going on and have a better fix
than a plain revert.

Best,
-- 

Kurt Garloff <kurt@garloff.de>

