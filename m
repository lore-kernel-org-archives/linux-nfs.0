Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.jrc.it ([139.191.1.110]:34624 "EHLO mx2.jrc.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754128Ab1F2Prp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jun 2011 11:47:45 -0400
Received: from irelay.jrc.it (irelay.jrc.it [139.191.254.63])
	by mx2.jrc.it (LMC5614Amx2) with ESMTP id p5TEbUNE004538
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 16:37:30 +0200 (CEST)
Received: from mail-zone.jrc.it (mail-zone.jrc.it [139.191.244.42])
        by irelay.jrc.it (LMC5614Ainternal) with SMTP id p5TEbTp0002551
        for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 16:37:29 +0200 (MEST)
Content-type: text/plain; CHARSET=US-ASCII; format=flowed
Received: from email-02-ext.jrc.it ([unknown] [139.191.244.20])
 by mail-zone.jrc.it
 (Sun Java(tm) System Messaging Server 7.3-11.01 64bit (built Sep  1 2009))
 with ESMTP id <0LNK00AOW3ACWG50@mail-zone.jrc.it> for
 linux-nfs@vger.kernel.org; Wed, 29 Jun 2011 16:37:24 +0200 (CEST)
Received: from [139.191.142.132] ([unknown] [139.191.229.250])
 by email-02-ext.jrc.it
 (Sun Java(tm) System Messaging Server 7.3-11.01 64bit (built Sep  1 2009))
 with ESMTPA id <0LNK003N43AB2B20@email-02-ext.jrc.it> for
 linux-nfs@vger.kernel.org; Wed, 29 Jun 2011 16:37:24 +0200 (CEST)
Message-id: <4E0B3897.40209@jrc.ec.europa.eu>
Date: Wed, 29 Jun 2011 16:37:11 +0200
From: Franck Eyraud <franck.eyraud@jrc.ec.europa.eu>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 null request and compatibility with netapp
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Dear nfs linux list,

I have an issue with NFSv4 clients running debian with linux kernel 
version 2.6.29 and above. The NFS4 server is n a NetApp NAS.

The problem arised when, after upgrading the kernel of our machines, the 
filer started to issue a lot of these messages :

Client 1XX.1XX.2XX.73 has an authentication error 2
Client 1XX.1XX.2XX.73 is sending bad rpc requests with error: RPC version mismatch or authentication error(73)

The NetApp team analyzed the tcp trace and sent us with this answer, basically saying that the fault is from client side :

Can someone on the list confirm that their affirmations are correct ?

I already opened a bug on debian http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=632074 where they said that maybe the client behavior is not that odd with respect with the RFC standard.

---------
Tue May 24 10:05:59 MEST [vcid@s-jrciprna004p: nfsd.rpc.request.bad:warning]: Client 1XX.1XX.2XX.73 is sending bad rpc requests with error: RPC version mismatch or
authentication error(73)

We looked in the code and the (73) has no significance here and is simply the error code number for "RPC version mismatch or authentication error".

What we see is that the following occurs at the time of these errors:
- The client has an established TCP session on which it does NFSv4.
- The NFSv4 calls uses Kerberos.
- On that TCP session, the client occasionally does a NULL call.
- The filer rejects it with an authentication error (auth state 2, client must begin new session)
- The client does a new NULL call on a separate TCP session without a GSS context.
- The filer responds and a new context is established.
- The client continues on the original TCP session with the new context.

This explains why no side effect is seen: the client simply establishes a new context and continues as if nothing had happened.
We have checked through the trace for vlan 240 and the pattern is the same throughout and the error always happens for NULL calls only (occasionally two replies may be
sent in the same TCP payload, but the error is always on the NULL reply, then).
We know that some Debian kernels do not exhibit this problem at any time, but others do. This (along with the problem being tied to NULL calls only)
suggest to us that this is due to client side behaviour.

Anyway, we tried to check for the first occurrence of the error, which warrants some chronology. We'll do references per clock second for ease.
- The first client call is at 10:04:16 in an established NFS mount.
- The initial part of the trace, the client only uses TCP port 1006.
- The client uses the same GSS context, with the exception of a SETCLIENTID and a SETCLIENTID_CONFIRM call.
- At 10:05:00 the client tears down four GSS sessions (used for Kerberos) using RPCSEC_GSS_DESTROY in an NFSv4 NULL call. This is done from TCP port 1006 but for four
different contexts. None of these have been used in the trace at that point.
- The client continues with more cals on port 1006 using the the same GSS context.
- Still at 10:05:00 (frame 1982792), the client uses an NFSv4 call to do a RPCSEC_GSS_INIT to establish a new GSS context.
- The client continues using the new GSS context and does not reuse the old context.
- The sequence described above on the NULL calls start.

Looking closer at these steps, we notice something important in the NULL calls.
Above, the client destroyed four GSS contexts that were not used during the trace. However, it did not destroy the GSS context it was using for a while there.

However, we now note the client actually does a RPCSEC_GSS_DESTROY in each of the NFSv4 NULL calls where we respond with an authentication error. As the error
indicates that the client has to begin a new session, this seems like a reasonable response to the call.

So to summarize:
- The filer logs these errors when the client destroys a GSS context.
- The error message is a logical response.

The decission to tear down the GSS context is with the client. So this would seem to be a client side issue after all, which just happens to get logged on the filer.
-------------

Thank you for your help,

Franck Eyraud

