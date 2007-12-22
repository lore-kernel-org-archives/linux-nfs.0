From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux client misses lack of open-confirm?
Date: Sat, 22 Dec 2007 10:27:29 -0500
Message-ID: <1198337249.7741.52.camel@heimdal.trondhjem.org>
References: <476C8F4F.7080100@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:53056 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751302AbXLVP1e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Dec 2007 10:27:34 -0500
In-Reply-To: <476C8F4F.7080100@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2007-12-21 at 23:15 -0500, Jeff Garzik wrote:
> While debugging my NFS server, I may have caught a Linux client bug.
> 
> My server is currently buggy, in that, it never sets the 
> OPEN4_RESULT_CONFIRM bit after an OPEN with a new owner.  Shockingly, I 
> can pass ~530 pynfs tests, fsx-linux [Linux v4 client], and build a 
> kernel [Linux v4 client] even with such brokenness.  ;-)
> 
> Anyway, the Linux NFSv4 client (2.6.24-rc6) seems quite happy with this 
> state of affairs, right until CLOSE time, when it passes "seqid + 2" to 
> my server rather than the expected "seqid + 1".
> 
> Though I am quite happy that Linux managed to workaround my stupid 
> server and store data successfully _anyway_, I thought it was worth 
> commenting.  I was assuming either
> 
> 	a) Linux would notice the lack of OPEN4_RESULT_CONFIRM and
> 	   complain accordingly, or,
> 
> 	b) Linux would generate a correct seqid, taking into account
> 	   the fact that it did not issue OPEN_CONFIRM.
> 
> As you can see from the wireshark-0.99.7-2.fc8 binary dump at
> 
> 	http://gtf.org/garzik/misc/dump.bz2 (33k compressed)
> 
> we see many examples of
> 
> 	C:	OPEN	(seqid == 0)
> 	S:	NFS4_OK
> 
> 	C:	[perhaps some intervening READ or WRITE or *ATTR]
> 	S:	[replies as expected]
> 
> 	C:	CLOSE	(seqid == 2)
> 	S:	NFS4ERR_BAD_SEQID
> 
> If you feel this behavior is fine given a broken server, that's cool... 
>   I just figured I would post in case somebody cared about this data point.

Hmm... That's not good. It is perfectly legal for a server to not
request OPEN4_RESULT_CONFIRM (although it is probably not a very good
idea), and the client should be able to cope with that.

I'll have a look at what is going on there.

> P.S.  I really really hate stateid/seqids at this point.  RFC 
> nonwithstanding, they are basically undocumented.  I am reduced to 
> poking through NFSv4 WG archives and Linux kernel code to find out what 
> my server should be doing.  pynfs is no help here, either.

The primary function of seqids is to allow the server to distinguish
replayed non-idempotent RPC requests from new requests, so their
properties are really quite simple:

      * If the seqid presented by the client is in sequence, then the
        server is supposed to handle the request.
      * If the seqid matches that of the last request, then the server
        is supposed to replay the reply.
      * If the seqid is completely out of sequence, then the server
        should return the BAD_SEQID error.

As for stateids, their purpose is to allow the server to figure out to
which client it is talking, and to track what state the client thinks it
is holding. Apart from the seqid field (which is there in order to track
the ordering of OPEN requests), a stateid is an opaque structure.
The only really important requirement here is that you need to be able
to distinguish stale state from valid state so that you can fence off
RPC requests that refer to stale locks.

Cheers
  Trond

