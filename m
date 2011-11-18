Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52480 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757002Ab1KRWiJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 17:38:09 -0500
Message-ID: <1321655886.10541.24.camel@lade.trondhjem.org>
Subject: Re: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket
 expiry. Try 2 with added man pages.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: John Hughes <john@calvaedi.com>
Cc: John Hughes <john@calva.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Sat, 19 Nov 2011 00:38:06 +0200
In-Reply-To: <4EC6D767.6030109@calvaedi.com>
References: <4EC66D12.2090505@Calva.COM>
		 <1321641333.2653.15.camel@lade.trondhjem.org>
		 <4EC6AFA9.9000705@calvaedi.com>
	 <1321648435.2653.53.camel@lade.trondhjem.org>
	 <4EC6D767.6030109@calvaedi.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-11-18 at 23:08 +0100, John Hughes wrote: 
> On 11/18/2011 09:33 PM, Trond Myklebust wrote:
> > On Fri, 2011-11-18 at 20:19 +0100, John Hughes wrote:
> >    
> >> On 11/18/2011 07:35 PM, Trond Myklebust wrote:
> >>      
> >>>
> >>> You need a big fat warning somewhere that enabling this option WILL
> >>> cause data corruption...
> >>>
> >>>        
> >> Why?
> >>
> >> Because some process may get the EACCES error half way through it's
> >> operation.
> >>      
> > No. Because the process can receive a reply to the write() syscall that
> > indicates that the data is safe,
> 
> There is no reply from "write(2)" that says the data is safe.

Read the rest of the thread... Jim and Nick already made this point, and
I've replied.

The fact of the matter is that most application writers remain blithely
oblivious of the need to fsync() as the ext4 people know all to well:
see the attempts to impose the fully posix-compatible 'data=writeback'
mode as the default and the catastrophe that occurred when
'data=ordered' semantics changed for the rename() syscall. Adding new
failure modes needs to be done with care, or GNOME will crash and/or
your word processor _will_ lose your last hour or so of work.

> >   but the EKEYEXPIRED error will cause
> > the data to be lost when the client tries to actually commit the data to
> > disk.
> >
> >    
> >> The traditional Kerberos/AFS way was to behave the old way, and use
> >> krenew to keep the ticket from expiring if a process needed to be run
> >> overnight.
> >>      
> > Which is just wrong: the general intention of kerberos security is to
> > ensure that the _user_ has ACKed an operation. Renewing tickets without
> > user input would circumvent that intention. If you need to have the job
> > run overnight, then ask for a longer lifetime for your ticket.
> >    
> 
> Ok, so no need for the hang on ticket expired then.
> 
> (Although I don't think renewable tickets and krenew are a figment of my 
> imagination).

They are a workaround to the problem of users failing to plan ahead
and/or jobs not running as quickly as originally scheduled. You can run
them if you feel safe doing so, but they should not be a mandatory
feature to ensure data isn't lost during normal operation.

BTW: instead of trying to change existing kernel and gssd semantics, why
not concentrate on adding the equivalent of krenewd/kstart?

> >> What other way is there of fixing the problem if we are going to keep
> >> the "hang 'till a ticket turns up" behaviour?  (rewrite gnome and kde
> >> seems kind of a big job).
> >>      
> > Notify the kernel that a ticket is about to expire so that the kernel
> > can decide to block the process on the next NFS-related syscall.
> >
> >    
> I don't understand.  How is it a win to block processes *before* the 
> ticket has expired?

So that the kernel can flush out any dirty data while the ticket is
valid, and block further asynchronous read/write operations (either by
making them synchronous, or by returning an appropriate error). We may
also want to consider closing open file state and possibly freeing up
locks so that other processes with valid credentials may still access
the data.

IOW: that allows for an _orderly_ failure mode instead of the current
catastrophic mode. The application gets a chance to deal with any errors
_before_ the data is lost.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

