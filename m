From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/2] nfsd4: complete enforcement of 4.1 op ordering
Date: Tue, 27 Apr 2010 19:44:51 +0300
Message-ID: <4BD71483.1090604@panasas.com>
References: <1271946744-5877-1-git-send-email-bfields@citi.umich.edu> <20100422144831.GA5926@fieldses.org> <20100423212411.GC1964@fieldses.org> <4BD6F775.2050801@panasas.com> <20100427150103.GC30729@fieldses.org> <4BD706E3.4070608@panasas.com> <20100427161244.GG30729@fieldses.org> <4BD70F5F.7080409@panasas.com> <20100427163404.GH30729@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, postmaster@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:39322 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750735Ab0D0Qoy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Apr 2010 12:44:54 -0400
In-Reply-To: <20100427163404.GH30729@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 27, 2010, 19:34 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> On Tue, Apr 27, 2010 at 07:22:55PM +0300, Benny Halevy wrote:
>> On Apr. 27, 2010, 19:12 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
>>> On Tue, Apr 27, 2010 at 06:46:43PM +0300, Benny Halevy wrote:
>>>> On Apr. 27, 2010, 18:01 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
>>>>> On Tue, Apr 27, 2010 at 05:40:53PM +0300, Benny Halevy wrote:
>>>>>> Bruce, Oddly enough I didn't receive the patch you're commenting on into
>>>>>> my inbox.  It already happened before on this list and I've no idea what
>>>>>> could have went wrong. (I also have a gmail account subscribed on this list
>>>>>> and I can't find it there, even in the spam folder :-/)
>>>>>
>>>>> Huh.  I see it in various archives, so I'll assume the problem's on your
>>>>> end.
>>>>>
>>>>
>>>> I see it on the archives too, but since I don't ever erase anything out
>>>> of my gmail lists account the fact that it's not there AND not
>>>> on my panasas account as well is really suspicious.  I wonder if
>>>> vger had some sort of outage or glitch that could explain that.
>>>
>>> For what it's worth I've found postmaster at vger.kernel.org can
>>> sometimes help troubleshoot problems.
>>>
>>> --b.
>>
>> Oddly enough, it seems like I'm subscribed this list (called "linux-nfsv4"):
>> http://marc.info/?l=linux-nfsv4&r=1&b=201004&w=2
>> rather than
>> http://marc.info/?l=linux-nfs&r=1&b=201004&w=2
>>
>> Although my subscription messages from majordomo@vger.kernel.org
>> say "linux-nfs"
>>
>> The former is essentially nfsv4@linux-nfs.org, right?
>> Maybe I got bounced off of linux-nfs.org for some reason...

I've re-subscribed to linux-nfs. I hope I stay there now.
I've no idea why I was bounced off.
I'm not really sure if I should have got an email telling me I was bounced.

BTW, the "which <my-email>" command doesn't seem to work properly on
majordomo@vger.kernel.org as it returns "No matches found" even though
I'm subscribed now.

> 
> The main lists we've been using are:
> 
> 	linux-nfs@vger.kernel.org
> 	    nfsv4@linux-nfs.org
> 	     pnfs@linux-nfs.org
> 
> This seems to be confusing.  We've talked before about transitioning
> away from one (probably nfsv4@linux-nfs.org).  Maybe now's the time to
> start.

I'm all for it.
Maybe it's time to fold the pnfs list into linux-nfs too.

> 
> (Oh, and there's also an older sourceforge list; I think mail still gets
> forwarded from the vger list to there?  Or is it the other way around?
> May be time to turn that one off completely.)

Never heard of it 'till now :)

Benny

> 
> --b.

