Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7831CC2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 14:03:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4ACEF20823
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 14:03:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ACEF20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728148AbeJ3W5F (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 30 Oct 2018 18:57:05 -0400
Received: from mx1.redhat.com ([209.132.183.28]:35084 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728092AbeJ3W5F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Oct 2018 18:57:05 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 76FCE30023A2;
        Tue, 30 Oct 2018 14:03:29 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-121-196.rdu2.redhat.com [10.10.121.196])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 774445ED29;
        Tue, 30 Oct 2018 14:03:28 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "zhong jiang" <zhongjiang@huawei.com>
Cc:     herbert@gondor.apana.org.au, trond.myklebust@hammerspace.com,
        bfields@redhat.com, linux-crypto@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [Qestion] Lots of memory leaks when mounting and unmounting nfs
 client to server continuously.
Date:   Tue, 30 Oct 2018 10:03:29 -0400
Message-ID: <8975EA60-7C42-426A-ADA3-DEE0E2CEE964@redhat.com>
In-Reply-To: <5BD86392.7070200@huawei.com>
References: <5BD85266.6000301@huawei.com>
 <1DEE371C-69EB-4D92-8F78-535AA5203007@redhat.com>
 <5BD86392.7070200@huawei.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 30 Oct 2018 14:03:29 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 30 Oct 2018, at 9:58, zhong jiang wrote:

> On 2018/10/30 21:06, Benjamin Coddington wrote:
>> Hi zhong jiang,
>>
>> Try asking in linux-nfs.. but I'll also note that 3.10-stable may be
>> missing a number of fixes to leaks in the NFS GSS code.
>>
>> I can see a more than a few fixes to memory leaks with: git log
>> --grep=leak --oneline net/sunrpc/auth_gss/
>>
> Thanks for your reply.  I has tested some of them in the upsteam as you
> have said.  but It fails to solve the issue completely.

What have you tested?  It is hard to help without specifics.
