Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:5568 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363Ab3APUOU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jan 2013 15:14:20 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: =?utf-7?B?UGF3ZStBVUktIFNpa29yYQ==?= <pawel.sikora@agmk.net>,
        "Steve Dickson" <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "baggins@pld-linux.org" <baggins@pld-linux.org>
Subject: Re: mount.nfs: cannot allocate memory.
Date: Wed, 16 Jan 2013 20:14:12 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9119BF981@SACEXCMBX04-PRD.hq.netapp.com>
References: <2891788.0SBnrhN2VX@pawels> <50EADFED.1070505@RedHat.com>
	 <2367820.SDlsSOm8Xm@localhost> <1435172.ktCUaNjhdC@localhost>
	 <20130116193932.GA5002@fieldses.org>
In-Reply-To: <20130116193932.GA5002@fieldses.org>
Content-Type: multipart/mixed;
	boundary="_002_4FA345DA4F4AE44899BD2B03EEEC2FA9119BF981SACEXCMBX04PRDh_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA9119BF981SACEXCMBX04PRDh_
Content-Type: text/plain; charset="utf-7"
Content-ID: <91C32809963C5841A3ED8415FED36CF9@tahoe.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-01-16 at 14:39 -0500, J. Bruce Fields wrote:
+AD4- On Wed, Jan 16, 2013 at 08:03:14PM +-0100, Pawe+AUI- Sikora wrote:
+AD4- +AD4- +AFs-259176.973751+AF0- NFS: nfs mount opts+AD0-'soft,addr+AD0-=
10.0.2.28,vers+AD0-3,proto+AD0-tcp,mountvers+AD0-3,mountproto+AD0-udp,mount=
port+AD0-50252'
+AD4- +AD4- +AFs-259176.973757+AF0- NFS:   parsing nfs mount option 'soft'
+AD4- +AD4- +AFs-259176.973759+AF0- NFS:   parsing nfs mount option 'addr+A=
D0-10.0.2.28'
+AD4- +AD4- +AFs-259176.973765+AF0- NFS:   parsing nfs mount option 'vers+A=
D0-3'
+AD4- +AD4- +AFs-259176.973769+AF0- NFS:   parsing nfs mount option 'proto+=
AD0-tcp'
+AD4- +AD4- +AFs-259176.973772+AF0- NFS:   parsing nfs mount option 'mountv=
ers+AD0-3'
+AD4- +AD4- +AFs-259176.973776+AF0- NFS:   parsing nfs mount option 'mountp=
roto+AD0-udp'
+AD4- +AD4- +AFs-259176.973779+AF0- NFS:   parsing nfs mount option 'mountp=
ort+AD0-50252'
+AD4- +AD4- +AFs-259176.973784+AF0- NFS: MNTPATH: '/R10'
+AD4- +AD4- +AFs-259176.973788+AF0- NFS: sending MNT request for nexus:/R10
+AD4- +AD4- +AFs-259176.974620+AF0- NFS: received 1 auth flavors
+AD4- +AD4- +AFs-259176.974623+AF0- NFS:   auth flavor+AFs-0+AF0-: 1
+AD4- +AD4- +AFs-259176.974640+AF0- NFS: MNT request succeeded
+AD4- +AD4- +AFs-259176.974643+AF0- NFS: using auth flavor 1
+AD4- +AD4- +AFs-259176.974688+AF0- --+AD4- nfs+AF8-init+AF8-server()
+AD4- +AD4- +AFs-259176.974691+AF0- --+AD4- nfs+AF8-get+AF8-client(nexus,v3=
)
+AD4- +AD4- +AFs-259176.974698+AF0- NFS: get client cookie (0xffff88021146f=
800/0xffff8800ceb06640)
+AD4- +AD4- +AFs-259176.975704+AF0- +ADw--- nfs+AF8-init+AF8-server() +AD0-=
 0 +AFs-new ffff88021146f800+AF0-
+AD4- +AD4- +AFs-259176.975708+AF0- --+AD4- nfs+AF8-probe+AF8-fsinfo()
+AD4- +AD4- +AFs-259176.975711+AF0- NFS call  fsinfo
+AD4- +AD4- +AFs-259176.975959+AF0- NFS reply fsinfo: -116
+AD4-=20
+AD4- That's ESTALE.  Might be interesting to see the network traffic betwe=
en
+AD4- client and server.

Yes. The ENOMEM is a red herring. It turns out that there is a bug in
nfs+AF8-xdev+AF8-mount that converts all errors from clone+AF8-server() int=
o
ENOMEM...

The attached patch should fix it.

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA9119BF981SACEXCMBX04PRDh_
Content-Type: text/x-patch;
	name="0001-NFS-Fix-error-reporting-in-nfs_xdev_mount.patch"
Content-Description: 0001-NFS-Fix-error-reporting-in-nfs_xdev_mount.patch
Content-Disposition: attachment;
	filename="0001-NFS-Fix-error-reporting-in-nfs_xdev_mount.patch"; size=1868;
	creation-date="Wed, 16 Jan 2013 20:14:11 GMT";
	modification-date="Wed, 16 Jan 2013 20:14:11 GMT"
