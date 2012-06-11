Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:40888 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221Ab2FKQIi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 12:08:38 -0400
Message-ID: <4FD617D7.7030209@panasas.com>
Date: Mon, 11 Jun 2012 19:07:51 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: Benny Halevy <bhalevy@tonian.com>, Andy Adamson <androsadamson@gmail.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFSv4.1 mark layout when already returned
References: <1338571178-2096-1-git-send-email-andros@netapp.com> <1338571178-2096-2-git-send-email-andros@netapp.com> <4FCA98E7.2030006@panasas.com> <1C92D18B-1977-4A12-A4DA-84DAC4B3E81E@netapp.com> <4FCE1DC1.6050100@panasas.com> <CAHVgHyXVCUdVFMO1WcRofOCvgDs7Reqsrs39qrZR7UnXWzG8RQ@mail.gmail.com> <4FD5C0EA.806@tonian.com> <02293178-08CA-4CD6-A472-252860CC1FA7@netapp.com> <4FD610EF.2090702@tonian.com> <4F7E0716-F1A2-48E0-BC18-E91B33FBA5C2@netapp.com>
In-Reply-To: <4F7E0716-F1A2-48E0-BC18-E91B33FBA5C2@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/11/2012 06:52 PM, Adamson, Andy wrote:
<>

>>
>> Yeah, right now pnfs_return_layout always returns the whole layout
>> so this patch works.  Boaz's point (I think) was that marking the whole layout
>> as returned in the generic layer will prevent returning of layout segments
>> by the objects layout.
> 
> Yep. I agree that _pnfs_return_layout needs to operate on an input range, and 
> should wait for all lseg references - the "normal" behavior. 
> 


You mean the normal "error handling behavior" right?

> Then, after that is done,
> I will write a patch to allow the file layout driver to call _pnfs_return_layout in
> "fence mode" e.g returning the whole layout, and not waiting for the last lseg reference.
> 


This one I do not understand. And am really trying. please be slow with me?
1. What does it means "whole layout" Is that just a short hand for
   "all segments" ?
2. What is "fence mode" LAYOUTRETURN. where did you take this one from?
3. How does "fence mode" permits a client to use a layout segment after
   the send of LAYOUTRETURN. Since that is what we do (to date) because
   of race.

Thanks
Boaz

> -->Andy


