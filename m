Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:43869 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbeEJTHS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2018 15:07:18 -0400
Received: by mail-vk0-f51.google.com with SMTP id x191-v6so1840349vke.10
        for <linux-nfs@vger.kernel.org>; Thu, 10 May 2018 12:07:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8E0A99E2-7037-4023-99F5-594430919604@oracle.com>
References: <C4BAD0ED-E05B-4A43-8A9A-51176123D6B9@oracle.com>
 <CAN-5tyH8i0hmx8nvMUXhndZE_LcGAB0mySjBpDTq7eLQ-gFgiQ@mail.gmail.com> <8E0A99E2-7037-4023-99F5-594430919604@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 10 May 2018 15:07:16 -0400
Message-ID: <CAN-5tyFQ9vbTHQJ7g4_0sVLCO2ppyTmTcrww5t_SD-x9yg6u5A@mail.gmail.com>
Subject: Re: SETCLIENTID acceptor
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 10, 2018 at 2:09 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On May 10, 2018, at 1:40 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Wed, May 9, 2018 at 5:19 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> I'm right on the edge of my understanding of how this all works.
>>>
>>> I've re-keyed my NFS server. Now on my client, I'm seeing this on
>>> vers=4.0,sec=sys mounts:
>>>
>>> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
>>> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
>>> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
>>>
>>> manet is my client, and klimt is my server. I'm mounting with
>>> NFS/RDMA, so I'm mounting hostname klimt.ib, not klimt.
>>>
>>> Because the client is using krb5i for lease management, the server
>>> is required to use krb5i for the callback channel (S 3.3.3 of RFC
>>> 7530).
>>>
>>> After a SETCLIENTID, the client copies the acceptor from the GSS
>>> context it set up, and uses that to check incoming callback
>>> requests. I instrumented the client's SETCLIENTID proc, and I see
>>> this:
>>>
>>> check_gss_callback_principal: acceptor=nfs@klimt.ib.1015granger.net, principal=host@klimt.1015granger.net
>>>
>>> The principal strings are not equal, and that's why the client
>>> believes the callback credential is bogus. Now I'm trying to
>>> figure out whether it is the server's callback client or the
>>> client's callback server that is misbehaving.
>>>
>>> To me, the server's callback principal (host@klimt) seems like it
>>> is correct. The client would identify as host@manet when making
>>> calls to the server, for example, so I'd expect the server to
>>> behave similarly when performing callbacks.
>>>
>>> Can anyone shed more light on this?
>>
>> What are your full hostnames of each machine and does the reverse
>> lookup from the ip to hostname on each machine give you what you
>> expect?
>>
>> Sounds like all of them need to be resolved to <>.ib.1015grager.net
>> but somewhere you are getting <>.1015grager.net instead.
>
> The forward and reverse mappings are consistent, and rdns is
> disabled in my krb5.conf files. My server is multi-homed; it
> has a 1GbE interface (klimt.1015granger.net); an FDR IB
> interface (klimt.ib.1015granger.net); and a 25 GbE interface
> (klimt.roce.1015granger.net).

Ah, so you are keeping it very interesting...

> My theory is that the server needs to use the same principal
> for callback operations that the client used for lease
> establishment. The last paragraph of S3.3.3 seems to state
> that requirement, though it's not especially clear; and the
> client has required it since commit f11b2a1cfbf5 (2014).
>
> So the server should authenticate as nfs@klimt.ib and not
> host@klimt, in this case, when performing callback requests.

Yes I agree that server should have authenticated as nfs@klmit.ib and
that's what I see in my (simple) single home setup.

In nfs-utils there is code that deals with the callback and comment
about choices for the principal:
         * Restricting gssd to use "nfs" service name is needed for when
         * the NFS server is doing a callback to the NFS client.  In this
         * case, the NFS server has to authenticate itself as "nfs" --
         * even if there are other service keys such as "host" or "root"
         * in the keytab.
So the upcall for the callback should have specifically specified
"nfs" to look for the nfs/<hostname>. Question is if you key tab has
both:
nfs/klmit and nfs/klmit.ib how does it choose which one to take. I'm
not sure. But I guess in your case you are seeing that it choose
"host/<>" which would really be a nfs-utils bug.

What's in your server's key tab?

An output from gssd -vvv would be interesting.

> This seems to mean that the server stack is going to need to
> expose the SName in each GSS context so that it can dig that
> out to create a proper callback credential for each callback
> transport.
>
> I guess I've reported this issue before, but now I'm tucking
> in and trying to address it correctly.
>
>
> --
> Chuck Lever
>
>
>
