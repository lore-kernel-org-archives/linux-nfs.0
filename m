Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19076 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752101Ab1KRVEB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 16:04:01 -0500
Message-ID: <1321650239.2653.68.camel@lade.trondhjem.org>
Subject: Re: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket
 expiry. Try 2 with added man pages.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: John Hughes <john@calvaedi.com>, John Hughes <john@calva.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Fri, 18 Nov 2011 23:03:59 +0200
In-Reply-To: <20111118205749.GA1680@umich.edu>
References: <4EC66D12.2090505@Calva.COM>
	 <1321641333.2653.15.camel@lade.trondhjem.org>
	 <4EC6AFA9.9000705@calvaedi.com>
	 <1321648435.2653.53.camel@lade.trondhjem.org>
	 <20111118205749.GA1680@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-11-18 at 15:57 -0500, Jim Rees wrote: 
> Trond Myklebust wrote:
> 
>   On Fri, 2011-11-18 at 20:19 +0100, John Hughes wrote: 
>   > On 11/18/2011 07:35 PM, Trond Myklebust wrote:
>   > > On Fri, 2011-11-18 at 15:34 +0100, John Hughes wrote:
>   > >    
>   > >> Description: Add "-e" (ticket expiry is error) option to rpc.gssd
>   > >>    In kernels starting around 2.6.34 the nfs4 server will block all I/O
>   > >>    when a user ticket expires.  In earlier kernels the I/O would fail
>   > >>    with an EACCESS error.  This patch adds a "-e" option to rpc.gssd
>   > >>    which allow the earlier behaviour (EKEYEXPIRED is converted to
>   > >>    EACCESS).  This behaviour is particularly useful when user home
>   > >>    directories are nfs4 mounted with krb5 security - if the user is
>   > >>    absent from their workstation for long enough for the ticket to
>   > >>    expire a new ticket will be obtained (via pam_krb5) by the screen
>   > >>    unlock process.
>   > >>      
>   > > You need a big fat warning somewhere that enabling this option WILL
>   > > cause data corruption...
>   > >    
>   > Why?
>   > 
>   > Because some process may get the EACCES error half way through it's 
>   > operation.
>   
>   No. Because the process can receive a reply to the write() syscall that
>   indicates that the data is safe, but the EKEYEXPIRED error will cause
>   the data to be lost when the client tries to actually commit the data to
>   disk.
> 
> The write() syscall doesn't indicate whether the data is safe or not.  That
> would be the close() syscall.

fsync(). Which may succeed if the user renews their ticket first.
However you may still have data loss if dirty data has been lost because
of EKEYEXPIRED returns on the WRITE RPC call...

Also, for the fsync() to return EKEYEXPIRED _after_ the user has renewed
their ticket would seem counter-intuitive to most people.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

