From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: [PATCH 3/6] nfs-utils: skip getaddrinfo in create_auth_rpc_client
	unless we need port
Date: Mon, 6 Apr 2009 18:33:36 -0400
Message-ID: <4d569c330904061533r5e2182bai7b777b91563293a@mail.gmail.com>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
	 <1238595845-2186-4-git-send-email-jlayton@redhat.com>
	 <F913F7D5-DCEE-4F40-B9C8-52DC1053A61A@oracle.com>
	 <20090401134739.01b72029@barsoom.rdu.redhat.com>
	 <32D01620-325D-4D82-81EF-8584134BC7DC@oracle.com>
	 <20090403150415.3586bba3@tleilax.poochiereds.net>
	 <194FD47F-E529-48BD-A9BC-4CA39D9A67FB@oracle.com>
	 <20090406112106.6b29e2b0@tleilax.poochiereds.net>
	 <378C4858-3AC9-45C2-89D1-DF93F4147262@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:59044 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758014AbZDFWdi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Apr 2009 18:33:38 -0400
Received: by yw-out-2324.google.com with SMTP id 5so2344992ywb.1
        for <linux-nfs@vger.kernel.org>; Mon, 06 Apr 2009 15:33:36 -0700 (PDT)
In-Reply-To: <378C4858-3AC9-45C2-89D1-DF93F4147262@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 6, 2009 at 11:46 AM, Chuck Lever <chuck.lever@oracle.com> w=
rote:
> On Apr 6, 2009, at 11:21 AM, Jeff Layton wrote:
>>
>> On Mon, 6 Apr 2009 11:03:11 -0400
>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>>> On Apr 3, 2009, at 3:04 PM, Jeff Layton wrote:
>>>>
>>>> On Wed, 1 Apr 2009 14:01:30 -0400
>>>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>
>>>>> As far as I understand it, the ai_socktype and ai_protocol fields=
 are
>>>>> used to return the values needed for subsequent socket(2)/bind(2)
>>>>> system calls. =A0In this case you are not using these fields from=
 the
>>>>> results...
>>>>>
>>>>> If ai_protocol is zero, then getaddrinfo(3) assumes you want one =
copy
>>>>> of the address for each supported protocol type, so it returns th=
ree
>>>>> structures (one for IPPROTO_UDP, one for IPPROTO_TCP, and one wit=
h a
>>>>> zero protocol number). =A0The contents, except for the socktype a=
nd
>>>>> protocol fields, are the same for each.
>>>>
>>>> Hypothetical situation...
>>>>
>>>> Suppose there is a service in /etc/services that has a different p=
ort
>>>> number for tcp than for udp:
>>>>
>>>> fooserv =A0 =A0 =A0 =A0 50001/tcp
>>>> fooserv =A0 =A0 =A0 =A0 50002/udp
>>>>
>>>> You're saying that getaddrinfo will return the same port number in=
 all
>>>> of the returned structures? Won't that mean that one of the port
>>>> numbers
>>>> is wrong? That seems broken if so...
>>>
>>> I was trying to describe observed behavior here -- it's pretty
>>> unlikely that there will be different port numbers in these returne=
d
>>> structures. =A0It's difficult to say precisely how this is supposed=
 to
>>> behave based on the man page or even browsing the glibc source code
>>> for a few minutes.
>>>
>>> It's certainly possible to set up /etc/services as you suggest, but
>>> there is an IANA policy to assign the same port for both transports=
=2E
>>> As near as I can tell the reason we have the transport listed in /e=
tc/
>>> services at all is because some protocols support only one transpor=
t.
>>> So IMO it would be quite unlikely to encounter such a case where th=
e
>>> port number depended on the transport.
>>>
>>>> If that's not the case, then I think we need to at least set the
>>>> ai_protocol in the hints.
>>>
>>> Perhaps that's true. =A0What are the expected values of @service ?
>>
>> I've only ever seen "nfs" here, but I guess you could use this with
>> others. Maybe "nfsacl" too?
>
> What's even stranger is that one is supposed to use rpcbind to figure=
 out
> what NFS port to use, not /etc/services.
>
>> IANA might not set different port like this, but there's nothing
>> that stops someone from doing this at their site.
>
> True, but one might expect that setting the NFS service port via rpc.=
nfsd on
> the server would make gssd use that port too. =A0I guess that's why t=
he port
> number is now passed up from the kernel.
>
>> I agree that it's an unlikely (and somewhat pathological) situation,
>> but it's easy to deal with -- just set the protocol in the hints. I'=
ve
>> confirmed that it makes getaddrinfo do the right thing.
>
> That's good. =A0I think we need to understand exactly what this is su=
pposed to
> do, though. =A0Should we use an rpcbind call here instead? =A0This is=
 _rpc_
> gssd, after all. =A0If it's OK as it stands, then I think some commen=
ts about
> why this works this way are in order :-)
>
> Kevin, can you enlighten us?

Here is what I recall.  For v4 we are not supposed to need a
portmap/rpcbind call anymore (or at least an "extra" one from gssd).
So for cases where we don't get a port number in the upcall, we use
the normal port for "nfs".  If we get a port number in the upcall, we
use it.  (That may be the normal port, or a different one.  I'm not
sure where that value comes from.)

I recall there were complaints about the portmap call.  That resulted
in:  http://osdir.com/ml/linux.nfsv4/2005-12/msg00025.html

HTH a little?

K.C.
