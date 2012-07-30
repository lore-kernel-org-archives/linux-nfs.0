Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39497 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755042Ab2G3XMH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 19:12:07 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] SUNRPC: return negative value in case rpcbind client
 creation error
Date: Mon, 30 Jul 2012 23:12:05 +0000
Message-ID: <1343689924.8362.4.camel@lade.trondhjem.org>
References: <20120720114849.23572.91010.stgit@localhost.localdomain>
In-Reply-To: <20120720114849.23572.91010.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTA3LTIwIGF0IDE1OjU3ICswNDAwLCBTdGFuaXNsYXYgS2luc2J1cnNreSB3
cm90ZToNCj4gV2l0aG91dCB0aGlzIHBhdGNoIGtlcm5lbCB3aWxsIHBhbmljIG9uIExvY2tEIHN0
YXJ0LCBiZWNhdXNlIGxvY2tkX3VwKCkgY2hlY2tzDQo+IGxvY2tkX3VwX25ldCgpIHJlc3VsdCBm
b3IgbmVnYXRpdmUgdmFsdWUuDQo+ID5Gcm9tIG15IHBvdyBpdCdzIGJldHRlciB0byByZXR1cm4g
bmVnYXRpdmUgdmFsdWUgZnJvbSBycGNiaW5kIHJvdXRpbmVzIGluc3RlYWQNCj4gb2YgcmVwbGFj
aW5nIGFsbCBzdWNoIGNoZWNrcyBsaWtlIGluIGxvY2tkX3VwKCkuDQo+IA0KPiBTaWduZWQtb2Zm
LWJ5OiBTdGFuaXNsYXYgS2luc2J1cnNreSA8c2tpbnNidXJza3lAcGFyYWxsZWxzLmNvbT4NCj4g
LS0tDQo+ICBuZXQvc3VucnBjL3JwY2JfY2xudC5jIHwgICAgNCArKy0tDQo+ICAxIGZpbGVzIGNo
YW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQg
YS9uZXQvc3VucnBjL3JwY2JfY2xudC5jIGIvbmV0L3N1bnJwYy9ycGNiX2NsbnQuYw0KPiBpbmRl
eCA5MjUwOWZmLi5hNzBhY2FlIDEwMDY0NA0KPiAtLS0gYS9uZXQvc3VucnBjL3JwY2JfY2xudC5j
DQo+ICsrKyBiL25ldC9zdW5ycGMvcnBjYl9jbG50LmMNCj4gQEAgLTI1MSw3ICsyNTEsNyBAQCBz
dGF0aWMgaW50IHJwY2JfY3JlYXRlX2xvY2FsX3VuaXgoc3RydWN0IG5ldCAqbmV0KQ0KPiAgCWlm
IChJU19FUlIoY2xudCkpIHsNCj4gIAkJZHByaW50aygiUlBDOiAgICAgICBmYWlsZWQgdG8gY3Jl
YXRlIEFGX0xPQ0FMIHJwY2JpbmQgIg0KPiAgCQkJCSJjbGllbnQgKGVycm5vICVsZCkuXG4iLCBQ
VFJfRVJSKGNsbnQpKTsNCj4gLQkJcmVzdWx0ID0gLVBUUl9FUlIoY2xudCk7DQo+ICsJCXJlc3Vs
dCA9IFBUUl9FUlIoY2xudCk7DQo+ICAJCWdvdG8gb3V0Ow0KPiAgCX0NCj4gIA0KPiBAQCAtMjk4
LDcgKzI5OCw3IEBAIHN0YXRpYyBpbnQgcnBjYl9jcmVhdGVfbG9jYWxfbmV0KHN0cnVjdCBuZXQg
Km5ldCkNCj4gIAlpZiAoSVNfRVJSKGNsbnQpKSB7DQo+ICAJCWRwcmludGsoIlJQQzogICAgICAg
ZmFpbGVkIHRvIGNyZWF0ZSBsb2NhbCBycGNiaW5kICINCj4gIAkJCQkiY2xpZW50IChlcnJubyAl
bGQpLlxuIiwgUFRSX0VSUihjbG50KSk7DQo+IC0JCXJlc3VsdCA9IC1QVFJfRVJSKGNsbnQpOw0K
PiArCQlyZXN1bHQgPSBQVFJfRVJSKGNsbnQpOw0KPiAgCQlnb3RvIG91dDsNCj4gIAl9DQoNCldo
byBpcyBzdXBwb3NlZCB0byBjYXJyeSB0aGlzIHBhdGNoPyBJcyBpdCBCcnVjZSBvciBpcyBpdCBt
ZT8NCg0KQ2hlZXJzDQogIFRyb25kDQoNCg==
