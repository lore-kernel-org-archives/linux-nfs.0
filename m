Return-Path: <SRS0=oVQw=PJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5DFCC43387
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Jan 2019 17:49:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8272F2171F
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Jan 2019 17:49:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726094AbfAARtG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 1 Jan 2019 12:49:06 -0500
Received: from mx1.redhat.com ([209.132.183.28]:46176 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725912AbfAARtG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Jan 2019 12:49:06 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id F2A9E85546;
        Tue,  1 Jan 2019 17:49:05 +0000 (UTC)
Received: from localhost (ovpn-112-13.rdu2.redhat.com [10.10.112.13])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 236695D756;
        Tue,  1 Jan 2019 17:49:02 +0000 (UTC)
Date:   Tue, 01 Jan 2019 09:49:01 -0800 (PST)
Message-Id: <20190101.094901.728478837131793069.davem@redhat.com>
To:     deepa.kernel@gmail.com
Cc:     netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk, arnd@arndb.de,
        eric.dumazet@gmail.com, y2038@lists.linaro.org
Subject: Re: [PATCH v3] sock: Make sock->sk_stamp thread-safe
From:   David Miller <davem@redhat.com>
In-Reply-To: <20181228025509.14194-1-deepa.kernel@gmail.com>
References: <20181228025509.14194-1-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 01 Jan 2019 17:49:06 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Thu, 27 Dec 2018 18:55:09 -0800

> Al Viro mentioned (Message-ID
> <20170626041334.GZ10672@ZenIV.linux.org.uk>)
> that there is probably a race condition
> lurking in accesses of sk_stamp on 32-bit machines.
> 
> sock->sk_stamp is of type ktime_t which is always an s64.
> On a 32 bit architecture, we might run into situations of
> unsafe access as the access to the field becomes non atomic.
> 
> Use seqlocks for synchronization.
> This allows us to avoid using spinlocks for readers as
> readers do not need mutual exclusion.
> 
> Another approach to solve this is to require sk_lock for all
> modifications of the timestamps. The current approach allows
> for timestamps to have their own lock: sk_stamp_lock.
> This allows for the patch to not compete with already
> existing critical sections, and side effects are limited
> to the paths in the patch.
> 
> The addition of the new field maintains the data locality
> optimizations from
> commit 9115e8cd2a0c ("net: reorganize struct sock for better data
> locality")
> 
> Note that all the instances of the sk_stamp accesses
> are either through the ioctl or the syscall recvmsg.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>

Ok, I'm fine with this, so applied and queued up for -stable.

I will note in passing that there are several 32-bit architectures
that have 64-bit loads.  Sparc is one such case.  And they would not
need these changes.

But I don't think it's practical or worthwhile to add that level of
consideration into your changes.  I'd rather the commit stay as simple
as possible.

Thanks!
