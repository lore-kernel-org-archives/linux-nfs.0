Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755371Ab0DWWJp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Apr 2010 18:09:45 -0400
Subject: Re: NFS client send out of order offsets....
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
In-Reply-To: <4BD21777.1060305@RedHat.com>
References: <4BD21777.1060305@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 23 Apr 2010 18:09:43 -0400
Message-ID: <1272060583.3019.11.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-04-23 at 17:56 -0400, Steve Dickson wrote: 
> Hey Trond (and all),
> 
> It been brought to my attention that Linux NFS clients, with big-ish 
> writes (8GB and above), quickly started sending out writes with
> out-of-order offsets... Meaning in the start of an 8GB write a 7GB offset 
> will be send and then smaller offsets, closer to the the beginning 
> of the file, will follow.
> 
> Now I realize this is perfectly fine from a protocol standpoint and (w/out 
> any on hands investigation) pretty sure it has to do with how pages are
> being kicked out of the cache (i.e. memory pressure), meaning is 
> not an NFS issue at all...  but... 
> 
> It was also point out to me that this type of out of order-ness does 
> not happen with Solaris clients and with an AIX clients there is some 
> mount option fix out of order-ness... 
> 
> So my question is there some way to tweak the client to ensure
> offset are send sequential order... 
> 
> Note this happening on a older kernel, so before I go off  and 
> "re-invent the wheel", I was wonder if other people have seen this
> issue and has it been addressed... 
> 
> tia,
> 
> steved.

The NFS layer will always write out pages in order whenever it initiates
a flush.

The problem here is the VM's use of the 'range_cyclic' writeback control
option in functions like 'balance_dirty_pages()' and in the kflush
daemons.
That neither can nor should be fixed in the NFS layer. It really needs
to be addressed in the VM.

Cheers
  Trond
