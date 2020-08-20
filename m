Return-Path: <SRS0=3r48=B6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7892EC433E1
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Aug 2020 02:21:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 47A2C207DA
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Aug 2020 02:21:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726646AbgHTCVO convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Aug 2020 22:21:14 -0400
Received: from szxga03-in.huawei.com ([45.249.212.189]:3488 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726578AbgHTCVO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Aug 2020 22:21:14 -0400
Received: from dggeme701-chm.china.huawei.com (unknown [172.30.72.56])
        by Forcepoint Email with ESMTP id 1B3B915757EFECA11230;
        Thu, 20 Aug 2020 10:21:12 +0800 (CST)
Received: from dggeme753-chm.china.huawei.com (10.3.19.99) by
 dggeme701-chm.china.huawei.com (10.1.199.97) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id
 15.1.1913.5; Thu, 20 Aug 2020 10:21:11 +0800
Received: from dggeme753-chm.china.huawei.com ([10.7.64.70]) by
 dggeme753-chm.china.huawei.com ([10.7.64.70]) with mapi id 15.01.1913.007;
 Thu, 20 Aug 2020 10:21:11 +0800
From:   linmiaohe <linmiaohe@huawei.com>
To:     Chuck Lever <chuck.lever@oracle.com>
CC:     Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Convert to use the preferred fallthrough macro
Thread-Topic: [PATCH] nfsd: Convert to use the preferred fallthrough macro
Thread-Index: AdZ2mG6NaArBcemRGUaC0UhtB11ztg==
Date:   Thu, 20 Aug 2020 02:21:11 +0000
Message-ID: <66f183ce1fa4499dac09bf552038baa5@huawei.com>
Accept-Language: zh-CN, en-US
Content-Language: zh-CN
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.174.176.142]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
MIME-Version: 1.0
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Chuck Lever <chuck.lever@oracle.com> wrote:
>> On Aug 19, 2020, at 5:26 AM, Miaohe Lin <linmiaohe@huawei.com> wrote:
>> 
>> Convert the uses of fallthrough comments to fallthrough macro.
>
>The patch description would be more helpful if it referenced the commit that added the fallthrough macro to the kernel, or a permanent mailing list link that described its appropriate usage.
>
>Thanks!
>

Will add the commit that added the fallthrough macro to the kernel to commit log. Many thanks.

