Return-Path: <SRS0=teKl=A2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,NICE_REPLY_A,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFB23C433E4
	for <linux-nfs@archiver.kernel.org>; Wed, 15 Jul 2020 18:03:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 81C4020656
	for <linux-nfs@archiver.kernel.org>; Wed, 15 Jul 2020 18:03:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ijUhXUDW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725909AbgGOSDD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 15 Jul 2020 14:03:03 -0400
Received: from us-smtp-1.mimecast.com ([207.211.31.81]:44328 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1725861AbgGOSDC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2020 14:03:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1594836182;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=1gyKWB9YkGnY4sma0y6OrQ5pZnmVS5lFm+oqYsv83U8=;
        b=ijUhXUDWF9IS2AcUb3HefN/GKeVXCV0AlvhmnXlOu4EiinmVQ5JBNg3KjOI7eekPxqPbON
        R6pfk+Mjnw8c53dhb5xhDESKc88+6IOV/MLfFl5+bxLRaqQsXLTlbg6/ck+hbjqk7UslZp
        4Sx3NZXSgmVtpsOvzCNr1tGfXmQHMtk=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-451-m0uFDa1sMpGK7bIP8XUQ0A-1; Wed, 15 Jul 2020 14:02:59 -0400
X-MC-Unique: m0uFDa1sMpGK7bIP8XUQ0A-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id EC6C9100CCC2
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jul 2020 18:02:58 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-113-147.phx2.redhat.com [10.3.113.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id A943E60BF1;
        Wed, 15 Jul 2020 18:02:58 +0000 (UTC)
Subject: Re: [PATCH 0/4] nfs-utils: nfs.conf features to enable use of
 machine-id as nfs4_unique_id
To:     Alice Mitchell <ajmitchell@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <5a84777afb9ed8c866841471a1a7e3c9b295604d.camel@redhat.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <855f399a-3426-a487-c180-0166a685818f@RedHat.com>
Date:   Wed, 15 Jul 2020 14:02:58 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.5.0
MIME-Version: 1.0
In-Reply-To: <5a84777afb9ed8c866841471a1a7e3c9b295604d.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,

On 7/10/20 12:37 PM, Alice Mitchell wrote:
> This patch set introduces some additional features to the nfs.conf tool
> chain that allows automatic use of /etc/machine-id or other unique
> values for setups that otherwise do not have a unique hostname or disk
> image and would thus otherwise generate non-unique EXCHANGE_ID and
> SETCLIENTID messages. 
> 
> Signed-off-by: Alice Mitchell <ajmitchell@redhat.com>
> 
In the future, could you please use the '-s' git commit flag
which would add the Signed-off-by to every patch. thanks!

steved.

