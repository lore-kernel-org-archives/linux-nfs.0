Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:36063 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbbJAP0N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Oct 2015 11:26:13 -0400
Subject: Re: NFS / FuseFS Kernel Hangs Bug
To: "sascha a." <sascha.arthur@gmail.com>
References: <CAK_92-ECoKWOPJXbT=BNcXhd5aVq77rWOciKfKf6a-LYTFbDqg@mail.gmail.com>
 <560D4212.3010101@gmail.com>
 <CAK_92-HRCUAg6=ATiGT0Cbh+Qkhk9mHBUXje9z9utosEC7e0cw@mail.gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <560D505C.6000403@gmail.com>
Date: Thu, 1 Oct 2015 11:25:16 -0400
MIME-Version: 1.0
In-Reply-To: <CAK_92-HRCUAg6=ATiGT0Cbh+Qkhk9mHBUXje9z9utosEC7e0cw@mail.gmail.com>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms050606030806000502030201"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms050606030806000502030201
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-10-01 10:45, sascha a. wrote:
> Hello,
>
> Okay, i was wrong with FUSE and NFS thanks for the hint.
>
> About the Problem:
> Without digging deep into the kernel sources, your explaination is
> more or less that was i thinking about whats happening.
> Anyways, the reason why i report the Problem is that during this 120
> Seconds (until the Kernel solves this issue by killing (?) the
> process) the system is unusable.
>
> What i mean about it:
> Its not even possible to ssh on the server, even if /root and /home is
> local and should not be affected by the slow NFS Servers.
> Also it seems during this period a lot of network connections drop/free=
ze(?).
>
> Youre completly right when you says, theres no other way/its by design
> to wait for the NFS-Response. But in my point of view this 'wait' is
> happening on the wrong security level. If im not wrong the current
> implementation blocks/hangs tasks in kernelspace, or at least blocks
> the scheduler during this period.
If it's a single core system, and the kernel is configured with=20
PREEMPT_NONE, I could see that being possible, but I think Debian=20
(assuming you're using Debian because the /proc/version info that you=20
posted in the original e-mail indicated the kernel was a Debian build)=20
builds with PREEMPT_VOLUNTARY by default.  I have little knowledge of=20
the internal workings of the kernel's NFS client implementation, so I'm=20
Cc'ing the associated mailing list.

If you don't need guaranteed data safety, you might try adding 'async'=20
to the share options on the NFS server in /etc/exports.  Keep in mind=20
though that using this has a significant chance to cause data loss (from =

the client's perspective that is, it will look like calls to write()=20
that returned success never happened) if the NFS server crashes, so you=20
should only do this if you are 100% certain that you can afford the=20
potential data loss.  Also keep in mind that this violates the official=20
NFS standards, so some third-party software may lose it's mind when used =

with this.

If you're just using NFSv3 you may also try using udp instead of tcp=20
(this actually doesn't hurt reliability much when used on a reliable=20
network), I've seen doing so more than double performance and cut server =

load in half in some cases (maintaining a TCP connection is pretty=20
network and processor intensive, as it was designed for reliable=20
communications across unreliable networks).
> 2015-10-01 16:24 GMT+02:00 Austin S Hemmelgarn <ahferroin7@gmail.com>:
>> On 2015-10-01 09:06, sascha a. wrote:
>>>
>>> Hello,
>>>
>>>
>>> I want to report a Bug with NFS / FuseFS.
>>>
>>> Theres trouble with mounting a NFS FS with FuseFS, if the NFS Server
>>> is slowly responding.
>>>
>>> The problem occurs, if you mount a NFS FS with FuseFS driver for
>>> example with this command:
>>>
>>> mount -t nfs -o vers=3D3,nfsvers=3D3,hard,intr,tcp server /dest
>>>
>>> Working on this nfs overlay works like a charm, as long as the NFS
>>> Server is not under heavy load. If it gets under HEAVY load from time=

>>> to time the kernel hangs (which should in my opinion never ever
>>> occur).
>>
>> OK, before I start on an explanation of why what is happening is happe=
ning,
>> I should note that unless you're using some special FUSE driver instea=
d of
>> the regular NFS tools, you're not using FUSE to mount the NFS share, y=
ou're
>> using a regular kernel driver.
>>
>> Now, on to the explanation:
>> This behavior is expected and unavoidable for any network filesystem u=
nder
>> the described conditions.  Sync (or any other command that causes acce=
ss to
>> the filesystem that isn't served by the local cache) requires sending =
a
>> command to the server.  Sync in particular is _synchronous_ (and it sh=
ould
>> be, otherwise you break the implied data safety from using it), which =
means
>> that it will wait until it gets a reply from the server before it retu=
rns,
>> which means that if the server is heavily loaded (or just ridiculously=

>> slow), it will be a while before it returns.  On top of this, dependin=
g on
>> how the server is caching data, it may take a long time to return even=
 on a
>> really fast server with no other load.
>>
>> The stacktrace you posted indicates simply that the kernel noticed tha=
t
>> 'sync' was in an I/O sleep state (the 'D state' it refers to) for more=
 than
>> 120 seconds, which is the default detection timeout for this.
>>



--------------ms050606030806000502030201
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUxMDAxMTUyNTE2WjBPBgkq
hkiG9w0BCQQxQgRAQn0AIZAWecYljrDhUB2FdIKJ6WDa+ii+Sdxakrsd4Tx1d9JSKgEyo4GS
zUR0eW/B6I1VbpbuUpv4lbr9925R8zBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxEt+DCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DAN
BgkqhkiG9w0BAQEFAASCAgCQCMjEKPQ/XFCaQJ+nBk9HBpwqNV2DzBcpYb4upl7/44PXAQyG
ZAN8n8WccvpEbKMahTqF4TJ3yk9wo+pUrUkUICXXHsnZVlmLcKeibeXitlJutTME7YnCwvx1
exKuvj+bs+XUjs4rakBdnKjITfoH3lGzmKAKGLVyi7mqxw1QFKmhl1d4620aNDmaw19UDGBn
0Jd+FR7yjC0Ix4HkDeRcJYq9TgOs/JcHUEiM+kCQ3rEwVzC9rhWUWL0d+/TMV95rJNxnJV3U
p0FcjCtQp2I72VgX90tek6ZbjHFuZEUO6s9Vnw7GhpduTE2Z8Wm4sTEpgHaSk45mO7PinFsE
8rZFV90LRW6UVvtbFyrFxT5X2PmUpBLwKD83DfUwgcrQq3zFrXN8rqQxL/gGFsQ6gRJ4H2nj
sCnOyBXb9QBJRQnIbMKAW3vXHLX59kVkby2WUo7DaJkbrEjwB0GqZV/H6+3rP6Aq9kJPogcR
J76uSa7aUPk2ynDF5tRzE8tcUNbuWSzQNxhbX3QIwU6e47WzXXrFg5hCsnXx8tKlkDFnmfxK
MM803zQRCrD/UHCxu0SY7I23NR16c12DgvjhTJfM9pyg8+J0wAKHxDKoxh1ocSZjSm6WO+MT
iDe5cNZ5qm34glEo7fwErSgFEaCL/Es7mbRNk5yPvG/0rADyXy8yaH8JhAAAAAAAAA==
--------------ms050606030806000502030201--
