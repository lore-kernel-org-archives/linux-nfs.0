From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Linux client misses lack of open-confirm?
Date: Sat, 22 Dec 2007 21:05:44 -0500
Message-ID: <476DC278.7090309@garzik.org>
References: <476C8F4F.7080100@garzik.org> <1198337249.7741.52.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35793 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751200AbXLWCFr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Dec 2007 21:05:47 -0500
In-Reply-To: <1198337249.7741.52.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Fri, 2007-12-21 at 23:15 -0500, Jeff Garzik wrote:
>> While debugging my NFS server, I may have caught a Linux client bug.
>>
>> My server is currently buggy, in that, it never sets the 
>> OPEN4_RESULT_CONFIRM bit after an OPEN with a new owner.  Shockingly, I 
>> can pass ~530 pynfs tests, fsx-linux [Linux v4 client], and build a 
>> kernel [Linux v4 client] even with such brokenness.  ;-)
>>
>> Anyway, the Linux NFSv4 client (2.6.24-rc6) seems quite happy with this 
>> state of affairs, right until CLOSE time, when it passes "seqid + 2" to 
>> my server rather than the expected "seqid + 1".
>>
>> Though I am quite happy that Linux managed to workaround my stupid 
>> server and store data successfully _anyway_, I thought it was worth 
>> commenting.  I was assuming either
>>
>> 	a) Linux would notice the lack of OPEN4_RESULT_CONFIRM and
>> 	   complain accordingly, or,
>>
>> 	b) Linux would generate a correct seqid, taking into account
>> 	   the fact that it did not issue OPEN_CONFIRM.
>>
>> As you can see from the wireshark-0.99.7-2.fc8 binary dump at
>>
>> 	http://gtf.org/garzik/misc/dump.bz2 (33k compressed)
>>
>> we see many examples of
>>
>> 	C:	OPEN	(seqid == 0)
>> 	S:	NFS4_OK
>>
>> 	C:	[perhaps some intervening READ or WRITE or *ATTR]
>> 	S:	[replies as expected]
>>
>> 	C:	CLOSE	(seqid == 2)
>> 	S:	NFS4ERR_BAD_SEQID
>>
>> If you feel this behavior is fine given a broken server, that's cool... 
>>   I just figured I would post in case somebody cared about this data point.
> 
> Hmm... That's not good. It is perfectly legal for a server to not
> request OPEN4_RESULT_CONFIRM (although it is probably not a very good
> idea), and the client should be able to cope with that.

If you want to reproduce, my server is open (though largely unannounced, 
since its still in initial coding phase): 
git://git.kernel.org/pub/scm/daemon/nfs/nfs4-ram.git

Commit b3f602203ab023aa559c4db5449448b9c7044f36 (HEAD~2 currently) can 
reproduce the behavior nicely.

The server is currently a zero-configuration-file RAM server, so its 
easy to test: just build and run (./nfs4_ramd).  It binds to port 2049 
with an empty filesystem, each time it is started.  (--help for 
alternate port or other options)


> I'll have a look at what is going on there.
> 
>> P.S.  I really really hate stateid/seqids at this point.  RFC 
>> nonwithstanding, they are basically undocumented.  I am reduced to 
>> poking through NFSv4 WG archives and Linux kernel code to find out what 
>> my server should be doing.  pynfs is no help here, either.
> 
> The primary function of seqids is to allow the server to distinguish
> replayed non-idempotent RPC requests from new requests, so their
> properties are really quite simple:
> 
>       * If the seqid presented by the client is in sequence, then the
>         server is supposed to handle the request.
>       * If the seqid matches that of the last request, then the server
>         is supposed to replay the reply.
>       * If the seqid is completely out of sequence, then the server
>         should return the BAD_SEQID error.
> 
> As for stateids, their purpose is to allow the server to figure out to
> which client it is talking, and to track what state the client thinks it
> is holding. Apart from the seqid field (which is there in order to track
> the ordering of OPEN requests), a stateid is an opaque structure.
> The only really important requirement here is that you need to be able
> to distinguish stale state from valid state so that you can fence off
> RPC requests that refer to stale locks.

Yeah I figured out the purpose pretty quickly.  The thing I missed was 
that the seqid is per-lockowner, and not per-openfile.  No surprise 
things got weird, when I coded a server following that logic...

Plus there are a ton of undocumented -ordering- constraints you must 
follow, with regards to validating seqid/stateid and then returning the 
correct error.

Thanks for the response!  Hope my buggy server helps you track down 
client problems ;-)

	Jeff


