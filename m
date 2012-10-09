Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757150Ab2JIXaZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Oct 2012 19:30:25 -0400
Message-ID: <5074B38E.5030909@RedHat.com>
Date: Tue, 09 Oct 2012 19:30:22 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Quentin Barnes <qbarnes@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Long-standing NFSv3 UDP client performance problem, probably
 due to RPC?
References: <CAKjHkpC4yQRHJK1e66dg20t_AL3oy+vu_yue2vKEAxKRvd75gQ@mail.gmail.com> <5072B4BC.9050006@RedHat.com> <CAKjHkpA+w329RtUo30utEi-sYmkDdDNSDZgxTDxv13Z_f-M=Jg@mail.gmail.com>
In-Reply-To: <CAKjHkpA+w329RtUo30utEi-sYmkDdDNSDZgxTDxv13Z_f-M=Jg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/10/12 11:08, Quentin Barnes wrote:
> On Mon, Oct 8, 2012 at 6:10 AM, Steve Dickson <SteveD@redhat.com> wrote:
>> On 05/10/12 13:57, Quentin Barnes wrote:
> [...]
>>> Since for our work, for other reasons, we've switched over to
>>> using NFSv3 TCP mounts, so I can't justify spending a lot of time
>>> debugging this UDP/RPC problem.  However, for example if someone
>>> wants me to try something out and gather some new test results or
>>> a patch to test, I can squeeze that in.
> [...]
>>
>> I think there probably has been a steady decline in UPD performance
>> over the years.
> 
> In my data, after the initial big hit between RHEL4 and RHEL5,
> NFSv3/UDP performance went back up peaking with 2.6.31, then declined
> with 2.6.32 and RHEL6, and has then held steady ever since.
Wow... Impressive... Very rarely do we get a such a time line 
in WRT performance... I'm not sure what happen in the 2.6.32 kernel,
but maybe it has something to do with the RPC slot table???
That pure speculation... 

> 
> Now I have seen a significant dip my NFSv3/TCP performance data
> after 3.3 with 3.6 (I don't have data points for 3.4 & 3.5), but
> didn't want to get into that here and I hadn't looked into it hard
> enough yet to verify it.
Now this is not good... I do remember come claims that RHEL5 was
quicker than RHEL6, but there was never any numbers to back
it up... 
> 
>> The main reason is that nobody uses it since TCP is a
>> much better transport to use with NFS...
> 
> I disagree somewhat, at least for my particular configuration and
> networks.  With my testing and tuning with FreeBSD and 2.6.9 and
> earlier Linux kernels, NFSv3/UDP overall performance is generally
> 10%-15% better than NFSv3/TCP.
I did meant in production... We too still test v2 over UDP and TCP... 

> 
>> Why are you still using UDP as your transport?
> 
> We're not.  See my above quoted paragraph.  I still measure and
> monitor NFSv3/UDP's performance as part of my kernel development
> work improving the kernel's NFS performance for our needs, but since
> no one uses UDP mounts in house currently, I can't justify the time
> to find and fix the bug.
Agreed... Justifying working/fixing technology what we are moving
away from is tough... 

steved.
