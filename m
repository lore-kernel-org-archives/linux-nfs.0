From: "Steve French (smfltc)" <smfltc@us.ibm.com>
Subject: Re: [RFC PATCH 0/9] sunrpc: teach the SUNRPC layer how to speak SMB
Date: Mon, 28 Sep 2009 13:40:23 -0500
Message-ID: <4AC10317.5090403@us.ibm.com>
References: <mailman.1290.1254136357.2670.linux-cifs-client@lists.samba.org> <4AC0CB04.9070502@us.ibm.com> <20090928115427.4103826e@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: Jeff Layton <jlayton@redhat.com>,
	linux-cifs-client@lists.samba.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:55115 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320AbZI1Sll (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2009 14:41:41 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8SIkToa024939
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2009 14:46:29 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8SIfi9M149660
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2009 14:41:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8SIfiLm027985
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2009 14:41:44 -0400
In-Reply-To: <20090928115427.4103826e-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:
> On Mon, 28 Sep 2009 09:41:08 -0500
> "Steve French (smfltc)" <smfltc@us.ibm.com> wrote:
>
>   
>>>> This patchset is still preliminary and is just an RFC...
>>>>
>>>> First, some background. When I was at Connectathon this year, Trond
>>>> mentioned an interesting idea to me. He said (paraphrasing):
>>>>
>>>> "Why doesn't CIFS just use the RPC layer for transport? It's very
>>>> efficient at shoveling bits out onto the wire. You'd just need to
>>>> abstract out the XDR/RPC specific bits."
>>>>
>>>>     
>>>>         
>> My first reaction is that if you abstract out XDR/RPC specific parts of 
>> SunRPC it isn't SunRPC,
>> just a scheduler on top of tcp (not a bad thing in theory).   Pulling 
>> out the two key pieces from
>> SunRPC:
>>     - asynchronous event handling and scheduling
>>     - upcall for credentials
>> could be useful, but does add a lot of complexity.   If there is a way 
>> to use just the async
>> scheduling (and perhaps upcall) out of SunRPC, that part sounds fine as 
>> long as it
>> can skip the encoding/decoding and just pass in a raw kvec containing 
>> the SMB
>> header and data.
>>
>>     
>
> Well, the sunrpc layer currently contains a lot of pieces:
>
> 1) client side call/response handling (clnt routines)
> 2) server side call/response handling (svc routines)
> 3) XDR encoding and decoding routines (including crypto signatures, etc)
>
> ...the idea is to hook up new encoding and decoding routines and to add
> a new "transport class" which will make the client-side scheduler handle
> SMB/SMB2 properly.
>
> We'll also eventually have to add new authentication/credential
> "classes" too. I haven't researched that yet in any real depth, so I
> can't state much about how difficult it'll be.
>
>   
>>>> CIFS in particular is also designed around synchronous ops, which
>>>> seriously limits throughput. Retrofitting it for asynchronous operation
>>>> will be adding even more kludges. 
>>>>     
>>>>         
>> There are only three operations that we can send asynchronous today, all 
>> of which require
>> special case handling in the VFS already:
>>     - readpages
>>    - writepages
>>    - blocking locks
>> (and also directory change notification which we and nfs don't do).   I 
>> think the "slow_work"
>> mechanism is probably sufficient for these cases already.
>>
>>     
>
> The problem is that rolling a mechanism to handle asynchronous ops is
> difficult to get right. I think it makes a lot of sense to reuse a
> proven engine here. It also makes a lot of sense to implement
> synchronous ops on top of an asynchronous infrastructure. RPC does this
> under the hood, and so did smbfs.
>
> What you're proposing, in effect, is to do this in reverse -- implement
> an asynchronous transport engine using synchronous ops and offloading
> the background parts onto threads. That's possible I suppose, but it
> means you have a lot of tasks sleeping in the kernel and waiting for
> stuff to happen.
>
>   
I don't think it changes the number of tasks sleeping.   For sync 
operations it doesn't
change how many tasks that are sleeping.   For async operations, you no 
longer have a
task sleeping in cifs_writepages or cifs_readpages, but do have the 
ability to dispatch
a decode routine when the SMB Write or Read response is returned (may or
may not have a pool to do this).   Seems like about the same number of 
task (possibly
less).   Moving to all asynchronous operations under open, unlink, close 
doesn't reduce
the number of sleeping tasks (it may increase it or stay the same).
>>>>  works in our favor...
>>>> ------------------------------------------------------------------------
>>>> Q: can we hook up cifs or smbfs to use this as a transport?
>>>>
>>>> A: Not trivially. CIFS in particular is not designed with each call
>>>> having discrete encode and decode functions. They're sort of mashed
>>>>     
>>>>         
>> We certainly don't want to move to an abstract encoding mechanism, 
>> especially for SMB2
>> where there is only one encoding of wire operations, and no duplicate 
>> requests due
>> to 20 years of dialects. I can see an argument for abstract encoding 
>> for requests
>> like SMB open, vs. SMB OpenX vs. SMB NTCreateX but this would be harder or
>> to abstract and has to be done case by case anyway due to differences in
>> field length, missing fields, different compensations.  It is not
>> like the simpler NFS case where encoding involves endian conversion etc.
>>
>>     
>
> I'm not sure what you mean by this. Assembling an SMB header and call
> is very similar to assembling an RPC header and call. There are
> differences of course, but they aren't that substantial.
>
> SMB does introduce some more interesting wrinkles. For instance, since
> state is tied up with the actual socket connection, we'll probably need
> callbacks into the fs for socket state changes. That doesn't have much
> to do with how you abstract out the encoding and decoding though.
>
>   
>>>> ------------------------------------------------------------------------
>>>> Q: could we use this as a transport layer for a smb2fs ?
>>>>
>>>> A: Yes, I think so. This particular prototype is build around SMB1, but
>>>> SMB2 could be supported with only minor modifications. One of the
>>>> reasons for sending this patchset now before I've built a filesystem on
>>>> top of it is because I know that SMB2 work is in progress. I'd like to
>>>> see it based around a more asynchronous transport model, or at least
>>>> built with cleaner layering so that we can eventually bolt on a different
>>>> transport layer if we so choose.
>>>>     
>>>>         
>> Amost all the ops use "send_receive"  already - so there is no need to 
>> change the code much above
>> that if you want to experiment with changing the transport.   I like the 
>> idea of the
>> abtraction of async operations, and creating completion routines (and an 
>> async send
>> abstraction) for readpages,  writepages and directory change 
>> notification would make sense.
>> but in both cifs and smb2, the 95% of the operations that must be 
>> synchronous in
>> the VFS (open, lookup, unlink, create etc.) can already be hooked up to 
>> any transport
>> as long as it can send a kvec contain fs data and return a response 
>> (like the "send_receive"
>> and equivalent).
>>
>>     
>
> The problem with the send_receive interface is that it assumes that the
> encoding, send and decoding will be done by the same task. I think that
> assumption will greatly limit this code later and force you to rely on
> workarounds (like slow_work) to get asynchronous behavior.
>
> At the very least, I suggest splitting off the decode portions into
> separate functions. That at least should allow you the ability later to
> offload that part to other tasks (similar to how async tasks get
> offloaded to rpciod).
>
>   
That (splitting decode into a distinct helper) makes sense (at least for 
async capable ops,
in particular write, read and directory change notification and byte 
range locks).  The
"smb_decode_write_response" case is a particularly simple and useful one 
to do and would
be an easy one to do as a test.   I think the prototype patches for 
async write that someone did
for cifs a few years ago did that.
>> The idea of doing abstract translation and encoding of SMB protocol frames
>> does seem overengineered and probably would make it harder to 
>> read/understand
>> the setup of certain complex request frames which are quite different from
>> Samba to Windows.    As another example, generalized, abstract SMB frame
>> conversion isn't being done in Samba 3 for example, and with only
>> 19 requests in SMB2 it makes even less sense.   On the client, since
>> we have control over which types of requests we send, our case
>> is simpler than for the server for sending requests, but in
>> response processing since we have to work around server bugs, xdr like
>> decoding of SMB responses could get harder still.
>>
>>     
>
> Again, I don't see SMB as being that different from NFS in this regard.
> You have a transport header (similar to the fraghdr with NFS TCP
> transport), then a protocol header (the SMB/SMB2 header), and then
> call-specific information. RPC/NFS works exactly the same way.
>
>   
NFS and CIFS/SMB2 seem pretty different to me in this regard.   CIFS and 
SMB2
are much simpler - for these once protocols unlike nfs,  after you assemble
the CIFS or SMB2 header (possibly with a data area as in SMB Write)
you simply add a 4 byte length (actually 3 byte length, 0 byte 0) and
you send it - no endian conversions, xdr, no adding 80 bytes or so rpc 
prefix. 
SunRPC adds a whole layer (not just a length field) with credentials.   
SunRPC
typically adds 80 bytes (or more depending on auth flavor) before the 
nfs frame
(cifs and smb2 frame don't need this, so the net/sunrpc code which 
handles the
80 bytes or so of rpc header before the network fs frame
is not used for the cifs code)

In SMB2 the pacing is part of the SMB packet, not the transport packet, 
and in
SMB2 any reconnection code which would be built into the proposed modified
SunRPC transport would probably have to be aware of the new handle types
and locking operations and state that have been added in SMB2.1 which may
break the abstraction between network fs and SunRPC transport

> The code I've proposed more or less has abstractions along those lines.
> There's:
>
> transport class -- (net/sunrpc/xprtsmb.c)
> header encoding/decoding -- (net/sunrpc/smb.c)
>
> ...the other parts will be implemented by the filesystem (similar to
> how fs/nfs/nfs?xdr.c work).
>
>   
>> I like the idea of the way SunRPC keeps task information, and it may 
>> make it easier
>> to carry credentials around (although I think using Dave Howell's key 
>> management code
>> might be ok instead to access Winbind).   I am not sure how easy it 
>> would be to tie
>> SunRPC credential mapping to Winbind but that could probably be done.  I 
>> like the
>> async scheduling capability of SunRPC although I suspect that it is a 
>> factor in
>> a number of the (nfs client) performance problems we have seen so may 
>> need more work.
>> I don't like adding (in effect) an extra transport and "encoding layer" 
>> though to
>> protocols (cifs and smb2).   NFS since it is built on SunRPC on the 
>> wire, required
>> such a layer, and it makes sense for NFS to layer the code, like their 
>> protocol,
>> over SunRPC.   CIFS and SMB2 don't require (or even allow) XDR translation,
>> variable encodings, and SunRPC encapsulation so the idea of abstracting the
>> encoding of something that has a single defined encoding seems wrong.
>>     
>
> I'm not sure I understand this last comment. CIFS/SMB2 and NFS are just
> not that different in this regard. Either way you have to marshal up
> the buffer correctly before you send it, and decode it properly.
>
>   

As an example of one of the more complicated cases for cifs (setting a 
time field).  
The code looks something like this and is very straightforward to see where
the "linux field" is being put into the packet - and to catch errors in 
size or
endianness.   Most cases are simpler for cifs.

struct file_basic_info buf;  /* the wire format of the file basic info 
SMB info level */

buf->LastAccessTime = 0;  /* we can't set access time to Windows */
buf->LastWriteTime = cpu_to_le64(cifs_UnixTimeToNT(attrs->ia_atime));
(followed by a few similar assignment statements for the remaining fields)

then send the SMB header followed by the buffer.   There is no marshalling
or xdr conversion needed.   One thing I like about this approach is that
"sparse" (make modules C=1) immediately catches any mismatch
between the wire format (size or endianness) and the vfs data
structure element being put in the frame.

Looking at nfs4xdr.c as an example for comparison, it is much harder to 
see the actual line
where a bigendian (or littlenedian) 64 bit quantity is being put into 
the request frame.

Splitting encode and decode routines probably would make code more
reasonable - but converting from a "linux file system thing" to an 
abstract structure
and then to one of many wire possibilities for a frame - doesn't make 
much sense
for the case where there is only one wire encoding (SMB2) or for cases
where a single operation maps to more than one frame in some dialects
but not others (as in SMB) and so can't be encoded abstractly.
