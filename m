Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_SBL,
	URIBL_SBL_A autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 759DDC67839
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 22:27:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 39DC52084C
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 22:27:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39DC52084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726183AbeLKW1X (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 17:27:23 -0500
Received: from mx1.redhat.com ([209.132.183.28]:33766 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726158AbeLKW1X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Dec 2018 17:27:23 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 08BA13082201;
        Tue, 11 Dec 2018 22:27:23 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-117-6.phx2.redhat.com [10.3.117.6])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B27145C225;
        Tue, 11 Dec 2018 22:27:22 +0000 (UTC)
Subject: Re: [PATCH] nfsref: switch the way libraries are linked.
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20181211190944.71940-1-steved@redhat.com>
 <0F088877-F56A-47FF-BBF3-95A8293BF912@oracle.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <40177ab7-bf23-7966-fbfa-9bac12d4655c@RedHat.com>
Date:   Tue, 11 Dec 2018 17:27:22 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <0F088877-F56A-47FF-BBF3-95A8293BF912@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 11 Dec 2018 22:27:23 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 12/11/18 2:12 PM, Chuck Lever wrote:
> 
>> On Dec 11, 2018, at 2:09 PM, Steve Dickson <steved@redhat.com> wrote:
>>
>> Link the static libs before the dynamic libs allowing
>> the routines in the static libs to be defined
>> by the dynamic libs
> 
> Hi Steve, Why is this change necessary? Is there a bug report?
No... when I enabled junctions in the Fedora rawhide (F30) I got
a bunch of xml undefined routines 
   https://koji.fedoraproject.org/koji/getfile?taskID=31408933&volume=DEFAULT&name=build.log&offset=-4000

It compiled fine on f29 but not on rawhide

After asking if the XML api changed, people suggested I simply
change the order of how the static and dynamic libs are linked,
which worked

https://lists.fedoraproject.org/archives/list/devel@lists.fedoraproject.org/message/6UIAF47S73QFLCJDWEWXKQHZTOMB5JXQ/

https://lists.fedoraproject.org/archives/list/devel@lists.fedoraproject.org/message/VK2XPHV2MELV6IRKBG2ITI6GKUBMMRQW/

steved.

> 
> 
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> utils/nfsref/Makefile.am | 6 +++---
>> 1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/utils/nfsref/Makefile.am b/utils/nfsref/Makefile.am
>> index 44edc83..2409dd0 100644
>> --- a/utils/nfsref/Makefile.am
>> +++ b/utils/nfsref/Makefile.am
>> @@ -27,9 +27,9 @@ noinst_HEADERS		= nfsref.h
>>
>> sbin_PROGRAMS		= nfsref
>> nfsref_SOURCES		= add.c lookup.c nfsref.c remove.c
>> -LDADD			= $(LIBXML2) $(LIBCAP) \
>> -			  ../../support/nfs/libnfs.la \
>> -			  ../../support/junction/libjunction.la
>> +LDADD			= ../../support/nfs/libnfs.la \
>> +			  ../../support/junction/libjunction.la \
>> +			  $(LIBXML2) $(LIBCAP)
>>
>> man8_MANS		= nfsref.man
>>
>> -- 
>> 2.19.2
>>
> 
> --
> Chuck Lever
> 
> 
> 
