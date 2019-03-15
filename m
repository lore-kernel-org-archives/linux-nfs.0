Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 493EBC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 06:30:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1855D218A5
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 06:30:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728398AbfCOGa4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 02:30:56 -0400
Received: from out30-42.freemail.mail.aliyun.com ([115.124.30.42]:58356 "EHLO
        out30-42.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1728266AbfCOGa4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 02:30:56 -0400
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R491e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07488;MF=jiufei.xue@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TMlFdQy_1552631452;
Received: from ali-186590e05fa3.local(mailfrom:jiufei.xue@linux.alibaba.com fp:SMTPD_---0TMlFdQy_1552631452)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 15 Mar 2019 14:30:53 +0800
Subject: Re: [bug report] task hang while testing xfstests generic/323
To:     Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <trondmy@hammerspace.com>
Cc:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "joseph.qi@linux.alibaba.com" <joseph.qi@linux.alibaba.com>
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
 <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
 <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com>
 <57796366-0f08-2cfb-6f85-27d5485c07af@linux.alibaba.com>
 <ce839197cb70f3bc75413ed2e54f8baafafc01dd.camel@hammerspace.com>
 <365504c3-d785-7e4b-1dd2-c75f30c85c65@linux.alibaba.com>
 <740c1ad6c5b2afad196af34f48dda7097b5102b7.camel@hammerspace.com>
 <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com>
 <b729878b38f32053890a592a91f0645f15caa96f.camel@hammerspace.com>
 <46f5c870-f4fd-b29a-f5eb-eab39c4c1e89@linux.alibaba.com>
 <20190306160934.GB3066@fieldses.org>
 <CAN-5tyEPSDKao=83sW+voU9SPbcszZyR+XfZzcsD2-ozVa22Xg@mail.gmail.com>
 <ace3659edd3efb70d3d978e108ecf1fc22ee3966.camel@hammerspace.com>
 <CAN-5tyH8hFmEsAKDMDL4uey0MXh9+kY43=LEpgjj711eVUubAA@mail.gmail.com>
 <CAN-5tyEAfV_WA3Vyf8LQ-EN4yn99p1sk7fuu7n43t8H8+un2Yw@mail.gmail.com>
From:   Jiufei Xue <jiufei.xue@linux.alibaba.com>
Message-ID: <37b3d7db-0bdf-014a-adff-ea401ea92fc7@linux.alibaba.com>
Date:   Fri, 15 Mar 2019 14:30:52 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <CAN-5tyEAfV_WA3Vyf8LQ-EN4yn99p1sk7fuu7n43t8H8+un2Yw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Olga,

On 2019/3/11 下午11:13, Olga Kornievskaia wrote:
> Let me double check that. I have reproduced the "infinite loop" or
> CLOSE on the upstream (I'm looking thru the trace points from friday).

Do you try to capture the packages when reproduced this issue on the
upstream. I still lost kernel packages after some adjustment according
to bfield's suggestion :(

Thanks,
Jiufei
