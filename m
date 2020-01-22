Return-Path: <SRS0=bKkf=3L=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7E7EC2D0DB
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jan 2020 16:44:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A974621835
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jan 2020 16:44:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="CCJLR3Pd"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725883AbgAVQoX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 Jan 2020 11:44:23 -0500
Received: from us-smtp-2.mimecast.com ([207.211.31.81]:39816 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1725836AbgAVQoX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jan 2020 11:44:23 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1579711461;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=agcGWJuTCQ6fM1/SjZ+Ukz/kQBPrQ8tjNkwWfoXWULo=;
        b=CCJLR3PdW75DD+oGjTJij01gdHKUaO1Yjjelgat1lNDX/damiYHzUChIxTO3DU1jLCv5IK
        j8JKiqUKOSNxoTNbEfJd/eMscU5uOvP1r7HMnlXFQxfCfgwwow66JqeXwnfkmVCLPpyhAa
        byKBSQB1+fxdJ0nKUEVpqQpbhO1/xdY=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-295-gfLDAhTuMQWiSM6iY_omzw-1; Wed, 22 Jan 2020 11:44:19 -0500
X-MC-Unique: gfLDAhTuMQWiSM6iY_omzw-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 6EDC1800D5B;
        Wed, 22 Jan 2020 16:44:18 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (madhat.boston.devel.redhat.com [10.19.60.33])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 00DF5845A5;
        Wed, 22 Jan 2020 16:44:17 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] locktest: Makefile.am: remove host compiler
 costraint
To:     Petr Vorel <petr.vorel@gmail.com>
Cc:     Giulio Benetti <giulio.benetti@benettiengineering.com>,
        linux-nfs@vger.kernel.org, Mike Frysinger <vapier@gentoo.org>
References: <20200115160806.99991-1-giulio.benetti@benettiengineering.com>
 <20200119191047.GB11432@dell5510>
 <6606c604-61ef-a3fa-8ced-1d9dfb822f64@RedHat.com>
 <20200122161353.GA21075@dell5510>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <3cf84430-9384-3a91-0e0e-21ff2d47d68d@RedHat.com>
Date:   Wed, 22 Jan 2020 11:44:17 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.2.2
MIME-Version: 1.0
In-Reply-To: <20200122161353.GA21075@dell5510>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 1/22/20 11:13 AM, Petr Vorel wrote:
> Hi Steve,
> 
>>>> Currently locktest can be built only for host because CC_FOR_BUILD is
>>>> specified as CC, but this leads to build failure when passing CFLAGS not
>>>> available on host gcc(i.e. -mlongcalls) and most of all locktest would
>>>> be available on target systems the same way as rpcgen etc. So remove CC
>>>> and LIBTOOL assignments.
> 
>>>> Signed-off-by: Giulio Benetti <giulio.benetti@benettiengineering.com>
>>> Reviewed-by: Petr Vorel <petr.vorel@gmail.com>
>>> Tested-by: Petr Vorel <petr.vorel@gmail.com>
>>> NOTE: as I understand it's a compilation issue of a tool, so I didn't run
>>> rpcgen, I just test various compilation variants for buildroot.
>> Just to be clear... Giulio's patch, removing CC and LIBTOOL from the
>> locktest/Makefile.am does allows your cross build to succeed, correct?
> Yes, for buildroot it's ok. I'm just not able to verify Gentoo.
Thanks... Lets cross that path when get there... 

steved.

> 
>> steved.
> 
> Kind regards,
> Petr
> 

