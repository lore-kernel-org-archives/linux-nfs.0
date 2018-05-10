Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:51344 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966673AbeEJSJW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2018 14:09:22 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: SETCLIENTID acceptor
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyH8i0hmx8nvMUXhndZE_LcGAB0mySjBpDTq7eLQ-gFgiQ@mail.gmail.com>
Date: Thu, 10 May 2018 14:09:14 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8E0A99E2-7037-4023-99F5-594430919604@oracle.com>
References: <C4BAD0ED-E05B-4A43-8A9A-51176123D6B9@oracle.com>
 <CAN-5tyH8i0hmx8nvMUXhndZE_LcGAB0mySjBpDTq7eLQ-gFgiQ@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 10, 2018, at 1:40 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Wed, May 9, 2018 at 5:19 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>> I'm right on the edge of my understanding of how this all works.
>>=20
>> I've re-keyed my NFS server. Now on my client, I'm seeing this on
>> vers=3D4.0,sec=3Dsys mounts:
>>=20
>> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid =
cred
>> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid =
cred
>> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid =
cred
>>=20
>> manet is my client, and klimt is my server. I'm mounting with
>> NFS/RDMA, so I'm mounting hostname klimt.ib, not klimt.
>>=20
>> Because the client is using krb5i for lease management, the server
>> is required to use krb5i for the callback channel (S 3.3.3 of RFC
>> 7530).
>>=20
>> After a SETCLIENTID, the client copies the acceptor from the GSS
>> context it set up, and uses that to check incoming callback
>> requests. I instrumented the client's SETCLIENTID proc, and I see
>> this:
>>=20
>> check_gss_callback_principal: acceptor=3Dnfs@klimt.ib.1015granger.net, =
principal=3Dhost@klimt.1015granger.net
>>=20
>> The principal strings are not equal, and that's why the client
>> believes the callback credential is bogus. Now I'm trying to
>> figure out whether it is the server's callback client or the
>> client's callback server that is misbehaving.
>>=20
>> To me, the server's callback principal (host@klimt) seems like it
>> is correct. The client would identify as host@manet when making
>> calls to the server, for example, so I'd expect the server to
>> behave similarly when performing callbacks.
>>=20
>> Can anyone shed more light on this?
>=20
> What are your full hostnames of each machine and does the reverse
> lookup from the ip to hostname on each machine give you what you
> expect?
>=20
> Sounds like all of them need to be resolved to <>.ib.1015grager.net
> but somewhere you are getting <>.1015grager.net instead.

The forward and reverse mappings are consistent, and rdns is
disabled in my krb5.conf files. My server is multi-homed; it
has a 1GbE interface (klimt.1015granger.net); an FDR IB
interface (klimt.ib.1015granger.net); and a 25 GbE interface
(klimt.roce.1015granger.net).

My theory is that the server needs to use the same principal
for callback operations that the client used for lease
establishment. The last paragraph of S3.3.3 seems to state
that requirement, though it's not especially clear; and the
client has required it since commit f11b2a1cfbf5 (2014).

So the server should authenticate as nfs@klimt.ib and not
host@klimt, in this case, when performing callback requests.

This seems to mean that the server stack is going to need to
expose the SName in each GSS context so that it can dig that
out to create a proper callback credential for each callback
transport.

I guess I've reported this issue before, but now I'm tucking
in and trying to address it correctly.


--
Chuck Lever



