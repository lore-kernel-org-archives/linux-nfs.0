Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f46.google.com ([209.85.215.46]:63447 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab2JLXcP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 19:32:15 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so2315222lag.19
        for <linux-nfs@vger.kernel.org>; Fri, 12 Oct 2012 16:32:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5074B38E.5030909@RedHat.com>
References: <CAKjHkpC4yQRHJK1e66dg20t_AL3oy+vu_yue2vKEAxKRvd75gQ@mail.gmail.com>
	<5072B4BC.9050006@RedHat.com>
	<CAKjHkpA+w329RtUo30utEi-sYmkDdDNSDZgxTDxv13Z_f-M=Jg@mail.gmail.com>
	<5074B38E.5030909@RedHat.com>
Date: Fri, 12 Oct 2012 18:32:14 -0500
Message-ID: <CAKjHkpBFqaKrjtZfSE6uqdsWWNaYO+vaMrQeiDruTjzMXNXoWQ@mail.gmail.com>
Subject: Re: Long-standing NFSv3 UDP client performance problem, probably due
 to RPC?
From: Quentin Barnes <qbarnes@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 9, 2012 at 6:30 PM, Steve Dickson <SteveD@redhat.com> wrote:
> On 08/10/12 11:08, Quentin Barnes wrote:
>> On Mon, Oct 8, 2012 at 6:10 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>> On 05/10/12 13:57, Quentin Barnes wrote:
>> [...]
>>>> Since for our work, for other reasons, we've switched over to
>>>> using NFSv3 TCP mounts, so I can't justify spending a lot of time
>>>> debugging this UDP/RPC problem.  However, for example if someone
>>>> wants me to try something out and gather some new test results or
>>>> a patch to test, I can squeeze that in.
>> [...]
>>>
>>> I think there probably has been a steady decline in UPD performance
>>> over the years.
>>
>> In my data, after the initial big hit between RHEL4 and RHEL5,
>> NFSv3/UDP performance went back up peaking with 2.6.31, then declined
>> with 2.6.32 and RHEL6, and has then held steady ever since.
>
> Wow... Impressive... Very rarely do we get a such a time line
> in WRT performance...

That's with the chaotic UDP bug though.  If performance has drifted
up or down for others over that time, I haven't seen it because the
UDP/RPC perf bug with multiple processes is swamping anything
else in the data.

> I'm not sure what happen in the 2.6.32 kernel,
> but maybe it has something to do with the RPC slot table???
> That pure speculation...

That's a very interesting hypothesis.  I did try for awhile to
find it with git bisect, but had little luck.

I expect to be testing RHEL6.3 which has the RPC dynamic slot
allocator backport (RH BZ #785823) to see what effect that
work has on performance.

>> Now I have seen a significant dip my NFSv3/TCP performance data
>> after 3.3 with 3.6 (I don't have data points for 3.4 & 3.5), but
>> didn't want to get into that here and I hadn't looked into it hard
>> enough yet to verify it.
>
> Now this is not good... I do remember come claims that RHEL5 was
> quicker than RHEL6, but there was never any numbers to back
> it up...

With my testing of NFSv3/TCP, ops/sec from RHEL4 to RHEL5 using
just basic NFS improved about 50%.  However, for the environment
I'm monitoring performance for, we run with O_DIRECT which RHEL5
performance nosedived.  For us with O_DIRECT, RHEL5 NFSv3/TCP is
about 25% poorer in performance than with RHEL4.

I plan to test 3.4 and 3.5 kernels to narrow down some where such a
significant NFSv3/TCP performance drop is happening for us.

>>> The main reason is that nobody uses it since TCP is a
>>> much better transport to use with NFS...
>>
>> I disagree somewhat, at least for my particular configuration and
>> networks.  With my testing and tuning with FreeBSD and 2.6.9 and
>> earlier Linux kernels, NFSv3/UDP overall performance is generally
>> 10%-15% better than NFSv3/TCP.
>
> I did meant in production... We too still test v2 over UDP and TCP...

We'd use NFSv3/UDP in production except for a "feature" of Netapp
filers that don't support UDP as well as the do TCP for our use
cases.  (I don't know if the specifics of the issue are confidential
or not, so I'm glossing over them here.)

>>> Why are you still using UDP as your transport?
>>
>> We're not.  See my above quoted paragraph.  I still measure and
>> monitor NFSv3/UDP's performance as part of my kernel development
>> work improving the kernel's NFS performance for our needs, but since
>> no one uses UDP mounts in house currently, I can't justify the time
>> to find and fix the bug.
>
> Agreed... Justifying working/fixing technology what we are moving
> away from is tough...

Yep.  :-)

> steved.

Quentin
