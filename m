Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48317 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758911Ab1FVVwL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2011 17:52:11 -0400
Subject: Re: Issue with Race Condition on NFS4 with KRB
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Joshua Scoggins <theoretically.x64@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 22 Jun 2011 17:51:47 -0400
In-Reply-To: <BANLkTi=b1UJzYinAeW2VJj2AHzsAnwUpGg@mail.gmail.com>
References: <BANLkTik9J3qcdPcp+DdfRq9kj+DMKnjKZw@mail.gmail.com>
	 <1308767449.14997.10.camel@lade.trondhjem.org>
	 <BANLkTimyCA0QyF1TNc0SU2GYobOt-sAsNQ@mail.gmail.com>
	 <1308769054.14997.18.camel@lade.trondhjem.org>
	 <BANLkTi=b1UJzYinAeW2VJj2AHzsAnwUpGg@mail.gmail.com>
Content-Type: multipart/mixed; boundary="=-pvUFRjM+3/UqvYlI3Qys"
Message-ID: <1308779507.25875.7.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-pvUFRjM+3/UqvYlI3Qys
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-06-22 at 12:18 -0700, Joshua Scoggins wrote:=20
> According to the it guys they are running solaris 10 as the server platfo=
rm.

Ok. That should not be subject to the race I was thinking of...

> On Wed, Jun 22, 2011 at 11:57 AM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Wed, 2011-06-22 at 11:37 -0700, Joshua Scoggins wrote:
> >> Here are our mount options from auto.master
> >>
> >> /user -fstype=3Dnfs4,sec=3Dkrb5p,noresvport,noatime
> >> /group -fstype=3Dnfs4,sec=3Dkrb5p,noresvport,noatime
> >>
> >> As for the server, we don't control it. It's actually run by the
> >> campus wide it department we are just lab support for CS. I can
> >> potentially get the server information but I need to know what you wan=
t
> >> specifically as they're pretty paranoid about giving out information a=
bout
> >> their servers.
> >
> > I would just want to know _what_ server platform you are running
> > against. I know of at least one server bug that might explain what you
> > are seeing, and I'd like to eliminate that as a possibility.
> >
> > Trond
> >
> >> Joshua Scoggins
> >>
> >> On Wed, Jun 22, 2011 at 11:30 AM, Trond Myklebust
> >> <Trond.Myklebust@netapp.com> wrote:
> >> > On Wed, 2011-06-22 at 11:21 -0700, Joshua Scoggins wrote:
> >> >> Hello,
> >> >>
> >> >> We are trying to update our linux images in our CS lab and have it =
a
> >> >> bit of an issue. We are
> >> >> using nfs to load user home folder. While testing the new image we
> >> >> found that the nfs4 module will
> >> >>  crash when using firefox 3.6.17 for an extended period of time. So=
me
> >> >> research via google yielded that
> >> >> it's a potential race condition specific to nfs with krb auth with
> >> >> newer kernels. Our old image doesn't have
> >> >> this issue and it seems that its due to it running a far older kern=
el version.
> >> >>
> >> >> We have two images and both are having this problem. One is running
> >> >> 2.6.39 and the other is 2.6.38.
> >> >> Here is what dmesg spit out from the machine running 2.6.39 on one =
occasion:
> >> >>
> >> >> [  678.632061] ------------[ cut here ]------------
> >> >> [  678.632068] WARNING: at net/sunrpc/clnt.c:1567 call_decode+0xb2/=
0x69c()
> >> >> [  678.632070] Hardware name: OptiPlex 755
> >> >> [  678.632072] Modules linked in: nvidia(P) scsi_wait_scan
> >> >> [  678.632078] Pid: 3882, comm: kworker/0:2 Tainted: P
> >> >> 2.6.39-gentoo-r1 #1
> >> >> [  678.632080] Call Trace:
> >> >> [  678.632086]  [<ffffffff81035b20>] warn_slowpath_common+0x80/0x98
> >> >> [  678.632091]  [<ffffffff8117231e>] ? nfs4_xdr_dec_readdir+0xba/0x=
ba
> >> >> [  678.632094]  [<ffffffff81035b4d>] warn_slowpath_null+0x15/0x17
> >> >> [  678.632097]  [<ffffffff81426f48>] call_decode+0xb2/0x69c
> >> >> [  678.632101]  [<ffffffff8142d2b5>] __rpc_execute+0x78/0x24b
> >> >> [  678.632104]  [<ffffffff8142d4c9>] ? rpc_execute+0x41/0x41
> >> >> [  678.632107]  [<ffffffff8142d4d9>] rpc_async_schedule+0x10/0x12
> >> >> [  678.632111]  [<ffffffff8104a49d>] process_one_work+0x1d9/0x2e7
> >> >> [  678.632114]  [<ffffffff8104c402>] worker_thread+0x133/0x24f
> >> >> [  678.632118]  [<ffffffff8104c2cf>] ? manage_workers+0x18d/0x18d
> >> >> [  678.632121]  [<ffffffff8104f6a0>] kthread+0x7d/0x85
> >> >> [  678.632125]  [<ffffffff8145e314>] kernel_thread_helper+0x4/0x10
> >> >> [  678.632128]  [<ffffffff8104f623>] ? kthread_worker_fn+0x13a/0x13=
a
> >> >> [  678.632131]  [<ffffffff8145e310>] ? gs_change+0xb/0xb
> >> >> [  678.632133] ---[ end trace 6bfae002a63e020e ]---

