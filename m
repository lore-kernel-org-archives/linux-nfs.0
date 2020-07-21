Return-Path: <SRS0=ojZM=BA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88BFDC433E3
	for <linux-nfs@archiver.kernel.org>; Tue, 21 Jul 2020 15:20:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5B6AE20684
	for <linux-nfs@archiver.kernel.org>; Tue, 21 Jul 2020 15:20:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="hru92H9m"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728755AbgGUPUi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 21 Jul 2020 11:20:38 -0400
Received: from us-smtp-delivery-1.mimecast.com ([207.211.31.120]:42181 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726654AbgGUPUi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2020 11:20:38 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1595344837;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=iKuDsPoUOkgv4Eh9ysVNrnYJ3BM7sRpNuQi6UyjZAxs=;
        b=hru92H9m1s2blWbmMSVI25d9efw0jbet5LMTkCXb116nvgmaRJ6TLph+ngCOvdTO9t0tmh
        +66GsKTrfoxKIvPCZi8XRSgPnQgXkr/HsAfDfXdDvOE1xYKaFmcPgRwmt1W8kOL6IlbQbc
        kZYD8SunBc6ZjE69/C1QtoFwR+TPEDo=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-329-chozkSUaPD2E-ZLmiJp-pg-1; Tue, 21 Jul 2020 11:20:33 -0400
X-MC-Unique: chozkSUaPD2E-ZLmiJp-pg-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id A125A10059A2;
        Tue, 21 Jul 2020 15:20:32 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-113-147.phx2.redhat.com [10.3.113.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 3333810002B5;
        Tue, 21 Jul 2020 15:20:32 +0000 (UTC)
Subject: Re: [PATCH v2 4/4] nfs-utils: Update nfs4_unique_id module parameter
 from the nfs.conf value
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Alice Mitchell <ajmitchell@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <c6571aecaaeff95681421c1684814a823b8a087e.camel@redhat.com>
 <ff4f8d30e849190eeb2e0fee1ef501ee461a531f.camel@redhat.com>
 <F25A094C-CA96-45D3-8422-C2F77ECF9C78@oracle.com>
 <4dc8c372324d551456a47e60d73d926d96fc0d24.camel@redhat.com>
 <a6756b37-fe93-bf0c-715c-82a62407ead9@RedHat.com>
 <A1D15C75-D811-4214-8818-FBB99A7E48E6@oracle.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <8584c1f2-c771-8b07-7759-e597e3011544@RedHat.com>
Date:   Tue, 21 Jul 2020 11:20:31 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.5.0
MIME-Version: 1.0
In-Reply-To: <A1D15C75-D811-4214-8818-FBB99A7E48E6@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hey!

On 7/20/20 2:23 PM, Chuck Lever wrote:
> 
> 
>> On Jul 20, 2020, at 1:54 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>>
>> Hello,
>>
>> On 7/19/20 3:57 PM, Alice Mitchell wrote:
>>> Hi Chuck,
>>> I must have missed the discussion on Trond's work sorry, and I agree
>>> that having it fixed in a way that is both automatic and transparent to
>>> the user is far preferable to the solution I have posted. Do we have
>>> any timeline on this yet ?
>> I too did missed  the discussion... Chuck or Trond can you give us more 
>> context on how this is going to work automatically and transparent?
>> Is there a thread you can point us to?
> 
> https://lore.kernel.org/linux-nfs/20190611180832.119488-1-trond.myklebust@hammerspace.com/
Thanks! That is the kernel support but you mentioned something
about a udev-based mechanism for automation... What the story
on that? 

steved.

