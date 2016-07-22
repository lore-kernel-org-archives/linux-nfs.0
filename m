Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:34367 "EHLO
	mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbcGVO5q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2016 10:57:46 -0400
Received: by mail-it0-f51.google.com with SMTP id j8so6486908itb.1
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2016 07:57:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN63_cZ-dvf2o+xkQTrFpKNq51ZmVzuqBErLrX1xDQZO6x-3Mw@mail.gmail.com>
References: <CAN63_cbcrKWYuim5NZHSfYWFXFFmcssMpiT0H2PATEu_K=FEPw@mail.gmail.com>
 <20160713132601.GA8856@fieldses.org> <CAN63_caHoS68rSdWeHfYxx_5bBiiqetY5NgYrL-+-Kvs=sX3RQ@mail.gmail.com>
 <20160718140915.GD11071@fieldses.org> <CAN63_cY=qLZ4DsyXrUuxP7cF2LO-ZxUrN6Pmtps8Y8hZZGS=Aw@mail.gmail.com>
 <20160721171458.GB27148@fieldses.org> <CAN-5tyEQ7q=hRHSHK=x3hVuFd2FNoh0X13zur8HpiCkGUW_Oag@mail.gmail.com>
 <CAN63_canXB_PztbgA209rf9mBLmHEHsk7XzhOhkpzfFnfQv2hA@mail.gmail.com>
 <CAN-5tyFRRz1Q_M23n6CB0VwNYXKpHvX7=0rvQCOzFRzH5esC5Q@mail.gmail.com> <CAN63_cZ-dvf2o+xkQTrFpKNq51ZmVzuqBErLrX1xDQZO6x-3Mw@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 22 Jul 2016 10:57:44 -0400
Message-ID: <CAN-5tyHfrWfGWvZ0xFR7NzGeZYz0LR5rjD8THBwbHkrb8AWdAA@mail.gmail.com>
Subject: Re: open a file in 0100444 mode in NFSv4 may fail
To: Thomas Gambier <thomas.gambier@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 22, 2016 at 10:36 AM, Thomas Gambier
<thomas.gambier@gmail.com> wrote:
> On Fri, Jul 22, 2016 at 3:05 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> On Fri, Jul 22, 2016 at 5:36 AM, Thomas Gambier
>> <thomas.gambier@gmail.com> wrote:
>>> Hello,
>>>
>>> when doing more tests with TCL, I found a more critical problem.
>>>
>>> If I create a directory and just after I create a read only file (mode
>>> 0444) inside it, I got a permission denied error. See the attached C
>>> source code. As the previous error, it is random but I always have it
>>> fail before the 10th execution.
>>>
>>> I attach the network traffic but it seems that the problem is again in
>>> the client.
>>>
>>> Olga, could you test this new testcase on the newest kernel ?
>>
>> Works fine for me on the RHEL7.2 and upstream.
>>
> This is strange because I just tested on CentOS7.2 (my kernel is
> 3.10.0-327.el7.x86_64) and I have the problem.

I retested .327 RHEL7.2 against a linux server (and not netapp
server). It fails. The test app works in upstream against both
servers.

>
>>>
>>> Regards.
>>>
>>> Thomas.
>>>
>>> On Thu, Jul 21, 2016 at 8:10 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>> On Thu, Jul 21, 2016 at 1:14 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>>> On Thu, Jul 21, 2016 at 04:54:36PM +0200, Thomas Gambier wrote:
>>>>>> On Mon, Jul 18, 2016 at 4:09 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>>>> > On Mon, Jul 18, 2016 at 03:44:48PM +0200, Thomas Gambier wrote:
>>>>>> >> Hello,
>>>>>> >>
>>>>>> >> thanks for your answer. See my comments below.
>>>>>> >>
>>>>>> >> On Wed, Jul 13, 2016 at 3:26 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>>>> >> > On Mon, Jul 11, 2016 at 07:40:11PM +0200, Thomas Gambier wrote:
>>>>>> >> >> Hello,
>>>>>> >> >>
>>>>>> >> >> I just discovered a problem with NFSv4 file system. I was using TCL
>>>>>> >> >> scripts that were doing some file manipulation (mkdir, copy, ...) on
>>>>>> >> >> my NFSv4 file system and sometimes the scripts failed with "permission
>>>>>> >> >> denied" error.
>>>>>> >> >>
>>>>>> >> >> I ran strace and I found that the system call returning the error was:
>>>>>> >> >> open("d1/in.txt", O_WRONLY|O_CREAT|O_TRUNC, 0100444) = -1 EACCES
>>>>>> >> >> (Permission denied)
>>>>>> >> >
>>>>>> >> > Is that even allowed?  The open(2) man page says posix leaves behavior
>>>>>> >> > in that case unspecified, and doesn't say anything I can find about
>>>>>> >> > Linux behavior in this case.
>>>>>> >> >
>>>>>> >> You're right. I will send a mail to TCL mailing list to know why they
>>>>>> >> put this flag in the open call.
>>>>>> >>
>>>>>> >> > I guess it would be nicer for client or server to do something
>>>>>> >> > predictable, though.  First steps might be to confirm what happens other
>>>>>> >> > filesystems, then do a network trace (watch the traffic in wireshark) to
>>>>>> >> > see if it's the client rejecting this open, or the client passing
>>>>>> >> > through that bit in the mode and the server returning the error.
>>>>>> >>
>>>>>> >> I agree. For other filesystem, I only tested with ext4 which works
>>>>>> >> fine. Let me know if you want me to test specific filesystems.
>>>>>> >>
>>>>>> >> I attach the wireshark capture of a test with 8 open call working fine
>>>>>> >> and the 9th one failing. For me, it seems the activity on the network
>>>>>> >> is exactly the same for the failing case (same call from client to
>>>>>> >> server and same answer from server to client). It would mean that the
>>>>>> >> client itself is messing things up...
>>>>>> >
>>>>>> > Agreed, sounds like the client's only deciding to fail the open after
>>>>>> > the OPEN call to the server succeeds.
>>>>>> >
>>>>>> > Unfortunately, the client open logic is (necessarily) pretty
>>>>>> > complicated--a few minutes digging around wasn't enough for me to figure
>>>>>> > uot where the error's coming from.
>>>>>> >
>>>>>>
>>>>>> I'm not sure if I can help... I don't know the NFS source code at all.
>>>>>> I can do more tests if you need, though.
>>>>>
>>>>> It doesn't look like a high priority based just on what we know
>>>>> (slightly odd behavior in an undefined case), so I think we'll just have
>>>>> to leave it at that until somebody gets curious.  Thanks for the report.
>>>>>
>>>>
>>>> Hi Thomas,
>>>>
>>>> I don't know exactly what was fixed or when but I thought I'd note
>>>> that I don't see the problem on the upstream 4.7-rc7 but I can
>>>> reproduce the problem on RHEL7.2 kernel.
