Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 871CEC65BAF
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 22:11:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E8C742084E
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 22:11:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="ksV3m4p0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8C742084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=desy.de
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726437AbeLLWLW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 17:11:22 -0500
Received: from smtp-o-3.desy.de ([131.169.56.156]:37759 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726297AbeLLWLW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 17:11:22 -0500
Received: from smtp-buf-2.desy.de (smtp-buf-2.desy.de [IPv6:2001:638:700:1038::1:a5])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id DAA682804F6
        for <linux-nfs@vger.kernel.org>; Wed, 12 Dec 2018 23:11:19 +0100 (CET)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-3.desy.de DAA682804F6
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1544652679; bh=GXhgU3Ksozp0kEX+fTmvax64QqGfSqy4BLMEmiAI4G8=;
        h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
        b=ksV3m4p0TvnKvOmn4GOYAXjXV2Tv41wJ7ehg3/9YjgXMF9mm4wxV2VbTMRxuIqLqE
         nGCH1IdGgWMjdKgHGOV+cajdabdmEB0cGxiWVsLBqTcjElelpPtFhqz7YaY1xuGkp+
         Kd4xBjVnmFXNtS0T8TcVvOCEtoAmD1vKlCMFZsBI=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [IPv6:2001:638:700:1038::1:82])
        by smtp-buf-2.desy.de (Postfix) with ESMTP id D443E1A00CC;
        Wed, 12 Dec 2018 23:11:19 +0100 (CET)
X-Virus-Scanned: amavisd-new at desy.de
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id AE7021029;
        Wed, 12 Dec 2018 23:11:19 +0100 (MET)
Date:   Wed, 12 Dec 2018 23:11:19 +0100 (CET)
From:   "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To:     ffilz@redhat.com
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1207626803.5525544.1544652679619.JavaMail.zimbra@desy.de>
In-Reply-To: <378995dd-00b2-a2e8-fbee-025d4fc2eb24@redhat.com>
References: <043701d4925f$7b244530$716ccf90$@mindspring.com> <378995dd-00b2-a2e8-fbee-025d4fc2eb24@redhat.com>
Subject: Re: What is a reasonable minimum lease time?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Mailer: Zimbra 8.8.10_GA_3713 (ZimbraWebClient - FF63 (Linux)/8.8.10_GA_3041)
Thread-Topic: What is a reasonable minimum lease time?
Thread-Index: bI2UK45Yelj3Nc3Sl7s2XbotAQb0yw==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Frank,

IMHO, very short leases can trigger a massive state recovery on network hiccups.

Our server offers 90 seconds to the client. The client usually renew lease (sequence) once in a minute.
During high IO periods lease is not required and when idle, then once in a minute is sufficient to
keep the mount alive. In a worst case, when a client got a lock and dispersal, a competing lock/open
will block only for 90s. Whatever number you have, it should be 


BTW, IETF mailing list probably a better place for this question.

Regards,
   Tigran.


----- Original Message -----
> From: "Frank Filz" <ffilz@redhat.com>
> To: "linux-nfs" <linux-nfs@vger.kernel.org>
> Sent: Wednesday, December 12, 2018 10:14:59 PM
> Subject: What is a reasonable minimum lease time?

> We have an issue with the Ganesha server with very short (2 second)
> lease times. Ganesha uses a 1 second granularity for lease management,
> and considers a time since last renewed equal to the lease time as too
> long. The result is that the lease period may be short close to 2
> seconds depending on when within a given second things actually happened
> (so a last renew at 0.99 with a subsequent renew at 2.01 which is just
> over one second looks like 2 seconds to Ganesha and thus is >= the 2
> second lease time and not good enough. A simple change would be to
> change the >= to a >, which gives one more second, but it still could
> result in the lease time being almost 1 second too short which is
> significant with a 2 second lease time. But if the minimum reasonable
> lease time is more like 5 or 10 seconds, that 1 second becomes less
> significant.
> 
> The bigger fix would be to use a finer grained time, but that adds
> complexity, but if people really want to run with 2 second lease times
> and it makes any kind of sense, we would need to make that change.
> 
> Thanks
> 
> 
> Frank
