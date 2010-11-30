Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from blade3.isti.cnr.it ([194.119.192.19]:50237 "EHLO
	BLADE3.ISTI.CNR.IT" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755711Ab0K3Lon (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 06:44:43 -0500
Received: from SCRIPT-SPFWL-DAEMON.mx.isti.cnr.it by mx.isti.cnr.it
 (PMDF V6.5 #31825) id <01NUV96709E8LS5V2W@mx.isti.cnr.it> for
 linux-nfs@vger.kernel.org; Tue, 30 Nov 2010 12:44:12 +0100 (MET)
Received: from conversionlocal.isti.cnr.it by mx.isti.cnr.it (PMDF V6.5 #31825)
 id <01NUV966Q7Q8LS5WM7@mx.isti.cnr.it> for linux-nfs@vger.kernel.org; Tue,
 30 Nov 2010 12:44:11 +0100 (MET)
Date: Tue, 30 Nov 2010 12:44:11 +0100
From: Spelic <spelic@shiftmail.org>
Subject: Re: NFSv4 behaviour on unknown users
In-reply-to: <068f01cb9021$d1c10700$75431500$@gmail.com>
To: Spencer Shepler <spencer.shepler@gmail.com>
Cc: "'Trond Myklebust'" <Trond.Myklebust@netapp.com>, Daniel.Muntz@emc.com,
        linux-nfs@vger.kernel.org
Message-id: <4CF4E38B.4050706@shiftmail.org>
Content-type: text/plain; format=flowed; charset=UTF-8
References: <1291054975.12784.17.camel@heimdal.trondhjem.org>
 <DE966DA98A4ABE438D726BDF1699CF610437B188C9@MX05A.corp.emc.com>
 <067101cb9018$d70ba2f0$8522e8d0$@gmail.com>
 <1291072571.20567.26.camel@heimdal.trondhjem.org>
 <1291073174.20567.31.camel@heimdal.trondhjem.org>
 <068901cb901d$61395630$23ac0290$@gmail.com>
 <1291074002.20567.38.camel@heimdal.trondhjem.org>
 <068f01cb9021$d1c10700$75431500$@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/30/2010 01:02 AM, Spencer Shepler wrote:
>> It would not be backwards compatible: the linux server will currently
>> reject any uid/gid usage by the client.
>>
>> That said, I can imagine that for 'sec=sys', we might be able to change
>> the client to use the uid/gid format by default, and then change back to
>> doing name@domain upon receiving the first NFS4ERR_BADOWNER error from the
>> server.
>> It the server changes to match this, then that might suffice solve the
>> current problem that we have with doing nfsroot on NFSv4...
>>      
> IMO: I wouldn't worry about the mixed scenarios to start with.
> Provide the option on the client and server to use the straight-up
> uid/gid to string mappings and this will satisfy these simple
> deployments that are or will have trouble.
>    

+1 for this.  Changing mapping on the fly at the first NFS4ERR_BADOWNER 
received does not look very reliable to me: is scarcely controllable by 
the sysadmin and is gonna make the thing a headache to debug the first 
time it happens unwillingly (maybe the sysadmin was changing some config 
on the server and suddenly the everything stops working and he needs to 
restart the nfs client to restore things but this is scarcely 
intuitive...). +1 for simply providing a clear-upfront option for using 
numeric UIDs/GIDs.

Thanks for your understanding :-)
