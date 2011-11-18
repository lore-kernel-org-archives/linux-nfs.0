Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:57999 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969Ab1KRTSP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 14:18:15 -0500
Message-ID: <4EC6AFA9.9000705@calvaedi.com>
Date: Fri, 18 Nov 2011 20:19:05 +0100
From: John Hughes <john@calvaedi.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: John Hughes <john@calva.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket
 expiry. Try 2 with added man pages.
References: <4EC66D12.2090505@Calva.COM> <1321641333.2653.15.camel@lade.trondhjem.org>
In-Reply-To: <1321641333.2653.15.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/18/2011 07:35 PM, Trond Myklebust wrote:
> On Fri, 2011-11-18 at 15:34 +0100, John Hughes wrote:
>    
>> Description: Add "-e" (ticket expiry is error) option to rpc.gssd
>>    In kernels starting around 2.6.34 the nfs4 server will block all I/O
>>    when a user ticket expires.  In earlier kernels the I/O would fail
>>    with an EACCESS error.  This patch adds a "-e" option to rpc.gssd
>>    which allow the earlier behaviour (EKEYEXPIRED is converted to
>>    EACCESS).  This behaviour is particularly useful when user home
>>    directories are nfs4 mounted with krb5 security - if the user is
>>    absent from their workstation for long enough for the ticket to
>>    expire a new ticket will be obtained (via pam_krb5) by the screen
>>    unlock process.
>>      
> You need a big fat warning somewhere that enabling this option WILL
> cause data corruption...
>    
Why?

Because some process may get the EACCES error half way through it's 
operation.

Ok, that needs documenting.

So far we seem to have established that the old way of doing things was 
bad because it produced non-posix behaviour and could lead to data 
corruption if a ticket expires while a process needs it.

And the new way is bad because it leaves people puzzling over hung 
workstations in the morning.

The traditional Kerberos/AFS way was to behave the old way, and use 
krenew to keep the ticket from expiring if a process needed to be run 
overnight.

What other way is there of fixing the problem if we are going to keep 
the "hang 'till a ticket turns up" behaviour?  (rewrite gnome and kde 
seems kind of a big job).

