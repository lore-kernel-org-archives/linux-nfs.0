From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: Re: stuck/hung nfsv4 mounts
Date: Mon, 03 Nov 2008 18:45:01 -0500
Message-ID: <1225755901.2247.164.camel@brian-laptop>
References: <1225724721.2247.29.camel@brian-laptop>
	 <1225731544.6958.6.camel@heimdal.trondhjem.org>
	 <1225734631.2247.76.camel@brian-laptop>
	 <4d569c330811031158r26963e0w5bcf8331e0fb14b7@mail.gmail.com>
	 <1225742958.2247.128.camel@brian-laptop>
	 <4d569c330811031228r5bb9aefs7a970303910810e2@mail.gmail.com>
	 <1225746764.2247.133.camel@brian-laptop>
	 <4d569c330811031433k7ae18d4enfbda349e8f90a951@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:4086 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbYKCXpE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2008 18:45:04 -0500
Received: from linux.interlinx.bc.ca (d193-213-184.home3.cgocable.net [67.193.213.184])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 7F02C2805
	for <linux-nfs@vger.kernel.org>; Mon,  3 Nov 2008 18:45:02 -0500 (EST)
Received: from [10.75.22.172] (brian-laptop.ilinx [10.75.22.172])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 61960800A
	for <linux-nfs@vger.kernel.org>; Mon,  3 Nov 2008 18:45:01 -0500 (EST)
In-Reply-To: <4d569c330811031433k7ae18d4enfbda349e8f90a951-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-11-03 at 17:33 -0500, Kevin Coffman wrote:
> 
> Once again, this is all from librpcsecgss.  No messages originating
> from rpc.gssd itself here.

Not sure why.  FWIW, 
> 
> > Nov  3 15:17:33 linux krb5kdc[5006]: TGS_REQ (1 etypes {1}) 10.75.22.1: ISSUE: authtime 1225740577, etypes {rep=1 tkt=1 ses=1}, brian@ILINX for nfs/linux.interlinx.bc.ca@ILINX
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]: leaving poll
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]: handling null request
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]: sname = brian@ILINX
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]: DEBUG: serialize_krb5_ctx: lucid version!
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]: doing downcall
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]: mech: krb5, hndl len: 4, ctx len 85, timeout: 2147483647, uid: 1001, gid: 1001, num aux grps: 13:
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   1) 1001
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   2) 117
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   3) 1010
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   4) 1011
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   5) 2000
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   6) 29
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   7) 20
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   8) 24
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   9) 25
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (  10) 30
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (  11) 44
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (  12) 46
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (  13) 111
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]: sending null reply
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]: writing message: ...
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]: finished handling null request
> > Nov  3 15:17:33 linux rpc.svcgssd[13724]: entering poll
> 
> If you can get
> a packet trace between the client and server during the mount /
> context negotiation, check the NULL reply from the server for this
> error code.

Well, this is just it.

# mount -t nfs4 -s -o sec=krb5i,rw,intr,rsize=8192,wsize=8192 linux:/home/share /mnt/test

on the client does not result in any NFS4 traffic between the client and
the server.  In fact if I ^C the above mount and issue it again, I don't
get another gss/svcgssd upcall.  Is there some kind of caching going on?
How can I invalidate the cache?  Probably it's moot though given that
this sequence of events is not resulting in any NFS4 traffic anyway.

This was all working before last night, then all of a sudden, it
stopped.  Nothing remarkable happened at the time that
could/should/would have caused this silliness.  ~sigh~

b.


