Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31885 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146Ab2CHUuQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 15:50:16 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Olga Kornievskaia <aglo@citi.umich.edu>,
        Miklos Szeredi <miklos@szeredi.hu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSv4: Return the delegation if the server returns
 NFS4ERR_OPENMODE
Date: Thu, 8 Mar 2012 20:50:14 +0000
Message-ID: <1331239814.11759.1.camel@lade.trondhjem.org>
References: <87k42yjb0c.fsf@tucsk.pomaz.szeredi.hu>
	 <1331160049-3842-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1331160049-3842-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1331160049-3842-3-git-send-email-Trond.Myklebust@netapp.com>
	 <CAN-5tyG-w+ie3sxTwNA6e9x=CojxyDaJScJuCbS+9VE=yTmJNA@mail.gmail.com>
	 <1331230525.2472.39.camel@lade.trondhjem.org>
	 <CAN-5tyFYE5ECtv__C9S_GMT1gBMQ4+6WPS-1BjmSE7vHoRAQdw@mail.gmail.com>
	 <20120308204205.GB9273@fieldses.org>
In-Reply-To: <20120308204205.GB9273@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTAzLTA4IGF0IDE1OjQyIC0wNTAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIFRodSwgTWFyIDA4LCAyMDEyIGF0IDAzOjIzOjM0UE0gLTA1MDAsIE9sZ2EgS29ybmll
dnNrYWlhIHdyb3RlOg0KPiA+IE9uIFRodSwgTWFyIDgsIDIwMTIgYXQgMToxNSBQTSwgTXlrbGVi
dXN0LCBUcm9uZA0KPiA+IDxUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbT4gd3JvdGU6DQo+ID4g
PiBPbiBUaHUsIDIwMTItMDMtMDggYXQgMTI6NTIgLTA1MDAsIE9sZ2EgS29ybmlldnNrYWlhIHdy
b3RlOg0KPiA+ID4+IHdvdWxkbid0IGl0IGJlIGJldHRlciBmb3IgeW91IHRvIHByb2FjdGl2ZWx5
IHJldHVybiBhIHJlYWQgZGVsZWdhdGlvbg0KPiA+ID4+IHRoZW4gdW5uZWNlc3NhcmlseSBlcnJv
cmluZz8NCj4gPiA+DQo+ID4gPiBJZiBub2JvZHkgZWxzZSBob2xkcyBhIGRlbGVnYXRpb24sIHRo
ZW4gdGhlIE5GUyBjbGllbnQgaXMgYWN0dWFsbHkNCj4gPiA+IGFsbG93ZWQgdG8ga2VlcCBpdHMg
cmVhZCBkZWxlZ2F0aW9uIHdoaWxlIHdyaXRpbmcgdG8gdGhlIGZpbGUuIEl0IGRvZXMNCj4gPiA+
IGFkbWl0dGVkbHkgbmVlZCB0byByZXF1ZXN0IGFuIE9QRU4gc3RhdGVpZCBmb3Igd3JpdGUgaW4g
dGhhdCBjYXNlLi4uDQo+ID4gPiAoU2VlIHNlY3Rpb24gMTAuNCBvZiBSRkMzNTMwYmlzIGRyYWZ0
IDE2KQ0KPiA+IA0KPiA+IElmIHdlIGJvdGggYWdyZWUgdGhhdCB0aGVyZSBoYXMgdG8gYmUgYSBy
ZXF1ZXN0IGZvciBhbiBvcGVuIHN0YXRlaWQgZm9yDQo+ID4gYSB3cml0ZSwgdGhlbiBpbnN0ZWFk
IG9mIHJldHVybmluZyB0aGUgcmVhZCBkZWxlZ2F0aW9uIGlmIHRoZSBjbGllbnQgcmVjZWl2ZXMN
Cj4gPiBlcnJfb3Blbm1vZGUgKHdoZW4gaXQgc2VuZCB0aGUgcmVxdWVzdCB3aXRoIHJlYWQgZGVs
ZWdhdGlvbiBzdGF0ZWlkDQo+ID4gYXMgeW91IHNhaWQgcGVyIDM1NjBiaXMpLCBjYW4ndCB0aGUg
Y2xpZW50IHJlc2VuZCB0aGUgc2V0YXR0ciB3aXRoIHRoZSBvcGVuDQo+ID4gc3RhdGVpZD8gVGhl
IG9yZGVyaW5nIG9mIHRoZSBzdGF0ZWlkIHVzYWdlIGlzIGEgInNob3VsZCIgYW5kIG5vdCBhICJt
dXN0Ii4NCj4gPiANCj4gPiBJbiByZmM1NjYxLCBpdCByZWFsbHkgZG9lc24ndCBtYWtlIHNlbnNl
IHRvIGV2ZXIgc2VuZCBhIHNldGF0dHIgd2l0aA0KPiA+IGEgcmVhZCBkZWxlZ2F0aW9uIHN0YXRl
aWQuIEFjY29yZGluZyB0byA5LjEuMiwgdGhlIHNlcnZlciAiTVVTVCIgcmV0dXJuDQo+ID4gZXJy
X29wZW5fbW9kZSIgZXJyb3IgaW4gdGhhdCBjYXNlLg0KPiA+IA0KPiA+IEkgZ2F0aGVyIHlvdSBh
cmUgaW4gdGhpcyBjYXNlIGRlYWxpbmcgd2l0aCA0LjAgZGVsZWdhdGlvbnMuIEJ1dCBJIHdvbmRl
cg0KPiA+IGlmIHlvdSdsbCBkbyBzb21ldGhpbmcgZWxzZSBmb3IgNC4xIGRlbGVnYXRpb24gdGhl
bj8NCj4gDQo+IDM1MzBiaXMgaGFzIHRoZSBzYW1lIGxhbmd1YWdlICgiLi4ubXVzdCB2ZXJpZnkg
dGhhdCB0aGUgYWNjZXNzIG1vZGUNCj4gYWxsb3dzIHdyaXRpbmcgYW5kIHJldHVybiBhbiBORlM0
RVJSX09QRU5NT0RFIGVycm9yIGlmIGl0IGRvZXMgbm90IikuDQoNCk9LLCBzbyB3ZSBzaG91bGRu
J3Qgc2VuZCB0aGUgZGVsZWdhdGlvbiBzdGF0ZWlkIGVpdGhlciBmb3IgdjQgb3IgdjQuMS4NCkhv
d2V2ZXIgc2hvdWxkIHdlIHByZS1lbXB0aXZlbHkgcmV0dXJuIHRoZSBkZWxlZ2F0aW9uPyBJJ3Zl
IGJlZW4NCmFzc3VtaW5nIG5vdC4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBj
bGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3
d3cubmV0YXBwLmNvbQ0KDQo=
