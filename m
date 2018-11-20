Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0460DC43441
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 03:39:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C24C020870
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 03:39:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C24C020870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=talpey.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730424AbeKTOGA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 09:06:00 -0500
Received: from p3plsmtpa11-07.prod.phx3.secureserver.net ([68.178.252.108]:55017
        "EHLO p3plsmtpa11-07.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1730224AbeKTOF7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 09:05:59 -0500
Received: from [192.168.0.55] ([24.218.182.144])
        by :SMTPAUTH: with ESMTPSA
        id OwsNgJlSTsChsOwsNg119w; Mon, 19 Nov 2018 20:39:00 -0700
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
To:     Jason Gunthorpe <jgg@ziepe.ca>
Cc:     "Mora, Jorge" <Jorge.Mora@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Olga Kornievskaia <aglo@umich.edu>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <4A94F1A9-96A4-4A2F-8617-AF0E2380D0C1@oracle.com>
 <CAN-5tyGU85PJe4Uoocw5NkT8YiYSF8wTWTgg4HycAgKpyHSfiw@mail.gmail.com>
 <9BD3F7C9-96BF-4555-A901-5E82E2CF9E28@oracle.com>
 <CAN-5tyELSi-Vtf1W3CSFzynbgVW7rcyJnfHmcb6Ehs0NEUiy4A@mail.gmail.com>
 <4EE34B64-0BEB-439A-B2A2-D77673D4CF70@oracle.com>
 <5EA42399-05C2-40D3-A5CA-7B40971AEC33@netapp.com>
 <20181119224615.GM4890@ziepe.ca>
 <d6e65bdf-6cdd-1a23-36de-71aeb57a22e0@talpey.com>
 <20181120030916.GQ4890@ziepe.ca>
 <8fd325fa-290a-6381-80d8-e6ac20acffe8@talpey.com>
 <20181120033218.GS4890@ziepe.ca>
From:   Tom Talpey <tom@talpey.com>
Message-ID: <107378fb-669d-80b7-efb2-84694367ce9c@talpey.com>
Date:   Mon, 19 Nov 2018 22:38:58 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20181120033218.GS4890@ziepe.ca>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfMvE2dZJ0l7Wtig7nuP5/zAkSoi7fFNwbqMB2RP+f31AT4FhiI/L07DhttVLvXV2MvZzEiWM/EqL83dVUlyfz2L4Gicnk/8t16ZVh+u66SphPRAvkl4r
 N3GrDLM7QuUy3BF8sPMrsKHX4GoYRaXBmrW5x7O00xw3sMDw9q3Qzavnh3oS0F/mJBmrBoxs2fdoHxlx9H2LjOIUNDtgxZlFv06LCD7Ca20C3jN/yhvNn/r8
 rGAbvPPZCOZ/Ss1Bqm/c5Uux7tLNIXlNEg/4Bl9Ni+9BYJFDi9PskhnENM39uI4TG0Qt/8//sFwwz5JMC0AiAOZ1QwhE8jLQx6o1p2Q2g14=
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 11/19/2018 10:32 PM, Jason Gunthorpe wrote:
> On Mon, Nov 19, 2018 at 10:25:37PM -0500, Tom Talpey wrote:
> 
>> Absolutely, but if the offset walks into the high-order invariant bits,
>> they won't be invariant any longer. It would still work, but it would
>> defeat the wireshark trick that Chuck wants to play.
> 
> Sure, OK, if you care about the bits being invarient, and not simply
> randomized :)

Well, that was Chuck's proposal, to use the XID. SMB Direct originally
used a formula, then changed to randomized, and in future will likely
change it again. The point is, it's the RDMA consumer's choice, not a
verb, or adapter, or protocol, requirement.


>>> For many adaptors that means PAGE_SIZE or huge
>>> page size level alignment..
>>
>> I'm not sure I understand this. The FRWR hides the native page size, by
>> providing the page frames in the local work request. Their size isn't
>> known to the protocol.
> 
> Ah, some HW has limitations in how it can construct a VA. In many
> implementation the low order bits of the VA must match the offset into
> the page. If the page is 4K that is 12 bits, if it is 2M that is 21
> bits..
> 
> So there should be restrictions on what start VA can be assigned to a
> FRWR.

I think only the FBO (First Byte Offset) is really restricted. But
indeed yes, the number of possible FBO bits is a function of the page 
size. So, if so, we agree - ok.

Tom.
