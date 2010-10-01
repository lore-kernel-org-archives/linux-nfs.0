Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42829 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949Ab0JAUFt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 16:05:49 -0400
Received: by bwz11 with SMTP id 11so2452911bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 01 Oct 2010 13:05:48 -0700 (PDT)
In-Reply-To: <4CA63D1A.5070108@RedHat.com>
References: <4CA5C059.6000805@RedHat.com>
	<4CA5E744.9010006@desy.de>
	<4CA63D1A.5070108@RedHat.com>
Date: Fri, 1 Oct 2010 16:05:48 -0400
Message-ID: <AANLkTinAL6eSqEpzmtMOgw8=+3j4rz4q25VeEdDO9iAr@mail.gmail.com>
Subject: Re: Updated pNFS Developmental kernel repository
From: Fred Isaman <iisaman@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With recent code, you don't need a modprobe on the client.  All you
need to do is set up an alias.

In some /etc/modprobe.d file put:

alias nfs-layouttype4-1 nfs_layout_nfsv41_files

Fred

On Fri, Oct 1, 2010 at 3:57 PM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> On 10/01/2010 09:51 AM, Tigran Mkrtchyan wrote:
>>
>> Hi Steve,
>>
>> thanks for the builds. What I am missing is modprobe configuration file
>> which I have to add myself.
> Unfortunately yes... I have not figured out a good way to have
> the mobprobe done on the client since, in general, init scripts
> don't run on the client (with the exception of rpc.statd and rpc.gssd).
>
> I guess I could come up with an pnfs init script..but that
> seems like a bit overkill just to do a modprobe...
>
> steved.
>
>>
>> thanks,
>>    Tigran.
>>
>> On 10/01/2010 01:04 PM, Steve Dickson wrote:
>>> Hello,
>>>
>>> I've updated the Fedora pNFS development repository to include the
>>> Fedora 13, 14 and Devel kernels that have the latest pNFS bits:
>>>
>>>      Tag: pnfs-all-2.6.35-2010-09-14     for Fedora 13 and 14 kernels
>>>      Tag: pnfs-all-latest                for Devel/f15 kernels
>>>
>>> (Note: there are also kernel-debuginfo and kernel-devel rpms for people who
>>> use things like systemtap probes and crash).
>>>
>>> I have not updated the nfs-utils rpms because I'm waiting
>>> for a fix to a problem in rpc.mountd. Once the problem is resolve
>>> I'll update those rpms as well...
>>>
>>> Instructions on how to install and use these kernels are at:
>>> http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup
>>>
>>>   If/when bugs are found with these rpms please enter them
>>> in to the NFS Bugzilla Main Page at:
>>>      https://bugzilla.linux-nfs.org/index.cgi
>>>
>>> Please use the "pNFS" keyword..
>>>
>>> Any question or issues please feel free to contact me...
>>>
>>> steved.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
