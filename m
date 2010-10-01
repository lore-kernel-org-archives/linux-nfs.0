Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219Ab0JAT5X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 15:57:23 -0400
Message-ID: <4CA63D1A.5070108@RedHat.com>
Date: Fri, 01 Oct 2010 15:57:14 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Updated pNFS Developmental kernel repository
References: <4CA5C059.6000805@RedHat.com> <4CA5E744.9010006@desy.de>
In-Reply-To: <4CA5E744.9010006@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 10/01/2010 09:51 AM, Tigran Mkrtchyan wrote:
> 
> Hi Steve,
> 
> thanks for the builds. What I am missing is modprobe configuration file
> which I have to add myself.
Unfortunately yes... I have not figured out a good way to have
the mobprobe done on the client since, in general, init scripts
don't run on the client (with the exception of rpc.statd and rpc.gssd).

I guess I could come up with an pnfs init script..but that
seems like a bit overkill just to do a modprobe... 

steved.

> 
> thanks,
>    Tigran.
> 
> On 10/01/2010 01:04 PM, Steve Dickson wrote:
>> Hello,
>>
>> I've updated the Fedora pNFS development repository to include the
>> Fedora 13, 14 and Devel kernels that have the latest pNFS bits:
>>
>>      Tag: pnfs-all-2.6.35-2010-09-14     for Fedora 13 and 14 kernels
>>      Tag: pnfs-all-latest                for Devel/f15 kernels
>>
>> (Note: there are also kernel-debuginfo and kernel-devel rpms for people who
>> use things like systemtap probes and crash).
>>
>> I have not updated the nfs-utils rpms because I'm waiting
>> for a fix to a problem in rpc.mountd. Once the problem is resolve
>> I'll update those rpms as well...
>>
>> Instructions on how to install and use these kernels are at:
>> http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup
>>
>>   If/when bugs are found with these rpms please enter them
>> in to the NFS Bugzilla Main Page at:
>>      https://bugzilla.linux-nfs.org/index.cgi
>>
>> Please use the "pNFS" keyword..
>>
>> Any question or issues please feel free to contact me...
>>
>> steved.
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
