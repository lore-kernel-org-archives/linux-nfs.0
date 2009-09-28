From: "Steve French (smfltc)" <smfltc@us.ibm.com>
Subject: Re: linux-cifs-client Digest, Vol 70, Issue 25
Date: Mon, 28 Sep 2009 09:41:08 -0500
Message-ID: <4AC0CB04.9070502@us.ibm.com>
References: <mailman.1290.1254136357.2670.linux-cifs-client@lists.samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-cifs-client@lists.samba.org,
	Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:37480 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400AbZI1Omf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2009 10:42:35 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8SEZPQ4014557
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2009 10:35:25 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8SEgd3l178766
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2009 10:42:39 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8SEgal6027434
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2009 10:42:38 -0400
In-Reply-To: <mailman.1290.1254136357.2670.linux-cifs-client@lists.samba.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> This patchset is still preliminary and is just an RFC...
>>
>> First, some background. When I was at Connectathon this year, Trond
>> mentioned an interesting idea to me. He said (paraphrasing):
>>
>> "Why doesn't CIFS just use the RPC layer for transport? It's very
>> efficient at shoveling bits out onto the wire. You'd just need to
>> abstract out the XDR/RPC specific bits."
>>
>>     
My first reaction is that if you abstract out XDR/RPC specific parts of 
SunRPC it isn't SunRPC,
just a scheduler on top of tcp (not a bad thing in theory).   Pulling 
out the two key pieces from
SunRPC:
    - asynchronous event handling and scheduling
    - upcall for credentials
could be useful, but does add a lot of complexity.   If there is a way 
to use just the async
scheduling (and perhaps upcall) out of SunRPC, that part sounds fine as 
long as it
can skip the encoding/decoding and just pass in a raw kvec containing 
the SMB
header and data.

>>
>> CIFS in particular is also designed around synchronous ops, which
>> seriously limits throughput. Retrofitting it for asynchronous operation
>> will be adding even more kludges. 
>>     
There are only three operations that we can send asynchronous today, all 
of which require
special case handling in the VFS already:
    - readpages
   - writepages
   - blocking locks
(and also directory change notification which we and nfs don't do).   I 
think the "slow_work"
mechanism is probably sufficient for these cases already.

>>  works in our favor...
>> ------------------------------------------------------------------------
>> Q: can we hook up cifs or smbfs to use this as a transport?
>>
>> A: Not trivially. CIFS in particular is not designed with each call
>> having discrete encode and decode functions. They're sort of mashed
>>     
We certainly don't want to move to an abstract encoding mechanism, 
especially for SMB2
where there is only one encoding of wire operations, and no duplicate 
requests due
to 20 years of dialects.   I can see an argument for abstract encoding 
for requests
like SMB open, vs. SMB OpenX vs. SMB NTCreateX but this would be harder or
to abstract and has to be done case by case anyway due to differences in
field length, missing fields, different compensations.  It is not
like the simpler NFS case where encoding involves endian conversion etc.

>> ------------------------------------------------------------------------
>> Q: could we use this as a transport layer for a smb2fs ?
>>
>> A: Yes, I think so. This particular prototype is build around SMB1, but
>> SMB2 could be supported with only minor modifications. One of the
>> reasons for sending this patchset now before I've built a filesystem on
>> top of it is because I know that SMB2 work is in progress. I'd like to
>> see it based around a more asynchronous transport model, or at least
>> built with cleaner layering so that we can eventually bolt on a different
>> transport layer if we so choose.
>>     
Amost all the ops use "send_receive"  already - so there is no need to 
change the code much above
that if you want to experiment with changing the transport.   I like the 
idea of the
abtraction of async operations, and creating completion routines (and an 
async send
abstraction) for readpages,  writepages and directory change 
notification would make sense.
but in both cifs and smb2, the 95% of the operations that must be 
synchronous in
the VFS (open, lookup, unlink, create etc.) can already be hooked up to 
any transport
as long as it can send a kvec contain fs data and return a response 
(like the "send_receive"
and equivalent).

The idea of doing abstract translation and encoding of SMB protocol frames
does seem overengineered and probably would make it harder to 
read/understand
the setup of certain complex request frames which are quite different from
Samba to Windows.    As another example, generalized, abstract SMB frame
conversion isn't being done in Samba 3 for example, and with only
19 requests in SMB2 it makes even less sense.   On the client, since
we have control over which types of requests we send, our case
is simpler than for the server for sending requests, but in
response processing since we have to work around server bugs, xdr like
decoding of SMB responses could get harder still.

I like the idea of the way SunRPC keeps task information, and it may 
make it easier
to carry credentials around (although I think using Dave Howell's key 
management code
might be ok instead to access Winbind).   I am not sure how easy it 
would be to tie
SunRPC credential mapping to Winbind but that could probably be done.  I 
like the
async scheduling capability of SunRPC although I suspect that it is a 
factor in
a number of the (nfs client) performance problems we have seen so may 
need more work.
I don't like adding (in effect) an extra transport and "encoding layer" 
though to
protocols (cifs and smb2).   NFS since it is built on SunRPC on the 
wire, required
such a layer, and it makes sense for NFS to layer the code, like their 
protocol,
over SunRPC.   CIFS and SMB2 don't require (or even allow) XDR translation,
variable encodings, and SunRPC encapsulation so the idea of abstracting the
encoding of something that has a single defined encoding seems wrong.
