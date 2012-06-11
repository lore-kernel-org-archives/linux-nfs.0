Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:37371 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369Ab2FKOv3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 10:51:29 -0400
Message-ID: <4FD605DA.2070203@panasas.com>
Date: Mon, 11 Jun 2012 17:51:06 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: Benny Halevy <bhalevy@tonian.com>, "Welch, Brent" <welch@panasas.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        Andy Adamson <androsadamson@gmail.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        "Huang, James" <jhuang@panasas.com>
Subject: Re: [PATCH 2/3] NFSv4.1 mark layout when already returned
References: <1338571178-2096-1-git-send-email-andros@netapp.com> <1338571178-2096-2-git-send-email-andros@netapp.com> <4FCA98E7.2030006@panasas.com> <1C92D18B-1977-4A12-A4DA-84DAC4B3E81E@netapp.com> <4FCE1DC1.6050100@panasas.com> <CAHVgHyXVCUdVFMO1WcRofOCvgDs7Reqsrs39qrZR7UnXWzG8RQ@mail.gmail.com> <4FD5C0EA.806@tonian.com> <4FD5CBF6.6030800@panasas.com> <4FD5FAEF.5040004@tonian.com> <47AB2031-76C2-4E10-9C55-D328E2994780@netapp.com>
In-Reply-To: <47AB2031-76C2-4E10-9C55-D328E2994780@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/11/2012 05:21 PM, Adamson, Andy wrote:

> 
> On Jun 11, 2012, at 10:04 AM, Benny Halevy wrote:
> 
>> On 2012-06-11 13:44, Boaz Harrosh wrote:
>>> Basically my plan is to postpone the LAYOUTRETURN send to
>>> when the segment is last referenced, if a flag was set to
>>> do so, and make sure reference counting is done proper, so
>>> after flag set the last IO_done will send the LAYOUTRETURN.
>>>
>>> If that is OK with all I hope?
>>
>> Sounds OK to me.  Thanks!
> 
> Sounds fine to me as well, for LAYOUTRETURN during normal behavior.
> 
> -->Andy


I'm not sure I understood what you meant.

In the "normal behavior" we don't send a LAYOUTRETURN at all
in the forgetful model. Which proved beneficiary in the light
of concurrent GETs vs RETURNs.

I thought we are only taking about the error case. Do you
mean there is a 3rd case? please explain.

Thanks
Boaz
