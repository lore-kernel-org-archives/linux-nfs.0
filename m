Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:15390 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756753Ab0JAMeF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 08:34:05 -0400
Message-ID: <4CA5D537.30300@panasas.com>
Date: Fri, 01 Oct 2010 14:33:59 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Marc Eshel <eshel@almaden.ibm.com>
CC: Boaz Harrosh <bharrosh@panasas.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        NFS list <linux-nfs@vger.kernel.org>, linux-nfs-owner@vger.kernel.org,
        Fred Isaman <iisaman@netapp.com>
Subject: Re: pNFS DS session
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com> <4CA34830.1040703@desy.de> <4CA34883.40005@desy.de> <4CA34B93.2010100@panasas.com> <4CA44AAA.4030803@panasas.com> <4CA45462.1070503@desy.de> <4CA455C4.4030705@panasas.com> <OF6B8488BA.B9C50431-ON882577AF.0016FDCE-882577AF.0017999B@us.ibm.com> <4CA57BC6.9030701@desy.de> <4CA5A012.2090404@panasas.com>
In-Reply-To: <4CA5A012.2090404@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-01 10:47, Boaz Harrosh wrote:
> On 10/01/2010 08:12 AM, Tigran Mkrtchyan wrote:
>>   On 10/01/2010 06:17 AM, Marc Eshel wrote:
>>> Hi Benny,
>>>
>>> Running connectathon I see that some times the clients decides to destroy
>>> the session with the DS. The test continue and the session is
>>> re-established. It looks like layout return reduces the hold on device
>>> info the reduces the hold on the client struct which decide to destroy the
>>> session. Is that a known problem?
>>>
> 
> Yes, I want to emphasize on Marks words: "a known *problem*"

Marc, assuming the code behaves as expected, does this cause any other badness
like the GETATTRs you see going out to the DS?

Benny

> 
> I have objected strongly to this new "fixture" by Fred and backed up by Benny.
> They decided to only hold a deviceid as long as a layout references it. And
> not like before, until unmount. I think they are totally wrong with regard
> to current servers and implementation and a setup that might enjoy what is
> done now, will not exist for at least 3 years or more.
> 
> An argument was made that current code is more simple. But I have demonstrated
> that all that is needed is a one-line get_ref at device add. And that iteration
> on all devices at umount time that was there before and removed in latest code.
> 
> !!!
> Boaz
> 
> 
>> Just wan to confirm  that we see this as well (pnfs-submit and 
>> pnfs-all-latest).
>>
>> Tigran.
>>> Thanks, Marc.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
