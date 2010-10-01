Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:43372 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446Ab0JASAV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 14:00:21 -0400
Message-ID: <4CA621A4.2040508@almaden.ibm.com>
Date: Fri, 01 Oct 2010 11:00:04 -0700
From: Marc Eshel <eshel@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Benny Halevy <bhalevy@panasas.com>, Boaz Harrosh <bharrosh@panasas.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        NFS list <linux-nfs@vger.kernel.org>, linux-nfs-owner@vger.kernel.org,
        Fred Isaman <iisaman@netapp.com>
Subject: Re: pNFS DS session
References: <4CA34883.40005@desy.de> <4CA34B93.2010100@panasas.com> <4CA44AAA.4030803@panasas.com> <4CA45462.1070503@desy.de> <4CA455C4.4030705@panasas.com> <OF6B8488BA.B9C50431-ON882577AF.0016FDCE-882577AF.0017999B@us.ibm.com> <4CA57BC6.9030701@desy.de> <4CA5A012.2090404@panasas.com> <4CA5D537.30300@panasas.com> <4CA600F4.2010006@almaden.ibm.com> <20101001171012.GB30570@fieldses.org>
In-Reply-To: <20101001171012.GB30570@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  On 10/1/2010 10:10 AM, J. Bruce Fields wrote:
> On Fri, Oct 01, 2010 at 08:40:36AM -0700, Marc Eshel wrote:
>>   On 10/1/2010 5:33 AM, Benny Halevy wrote:
>>> On 2010-10-01 10:47, Boaz Harrosh wrote:
>>>> On 10/01/2010 08:12 AM, Tigran Mkrtchyan wrote:
>>>>>    On 10/01/2010 06:17 AM, Marc Eshel wrote:
>>>>>> Hi Benny,
>>>>>>
>>>>>> Running connectathon I see that some times the clients decides to destroy
>>>>>> the session with the DS. The test continue and the session is
>>>>>> re-established. It looks like layout return reduces the hold on device
>>>>>> info the reduces the hold on the client struct which decide to destroy the
>>>>>> session. Is that a known problem?
>>>>>>
>>>> Yes, I want to emphasize on Marks words: "a known *problem*"
>>> Marc, assuming the code behaves as expected, does this cause any other badness
>>> like the GETATTRs you see going out to the DS?
>>>
>>> Benny
>>>
>> No i don't see any "badness" the test continues without errors and
>> this problem is not related to the GETATTRs I see on the DS but I
>> would consider destroying the session in short run of couple of
>> minutes some times more than one time as something bad.
> Why?
>
> I wouldn't expect session destruction/creation to be *that* expensive.

I assumed that it is inexpensive. We are talking about potential 
destruction/creation of session from every DS for each file IO if there 
is no overlap in holding layouts, right ?

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>


