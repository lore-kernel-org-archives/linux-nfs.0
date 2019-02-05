Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25C02C282D7
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 14:59:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F1757217F9
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 14:59:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728496AbfBEO7H (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 09:59:07 -0500
Received: from mx3.molgen.mpg.de ([141.14.17.11]:40391 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726098AbfBEO7G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Feb 2019 09:59:06 -0500
Received: from theinternet.molgen.mpg.de (theinternet.molgen.mpg.de [141.14.31.7])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        (Authenticated sender: buczek)
        by mx.molgen.mpg.de (Postfix) with ESMTPSA id 67AEF201353433;
        Tue,  5 Feb 2019 15:59:04 +0100 (CET)
Subject: Re: [PATCH 4.14 0/2] Two nfsd4 fixes for 4.14 longterm
To:     Salvatore Bonaccorso <carnil@debian.org>
Cc:     stable@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
References: <20190205100141.25304-1-buczek@molgen.mpg.de>
 <20190205115948.azdwswkyetbop56r@lorien.valinor.li>
From:   Donald Buczek <buczek@molgen.mpg.de>
Message-ID: <7a263d82-27e7-077f-3a51-78180785a41f@molgen.mpg.de>
Date:   Tue, 5 Feb 2019 15:59:04 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190205115948.azdwswkyetbop56r@lorien.valinor.li>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 02/05/19 12:59, Salvatore Bonaccorso wrote:

> Are you planning to submit the same as well for 4.9 LTS? The two
> commits apply on top of 4.9.154 with line number updated.

No, I'm not, because I didn't do any testing with 4.9.

Additionally, I'm unsure about the right procedure for trivial backports
to multiple trees: Individual patch sets, which apply perfectly, a single
patch sets and Greg resolves that for the other trees or maybe no patch
set at all and just a "please cherry-pick .... from upstream" mail.

Best
   Donald