Content-ID: <4C218F985A77CB4BABB9892AD403A708@tahoe.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSBlNzE4Mjc2ZDJhMTcwNGFjNTQwZjUwMzdlZmFjNGVlNTVjMmU2MjIwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IFdlZCwgMTYgSmFuIDIwMTMgMTU6MDU6NDQgLTA1MDANClN1YmplY3Q6
IFtQQVRDSF0gTkZTOiBGaXggZXJyb3IgcmVwb3J0aW5nIGluIG5mc194ZGV2X21vdW50DQoNCkN1
cnJlbnRseSwgbmZzX3hkZXZfbW91bnQgY29udmVydHMgYWxsIGVycm9ycyBmcm9tIGNsb25lX3Nl
cnZlcigpIHRvDQpFTk9NRU0uIEZpeCB0aGF0Lg0KQWxzbyBlbnN1cmUgdGhhdCBpZiBuZnNfZnNf
bW91bnRfY29tbW9uKCkgcmV0dXJucyBhbiBlcnJvciwgd2UNCmRvbid0IGRwcmludGsoMCkuLi4N
Cg0KU2lnbmVkLW9mZi1ieTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0YXBw
LmNvbT4NCi0tLQ0KIGZzL25mcy9zdXBlci5jIHwgMjIgKysrKysrKysrLS0tLS0tLS0tLS0tLQ0K
IDEgZmlsZSBjaGFuZ2VkLCA5IGluc2VydGlvbnMoKyksIDEzIGRlbGV0aW9ucygtKQ0KDQpkaWZm
IC0tZ2l0IGEvZnMvbmZzL3N1cGVyLmMgYi9mcy9uZnMvc3VwZXIuYw0KaW5kZXggNzJjZDJkMi4u
YmVmYmFlMCAxMDA2NDQNCi0tLSBhL2ZzL25mcy9zdXBlci5jDQorKysgYi9mcy9uZnMvc3VwZXIu
Yw0KQEAgLTI1NDAsMjcgKzI1NDAsMjMgQEAgbmZzX3hkZXZfbW91bnQoc3RydWN0IGZpbGVfc3lz
dGVtX3R5cGUgKmZzX3R5cGUsIGludCBmbGFncywNCiAJc3RydWN0IG5mc19zZXJ2ZXIgKnNlcnZl
cjsNCiAJc3RydWN0IGRlbnRyeSAqbW50cm9vdCA9IEVSUl9QVFIoLUVOT01FTSk7DQogCXN0cnVj
dCBuZnNfc3VidmVyc2lvbiAqbmZzX21vZCA9IE5GU19TQihkYXRhLT5zYiktPm5mc19jbGllbnQt
PmNsX25mc19tb2Q7DQotCWludCBlcnJvcjsNCiANCi0JZHByaW50aygiLS0+IG5mc194ZGV2X21v
dW50X2NvbW1vbigpXG4iKTsNCisJZHByaW50aygiLS0+IG5mc194ZGV2X21vdW50KClcbiIpOw0K
IA0KIAltb3VudF9pbmZvLm1udGZoID0gbW91bnRfaW5mby5jbG9uZWQtPmZoOw0KIA0KIAkvKiBj
cmVhdGUgYSBuZXcgdm9sdW1lIHJlcHJlc2VudGF0aW9uICovDQogCXNlcnZlciA9IG5mc19tb2Qt
PnJwY19vcHMtPmNsb25lX3NlcnZlcihORlNfU0IoZGF0YS0+c2IpLCBkYXRhLT5maCwgZGF0YS0+
ZmF0dHIsIGRhdGEtPmF1dGhmbGF2b3IpOw0KLQlpZiAoSVNfRVJSKHNlcnZlcikpIHsNCi0JCWVy
cm9yID0gUFRSX0VSUihzZXJ2ZXIpOw0KLQkJZ290byBvdXRfZXJyOw0KLQl9DQogDQotCW1udHJv
b3QgPSBuZnNfZnNfbW91bnRfY29tbW9uKHNlcnZlciwgZmxhZ3MsIGRldl9uYW1lLCAmbW91bnRf
aW5mbywgbmZzX21vZCk7DQotCWRwcmludGsoIjwtLSBuZnNfeGRldl9tb3VudF9jb21tb24oKSA9
IDBcbiIpOw0KLW91dDoNCi0JcmV0dXJuIG1udHJvb3Q7DQorCWlmIChJU19FUlIoc2VydmVyKSkN
CisJCW1udHJvb3QgPSBFUlJfQ0FTVChzZXJ2ZXIpOw0KKwllbHNlDQorCQltbnRyb290ID0gbmZz
X2ZzX21vdW50X2NvbW1vbihzZXJ2ZXIsIGZsYWdzLA0KKwkJCQlkZXZfbmFtZSwgJm1vdW50X2lu
Zm8sIG5mc19tb2QpOw0KIA0KLW91dF9lcnI6DQotCWRwcmludGsoIjwtLSBuZnNfeGRldl9tb3Vu
dF9jb21tb24oKSA9ICVkIFtlcnJvcl1cbiIsIGVycm9yKTsNCi0JZ290byBvdXQ7DQorCWRwcmlu
dGsoIjwtLSBuZnNfeGRldl9tb3VudCgpID0gJWxkXG4iLA0KKwkJCUlTX0VSUihtbnRyb290KSA/
IFBUUl9FUlIobW50cm9vdCkgOiAwTCk7DQorCXJldHVybiBtbnRyb290Ow0KIH0NCiANCiAjaWYg
SVNfRU5BQkxFRChDT05GSUdfTkZTX1Y0KQ0KLS0gDQoxLjcuMTEuNw0KDQo=

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA9119BF981SACEXCMBX04PRDh_--
