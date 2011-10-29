Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout0.thls.bbc.co.uk ([132.185.240.35]:53460 "EHLO
	mailout0.thls.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914Ab1J2AZZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Oct 2011 20:25:25 -0400
Date: Sat, 29 Oct 2011 00:25:00 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>, linux-nfs@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS4ERR_STALE_CLIENTID loop
Message-ID: <20111029002500.GA2011@rd.bbc.co.uk>
References: <20111024104042.GD32587@rd.bbc.co.uk>
 <1319455367.8505.3.camel@lade.trondhjem.org>
 <20111024131734.GE32587@rd.bbc.co.uk>
 <1319463165.2734.1.camel@lade.trondhjem.org>
 <20111024145027.GF32587@rd.bbc.co.uk>
 <1319470302.2734.4.camel@lade.trondhjem.org>
 <20111027221742.GI32587@rd.bbc.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111027221742.GI32587@rd.bbc.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* David Flynn (davidf@rd.bbc.co.uk) wrote:
> * Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
> > Do you have an example of the stateid argument's value? Does it change
> > at all between separate WRITE attempts?
> 
> Further to all this, i've just had a similar fault on another machine,

Using the same kernel, same mountpoint as before, we're currently
experiencing a loop involving NFS4ERR_STALE_CLIENTID.
Trace:
  ftp://ftp.kw.bbc.co.uk/davidf/priv/saesheil.pcap

Unfortunately, this is resulting in about 40 nodes doing their best to
kill the poor solaris server.  Generating a combined total of
250Mbit/sec towards the NFS server (collecting a little under
200Mbit/sec of replies).

Have we not heard of exponential backoff?

This seems to require major attention, given that this amounted to a
site wide DoS: going round all the machines and killing the processes
that were having major problems brought the situation back under
control.  Frankly i'd rather that you panicked the kernel than this.

Regards,
..david
