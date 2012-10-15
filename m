Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4862 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299Ab2JOEiF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 00:38:05 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Bruce Fields <bfields@fieldses.org>
CC: Larry McVoy <lm@bitmover.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Date: Mon, 15 Oct 2012 04:38:02 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA909236E9E@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121012211701.GA8301@bitmover.com>
	 <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
	 <20121013002100.GB23247@bitmover.com>
	 <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDED5@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121013023147.GJ23247@bitmover.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FE478@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121013025600.GL23247@bitmover.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FFA38@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121014014215.GO23247@bitmover.com> <20121015004302.GF32420@fieldses.org>
In-Reply-To: <20121015004302.GF32420@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU3VuLCAyMDEyLTEwLTE0IGF0IDIwOjQzIC0wNDAwLCBCcnVjZSBGaWVsZHMgd3JvdGU6DQo+
IE9uIFNhdCwgT2N0IDEzLCAyMDEyIGF0IDA2OjQyOjE1UE0gLTA3MDAsIExhcnJ5IE1jVm95IHdy
b3RlOg0KPiA+ID4gUFM6IHlvdSBhcmUgcHJlc3VtYWJseSBydW5uaW5nIE5GU3YyIG9uIHlvdXIg
TWFjcy4gT2RkIHRoYXQgdGhleSBzaG91bGQNCj4gPiA+IGRlZmF1bHQgdG8gdGhhdC4uLg0KPiA+
IA0KPiA+IEkgZHVubm8gaWYgdGhleSBkZWZhdWx0IHRvIHRoYXQgb3Igd2UgZm9yY2UgdGhhdC4g
IFdlIGhhdmUgaGFkIGxvdHMgb2YNCj4gPiBwcm9ibGVtcyB3aXRoIExpbnV4IE5GUywgd2UgZXhw
b3J0IG91ciBob21lIGRpcmVjdG9yaWVzIGJ1dCB0aGV5IGFyZQ0KPiA+IG1vcmUgb3IgbGVzcyBy
ZWFkIG9ubHkuDQo+ID4gDQo+ID4gTWF5YmUgdGhpbmdzIGhhdmUgZ290dGVuIGJldHRlciBidXQg
YmFjayBpbiB0aGUgZGF5IEkgY291bGQgY3Jhc2ggdGhlDQo+ID4ga2VybmVsIHdpdGggYSBiayBj
bG9uZSB0byBhIE5GUyBkaXJlY3RvcnkuDQo+IA0KPiBCdWcgcmVwb3J0cyB3ZWxjb21lZCBpZiBh
bnkgb2YgdGhvc2UgYnVncyBhcmUgc3RpbGwgYXJvdW5kLg0KDQpUaGUgb3RoZXIgdGhpbmcgdG8g
bm90ZSBpcyB0aGF0IGF0IHRoaXMgcG9pbnQsIE5GU3YyIGhhcyBiZWVuIGxlZ2FjeQ0KY29kZSBm
b3IgbW9yZSB0aGFuIDEwIHllYXJzIG9uIExpbnV4IGFuZCBpcyBzdGFydGluZyB0byBzdWZmZXIg
YmlnIHRpbWUNCmZyb20gYml0IHJvdC4gV2Ugc2hvdWxkIHByb2JhYmx5IGFpbSB0byByZW1vdmUg
aXQgZW50aXJlbHkgaW4gdGhlIG5leHQNCjEtMiB5ZWFycy4gVGhlcmUgaXMgbm8gcGxhY2UgaW4g
dG9kYXkncyB3b3JsZCBmb3IgYSBwcm90b2NvbCB0aGF0IGNhbg0Kb25seSBkZWFsIHdpdGggYSAy
R0IgbWF4aW11bSBmaWxlIHNpemUuLi4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5G
UyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29t
DQp3d3cubmV0YXBwLmNvbQ0K
