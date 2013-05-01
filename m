Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:58367 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753970Ab3EANdW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 May 2013 09:33:22 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: =?iso-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Pseudoflavor 390004 not found!
Date: Wed, 1 May 2013 13:33:19 +0000
Message-ID: <1367415199.4189.6.camel@leira.trondhjem.org>
References: <5180DBCF.8070303@gmx.de>
In-Reply-To: <5180DBCF.8070303@gmx.de>
Content-Type: multipart/mixed;
	boundary="_002_136741519941896camelleiratrondhjemorg_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_136741519941896camelleiratrondhjemorg_
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <657EFA96B54A444E9E86024E8E9D5D2C@tahoe.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-05-01 at 11:09 +0200, Toralf F=F6rster wrote:
> With current git kernel 3.9-X (since 1 or 2 days) I'm getting the message=
s
> seen below at a user mode linux guest on which I run trinity.
>=20
> On the guest I mount via NFSv4 (and in parallel via hostfs) an EXT4 fs fr=
om the host system.
> The EXT4 resides within a file on a tmpfs which is mounted via loop devic=
e.
>=20
> So on the hosts it looks like :
> $> df -m
> tmpfs               3072   135      2938   5% /mnt/ramdisk
> /dev/loop0           241     5       224   3% /mnt/trinity
>=20
> $ cat /etc/exports
> # /etc/exports: NFS file systems being exported.  See exports(5).
> /mnt/trinity    192.168.0.0/16(rw,fsid=3D0,insecure,no_subtree_check,asyn=
c,no_root_squash)
>=20
> and the UML mounts the share /mnt/trinity just onto its mount points /mnt=
/n22 and /mnt/nfs/n22 respectively.
> And these are the messages I'm curious about :
>=20
> 2013-05-01T10:22:55.613+02:00 trinity kernel: gss_create: Pseudoflavor 39=
0004 not found!
> 2013-05-01T10:22:55.613+02:00 trinity kernel: RPC: Couldn't create auth h=
andle (flavor 390004)
>=20

It's a harmless message. The latest kernel will try to use krb5i to
establish the lease (i.e. for the SETCLIENTID call) as per the
recommendations in the RFC3530bis spec, but on systems such as yours
where you have not enabled krb5, it will fall back to using sec=3Dsys
(auth_sys).

We should just disable the above warnings.

Note that even if the lease negotiation uses krb5i, the actual mount
will continue to use whatever flavour you specify in your 'sec=3D' mount
option (or it will use NFSv4 security negotiation) when doing operations
on the filesystem.

The attached patch will turn off those messages for you.
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

--_002_136741519941896camelleiratrondhjemorg_
Content-Type: text/x-patch;
	name="0001-SUNRPC-Don-t-spam-syslog-with-Pseudoflavor-not-found.patch"
Content-Description: 0001-SUNRPC-Don-t-spam-syslog-with-Pseudoflavor-not-found.patch
Content-Disposition: attachment;
	filename="0001-SUNRPC-Don-t-spam-syslog-with-Pseudoflavor-not-found.patch";
	size=1690; creation-date="Wed, 01 May 2013 13:33:19 GMT";
	modification-date="Wed, 01 May 2013 13:33:19 GMT"
