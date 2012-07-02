Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33467 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153Ab2GBTkY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jul 2012 15:40:24 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "harshula@redhat.com" <harshula@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "mgorman@suse.de" <mgorman@suse.de>,
        "jan.kratochvil@redhat.com" <jan.kratochvil@redhat.com>
Subject: Re: [RFC PATCH v2] nfs: skip commit in releasepage if we're freeing
 memory for fs-related reasons
Date: Mon, 2 Jul 2012 19:40:22 +0000
Message-ID: <1341258017.8197.46.camel@lade.trondhjem.org>
References: <1340895773.5293.18.camel@lade.trondhjem.org>
	 <1340897113-18449-1-git-send-email-jlayton@redhat.com>
	 <20120702111751.3ac78d2c@tlielax.poochiereds.net>
In-Reply-To: <20120702111751.3ac78d2c@tlielax.poochiereds.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA3LTAyIGF0IDExOjE3IC0wNDAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
bmZzOiBicm9hZGVuIHRoZSBjYXNlcyB3aGVyZSB3ZSB1c2UgYSBub24tYmxvY2tpbmcgY29tbWl0
IGluIHJlbGVhc2VwYWdlDQo+IA0KPiBDdXJyZW50bHksIHdlIGp1c3QgZG8gYSBub24tYmxvY2tp
bmcgY29tbWl0IHdoZW4gY2FsbGVkIGZyb20ga3N3YXBkLCBidXQNCj4gdGhhdCBzdGlsbCBnaXZl
cyB1cyBzb21lIGNhc2VzIHdoZXJlIHdlIGVuZCB1cCBibG9ja2luZyBhZnRlciByZWN1cnNpbmcN
Cj4gYmFjayBpbnRvIHRoZSBmaWxlc3lzdGVtLiBJbnN0ZWFkLCB0dXJuIHRoYXQgY2hlY2sgaW50
byBhIGNoZWNrIGZvcg0KPiBQRl9NRU1BTExPQyBzbyB0aGF0IHdlIG5ldmVyIGJsb2NrIHdoZW4g
dHJ5aW5nIHRvIGZyZWUgbWVtb3J5IGluIG9yZGVyIHRvDQo+IHNhdGlzZnkgYW4gYWxsb2NhdGlv
bi4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEplZmYgTGF5dG9uIDxqbGF5dG9uQHJlZGhhdC5jb20+
DQo+IC0tLQ0KPiAgZnMvbmZzL2ZpbGUuYyB8ICAgIDQgKystLQ0KPiAgMSBmaWxlcyBjaGFuZ2Vk
LCAyIGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZnMv
bmZzL2ZpbGUuYyBiL2ZzL25mcy9maWxlLmMNCj4gaW5kZXggOTA3NTc2OS4uNjFkMzY3MCAxMDA2
NDQNCj4gLS0tIGEvZnMvbmZzL2ZpbGUuYw0KPiArKysgYi9mcy9uZnMvZmlsZS5jDQo+IEBAIC00
NjYsOCArNDY2LDggQEAgc3RhdGljIGludCBuZnNfcmVsZWFzZV9wYWdlKHN0cnVjdCBwYWdlICpw
YWdlLCBnZnBfdCBnZnApDQo+ICAJICAgICEoY3VycmVudC0+ZmxhZ3MgJiBQRl9GU1RSQU5TKSkg
ew0KPiAgCQlpbnQgaG93ID0gRkxVU0hfU1lOQzsNCj4gIA0KPiAtCQkvKiBEb24ndCBsZXQga3N3
YXBkIGRlYWRsb2NrIHdhaXRpbmcgZm9yIE9PTSBSUEMgY2FsbHMgKi8NCj4gLQkJaWYgKGN1cnJl
bnRfaXNfa3N3YXBkKCkpDQo+ICsJCS8qIERvbid0IGJsb2NrIGlmIHdlJ3JlIGZyZWVpbmcgZm9y
IGEgbWVtb3J5IGFsbG9jYXRpb24gKi8NCj4gKwkJaWYgKGN1cnJlbnQtPmZsYWdzICYgUEZfTUVN
QUxMT0MpDQo+ICAJCQlob3cgPSAwOw0KPiAgCQluZnNfY29tbWl0X2lub2RlKG1hcHBpbmctPmhv
c3QsIGhvdyk7DQo+ICAJfQ0KDQpVbW0uLi4gU28gd2hpY2ggcHJvY2VzcyB3aWxsIGFjdHVhbGx5
IGNhbGwgbmZzX3JlbGVhc2VfcGFnZSgpIHdpdGgNCkdGUF9LRVJORUwsIGJ1dCB3aXRob3V0IHRo
ZSBQRl9NRU1BTExPQyBmbGFnIGJlaW5nIHNldD8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxp
bnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRh
cHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
