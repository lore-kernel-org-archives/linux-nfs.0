Return-Path: <SRS0=QdOa=QZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 343DEC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 17:59:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 10A8221736
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 17:59:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388939AbfBRR76 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 12:59:58 -0500
Received: from mx1.redhat.com ([209.132.183.28]:37126 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388803AbfBRR76 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Feb 2019 12:59:58 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E14D31E339;
        Mon, 18 Feb 2019 17:59:57 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-107.phx2.redhat.com [10.3.116.107])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 6F1D5608C1;
        Mon, 18 Feb 2019 17:59:57 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: fix addrinfo usage with musl-1.1.21
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Peter Wagner <tripolar@gmx.at>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20190217173901.33296254@onion.lan>
 <1081BBCD-8CA0-49CC-A02C-16F46FF613BF@oracle.com>
 <20190218001153.3d21b28c@onion.lan>
 <34D9E70A-7F29-4C6B-8A10-18F7A7EFFE2E@oracle.com>
 <137b8db8-a6d6-33a6-408b-73f8915eee08@RedHat.com>
 <EE3790BC-A5B4-4C34-9F21-7009579B3A25@oracle.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <530ec927-e9c6-490c-1382-8e5be1aea203@RedHat.com>
Date:   Mon, 18 Feb 2019 12:59:56 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <EE3790BC-A5B4-4C34-9F21-7009579B3A25@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 18 Feb 2019 17:59:58 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


On 2/18/19 12:00 PM, Chuck Lever wrote:
>> I also took a look at how freeaddrinfo(3) in glibc works:
>>
>> void
>> freeaddrinfo (struct addrinfo *ai)
>> {
>>  struct addrinfo *p;
>>
>>  while (ai != NULL)
>>    {
>>      p = ai;
>>      ai = ai->ai_next;
>>      free (p->ai_canonname);
>>      free (p);
>>    }
>> }
>> It makes the assumption that ai_canonname is
>> free-able memory....
> Right, I seem to recall looking at this implementation when
> I wrote the IPv6 support for nfs-utils. That seems sensible
> to me.
> 
> However Peter's point is not all C libraries have to work
> that way, and I can see that argument too.
I agreed.... 
> 
> I have no objection to taking his fix as long as the hunk
> in host_numeric_addrinfo() is dropped while we figure out
> a more complete fix for that issue. 
Taking it out I can see us getting flagged for possible memory leaking....

Taking a look to why those frees were add... see commit 94ce1eb9
They should look very familiar to you ;-)  

> I would also like to
> see his fix use a helper like nfs_freeaddrinfo(), but that
> is only a suggestion.
That is a good suggestion... It definitely cleans up the code.

steved. 
> 
> 
