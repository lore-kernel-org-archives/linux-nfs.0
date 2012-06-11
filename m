Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44748 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755027Ab2FKOVu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 10:21:50 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Benny Halevy <bhalevy@tonian.com>
CC: Boaz Harrosh <bharrosh@panasas.com>, "Welch, Brent" <welch@panasas.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Andy Adamson <androsadamson@gmail.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        "Huang, James" <jhuang@panasas.com>
Subject: Re: [PATCH 2/3] NFSv4.1 mark layout when already returned
Date: Mon, 11 Jun 2012 14:21:33 +0000
Message-ID: <47AB2031-76C2-4E10-9C55-D328E2994780@netapp.com>
References: <1338571178-2096-1-git-send-email-andros@netapp.com>
 <1338571178-2096-2-git-send-email-andros@netapp.com>
 <4FCA98E7.2030006@panasas.com>
 <1C92D18B-1977-4A12-A4DA-84DAC4B3E81E@netapp.com>
 <4FCE1DC1.6050100@panasas.com>
 <CAHVgHyXVCUdVFMO1WcRofOCvgDs7Reqsrs39qrZR7UnXWzG8RQ@mail.gmail.com>
 <4FD5C0EA.806@tonian.com> <4FD5CBF6.6030800@panasas.com>
 <4FD5FAEF.5040004@tonian.com>
In-Reply-To: <4FD5FAEF.5040004@tonian.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 11, 2012, at 10:04 AM, Benny Halevy wrote:

> On 2012-06-11 13:44, Boaz Harrosh wrote:
>> On 06/11/2012 12:56 PM, Benny Halevy wrote:
>> 
>>> 
>>> It will for recovering files striped with RAID as the LAYOUTRETURN
>>> provides the server with a reliable "commit point" where it knows
>>> exactly what was written successfully to each stripe and can make
>>> the most efficient decision about recovering it (if needed).
>>> 
>>> Allowing I/O to the stripe post LAYOUTRETURN may result in data
>>> corruption due to parity inconsistency.
>>> 
>> 
>> 
>> The fact of the matter is that we - object guys - Which care about
>> LAYOUTRETURN the most, have neglected to notice and fix the current
>> situation which is even worse than After Andy's patch. Which will
>> send multiple LAYOUTRETURNs on the same layout, and might still
>> continue IO on returned layouts.
>> 
>> Thanks Andy for testing and highlighting the current problem,
>> I will prioritized this development internally at Panasas and
>> will work on a solution ASAP. I hope one that will satisfy
>> all.
>> 
>> Basically my plan is to postpone the LAYOUTRETURN send to
>> when the segment is last referenced, if a flag was set to
>> do so, and make sure reference counting is done proper, so
>> after flag set the last IO_done will send the LAYOUTRETURN.
>> 
>> If that is OK with all I hope?
> 
> Sounds OK to me.  Thanks!

Sounds fine to me as well, for LAYOUTRETURN during normal behavior.

-->Andy

> 
> Benny
> 
>> 
>>> Benny
>>> 
>> 
>> 
>> Thanks
>> Boaz
>> 

