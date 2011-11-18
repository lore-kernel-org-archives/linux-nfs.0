Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:58989 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105Ab1KRWHx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 17:07:53 -0500
Message-ID: <4EC6D767.6030109@calvaedi.com>
Date: Fri, 18 Nov 2011 23:08:39 +0100
From: John Hughes <john@calvaedi.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: John Hughes <john@calva.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket
 expiry. Try 2 with added man pages.
References: <4EC66D12.2090505@Calva.COM>	 <1321641333.2653.15.camel@lade.trondhjem.org>	 <4EC6AFA9.9000705@calvaedi.com> <1321648435.2653.53.camel@lade.trondhjem.org>
In-Reply-To: <1321648435.2653.53.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/18/2011 09:33 PM, Trond Myklebust wrote:
> On Fri, 2011-11-18 at 20:19 +0100, John Hughes wrote:
>    
>> On 11/18/2011 07:35 PM, Trond Myklebust wrote:
>>      
>>>
>>> You need a big fat warning somewhere that enabling this option WILL
>>> cause data corruption...
>>>
>>>        
>> Why?
>>
>> Because some process may get the EACCES error half way through it's
>> operation.
>>      
> No. Because the process can receive a reply to the write() syscall that
> indicates that the data is safe,

There is no reply from "write(2)" that says the data is safe.

>   but the EKEYEXPIRED error will cause
> the data to be lost when the client tries to actually commit the data to
> disk.
>
>    
>> The traditional Kerberos/AFS way was to behave the old way, and use
>> krenew to keep the ticket from expiring if a process needed to be run
>> overnight.
>>      
> Which is just wrong: the general intention of kerberos security is to
> ensure that the _user_ has ACKed an operation. Renewing tickets without
> user input would circumvent that intention. If you need to have the job
> run overnight, then ask for a longer lifetime for your ticket.
>    

Ok, so no need for the hang on ticket expired then.

(Although I don't think renewable tickets and krenew are a figment of my 
imagination).

>    
>> What other way is there of fixing the problem if we are going to keep
>> the "hang 'till a ticket turns up" behaviour?  (rewrite gnome and kde
>> seems kind of a big job).
>>      
> Notify the kernel that a ticket is about to expire so that the kernel
> can decide to block the process on the next NFS-related syscall.
>
>    
I don't understand.  How is it a win to block processes *before* the 
ticket has expired?


