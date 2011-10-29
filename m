Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17536 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933496Ab1J2R3i convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2011 13:29:38 -0400
Subject: Re: NFS4ERR_STALE_CLIENTID loop
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: David Flynn <davidf@rd.bbc.co.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Date: Sat, 29 Oct 2011 19:29:36 +0200
In-Reply-To: <20111029002500.GA2011@rd.bbc.co.uk>
References: <20111024104042.GD32587@rd.bbc.co.uk>
	 <1319455367.8505.3.camel@lade.trondhjem.org>
	 <20111024131734.GE32587@rd.bbc.co.uk>
	 <1319463165.2734.1.camel@lade.trondhjem.org>
	 <20111024145027.GF32587@rd.bbc.co.uk>
	 <1319470302.2734.4.camel@lade.trondhjem.org>
	 <20111027221742.GI32587@rd.bbc.co.uk> <20111029002500.GA2011@rd.bbc.co.uk>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1319909376.2760.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2011-10-29 at 00:25 +0000, David Flynn wrote: 
> * David Flynn (davidf@rd.bbc.co.uk) wrote:
> > * Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
> > > Do you have an example of the stateid argument's value? Does it change
> > > at all between separate WRITE attempts?
> > 
> > Further to all this, i've just had a similar fault on another machine,
> 
> Using the same kernel, same mountpoint as before, we're currently
> experiencing a loop involving NFS4ERR_STALE_CLIENTID.
> Trace:
>   ftp://ftp.kw.bbc.co.uk/davidf/priv/saesheil.pcap
> 
> Unfortunately, this is resulting in about 40 nodes doing their best to
> kill the poor solaris server.  Generating a combined total of
> 250Mbit/sec towards the NFS server (collecting a little under
> 200Mbit/sec of replies).
> 
> Have we not heard of exponential backoff?
> 
> This seems to require major attention, given that this amounted to a
> site wide DoS: going round all the machines and killing the processes
> that were having major problems brought the situation back under
> control.  Frankly i'd rather that you panicked the kernel than this.

OK. This is the first time I've seen this tcpdump.

The problem seems like a split-brain issue on the server... On the one
hand, it is happily telling us that our lease is OK when we RENEW. Then
when we try to use said lease in an OPEN, it is replying with
STALE_CLIENTID.

IOW: This isn't a problem I can fix on the client whether or not I add
exponential backoff. The problem needs to be addressed on the server by
the Solaris folks....

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

