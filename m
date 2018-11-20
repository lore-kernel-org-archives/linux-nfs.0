Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 528CEC28CF8
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 15:23:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C4BF820831
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 15:23:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4BF820831
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728019AbeKUBwi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 20:52:38 -0500
Received: from mga05.intel.com ([192.55.52.43]:24294 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726108AbeKUBwi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Nov 2018 20:52:38 -0500
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Nov 2018 07:22:59 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,257,1539673200"; 
   d="scan'208";a="93525854"
Received: from ddalessa-mobl2.amr.corp.intel.com (HELO [10.254.201.218]) ([10.254.201.218])
  by orsmga008.jf.intel.com with ESMTP; 20 Nov 2018 07:22:57 -0800
Subject: Re: [PATCH v1 1/4] xprtrdma: Remove support for FMR memory
 registration
To:     Jason Gunthorpe <jgg@ziepe.ca>,
        Bart Van Assche <bvanassche@acm.org>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, oulijun@huawei.com, umalhi@cisco.com,
        zhongjiang@huawei.com, venkata.s.dhanalakota@intel.com
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
 <20181119154551.10832.5498.stgit@manet.1015granger.net>
 <1542644197.185366.50.camel@acm.org> <20181119224143.GL4890@ziepe.ca>
From:   Dennis Dalessandro <dennis.dalessandro@intel.com>
Message-ID: <d1de2a1f-c20c-afbb-121b-464dc0cd75ef@intel.com>
Date:   Tue, 20 Nov 2018 10:22:56 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20181119224143.GL4890@ziepe.ca>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 11/19/2018 5:41 PM, Jason Gunthorpe wrote:
> On Mon, Nov 19, 2018 at 08:16:37AM -0800, Bart Van Assche wrote:
>> On Mon, 2018-11-19 at 10:45 -0500, Chuck Lever wrote:
>>> FMR is not supported on most recent RDMA devices. It is also slower
>>> and less secure than FRWR. As discussed during the RDMA BoF at LPC
>>> 2018, it is time to remove support for FMR in the NFS/RDMA client
>>> stack. NFS/RDMA server-side uses either local memory registration or
>>> FRWR.  There is no change required there to deprecate FMR.
>>>
>>> There are a few Infiniband/RoCE devices in the kernel tree that do
>>> not support MEM_MGT_EXTENSIONS, and therefore will no longer support
>>> client-side NFS/RDMA. These are:
>>>
>>>   - mthca
>>>   - qib
> 
> Ooh, qib was not in the list when we talked on this in plumbers. That
> does change things.
> 
> Dennis: Could qib be changed? HFI1 supports FRWR right?

Turns out that qib can not support FRWR because that requires HW support 
for opcodes that qib just doesn't understand.

hfi1 is good to go though.

>>>   - usnic
>>>   - hns (RoCE)
>>
>> Can someone from Intel comment on how many of their customers rely on the qib
>> driver?

There is a user base. I can't say how large though. But I have had 
discussions with mgmt and we aren't quite ready to leave qib out in the 
cold just yet.

We have a lot of people out this week due to the US Thanksgiving 
holiday. Once people are back in the office on Monday I'll find out some 
more as to the impact of this change.

-Denny
