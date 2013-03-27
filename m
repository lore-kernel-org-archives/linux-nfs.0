Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960Ab3C0NGV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Mar 2013 09:06:21 -0400
Message-ID: <5152EED1.3070303@RedHat.com>
Date: Wed, 27 Mar 2013 09:06:25 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountd: regression in crossmounts
References: <1364049149-3751-1-git-send-email-steved@redhat.com> <20130325181314.GA10120@fieldses.org> <5150B1FD.1070405@RedHat.com> <20130325212736.GC10887@fieldses.org> <20130325233649.GF10887@fieldses.org>
In-Reply-To: <20130325233649.GF10887@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 25/03/13 19:36, J. Bruce Fields wrote:
> On Mon, Mar 25, 2013 at 05:27:36PM -0400, J. Bruce Fields wrote:
>> On Mon, Mar 25, 2013 at 04:22:21PM -0400, Steve Dickson wrote:
>>>
>>>
>>> On 25/03/13 14:13, J. Bruce Fields wrote:
>>>> On Sat, Mar 23, 2013 at 10:32:29AM -0400, Steve Dickson wrote:
>>>>> commit 8e2fb3fc cause a regression in mount export
>>>>> that are on different local file system.
>>>>> Exports like (all on different filesystems)
>>>>>
>>>>> /home *(rw,fsid=0,crossmnt)
>>>>> /home/fs1 *(rw,crossmnt)
>>>>> /home/fs1/fs2/fs3 *(rw,nohide)
>>>>>
>>>>> and then a mount of the root 'mount /home /mnt'
>>>>> would end up mounting /home/fs1/fs2/fs3 not /home
>>>>
>>>> That's strange.
>>> Yeah... I had this guy reporting from day one that the 
>>> latest nfs-utils broke his export world... 
>>>  
>>>>
>>>>> Reverting the logic of commit 8e2fb3fc until
>>>>> a better solution can be found for the original
>>>>> problem.
>>>>
>>>> I can't figure out why the patch below would help.  The only change I
>>>> can see is to the way that an export of "/" would be handled.
>>> The reason I didn't debug this further was I did not know how to 
>>> reproduce the original problem the patch was trying to fix... 
>>
>> Could you remind me where the bug report for this is?
> 
> Oh, right, it was https://bugzilla.redhat.com/show_bug.cgi?id=909882
> 
> I'm not seeing why you think this helps.
Because it does... ;-) 
     https://bugzilla.redhat.com/show_bug.cgi?id=909882#c10
     https://admin.fedoraproject.org/updates/FEDORA-2013-4396/nfs-utils-1.2.7-5.fc18

What I would like to is how to reproduce the original problem so
we can fix it without creating this regression.... 

steved.
 
