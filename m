Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5907 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753502Ab0JCOz6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Oct 2010 10:55:58 -0400
Message-ID: <4CA89979.2070308@panasas.com>
Date: Sun, 03 Oct 2010 10:55:53 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Andy Adamson <andros@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Marc Eshel <eshel@almaden.ibm.com>, Benny Halevy <bhalevy@panasas.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        NFS list <linux-nfs@vger.kernel.org>, linux-nfs-owner@vger.kernel.org,
        Fred Isaman <iisaman@netapp.com>
Subject: Re: pNFS DS session
References: <4CA44AAA.4030803@panasas.com> <4CA45462.1070503@desy.de> <4CA455C4.4030705@panasas.com> <OF6B8488BA.B9C50431-ON882577AF.0016FDCE-882577AF.0017999B@us.ibm.com> <4CA57BC6.9030701@desy.de> <4CA5A012.2090404@panasas.com> <4CA5D537.30300@panasas.com> <4CA600F4.2010006@almaden.ibm.com> <20101001171012.GB30570@fieldses.org> <4CA621A4.2040508@almaden.ibm.com> <20101001181455.GC32256@fieldses.org> <2DE155F2-DCC3-4930-8CAE-D21F26730058@netapp.com>
In-Reply-To: <2DE155F2-DCC3-4930-8CAE-D21F26730058@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 10/01/2010 02:29 PM, Andy Adamson wrote:
> 
> On Oct 1, 2010, at 2:14 PM, J. Bruce Fields wrote:
> 
>> On Fri, Oct 01, 2010 at 11:00:04AM -0700, Marc Eshel wrote:
>>> On 10/1/2010 10:10 AM, J. Bruce Fields wrote:
>>>> On Fri, Oct 01, 2010 at 08:40:36AM -0700, Marc Eshel wrote:
>>>>> On 10/1/2010 5:33 AM, Benny Halevy wrote:
>>>>>> On 2010-10-01 10:47, Boaz Harrosh wrote:
>>>>>>> On 10/01/2010 08:12 AM, Tigran Mkrtchyan wrote:
>>>>>>>>  On 10/01/2010 06:17 AM, Marc Eshel wrote:
>>>>>>>>> Hi Benny,
>>>>>>>>>
>>>>>>>>> Running connectathon I see that some times the clients decides to destroy
>>>>>>>>> the session with the DS. The test continue and the session is
>>>>>>>>> re-established. It looks like layout return reduces the hold on device
>>>>>>>>> info the reduces the hold on the client struct which decide to destroy the
>>>>>>>>> session. Is that a known problem?
>>>>>>>>>
>>>>>>> Yes, I want to emphasize on Marks words: "a known *problem*"
>>>>>> Marc, assuming the code behaves as expected, does this cause any other badness
>>>>>> like the GETATTRs you see going out to the DS?
>>>>>>
>>>>>> Benny
>>>>>>
>>>>> No i don't see any "badness" the test continues without errors and
>>>>> this problem is not related to the GETATTRs I see on the DS but I
>>>>> would consider destroying the session in short run of couple of
>>>>> minutes some times more than one time as something bad.
>>>> Why?
>>>>
>>>> I wouldn't expect session destruction/creation to be *that* expensive.
>>>
>>> I assumed that it is inexpensive. We are talking about potential
>>> destruction/creation of session from every DS for each file IO if
>>> there is no overlap in holding layouts, right ?
>>
>> Well, I guess the tradeoffs aren't obvious to me: if you end up having
>> to set up an enormous number of sessions (and tcp connections, etc.) all
>> at once, then I can see why it might be a problem.  It would also seem
>> inefficient to keep around an enormous number of those when they aren't
>> being used for a while.
> 
> The plan is to add some code that waits a lease time before destroying an un-referenced deviceid.
> The next submission patch set will include layoutreturn and the return-on-close code, so it will
> probably be added then.

Rrr No! That's not what I wont. I want a cap on resources. That is say 17 servers I'll keep
for ever, anything over I can drop when done on a: least used basis.

I don't get this Gerrila programming, all of a sudden. Why do you guys go to grate length to shoot
yourself in the foot. We all have a limited and constant number of servers in our clusters. It
is counter performance, counter memory efficient, and a call for grate instability. Why deallocate
what I know for sure that I'll need on every future IO.

Time is not an issue here. Resources is, and speed. I'm idle for a while. Then on next IO I'm
slowed to an halt. It's not like I'm not sure the same servers will be used again.

The system Bruce describes above "It would also seem inefficient to keep around an enormous
number of those" does not yet exist. You are all talking about a future, not existent system.
Mean while sacrificing stability and performance. For no gain.

I can't see why you are picking on this simple matter.

You need memory problems on your head. Clone a Linux git tree on a system with less then
128Mg over pnfs. There you have a problem! it dead locks on network out of memory.

Boaz
> 
> -->Andy
> 
