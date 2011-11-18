Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21502 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752093Ab1KRUeN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 15:34:13 -0500
Message-ID: <1321648435.2653.53.camel@lade.trondhjem.org>
Subject: Re: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket
 expiry. Try 2 with added man pages.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: John Hughes <john@calvaedi.com>
Cc: John Hughes <john@calva.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Fri, 18 Nov 2011 22:33:55 +0200
In-Reply-To: <4EC6AFA9.9000705@calvaedi.com>
References: <4EC66D12.2090505@Calva.COM>
	 <1321641333.2653.15.camel@lade.trondhjem.org>
	 <4EC6AFA9.9000705@calvaedi.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-11-18 at 20:19 +0100, John Hughes wrote: 
> On 11/18/2011 07:35 PM, Trond Myklebust wrote:
> > On Fri, 2011-11-18 at 15:34 +0100, John Hughes wrote:
> >    
> >> Description: Add "-e" (ticket expiry is error) option to rpc.gssd
> >>    In kernels starting around 2.6.34 the nfs4 server will block all I/O
> >>    when a user ticket expires.  In earlier kernels the I/O would fail
> >>    with an EACCESS error.  This patch adds a "-e" option to rpc.gssd
> >>    which allow the earlier behaviour (EKEYEXPIRED is converted to
> >>    EACCESS).  This behaviour is particularly useful when user home
> >>    directories are nfs4 mounted with krb5 security - if the user is
> >>    absent from their workstation for long enough for the ticket to
> >>    expire a new ticket will be obtained (via pam_krb5) by the screen
> >>    unlock process.
> >>      
> > You need a big fat warning somewhere that enabling this option WILL
> > cause data corruption...
> >    
> Why?
> 
> Because some process may get the EACCES error half way through it's 
> operation.

No. Because the process can receive a reply to the write() syscall that
indicates that the data is safe, but the EKEYEXPIRED error will cause
the data to be lost when the client tries to actually commit the data to
disk.

> Ok, that needs documenting.
> 
> So far we seem to have established that the old way of doing things was 
> bad because it produced non-posix behaviour and could lead to data 
> corruption if a ticket expires while a process needs it.
> 
> And the new way is bad because it leaves people puzzling over hung 
> workstations in the morning.
> 
> The traditional Kerberos/AFS way was to behave the old way, and use 
> krenew to keep the ticket from expiring if a process needed to be run 
> overnight.

Which is just wrong: the general intention of kerberos security is to
ensure that the _user_ has ACKed an operation. Renewing tickets without
user input would circumvent that intention. If you need to have the job
run overnight, then ask for a longer lifetime for your ticket.

> What other way is there of fixing the problem if we are going to keep 
> the "hang 'till a ticket turns up" behaviour?  (rewrite gnome and kde 
> seems kind of a big job).

Notify the kernel that a ticket is about to expire so that the kernel
can decide to block the process on the next NFS-related syscall.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

