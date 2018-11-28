Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1C7FC43610
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 08:46:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8AA5420832
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 08:46:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AA5420832
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727726AbeK1Tq5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 14:46:57 -0500
Received: from relay.sw.ru ([185.231.240.75]:57688 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727716AbeK1Tq5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Nov 2018 14:46:57 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gRvTk-0003rC-Qi; Wed, 28 Nov 2018 11:45:52 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 0/1] cache_head leak in sunrpc_cache_lookup()
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Cc:     "David S. Miller" <davem@davemloft.net>,
        NeilBrown <neilb@suse.com>,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Message-ID: <d6bac5b8-9ee9-289c-7e85-0d4b6f55c931@virtuozzo.com>
Date:   Wed, 28 Nov 2018 11:45:46 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Dear all,
we have found memory leak on OpenVz7 node and believe it affects mainline too.

sunrpc_cache_lookup() removes exprired cache_head from hash,
however if it waits for reply on submitted cache_request 
both of them can leak forever, nobody cleans unhashed cache_heads.

Originally we had claim on busy loop device of stopped container,
that had executed nfs server inside.  
Device was kept by mount that was detached from already destroyed mount namespace.
By using crash search we have found some structure with path struct related to our mount.
Finally we have found that it was alive svc_export struct used by to alive cache_request,
however both of them pointed to already freed cache_detail.

We decided that cache_detail was correctly freed during destroy of net namespace,
however svc_export with taken path struct, cache_request and some other structures 
seems was leaked forever.

This could  happen only if cache_head of svc_export was removed from hash on cache_detail
before its destroy. Finally we have found that it could happen when sunrpc_cache_lookup()
removes expired cache_head from hash.

Usually it works correctly and cache_put(freeme) frees expired cache_head.
However in our case cache_head have an extra reference counter from stalled cache_request.
Becasue of cache_head was removed from hash of cache_detail it cannot be found in cache_clean()
and its cache_request cannot be freed in cache_dequeue(). Memory leaks forever, 
exactly like we observed.

After may attempts we have reproduced this situation on OpenVz7 kernel, 
however our reproducer is quite long and complex. Unfortunately we still
did not reproduced this problem on mainline kernel and did not validated the patch yet.

It would be great if someone advised us some simple way to trigger described scenario.
We are not sure that our patch is correct, please let us know if our analyze missed something.

Vasily Averin (1):
  sunrpc: cache_head leak due queued requests

 net/sunrpc/cache.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

-- 
2.17.1
