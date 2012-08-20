Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47764 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755548Ab2HTQLj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 12:11:39 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] NFS: put net in case of idr allocation failure
Date: Mon, 20 Aug 2012 16:11:37 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA93BF311@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120820134350.27917.55176.stgit@localhost.localdomain>
In-Reply-To: <20120820134350.27917.55176.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA4LTIwIGF0IDE3OjQzICswNDAwLCBTdGFuaXNsYXYgS2luc2J1cnNreSB3
cm90ZToNCj4gUHV0IG5ldCByZWZlcmVuY2Ugd2UgZ290IGluIG5mc19hbGxvY19jbGllbnQoKSBv
biBlcnJvciBwYXRoLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogU3RhbmlzbGF2IEtpbnNidXJza3kg
PHNraW5zYnVyc2t5QHBhcmFsbGVscy5jb20+DQo+IC0tLQ0KPiAgZnMvbmZzL25mczRjbGllbnQu
YyB8ICAgIDEgKw0KPiAgMSBmaWxlcyBjaGFuZ2VkLCAxIGluc2VydGlvbnMoKyksIDAgZGVsZXRp
b25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZnMvbmZzL25mczRjbGllbnQuYyBiL2ZzL25mcy9u
ZnM0Y2xpZW50LmMNCj4gaW5kZXggY2JjZGZhZi4uYjg5NTYyOSAxMDA2NDQNCj4gLS0tIGEvZnMv
bmZzL25mczRjbGllbnQuYw0KPiArKysgYi9mcy9uZnMvbmZzNGNsaWVudC5jDQo+IEBAIC03NCw2
ICs3NCw3IEBAIHN0cnVjdCBuZnNfY2xpZW50ICpuZnM0X2FsbG9jX2NsaWVudChjb25zdCBzdHJ1
Y3QgbmZzX2NsaWVudF9pbml0ZGF0YSAqY2xfaW5pdCkNCj4gIAlyZXR1cm4gY2xwOw0KPiAgDQo+
ICBlcnJvcjoNCj4gKwlwdXRfbmV0KGNscC0+Y2xfbmV0KTsNCj4gIAlrZnJlZShjbHApOw0KPiAg
CXJldHVybiBFUlJfUFRSKGVycik7DQo+ICB9DQoNCg0KTm8sIHRoYXQgaXNuJ3QgYW55d2hlcmUg
bmVhciBzdWZmaWNpZW50Lg0KDQpUaGUgY29ycmVjdCB0aGluZyB0byBkbyBoZXJlIGlzIHRvIHJl
cGxhY2UgdGhlIGtmcmVlIHdpdGggYSBjYWxsIHRvDQpuZnNfZnJlZV9jbGllbnQoKSwgd2hpY2gg
d2lsbCBhbHNvIGNsZWFuIHVwIHRoZSBhbGxvY2F0aW9uIG9mDQpjbF9ob3N0bmFtZSwgcHV0IHRo
ZSBtb2R1bGUsIGV0Yy4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQg
bWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0
YXBwLmNvbQ0KDQo=