Looking at the code, there is only one way I can see for that warning to
occur, and that is if we put the request back on the 'xprt->recv' list
after it has already received a reply from the server.

Can you reproduce the problem with the attached patch?

Trond

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


--=-pvUFRjM+3/UqvYlI3Qys
Content-Disposition: attachment;
	filename*0=0001-SUNRPC-Fix-a-potential-race-in-between-xprt_complete.pat;
	filename*1=ch
Content-Transfer-Encoding: base64
Content-Type: text/x-patch;
	name="0001-SUNRPC-Fix-a-potential-race-in-between-xprt_complete.patch";
	charset="UTF-8"

RnJvbSA3ZmZmYjZiNDc5NDU0NTYwNTAzYmEzMTY2MTUxYjUwMTM4MWY1YTZkIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IFdlZCwgMjIgSnVuIDIwMTEgMTc6Mjc6MTYgLTA0MDANClN1YmplY3Q6
IFtQQVRDSF0gU1VOUlBDOiBGaXggYSBwb3RlbnRpYWwgcmFjZSBpbiBiZXR3ZWVuIHhwcnRfY29t
cGxldGVfcnFzdA0KIGFuZCB4cHJ0X3RyYW5zbWl0DQoNCkluIHhwcnRfdHJhbnNtaXQsIGlmIHRo
ZSB0ZXN0IGZvciBsaXN0X2VtcHR5KCZyZXEtPnJxX2xpc3QpIGlzIHRvIHJlbWFpbg0KbG9ja2xl
c3MsIHdlIG5lZWQgdG8gdGVzdCBmb3Igd2hldGhlciBvciBub3QgcmVxLT5ycV9yZXBseV9ieXRl
c19yZWN2ZCBpcw0Kc2V0IChpLmUuICB3ZSBhbHJlYWR5IGhhdmUgYSByZXBseSkgYWZ0ZXIgdGhh
dCB0ZXN0Lg0KVGhlIHJlYXNvbiBpcyB0aGF0IHhwcnRfY29tcGxldGVfcnFzdCBvcmRlcnMgdGhl
IGxpc3QgZGVsZXRpb24gYW5kDQp0aGUgc2V0dGluZyBvZiB0aGUgcmVxLT5ycV9yZXBseV9ieXRl
c19yZWN2ZC4NCg0KQnkgZG9pbmcgdGhlIHRlc3Qgb2YgcmVxLT5ycV9yZXBseV9ieXRlc19yZWN2
ZCB1bmRlciB0aGUgc3BpbmxvY2ssIHdlDQphdm9pZCBhbiBleHRyYSBzbXBfcm1iKCkuDQoNCkFs
c28gZW5zdXJlIHRoYXQgd2UgdHVybiBvZmYgYXV0b2Rpc2Nvbm5lY3Qgd2hldGhlciBvciBub3Qg
dGhlIFJQQyByZXF1ZXN0DQpleHBlY3RzIGEgcmVwbHkuDQoNClNpZ25lZC1vZmYtYnk6IFRyb25k
IE15a2xlYnVzdCA8VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20+DQotLS0NCiBuZXQvc3VucnBj
L3hwcnQuYyB8ICAgMzQgKysrKysrKysrKysrKysrKysrKysrLS0tLS0tLS0tLS0tLQ0KIDEgZmls
ZXMgY2hhbmdlZCwgMjEgaW5zZXJ0aW9ucygrKSwgMTMgZGVsZXRpb25zKC0pDQoNCmRpZmYgLS1n
aXQgYS9uZXQvc3VucnBjL3hwcnQuYyBiL25ldC9zdW5ycGMveHBydC5jDQppbmRleCBjZTVlYjY4
Li4xMGUxZjIxIDEwMDY0NA0KLS0tIGEvbmV0L3N1bnJwYy94cHJ0LmMNCisrKyBiL25ldC9zdW5y
cGMveHBydC5jDQpAQCAtODc4LDIzICs4NzgsMzEgQEAgdm9pZCB4cHJ0X3RyYW5zbWl0KHN0cnVj
dCBycGNfdGFzayAqdGFzaykNCiANCiAJZHByaW50aygiUlBDOiAlNXUgeHBydF90cmFuc21pdCgl
dSlcbiIsIHRhc2stPnRrX3BpZCwgcmVxLT5ycV9zbGVuKTsNCiANCi0JaWYgKCFyZXEtPnJxX3Jl
cGx5X2J5dGVzX3JlY3ZkKSB7DQotCQlpZiAobGlzdF9lbXB0eSgmcmVxLT5ycV9saXN0KSAmJiBy
cGNfcmVwbHlfZXhwZWN0ZWQodGFzaykpIHsNCi0JCQkvKg0KLQkJCSAqIEFkZCB0byB0aGUgbGlz
dCBvbmx5IGlmIHdlJ3JlIGV4cGVjdGluZyBhIHJlcGx5DQotCQkJICovDQorCWlmIChsaXN0X2Vt
cHR5KCZyZXEtPnJxX2xpc3QpKSB7DQorCQkvKg0KKwkJICogQWRkIHRvIHRoZSBsaXN0IG9ubHkg
aWYgd2UncmUgZXhwZWN0aW5nIGEgcmVwbHkNCisJCSAqLw0KKwkJaWYgKHJwY19yZXBseV9leHBl
Y3RlZCh0YXNrKSkgew0KIAkJCXNwaW5fbG9ja19iaCgmeHBydC0+dHJhbnNwb3J0X2xvY2spOw0K
LQkJCS8qIFVwZGF0ZSB0aGUgc29mdGlycSByZWNlaXZlIGJ1ZmZlciAqLw0KLQkJCW1lbWNweSgm
cmVxLT5ycV9wcml2YXRlX2J1ZiwgJnJlcS0+cnFfcmN2X2J1ZiwNCi0JCQkJCXNpemVvZihyZXEt
PnJxX3ByaXZhdGVfYnVmKSk7DQotCQkJLyogQWRkIHJlcXVlc3QgdG8gdGhlIHJlY2VpdmUgbGlz
dCAqLw0KLQkJCWxpc3RfYWRkX3RhaWwoJnJlcS0+cnFfbGlzdCwgJnhwcnQtPnJlY3YpOw0KKwkJ
CS8qIERvbid0IHB1dCBiYWNrIG9uIHRoZSBsaXN0IGlmIHdlIGhhdmUgYSByZXBseQ0KKwkJCSAq
IFdlIGRvIHRoaXMgdGVzdCB1bmRlciB0aGUgc3BpbiBsb2NrIHRvIGF2b2lkDQorCQkJICogYW4g
ZXh0cmEgc21wX3JtYigpIGJldHdlZW50IHRoZSB0ZXN0cyBvZg0KKwkJCSAqIHJlcS0+cnFfbGlz
dCBhbmQgcmVxLT5ycV9yZXBseV9ieXRlc19yZWN2ZA0KKwkJCSAqLw0KKwkJCWlmIChyZXEtPnJx
X3JlcGx5X2J5dGVzX3JlY3ZkID09IDApIHsNCisJCQkJLyogVXBkYXRlIHRoZSBzb2Z0aXJxIHJl
Y2VpdmUgYnVmZmVyICovDQorCQkJCW1lbWNweSgmcmVxLT5ycV9wcml2YXRlX2J1ZiwgJnJlcS0+
cnFfcmN2X2J1ZiwNCisJCQkJCQlzaXplb2YocmVxLT5ycV9wcml2YXRlX2J1ZikpOw0KKwkJCQkv
KiBBZGQgcmVxdWVzdCB0byB0aGUgcmVjZWl2ZSBsaXN0ICovDQorCQkJCWxpc3RfYWRkX3RhaWwo
JnJlcS0+cnFfbGlzdCwgJnhwcnQtPnJlY3YpOw0KKwkJCX0NCiAJCQlzcGluX3VubG9ja19iaCgm
eHBydC0+dHJhbnNwb3J0X2xvY2spOw0KIAkJCXhwcnRfcmVzZXRfbWFqb3J0aW1lbyhyZXEpOw0K
LQkJCS8qIFR1cm4gb2ZmIGF1dG9kaXNjb25uZWN0ICovDQotCQkJZGVsX3NpbmdsZXNob3RfdGlt
ZXJfc3luYygmeHBydC0+dGltZXIpOw0KIAkJfQ0KLQl9IGVsc2UgaWYgKCFyZXEtPnJxX2J5dGVz
X3NlbnQpDQorCQkvKiBUdXJuIG9mZiBhdXRvZGlzY29ubmVjdCAqLw0KKwkJZGVsX3NpbmdsZXNo
b3RfdGltZXJfc3luYygmeHBydC0+dGltZXIpOw0KKwl9DQorCWlmIChyZXEtPnJxX3JlcGx5X2J5
dGVzX3JlY3ZkICE9IDAgJiYgcmVxLT5ycV9ieXRlc19zZW50ID09IDApDQogCQlyZXR1cm47DQog
DQogCXJlcS0+cnFfY29ubmVjdF9jb29raWUgPSB4cHJ0LT5jb25uZWN0X2Nvb2tpZTsNCi0tIA0K
MS43LjUuNA0KDQo=

--=-pvUFRjM+3/UqvYlI3Qys--
