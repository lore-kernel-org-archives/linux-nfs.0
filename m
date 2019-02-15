Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 602BAC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 05:14:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 38081206DD
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 05:14:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726667AbfBOFOE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 00:14:04 -0500
Received: from out30-57.freemail.mail.aliyun.com ([115.124.30.57]:46322 "EHLO
        out30-57.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726336AbfBOFOE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2019 00:14:04 -0500
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R611e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=wuyihao@linux.alibaba.com;NM=1;PH=DS;RN=3;SR=0;TI=SMTPD_---0TK6rqk-_1550207639;
Received: from ali-186590dcce93-2.local(mailfrom:wuyihao@linux.alibaba.com fp:SMTPD_---0TK6rqk-_1550207639)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 15 Feb 2019 13:13:59 +0800
Subject: Re: Why doesn't NFSv3 implement LOOKUPP?
To:     Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
References: <3dc67361-9c2f-d183-09e5-0a4d5c48d0f7@linux.alibaba.com>
 <0bd905c30a652d19404eef82b40f6b92987ca814.camel@redhat.com>
From:   Yihao Wu <wuyihao@linux.alibaba.com>
Message-ID: <2a2b8156-69c1-ad7f-6000-716f28690fb7@linux.alibaba.com>
Date:   Fri, 15 Feb 2019 13:14:00 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <0bd905c30a652d19404eef82b40f6b92987ca814.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2019/2/13 7:50 PM, Jeff Layton wrote:
> On Wed, 2019-02-13 at 16:41 +0800, Yihao Wu wrote:
>> Hi all,
>>
>> When looking into "Failures: generic/467" given by xfstests, I found that NFSv3
>> didn't implement LOOKUPP. I know that this might be by design. But LOOKUPP was
>> meant to replace ".." in NFSv3, right?
>>
>> xfstests's generic/467 test case performs the following sequence of operations.
>>
>> name_to_handle -> drop_caches -> open_by_handle
>>
>> Dentry becomes disconnected due to drop_caches. NFSv3 doesn't support LOOKUPP.
>> So when it performs open_by_handle to an directory, this test case fails.
>>
>> I did some small experiment by implementing LOOKUPP for NFSv3. The way I tried
>> is to merely pass ".." to nfs3_proc_lookup. And it seems to work. At least it's
>> a workaround for xfstests.
>>
>> I'm curious whether this sort of simulation of LOOKUPP will work or make sense.
>>
>> Thanks,
>> Yihao Wu
> 
> v3 was mostly designed with unix-like clients in mind. For v4, the spec
> writers cast a wider net and decided not to put special meaning on
> lookups of "." and "..", but they still needed a way to do a lookup of
> "..".
> 
> The question is why you want to implement LOOKUPP in v3. Mostly we added
> it to the client to support reexporting NFSv4 filesystems via NFSv3. Are
> you looking to reexport v3 filesystems for some reason?
> 

Thanks a lot for your reply, Jeff!

I'm just managing to figure out the source of this xfstests failure, that
open_by_handle is simply not working for NFSv3 after drop_caches. I think NFSv3
might become able to reconnect_path too, with LOOKUP "..". However it's not,
because nfs_get_parent fails as long as LOOKUPP is not supported.

My server & client both support NFSv3. Can I take it that re-exporting is not a
required option in this case?

Thanks,
Yihao Wu
