Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:34986 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755790Ab3GVQqi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 12:46:38 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] NFSv4.1 Use the mount point rpc_clnt for
 layoutreturn
Date: Mon, 22 Jul 2013 16:46:34 +0000
Message-ID: <1374511594.7972.1.camel@leira.trondhjem.org>
References: <1374511328-49579-1-git-send-email-andros@netapp.com>
	 <1374511492.7972.0.camel@leira.trondhjem.org>
In-Reply-To: <1374511492.7972.0.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEzLTA3LTIyIGF0IDEyOjQ0IC0wNDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IE9uIE1vbiwgMjAxMy0wNy0yMiBhdCAxMjo0MiAtMDQwMCwgYW5kcm9zQG5ldGFwcC5jb20g
d3JvdGU6DQo+ID4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gPiAN
Cj4gPiBTaG91bGQgbm90IHVzZSB0aGUgY2xpZW50aWQgbWFpbnRlbmFuY2UgcnBjX2NsbnQuDQo+
ID4gDQo+ID4gU2lnbmVkLW9mZi1ieTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4N
Cj4gPiAtLS0NCj4gPiAgZnMvbmZzL25mczRwcm9jLmMgfCAyICstDQo+ID4gIDEgZmlsZSBjaGFu
Z2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQ0KPiA+IA0KPiA+IGRpZmYgLS1naXQg
YS9mcy9uZnMvbmZzNHByb2MuYyBiL2ZzL25mcy9uZnM0cHJvYy5jDQo+ID4gaW5kZXggY2YxMTc5
OS4uN2E4NDZiNiAxMDA2NDQNCj4gPiAtLS0gYS9mcy9uZnMvbmZzNHByb2MuYw0KPiA+ICsrKyBi
L2ZzL25mcy9uZnM0cHJvYy5jDQo+ID4gQEAgLTY4NzYsNyArNjg3Niw3IEBAIGludCBuZnM0X3By
b2NfbGF5b3V0cmV0dXJuKHN0cnVjdCBuZnM0X2xheW91dHJldHVybiAqbHJwKQ0KPiA+ICAJCS5y
cGNfY3JlZCA9IGxycC0+Y3JlZCwNCj4gPiAgCX07DQo+ID4gIAlzdHJ1Y3QgcnBjX3Rhc2tfc2V0
dXAgdGFza19zZXR1cF9kYXRhID0gew0KPiA+IC0JCS5ycGNfY2xpZW50ID0gbHJwLT5jbHAtPmNs
X3JwY2NsaWVudCwNCj4gPiArCQkucnBjX2NsaWVudCA9IE5GU19TRVJWRVIobHJwLT5hcmdzLmlu
b2RlKS0+Y2xpZW50LA0KPiA+ICAJCS5ycGNfbWVzc2FnZSA9ICZtc2csDQo+ID4gIAkJLmNhbGxi
YWNrX29wcyA9ICZuZnM0X2xheW91dHJldHVybl9jYWxsX29wcywNCj4gPiAgCQkuY2FsbGJhY2tf
ZGF0YSA9IGxycCwNCj4gDQo+IE5BQ0suIExBWU9VVFJFVFVSTiBuZWVkcyB0byB1c2UgdGhlIHNh
bWUgY3JlZGVudGlhbCBhcyBMQVlPVVRHRVQuDQo+IA0KDQpOZXZlciBtaW5kLiBJIGNvbXBsZXRl
bHkgbWlzcmVhZCB0aGUgcGF0Y2guDQoNCkFncmVlZCB0aGF0IHRoaXMgaXMgdGhlIHJpZ2h0IHRo
aW5nIHRvIGRvLg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRh
aW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNv
bQ0K
