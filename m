Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42833 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758724Ab2EVOpH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 10:45:07 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v3] NFS: put net on idr allocation failure
Date: Tue, 22 May 2012 14:45:06 +0000
Message-ID: <1337697906.4269.10.camel@lade.trondhjem.org>
References: <20120522073709.20602.33027.stgit@localhost.localdomain>
	  <20120522080307.21303.60025.stgit@localhost.localdomain>
	 <1337697459.4269.7.camel@lade.trondhjem.org>
	 <4FBBA59F.2050001@parallels.com>
In-Reply-To: <4FBBA59F.2050001@parallels.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA1LTIyIGF0IDE4OjQxICswNDAwLCBTdGFuaXNsYXYgS2luc2J1cnNreSB3
cm90ZToNCj4gT24gMjIuMDUuMjAxMiAxODozNywgTXlrbGVidXN0LCBUcm9uZCB3cm90ZToNCj4g
PiBPbiBUdWUsIDIwMTItMDUtMjIgYXQgMTI6MDMgKzA0MDAsIFN0YW5pc2xhdiBLaW5zYnVyc2t5
IHdyb3RlOg0KPiA+PiBTaWduZWQtb2ZmLWJ5OiBTdGFuaXNsYXYgS2luc2J1cnNreTxza2luc2J1
cnNreUBwYXJhbGxlbHMuY29tPg0KPiA+PiAtLS0NCj4gPj4gICBmcy9uZnMvY2xpZW50LmMgfCAg
ICA0ICsrKy0NCj4gPj4gICAxIGZpbGVzIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMSBkZWxl
dGlvbnMoLSkNCj4gPj4NCj4gPj4gZGlmZiAtLWdpdCBhL2ZzL25mcy9jbGllbnQuYyBiL2ZzL25m
cy9jbGllbnQuYw0KPiA+PiBpbmRleCA0NGNkNzBmLi5hZTI5ZDRmIDEwMDY0NA0KPiA+PiAtLS0g
YS9mcy9uZnMvY2xpZW50LmMNCj4gPj4gKysrIGIvZnMvbmZzL2NsaWVudC5jDQo+ID4+IEBAIC0x
NzYsOCArMTc2LDEwIEBAIHN0YXRpYyBzdHJ1Y3QgbmZzX2NsaWVudCAqbmZzX2FsbG9jX2NsaWVu
dChjb25zdCBzdHJ1Y3QgbmZzX2NsaWVudF9pbml0ZGF0YSAqY2xfDQo+ID4+DQo+ID4+ICAgI2lm
ZGVmIENPTkZJR19ORlNfVjQNCj4gPj4gICAJZXJyID0gbmZzX2dldF9jYl9pZGVudF9pZHIoY2xw
LCBjbF9pbml0LT5taW5vcnZlcnNpb24pOw0KPiA+PiAtCWlmIChlcnIpDQo+ID4+ICsJaWYgKGVy
cikgew0KPiA+PiArCQlwdXRfbmV0KGNscC0+bmV0KTsNCj4gPj4gICAJCWdvdG8gZXJyb3JfY2xl
YW51cDsNCj4gPj4gKwl9DQo+ID4+DQo+ID4+ICAgCXNwaW5fbG9ja19pbml0KCZjbHAtPmNsX2xv
Y2spOw0KPiA+PiAgIAlJTklUX0RFTEFZRURfV09SSygmY2xwLT5jbF9yZW5ld2QsIG5mczRfcmVu
ZXdfc3RhdGUpOw0KPiA+Pg0KPiA+DQo+ID4gTGV0J3MganVzdCBtb3ZlIHRoZSBhY3R1YWwgZ2V0
X25ldCgpIGNhbGwgdG8gdGhlIGVuZCBvZiB0aGUgZnVuY3Rpb24uDQo+ID4NCj4gDQo+IE9rLiBC
dXQgaXQgd2lsbCBsb29rIGEgYml0IHN0cmFuZ2UsIGxpa2UgdGhpczoNCj4gDQo+IGNscC0+bmV0
ID0gbmV0Ow0KPiAuLi4NCj4gbmZzX2dldF9jYl9pZGVudF9pZHINCj4gLi4uDQo+IGdldF9uZXQo
Y2xwLT5uZXQpDQo+IA0KPiBPciBJIGNhbiBwYXNzIG5ldCB0byBuZnNfZ2V0X2NiX2lkZW50X2lk
cigpIGFzIGEgcGFyYW1ldGVyLg0KPiBXaGljaCBzb2x1dGlvbiBpcyBtb3JlIHByZWZlcmFibGUm
Pw0KDQpKdXN0IHB1dCB0aGUgZ2V0X25ldCgpIGF0IHRoZSBlbmQuIEl0IGRvZXNuJ3QgbWF0dGVy
IGlmIGl0IGxvb2tzIGEgYml0DQpvZGQ6IHRoZSBpbnRlbnQgaXMgc3RpbGwgb2J2aW91cy4NCg0K
LS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRB
cHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
