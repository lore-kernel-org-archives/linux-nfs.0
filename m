Return-Path: linux-nfs-owner@vger.kernel.org
Received: from isrv.corpit.ru ([86.62.121.231]:48267 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728Ab2E3HLp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 May 2012 03:11:45 -0400
Message-ID: <4FC5C82E.4020806@msgid.tls.msk.ru>
Date: Wed, 30 May 2012 11:11:42 +0400
From: Michael Tokarev <mjt@tls.msk.ru>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, Linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: 3.0+ NFS issues
References: <4FBF2C57.3070203@msgid.tls.msk.ru> <20120529152416.GC3441@fieldses.org>
In-Reply-To: <20120529152416.GC3441@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 29.05.2012 19:24, J. Bruce Fields wrote:
> On Fri, May 25, 2012 at 10:53:11AM +0400, Michael Tokarev wrote:
>> I updated my nfs server machine to kernel 3.0, and
>> noticed that its main usage become, well, problematic.
>>
>> While trying to dig deeper, I also found a few other
>> interesting issues, which are mentioned below.
>>
>> But first thing first: nfs.
>>
>> i686pae kernel, lots of RAM, Atom-based (cedar trail)
>> machine with usual rtl8169 NIC.  3.0 or 3.2 kernel
>> (I will try current 3.4 but I don't have much hopes
>> there).  NFSv4.
>>
>> When a client machine (also 3.0 kernel) does some reading,
>> the process often stalls somewhere in the read syscall,
>> or, rarer, during close, for up to two MINUTES.  During
>> this time, the client (kernel) reports "NFS server <foo>
>> does not respond" several times, and finally "NFS server
>> <foo> ok", client process "unstucks" from the read(2),
>> and is able to perform a few more reads till the whole
>> thing repeats.
> 
> You say 2.6.32 was OK; have you tried anything else between?

Well, I thought bisecting between 2.6.32 and 3.0 will be quite
painful...  But I'll try if nothing else helps.  And no, I haven't
tried anything in-between.

> And you're holding the client constant while varying only the server
> version, right?

Yes.

> Is your network otherwise working?  (E.g. does transferring a bunch of
> data from server to client using some other protocol work reliably?)

Yes, it works flawlessly, all other protocols works so far.

To the date, I resorted to using a small webserver plus wget as an ugly
workaround for the problem - http works for reads from the server, while
nfs works for writes.

> Is there anything happening on the network during these stalls?  (You
> can watch the network with wireshark, for example.)

The network load is irrelevant - it behaves the same way with
100% idle network or with network busy doing other stuff.

> Does NFSv3 behave the same way?

Yes it does.  With all NFSDs on server eating all available CPUs for
quite some time, and with being "ghosts" for perf top.

And with the client being unkillable again.

Can at least the client be made interruptible?  Mounting with
-o intr,soft makes no visible difference...

Thanks,

/mjt
