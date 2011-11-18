Return-Path: linux-nfs-owner@vger.kernel.org
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:57904 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756544Ab1KRVqO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 16:46:14 -0500
Date: Fri, 18 Nov 2011 15:47:28 -0500
From: Nick Bowler <nbowler@elliptictech.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: John Hughes <john@calvaedi.com>, John Hughes <john@calva.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket
 expiry. Try 2 with added man pages.
Message-ID: <20111118204728.GA5761@elliptictech.com>
References: <4EC66D12.2090505@Calva.COM>
 <1321641333.2653.15.camel@lade.trondhjem.org>
 <4EC6AFA9.9000705@calvaedi.com>
 <1321648435.2653.53.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321648435.2653.53.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-18 22:33 +0200, Trond Myklebust wrote:
> On Fri, 2011-11-18 at 20:19 +0100, John Hughes wrote: 
> > On 11/18/2011 07:35 PM, Trond Myklebust wrote:
> > > On Fri, 2011-11-18 at 15:34 +0100, John Hughes wrote:
> > >    
> > >> Description: Add "-e" (ticket expiry is error) option to rpc.gssd
> > >>    In kernels starting around 2.6.34 the nfs4 server will block all I/O
> > >>    when a user ticket expires.  In earlier kernels the I/O would fail
> > >>    with an EACCESS error.  This patch adds a "-e" option to rpc.gssd
> > >>    which allow the earlier behaviour (EKEYEXPIRED is converted to
> > >>    EACCESS).  This behaviour is particularly useful when user home
> > >>    directories are nfs4 mounted with krb5 security - if the user is
> > >>    absent from their workstation for long enough for the ticket to
> > >>    expire a new ticket will be obtained (via pam_krb5) by the screen
> > >>    unlock process.
> > >>      
> > > You need a big fat warning somewhere that enabling this option WILL
> > > cause data corruption...
> > >    
> > Why?
> > 
> > Because some process may get the EACCES error half way through it's 
> > operation.
> 
> No. Because the process can receive a reply to the write() syscall that
> indicates that the data is safe, but the EKEYEXPIRED error will cause
> the data to be lost when the client tries to actually commit the data to
> disk.

But on a local disk, a successful return from the write syscall doesn't
mean "the data is safe".  It seems odd to me that NFS should provide
this guarantee while a local disk does not.

Is this guarantee documented anywhere?

Cheers,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