Content-ID: <F679CA468C4666458F999957037008C1@tahoe.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSA5YzlhN2YwZDc4MWFlMzRjZGY3NzcwZGNhYTllNjdlYzdjYjA0NzVjIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IFdlZCwgMSBNYXkgMjAxMyAwOToxNzo1MCAtMDQwMA0KU3ViamVjdDog
W1BBVENIXSBTVU5SUEM6IERvbid0IHNwYW0gc3lzbG9nIHdpdGggIlBzZXVkb2ZsYXZvciBub3Qg
Zm91bmQiDQogbWVzc2FnZXMNCg0KSnVzdCBjb252ZXJ0IHRob3NlIG1lc3NhZ2VzIHRvIGRwcmlu
dGsoKXMgc28gdGhhdCB0aGV5IGNhbiBiZSB1c2VkDQp3aGVuIGRlYnVnZ2luZy4NCg0KU2lnbmVk
LW9mZi1ieTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbT4NCi0t
LQ0KIG5ldC9zdW5ycGMvYXV0aF9nc3MvYXV0aF9nc3MuYyB8IDMgKy0tDQogbmV0L3N1bnJwYy9j
bG50LmMgICAgICAgICAgICAgIHwgMiArLQ0KIDIgZmlsZXMgY2hhbmdlZCwgMiBpbnNlcnRpb25z
KCspLCAzIGRlbGV0aW9ucygtKQ0KDQpkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy9hdXRoX2dzcy9h
dXRoX2dzcy5jIGIvbmV0L3N1bnJwYy9hdXRoX2dzcy9hdXRoX2dzcy5jDQppbmRleCA1MTQxNWIw
Li5iNWRkNjkyIDEwMDY0NA0KLS0tIGEvbmV0L3N1bnJwYy9hdXRoX2dzcy9hdXRoX2dzcy5jDQor
KysgYi9uZXQvc3VucnBjL2F1dGhfZ3NzL2F1dGhfZ3NzLmMNCkBAIC04NjcsOCArODY3LDcgQEAg
Z3NzX2NyZWF0ZShzdHJ1Y3QgcnBjX2NsbnQgKmNsbnQsIHJwY19hdXRoZmxhdm9yX3QgZmxhdm9y
KQ0KIAllcnIgPSAtRUlOVkFMOw0KIAlnc3NfYXV0aC0+bWVjaCA9IGdzc19tZWNoX2dldF9ieV9w
c2V1ZG9mbGF2b3IoZmxhdm9yKTsNCiAJaWYgKCFnc3NfYXV0aC0+bWVjaCkgew0KLQkJcHJpbnRr
KEtFUk5fV0FSTklORyAiJXM6IFBzZXVkb2ZsYXZvciAlZCBub3QgZm91bmQhXG4iLA0KLQkJCQlf
X2Z1bmNfXywgZmxhdm9yKTsNCisJCWRwcmludGsoIlJQQzogICAgICAgUHNldWRvZmxhdm9yICVk
IG5vdCBmb3VuZCFcbiIsIGZsYXZvcik7DQogCQlnb3RvIGVycl9mcmVlOw0KIAl9DQogCWdzc19h
dXRoLT5zZXJ2aWNlID0gZ3NzX3BzZXVkb2ZsYXZvcl90b19zZXJ2aWNlKGdzc19hdXRoLT5tZWNo
LCBmbGF2b3IpOw0KZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMvY2xudC5jIGIvbmV0L3N1bnJwYy9j
bG50LmMNCmluZGV4IGQyNTlmYTkuLmU5MTQzZWQgMTAwNjQ0DQotLS0gYS9uZXQvc3VucnBjL2Ns
bnQuYw0KKysrIGIvbmV0L3N1bnJwYy9jbG50LmMNCkBAIC0zNjAsNyArMzYwLDcgQEAgc3RhdGlj
IHN0cnVjdCBycGNfY2xudCAqIHJwY19uZXdfY2xpZW50KGNvbnN0IHN0cnVjdCBycGNfY3JlYXRl
X2FyZ3MgKmFyZ3MsIHN0cnUNCiANCiAJYXV0aCA9IHJwY2F1dGhfY3JlYXRlKGFyZ3MtPmF1dGhm
bGF2b3IsIGNsbnQpOw0KIAlpZiAoSVNfRVJSKGF1dGgpKSB7DQotCQlwcmludGsoS0VSTl9JTkZP
ICJSUEM6IENvdWxkbid0IGNyZWF0ZSBhdXRoIGhhbmRsZSAoZmxhdm9yICV1KVxuIiwNCisJCWRw
cmludGsoIlJQQzogICAgICAgQ291bGRuJ3QgY3JlYXRlIGF1dGggaGFuZGxlIChmbGF2b3IgJXUp
XG4iLA0KIAkJCQlhcmdzLT5hdXRoZmxhdm9yKTsNCiAJCWVyciA9IFBUUl9FUlIoYXV0aCk7DQog
CQlnb3RvIG91dF9ub19hdXRoOw0KLS0gDQoxLjguMS40DQoNCg==

--_002_136741519941896camelleiratrondhjemorg_--
