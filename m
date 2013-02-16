Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753326Ab3BPPLn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Feb 2013 10:11:43 -0500
Message-ID: <511FA1A6.2060903@RedHat.com>
Date: Sat, 16 Feb 2013 10:11:34 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: V4 unmount causes a GETATTR
References: <511E5838.2020103@RedHat.com> <20130215182531.GB19923@fieldses.org> <511EAC8B.3050403@RedHat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA91F3DA928@sacexcmbx05-prd.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91F3DA928@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 16/02/13 00:17, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>> owner@vger.kernel.org] On Behalf Of Steve Dickson
>> Sent: Friday, February 15, 2013 4:46 PM
>> To: J. Bruce Fields
>> Cc: linux-nfs@vger.kernel.org
>> Subject: Re: V4 unmount causes a GETATTR
>>
>>
>>
>> On 15/02/13 13:25, J. Bruce Fields wrote:
>>> On Fri, Feb 15, 2013 at 10:46:00AM -0500, Steve Dickson wrote:
>>>> Hello,
>>>>
>>>> I have not tracked down as to the exact reason, but it appears umount
>>>> of v4 file system cause the directory to be revalidating causing the
>>>> GETATTR.
>>>>
>>>> Is this revalidation really necessary on an unmount?
>>>
>>> I don't know, maybe not.  But even if it's not, there are other things
>>> (like cleaning up state) that the client will likely try to do on
>>> unmount.  In the presence of delegations it could have dirty data that
>>> it's required to write back even if applications don't currently hold
>>> any open files.
>> Understood with dirty data... but what I as seeing was a v4 mount and then a
>> reboot with no activity on the mount point...
>>
>>>
>>> So I don't think we can promise umount will work without the network.
>> Again with open files (aka activity on the mount point) I agree but with no
>> activity or open files, I'm think that GETATTR is simply not necessary...
> 
> You'd need to add a lookup intent specifically for umount. Otherwise the filesystem will not be able distinguish between path lookups for umount and other activity.
> 
> Also note that "no activity or open files" is no guarantee that you won't be holding delegations or pNFS layouts to return; you may still see hangs.
> 
I've also noticed force mounts this clean up does not happen (aka the GETATTR is not sent)... which is the price of doing forced mounts... 

steved.

