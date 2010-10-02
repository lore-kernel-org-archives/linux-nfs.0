Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836Ab0JBQt6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Oct 2010 12:49:58 -0400
Message-ID: <4CA762AE.5000807@RedHat.com>
Date: Sat, 02 Oct 2010 12:49:50 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Updated pNFS Developmental kernel repository
References: <4CA5C059.6000805@RedHat.com> <4CA5E744.9010006@desy.de> <4CA63D1A.5070108@RedHat.com> <4CA72977.10908@desy.de>
In-Reply-To: <4CA72977.10908@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 10/02/2010 08:45 AM, Tigran Mkrtchyan wrote:
> On 10/01/2010 09:57 PM, Steve Dickson wrote:
>>
>> On 10/01/2010 09:51 AM, Tigran Mkrtchyan wrote:
>>   
>>> Hi Steve,
>>>
>>> thanks for the builds. What I am missing is modprobe configuration file
>>> which I have to add myself.
>>>     
>> Unfortunately yes... I have not figured out a good way to have
>> the mobprobe done on the client since, in general, init scripts
>> don't run on the client (with the exception of rpc.statd and rpc.gssd).
>>
>> I guess I could come up with an pnfs init script..but that
>> seems like a bit overkill just to do a modprobe... 
>>
>>   
> I include /etc/modprobe.d/nfsv41 into rpms  which I build for our
> systems (RHEL5) with following content:
> 
> alias nfs-layouttype4-1 nfs_layout_nfsv41_files
> alias nfs-layouttype4-2 off
> alias nfs-layouttype4-3 off
> 
> 
> and following  into the spec file:
> 
> %config(noreplace) /etc/modprobe.d/nfsv41
> 
> I made it part of kernel rpm, but may be nfs-utils is more appropriate
> place.
Very cool... I try to incorporate this into the upcoming nfs-utils...

Because at the end of day, the distro "powers to be" are really 
against more init scripts... more init script means a longer time
to boot... and it seems fast reboots are the new in thing to have...
(which is a good thing.. :-) )

steved. 
