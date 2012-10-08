Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18800 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752782Ab2JHUEJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Oct 2012 16:04:09 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Andy Adamson <androsadamson@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSv4.1: pNFS has no business touching the slot
 table wait queue...
Date: Mon, 8 Oct 2012 20:04:06 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA90900EFF1@SACEXCMBX04-PRD.hq.netapp.com>
References: <1349718630-26008-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1349718630-26008-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1349718630-26008-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1349718630-26008-4-git-send-email-Trond.Myklebust@netapp.com>
	 <CAHVgHyV7aW8TArsu0xi0Nz6AhO98bO2qVzAvY9XZYx7hQZcx4w@mail.gmail.com>
In-Reply-To: <CAHVgHyV7aW8TArsu0xi0Nz6AhO98bO2qVzAvY9XZYx7hQZcx4w@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTEwLTA4IGF0IDE1OjU5IC0wNDAwLCBBbmR5IEFkYW1zb24gd3JvdGU6DQo+
IE9uIE1vbiwgT2N0IDgsIDIwMTIgYXQgMTo1MCBQTSwgVHJvbmQgTXlrbGVidXN0DQo+IDxUcm9u
ZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbT4gd3JvdGU6DQo+ID4gQXNpZGUgZnJvbSBpdCBiZWluZyBh
IGxheWVyaW5nIHZpb2xhdGlvbiwgdGhlcmUgaXMgbm8gcG9pbnQgaW4gZG9pbmcgc286DQo+ID4g
LSBJZiBzbG90cyBhcmUgYXZhaWxhYmxlLCB0aGVuIHRoZSB3YWl0cXVldWUgd2lsbCBiZSBlbXB0
eS4NCj4gPiAtIElmIG5vIHNsb3RzIGFyZSBhdmFpbGFibGUsIHRoZW4gdGhlIHdha2UgdXAganVz
dCBjYXVzZXMgd2FpdHF1ZXVlIGNodXJuDQo+IA0KPiBXZSBjYWxsIHJwY193YWtlX3VwIHNvIHRo
YXQgSS9PIHdhaXRpbmcgb24gdGhlIERTIHNlc3Npb24sIGFsbCBvZg0KPiB3aGljaCBuZWVkcyB0
byBiZSByZS1kaXJlY3RlZCB0byB0aGUgTURTIChub3QgdmlhIHRoZSBzdGF0ZSByZWNvdmVyeQ0K
PiBtYWNoaW5lcnkpLCB3aWxsIGJ5LXBhc3MgdGhlIFJQQyBtYWNoaW5lICJ0cnkgZWFjaCB0YXNr
IG9uZSBhdCBhIHRpbWUNCj4gYW5kIHJlZGlyZWN0IG9uIGZhaWx1cmUiIHdoaWNoIGluY2x1ZGVz
IHRoZSA2MCBzZWNvbmQgVENQIHRpbWVvdXQgb24NCj4gRFMgY29ubmVjdGlvbiBmYWlsdXJlcy4N
Cj4gDQo+IFNvLCBpdCBkb2Vzbid0IGp1c3QgY2F1c2Ugd2FpdHF1ZXVlIGNodXJuLCBpdCBzaWdu
aWZpY2FudGx5IHJlZHVjZXMNCj4gdGhlIHRpbWUgaXQgdGFrZXMgdG8gcmVjb3ZlciB0byB0aGUg
TURTLg0KPiANCg0KQWxsIGl0IGRvZXMgaXMgYSB3YWtlIHVwLi4uIFRoYXQgd2lsbCBoYXBwZW4g
X0FOWVdBWV8gYXMgc29vbiBhcyBhIHNsb3QNCmlzIG1hZGUgYXZhaWxhYmxlLg0KDQpTbyB5ZXMs
IGl0IGlzIHB1cmUgY2h1cm4uLi4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBj
bGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3
d3cubmV0YXBwLmNvbQ0K
