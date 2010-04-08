From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs + Reiser4
Date: Thu, 08 Apr 2010 17:33:51 -0400
Message-ID: <1270762431.7276.28.camel@localhost.localdomain>
References: <op.vaq49joctxpshh@localhost.localdomain>
	 <20100407173438.GA25614@fieldses.org> <4BBCD271.5040100@oracle.com>
	 <20100407185157.GF26072@fieldses.org> <4BBCD618.50301@oracle.com>
	 <20100407192025.GH26072@fieldses.org>
	 <1270674567.3177.2.camel@localhost.localdomain>
	 <4BBCFA28.2030101@catking.net>
	 <1270680542.6995.21.camel@localhost.localdomain>
	 <4BBE448A.3050408@catking.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:50699 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759107Ab0DHVd7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 17:33:59 -0400
In-Reply-To: <4BBE448A.3050408-B3jsHfKwJfLR7s880joybQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-04-08 at 23:03 +0200, gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org wrote: 
> OK , I just tried this on ext3 partition and I'm not seeing the erratic 
> behaviour.  So this may be down to a bad reaction between nfs and R4 as 
> I suspected.
> 
> However, I am still seeing vers=2 , does this indicate some problem in 
> initial negociation and a drop back to nfs2 ?
> 
> /dev/root on / type nfs 
> (rw,vers=2,rsize=4096,wsize=4096,namlen=255,hard,nointr,nolock,proto=udp,timeo=11,retrans=3,sec=sys,addr=192.168.1.3) 

I believe that nfsroot always defaults to vers=2 and udp unless you
explicitly set the 'nfsvers=3' and 'proto=tcp' mount options.

It also defaults to 4k rsize and wsize (set 'rsize=0,wsize=0' if you
want the client to autonegotiate their values)...

Cheers
  Trond

