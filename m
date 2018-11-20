Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96FD6C43441
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 02:52:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 670D520870
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 02:52:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 670D520870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=talpey.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728794AbeKTNTd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 08:19:33 -0500
Received: from p3plsmtpa11-03.prod.phx3.secureserver.net ([68.178.252.104]:56193
        "EHLO p3plsmtpa11-03.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1728538AbeKTNTc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 08:19:32 -0500
X-Greylist: delayed 439 seconds by postgrey-1.27 at vger.kernel.org; Tue, 20 Nov 2018 08:19:32 EST
Received: from [192.168.0.55] ([24.218.182.144])
        by :SMTPAUTH: with ESMTPSA
        id Ow2Wg3sxZROT0Ow2WgB0cj; Mon, 19 Nov 2018 19:45:25 -0700
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
To:     Jason Gunthorpe <jgg@ziepe.ca>,
        "Mora, Jorge" <Jorge.Mora@netapp.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Olga Kornievskaia <aglo@umich.edu>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20181119154607.10832.92558.stgit@manet.1015granger.net>
 <CAN-5tyG26W+TjTsjpTVvF3RJOGCnD8L79dCbRqKTm5F1V3fuxw@mail.gmail.com>
 <6592845E-0136-4D42-8426-3E2A0BB5FFE7@oracle.com>
 <CAN-5tyEw5iRaA6mCp5DeNv1DMkFGAqtvq1PcRSiFZ6PQyJpDUA@mail.gmail.com>
 <4A94F1A9-96A4-4A2F-8617-AF0E2380D0C1@oracle.com>
 <CAN-5tyGU85PJe4Uoocw5NkT8YiYSF8wTWTgg4HycAgKpyHSfiw@mail.gmail.com>
 <9BD3F7C9-96BF-4555-A901-5E82E2CF9E28@oracle.com>
 <CAN-5tyELSi-Vtf1W3CSFzynbgVW7rcyJnfHmcb6Ehs0NEUiy4A@mail.gmail.com>
 <4EE34B64-0BEB-439A-B2A2-D77673D4CF70@oracle.com>
 <5EA42399-05C2-40D3-A5CA-7B40971AEC33@netapp.com>
 <20181119224615.GM4890@ziepe.ca>
From:   Tom Talpey <tom@talpey.com>
Message-ID: <d6e65bdf-6cdd-1a23-36de-71aeb57a22e0@talpey.com>
Date:   Mon, 19 Nov 2018 21:45:24 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20181119224615.GM4890@ziepe.ca>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfCdgIQleB9Yk4FA122PCq8ti6lJaso4nDP07ZN0aLg7QnHLSLAqJIL4EPOHwptYNkOupPk5UYHFX1zhBuoTNXtYFcS2Hy45JjTH2hsA315QI+M8Sn2lZ
 495QB3+527ouOx5B2jZoScSfWju10Ey1/6yRvN5tzDlD+/8Nkm3pLjpQ+vRYpsESZtuThz7OXXUrWi3ydjWt2BRAeAOYmPxjMXFwlcJ64OX5AIRHD/uInclE
 98fY4DzjKZUgDkEEdCe2QEj7Biz4Y307JIYUzKSp6P/5rY/keKRwzHuHGK6wsxYkTHlwG4p7v8YuwrrjRQU/2AXxtR5L46r+bUB4OoVpidU=
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 11/19/2018 5:46 PM, Jason Gunthorpe wrote:
> On Mon, Nov 19, 2018 at 09:42:56PM +0000, Mora, Jorge wrote:
>> Hello Chuck,
>>
>> I am confused, is it the whole purpose of RDMA is to place the data
>> directly into the memory location given by the virtual address or
>> offset? What you are saying is that this offset is not the actual
>> memory address and so the driver must map this offset to the actual
>> address?
> 
> All RDMA on the wire addresses are 'virtual' and always go through
> translation hardware to reach a physical memory address. Even if you
> have a virtual address that matches your physical address there will
> still be translation hardware to enforce security.
> 
> The direct placement refers to not copying data, not to using physical
> memory addresses throughout the protocol design.
> 
> So it is better to use a virtual address that doesn't disclose any
> information about the host's configuration to the network, such as
> physical locations of kernel memory.

Agreed. And, this is a very subtle but very powerful aspect of FRWR
registration, that the high-order bits of the "virtual address" can
basically be any value of the requestor's (client's) choice.

Note, the low-order bits, up to the maximum offset used by the upper
layer (e.g. a few MB for NFS), must be reserved in order to allow RDMA
segments to iterate over the range of bytes in the region. That's only
24 or so bits out of the available 64, here however.

For other registration methods, this is not always the case. It is
definitely best to leverage this important property for FRWR.

SMB Direct in Windows does a similar swizzling, by the way. We have
taken several different approaches to the format, over time.

Tom.
