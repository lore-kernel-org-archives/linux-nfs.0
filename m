Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74D01C43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 18:37:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4E9FE21019
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 18:37:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E9FE21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726891AbeK3Fn1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 00:43:27 -0500
Received: from mx1.redhat.com ([209.132.183.28]:54632 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727272AbeK3FnZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 00:43:25 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6F4B431256D9;
        Thu, 29 Nov 2018 18:37:06 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 222F21C951;
        Thu, 29 Nov 2018 18:37:06 +0000 (UTC)
Subject: Re: [PATCH v1 3/3] Finish port of junction support to nfs-utils
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20181031200218.7507.15214.stgit@klimt.1015granger.net>
 <20181031200229.7507.26189.stgit@klimt.1015granger.net>
 <EA0135DC-ADCF-49C1-A5C3-03499F62C37E@oracle.com>
 <6443fe07-373c-2ef2-c491-20bdd083e620@RedHat.com>
 <D30C0131-84B2-4A95-ADEC-E688FFF2FE64@oracle.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <882ab389-6d85-2457-2ecb-f0f2ca6e0dc4@RedHat.com>
Date:   Thu, 29 Nov 2018 13:37:05 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <D30C0131-84B2-4A95-ADEC-E688FFF2FE64@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 29 Nov 2018 18:37:06 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 11/28/18 4:05 PM, Chuck Lever wrote:
> 
> 
>> On Nov 28, 2018, at 4:00 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>>
>>
>>
>> On 11/27/18 11:45 AM, Chuck Lever wrote:
>>> Ping!
>> My apologies for taking so long to get to this... 
>> I took an extended Thanksgiving then completely 
>> for got about it... Thanks for the ping... but :-) 
>>
>> When I enable junctions via  --enable-junction I get the
>> following compile error with or w/out these patches
>>
>> gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I. -I../../support/include -D_GNU_SOURCE -pipe  -Wall  -Wextra  -Werror=strict-prototypes  -Werror=missing-prototypes  -Werror=missing-declarations  -Werror=format=2  -Werror=undef  -Werror=missing-include-dirs  -Werror=strict-aliasing=2  -Werror=init-self  -Werror=implicit-function-declaration  -Werror=return-type  -Werror=switch  -Werror=overflow  -Werror=parentheses  -Werror=aggregate-return  -Werror=unused-result  -fno-strict-aliasing  -Werror=format-overflow=2 -Werror=int-conversion -Werror=incompatible-pointer-types -Werror=misleading-indentation -g -O2 -MT remove.o -MD -MP -MF .deps/remove.Tpo -c -o remove.o remove.c
>> In file included from lookup.c:31:
>> ../../support/include/rpcsvc/nfs_prot.h:9:10: fatal error: rpc/rpc.h: No such file or directory
>> #include <rpc/rpc.h>
>>          ^~~~~~~~~~~
>> I know how to fix it... Add the following to CFLAGS and LDFLAGS
>> `pkg-config --cflags libtirpc`
>> `pkg-config --libs libtirpc`
>>
>> First I'm wonder how you got things to compile w/out making these changes
> 
> Well I built and tested this on RHEL 7. If you're testing on
> late-model Fedora, you're probably getting a slightly different
> build configuration. Just a guess.
Fair enough.... 

> 
> 
>> and secondly I'm wondering where we should make these changes... 
>>
>> Maybe we should hardcode the -I/usr/include/tirpc and -ltirpc
>> flags in aclocal/libtirpc.m4?
> 
> libtirpc.m4 seems like the right place, but hard-coding seems
> like a sledgehammer. Maybe have a look at the changes I made
> to libxml2.m4 and do something similar?
It turns out that the AM_CPPFLAGS were being overwritten by
the nfsref/Makefile.am file... Removing that definition 
allowed the proper flags and libs to be set...

steved.
