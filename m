Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-2.desy.de ([131.169.56.85]:37074 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008Ab0JBMpw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Oct 2010 08:45:52 -0400
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id 6F542DC8
	for <linux-nfs@vger.kernel.org>; Sat,  2 Oct 2010 14:45:50 +0200 (MEST)
Received: from adserv72.win.desy.de (adserv72.win.desy.de [131.169.97.58])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id 681B4DB9
	for <linux-nfs@vger.kernel.org>; Sat,  2 Oct 2010 14:45:50 +0200 (MEST)
Message-ID: <4CA72977.10908@desy.de>
Date: Sat, 02 Oct 2010 14:45:43 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
CC: Steve Dickson <SteveD@redhat.com>
Subject: Re: Updated pNFS Developmental kernel repository
References: <4CA5C059.6000805@RedHat.com> <4CA5E744.9010006@desy.de> <4CA63D1A.5070108@RedHat.com>
In-Reply-To: <4CA63D1A.5070108@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 10/01/2010 09:57 PM, Steve Dickson wrote:
>
> On 10/01/2010 09:51 AM, Tigran Mkrtchyan wrote:
>   
>> Hi Steve,
>>
>> thanks for the builds. What I am missing is modprobe configuration file
>> which I have to add myself.
>>     
> Unfortunately yes... I have not figured out a good way to have
> the mobprobe done on the client since, in general, init scripts
> don't run on the client (with the exception of rpc.statd and rpc.gssd).
>
> I guess I could come up with an pnfs init script..but that
> seems like a bit overkill just to do a modprobe... 
>
>   
I include /etc/modprobe.d/nfsv41 into rpms  which I build for our
systems (RHEL5) with following content:

alias nfs-layouttype4-1 nfs_layout_nfsv41_files
alias nfs-layouttype4-2 off
alias nfs-layouttype4-3 off


and following  into the spec file:

%config(noreplace) /etc/modprobe.d/nfsv41

I made it part of kernel rpm, but may be nfs-utils is more appropriate
place.

Regards,
   Tigran.
> steved.
>
>   
>> thanks,
>>    Tigran.
>>
>> On 10/01/2010 01:04 PM, Steve Dickson wrote:
>>     
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
>>>       
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>     

