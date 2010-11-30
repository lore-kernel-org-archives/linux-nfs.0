Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:15766 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288Ab0K3Ps6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 10:48:58 -0500
Message-ID: <4CF51CE7.4000701@panasas.com>
Date: Tue, 30 Nov 2010 17:48:55 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Spelic <spelic@shiftmail.org>, Spencer Shepler <spencer.shepler@gmail.com>,
        Daniel.Muntz@emc.com, linux-nfs@vger.kernel.org
Subject: Re: NFSv4 behaviour on unknown users
References: <1291054975.12784.17.camel@heimdal.trondhjem.org>	 <DE966DA98A4ABE438D726BDF1699CF610437B188C9@MX05A.corp.emc.com>	 <067101cb9018$d70ba2f0$8522e8d0$@gmail.com>	 <1291072571.20567.26.camel@heimdal.trondhjem.org>	 <1291073174.20567.31.camel@heimdal.trondhjem.org>	 <068901cb901d$61395630$23ac0290$@gmail.com>	 <1291074002.20567.38.camel@heimdal.trondhjem.org>	 <068f01cb9021$d1c10700$75431500$@gmail.com>	 <4CF4E38B.4050706@shiftmail.org> <1291122263.3204.2.camel@heimdal.trondhjem.org>
In-Reply-To: <1291122263.3204.2.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/30/2010 03:04 PM, Trond Myklebust wrote:
> On Tue, 2010-11-30 at 12:44 +0100, Spelic wrote:
>> On 11/30/2010 01:02 AM, Spencer Shepler wrote:
>>>> It would not be backwards compatible: the linux server will currently
>>>> reject any uid/gid usage by the client.
>>>>
>>>> That said, I can imagine that for 'sec=sys', we might be able to change
>>>> the client to use the uid/gid format by default, and then change back to
>>>> doing name@domain upon receiving the first NFS4ERR_BADOWNER error from the
>>>> server.
>>>> It the server changes to match this, then that might suffice solve the
>>>> current problem that we have with doing nfsroot on NFSv4...
>>>>      
>>> IMO: I wouldn't worry about the mixed scenarios to start with.
>>> Provide the option on the client and server to use the straight-up
>>> uid/gid to string mappings and this will satisfy these simple
>>> deployments that are or will have trouble.
>>>    
>>
>> +1 for this.  Changing mapping on the fly at the first NFS4ERR_BADOWNER 
>> received does not look very reliable to me: is scarcely controllable by 
>> the sysadmin and is gonna make the thing a headache to debug the first 
>> time it happens unwillingly (maybe the sysadmin was changing some config 
>> on the server and suddenly the everything stops working and he needs to 
>> restart the nfs client to restore things but this is scarcely 
>> intuitive...). +1 for simply providing a clear-upfront option for using 
>> numeric UIDs/GIDs.
>>
>> Thanks for your understanding :-)
> 
> Sorry, but BADOWNER is an error that means "I don't get it" and the spec
> _is_ adamant about what the client should do. This is a take it or leave
> it: I'm not going to waste a lot of time and effort on this.
> 

Perhaps a BIG FAT message in dmsg should help the poor admin investigating
the matter.

Thanks
> Trond
> 

