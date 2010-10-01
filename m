Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9422 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754627Ab0JAU6R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 16:58:17 -0400
Message-ID: <4CA64B65.3050808@panasas.com>
Date: Fri, 01 Oct 2010 22:58:13 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Updated pNFS Developmental kernel repository
References: <4CA5C059.6000805@RedHat.com> <4CA5E744.9010006@desy.de> <4CA63D1A.5070108@RedHat.com>
In-Reply-To: <4CA63D1A.5070108@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-01 21:57, Steve Dickson wrote:
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

One feature I want to do for a long time is to automatically
load the driver from the kernel and eventually add a mount option
to optionally load a layoutdriver on demand, or disable pnfs
for this mount altogether.  For example:

pnfs=(auto|none|<layout_driver>|<layout_type>)

Benny

> 
> steved.
> 
>>
>> thanks,
>>    Tigran.
>>
>> On 10/01/2010 01:04 PM, Steve Dickson wrote:
>>> Hello,
>>>
>>> I've updated the Fedora pNFS development repository to include the
>>> Fedora 13, 14 and Devel kernels that have the latest pNFS bits:
>>>
>>>      Tag: pnfs-all-2.6.35-2010-09-14     for Fedora 13 and 14 kernels
>>>      Tag: pnfs-all-latest                for Devel/f15 kernels
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
>>>   If/when bugs are found with these rpms please enter them
>>> in to the NFS Bugzilla Main Page at:
>>>      https://bugzilla.linux-nfs.org/index.cgi
>>>
>>> Please use the "pNFS" keyword..
>>>
>>> Any question or issues please feel free to contact me...
>>>
>>> steved.
>>> -- 
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
