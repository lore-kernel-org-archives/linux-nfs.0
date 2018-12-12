Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2C4FC67839
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 21:15:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5BAE020851
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 21:15:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BAE020851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728295AbeLLVPB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 16:15:01 -0500
Received: from mx1.redhat.com ([209.132.183.28]:34032 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728012AbeLLVPB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 16:15:01 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 304B0307886D
        for <linux-nfs@vger.kernel.org>; Wed, 12 Dec 2018 21:15:01 +0000 (UTC)
Received: from localhost.localdomain (ovpn-124-181.rdu2.redhat.com [10.10.124.181])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C8C9F6012B
        for <linux-nfs@vger.kernel.org>; Wed, 12 Dec 2018 21:15:00 +0000 (UTC)
Subject: What is a reasonable minimum lease time?
Reply-To: ffilz@redhat.com
References: <043701d4925f$7b244530$716ccf90$@mindspring.com>
To:     linux-nfs@vger.kernel.org
From:   Frank Filz <ffilz@redhat.com>
Organization: Red Hat
X-Forwarded-Message-Id: <043701d4925f$7b244530$716ccf90$@mindspring.com>
Message-ID: <378995dd-00b2-a2e8-fbee-025d4fc2eb24@redhat.com>
Date:   Wed, 12 Dec 2018 13:14:59 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <043701d4925f$7b244530$716ccf90$@mindspring.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 12 Dec 2018 21:15:01 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We have an issue with the Ganesha server with very short (2 second) 
lease times. Ganesha uses a 1 second granularity for lease management, 
and considers a time since last renewed equal to the lease time as too 
long. The result is that the lease period may be short close to 2 
seconds depending on when within a given second things actually happened 
(so a last renew at 0.99 with a subsequent renew at 2.01 which is just 
over one second looks like 2 seconds to Ganesha and thus is >= the 2 
second lease time and not good enough. A simple change would be to 
change the >= to a >, which gives one more second, but it still could 
result in the lease time being almost 1 second too short which is 
significant with a 2 second lease time. But if the minimum reasonable 
lease time is more like 5 or 10 seconds, that 1 second becomes less 
significant.

The bigger fix would be to use a finer grained time, but that adds 
complexity, but if people really want to run with 2 second lease times 
and it makes any kind of sense, we would need to make that change.

Thanks


Frank

