Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAE53C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 16:41:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B5D902186A
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 16:41:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726356AbfB0Qlt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Feb 2019 11:41:49 -0500
Received: from mx1.redhat.com ([209.132.183.28]:44102 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725854AbfB0Qls (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Feb 2019 11:41:48 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C3173C057F4D;
        Wed, 27 Feb 2019 16:41:48 +0000 (UTC)
Received: from madhat.home.dicksonnet.net (ovpn-118-12.phx2.redhat.com [10.3.118.12])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 114DC5D6A9;
        Wed, 27 Feb 2019 16:41:47 +0000 (UTC)
Subject: Re: [PATCH 1/3] configure.ac: more carefully detect availability of
 res_querydomain(3)
To:     Patrick Steinhardt <ps@pks.im>, linux-nfs@vger.kernel.org
References: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
 <20190222075202.GA13960@ncase>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <5d6ccf4a-2bee-f45b-5ef8-f8729185fd9f@RedHat.com>
Date:   Wed, 27 Feb 2019 11:41:47 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190222075202.GA13960@ncase>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 27 Feb 2019 16:41:48 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 2/22/19 2:52 AM, Patrick Steinhardt wrote:
> On Mon, Feb 04, 2019 at 03:31:18PM +0100, Patrick Steinhardt wrote:
>> Since glibc 2.2, the function res_querydomain(3) is implemented as a
>> define to `__res_querydomain`. Due to this implementation detail, using
>> `AC_CHECK_LIB` with a symbol name of "res_querydomain" will cause a
>> linking failure and thus fail to detect its availability. This is why
>> right now, we try to detect availability of `__res_querydomain` instead.
>>
>> Unfortunately, this may break on other platforms where there is no
>> `__res_querydomain` but only the function without leading underscores.
>> To fix this, we can perform another `AC_CHECK_LIB([resolv],
>> [res_querydomain], ...)` call in case where the other one was not found
>> and only raise an error if both symbols weren't found.
>>
>> Signed-off-by: Patrick Steinhardt <ps@pks.im>
> 
> Is there anything I can do to get this rolling and improve my
> patches? Or did I accidentally pick the wrong mailing list for
> the userspace part of nfs?
Sorry about this... I'm looking at them now... 

steved.

> 
> Patrick
> 
