Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout0.mh.bbc.co.uk ([132.185.144.151]:37691 "EHLO
	mailout0.mh.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933606Ab1J2SDG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2011 14:03:06 -0400
Date: Sat, 29 Oct 2011 18:02:27 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>, linux-nfs@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS4ERR_STALE_CLIENTID loop
Message-ID: <20111029180227.GC2011@rd.bbc.co.uk>
References: <20111024104042.GD32587@rd.bbc.co.uk>
 <1319455367.8505.3.camel@lade.trondhjem.org>
 <20111024131734.GE32587@rd.bbc.co.uk>
 <1319463165.2734.1.camel@lade.trondhjem.org>
 <20111024145027.GF32587@rd.bbc.co.uk>
 <1319470302.2734.4.camel@lade.trondhjem.org>
 <20111027221742.GI32587@rd.bbc.co.uk>
 <20111029002500.GA2011@rd.bbc.co.uk>
 <1319909376.2760.11.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319909376.2760.11.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
> > Using the same kernel, same mountpoint as before, we're currently
> > experiencing a loop involving NFS4ERR_STALE_CLIENTID.
...
> The problem seems like a split-brain issue on the server... On the one
> hand, it is happily telling us that our lease is OK when we RENEW. Then
> when we try to use said lease in an OPEN, it is replying with
> STALE_CLIENTID.

Thank you for the quick update, especially at the weekend.  I'm
wondering if it is possible that the STALE_CLIENTID issue is a by-product
of the BAD_STATEID issue from earlier.  We have observed several times
the BAD_STATEID loop, but the CLIENTID problem only seemed to occur when
all 40+ nodes were all showing problems.

After killing off sufficient processes, the some of the machines then
recovered of their own accord.  So your conclusion that there is a
server issue sounds reasonable.

On any such possible backoff, the previous case was with quite small
requests in quite a tight loop that seemed to cause the server grief.
This morning, a machine with a 10GbE interface had a BAD_STATEID issue
but involving some much larger writes[1], resulting in 1.6Gbit/sec from
that machine alone.  Thankfully there was only a second machine with
1GbE interfaces bringing the total up to 2.5Gbit/sec.

It is this ability for a group of clients to make matters worse that
is just as bad as any fault with Solaris.

(In a similar vein, it can be just as frustrating trying to get a client
to stop looping like this - it is often impossible to kill the process
that triggered the problem; for these, we had to resort to deleting
the files using NFSv3 (which was working quite happily))

Thank you again,
..david

[1] Capture: ftp://ftp.kw.bbc.co.uk/davidf/priv/waquahso.pcap
