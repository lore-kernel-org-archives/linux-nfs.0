Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-by2nam01on0121.outbound.protection.outlook.com ([104.47.34.121]:59930
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727701AbeJEUfI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 Oct 2018 16:35:08 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "arnd@arndb.de" <arnd@arndb.de>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "james@ettle.org.uk" <james@ettle.org.uk>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: Re: [PATCH] SUNRPC: use cmpxchg64() in gss_seq_send64_fetch_and_inc()
Date: Fri, 5 Oct 2018 13:36:19 +0000
Message-ID: <7c783e6ecca13af5ae603b75689a377e7a8a4855.camel@hammerspace.com>
References: <20181002205809.2300654-1-arnd@arndb.de>
In-Reply-To: <20181002205809.2300654-1-arnd@arndb.de>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE4LTEwLTAyIGF0IDIyOjU3ICswMjAwLCBBcm5kIEJlcmdtYW5uIHdyb3RlOg0K
PiBUaGUgbmV3bHkgaW50cm9kdWNlZCBnc3Nfc2VxX3NlbmQ2NF9mZXRjaF9hbmRfaW5jKCkgZmFp
bHMgdG8gYnVpbGQgb24NCj4gMzItYml0IGFyY2hpdGVjdHVyZXM6DQo+IA0KPiBuZXQvc3VucnBj
L2F1dGhfZ3NzL2dzc19rcmI1X3NlYWwuYzoxNDQ6MTQ6IG5vdGU6IGluIGV4cGFuc2lvbiBvZg0K
PiBtYWNybyAnY21weGNoZycNCj4gICAgc2VxX3NlbmQgPSBjbXB4Y2hnKCZjdHgtPnNlcV9zZW5k
NjQsIG9sZCwgb2xkICsgMSk7DQo+ICAgICAgICAgICAgICAgXn5+fn5+fg0KPiBhcmNoL3g4Ni9p
bmNsdWRlL2FzbS9jbXB4Y2hnLmg6MTI4OjM6IGVycm9yOiBjYWxsIHRvDQo+ICdfX2NtcHhjaGdf
d3Jvbmdfc2l6ZScgZGVjbGFyZWQgd2l0aCBhdHRyaWJ1dGUgZXJyb3I6IEJhZCBhcmd1bWVudA0K
PiBzaXplIGZvciBjbXB4Y2hnDQo+ICAgIF9fY21weGNoZ193cm9uZ19zaXplKCk7ICAgICBcDQo+
IA0KPiBBcyB0aGUgbWVzc2FnZSB0ZWxscyB1cywgY21weGNoZygpIGNhbm5vdCBiZSB1c2VkIG9u
IDY0LWJpdA0KPiBhcmd1bWVudHMsDQo+IHRoYXQncyB3aGF0IGNtcHhjaGc2NCgpIGRvZXMuDQo+
IA0KPiBGaXhlczogNTcxZWQxZmQyMzkwICgiU1VOUlBDOiBSZXBsYWNlIGtyYjVfc2VxX2xvY2sg
d2l0aCBhIGxvY2tsZXNzDQo+IHNjaGVtZSIpDQo+IFNpZ25lZC1vZmYtYnk6IEFybmQgQmVyZ21h
bm4gPGFybmRAYXJuZGIuZGU+DQo+IC0tLQ0KPiAgbmV0L3N1bnJwYy9hdXRoX2dzcy9nc3Nfa3Ji
NV9zZWFsLmMgfCAyICstDQo+ICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVs
ZXRpb24oLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9uZXQvc3VucnBjL2F1dGhfZ3NzL2dzc19rcmI1
X3NlYWwuYw0KPiBiL25ldC9zdW5ycGMvYXV0aF9nc3MvZ3NzX2tyYjVfc2VhbC5jDQo+IGluZGV4
IDkyNTk0NjgxZDYxOS4uNTc3NWI5ODA1YmRjIDEwMDY0NA0KPiAtLS0gYS9uZXQvc3VucnBjL2F1
dGhfZ3NzL2dzc19rcmI1X3NlYWwuYw0KPiArKysgYi9uZXQvc3VucnBjL2F1dGhfZ3NzL2dzc19r
cmI1X3NlYWwuYw0KPiBAQCAtMTQxLDcgKzE0MSw3IEBAIGdzc19zZXFfc2VuZDY0X2ZldGNoX2Fu
ZF9pbmMoc3RydWN0IGtyYjVfY3R4DQo+ICpjdHgpDQo+ICANCj4gIAlkbyB7DQo+ICAJCW9sZCA9
IHNlcV9zZW5kOw0KPiAtCQlzZXFfc2VuZCA9IGNtcHhjaGcoJmN0eC0+c2VxX3NlbmQ2NCwgb2xk
LCBvbGQgKyAxKTsNCj4gKwkJc2VxX3NlbmQgPSBjbXB4Y2hnNjQoJmN0eC0+c2VxX3NlbmQ2NCwg
b2xkLCBvbGQgKyAxKTsNCj4gIAl9IHdoaWxlIChvbGQgIT0gc2VxX3NlbmQpOw0KPiAgCXJldHVy
biBzZXFfc2VuZDsNCj4gIH0NCg0KVGhhbmtzIEFybmR0ISBBcHBsaWVkLg0KDQotLSANClRyb25k
IE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJv
bmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
