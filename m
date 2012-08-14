Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13172 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754894Ab2HNSsz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Aug 2012 14:48:55 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: Richard Ems <richard.ems@cape-horn-eng.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs_lookup_revalidate BUG ?
Date: Tue, 14 Aug 2012 18:48:35 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA93A4DFC@SACEXCMBX04-PRD.hq.netapp.com>
References: <502A21A1.7020206@cape-horn-eng.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA93A4848@SACEXCMBX04-PRD.hq.netapp.com>
	 <20120814183512.GI23464@ZenIV.linux.org.uk>
In-Reply-To: <20120814183512.GI23464@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA4LTE0IGF0IDE5OjM1ICswMTAwLCBBbCBWaXJvIHdyb3RlOg0KPiBPbiBU
dWUsIEF1ZyAxNCwgMjAxMiBhdCAwNjowNDowOFBNICswMDAwLCBNeWtsZWJ1c3QsIFRyb25kIHdy
b3RlOg0KPiA+ID4gSXMgdGhpcyBhIGtub3duIEJVRyA/DQo+ID4gPiBXaGljaCBvdGhlciBpbmZv
cm1hdGlvbiBvciB0ZXN0IGNhbiBJIGRvIHRvIGNvbnRyaWJ1dGUgc2VhcmNoaW5nL3Jlc29sdmlu
ZyB0aGlzIGlzc3VlPw0KPiA+IA0KPiA+IEknbSBub3QgMTAwJSBjZXJ0YWluLCBidXQgaXQgbG9v
a3MgdG8gbWUgYXMgaWYgdGhlIGNhbGwgdG8gZGdldF9wYXJlbnQoKQ0KPiA+IGluIG5mc19sb29r
dXBfcmV2YWxpZGF0ZSBpcyByZXR1cm5pbmcgTlVMTC4NCj4gPiANCj4gPiBDb3VsZCB5b3UgcGxl
YXNlIGFwcGx5IHRoZSBmb2xsb3dpbmcgcGF0Y2gsIGFuZCBzZWUgaWYgdGhhdCB0cmlnZ2VycyB0
aGUNCj4gPiBXQVJOX09OIGluc3RlYWQgb2YgdGhlIGFib3ZlIE9vcHM/DQo+IA0KPiBVbmxpa2Vs
eSBhcyBoZWxsLiAgZGdldF9wYXJlbnQoKSBoYXMgb25seSBvbmUgcmV0dXJuIGluIGl0LCBhbmQg
aXQncw0KPiAgICAgICAgIEJVR19PTighcmV0LT5kX2NvdW50KTsNCj4gICAgICAgICByZXQtPmRf
Y291bnQrKzsNCj4gICAgICAgICBzcGluX3VubG9jaygmcmV0LT5kX2xvY2spOw0KPiAgICAgICAg
IHJldHVybiByZXQ7DQo+IHNvIGl0J3MgZXh0cmVtZWx5IHVubGlrZWx5IHRoYXQgaXQgd291bGQg
bWFuYWdlZCB0byByZXR1cm4gTlVMTC4gIE5vdA0KPiB3aXRob3V0IG9vcHNpbmcuLi4NCg0KQWdy
ZWVkLCBidXQgdGhlIE9vcHMgaXMgYSBOVUxMIHBvaW50ZXIgZGVyZWZlcmVuY2Ugb2Ygb2Zmc2V0
IDAwMDM4LA0Kd2hpY2ggbG9va3Mgc3VzcGljaW91c2x5IGxpa2UgYSBkZWZlcmVuY2Ugb2YgKHN0
cnVjdCBkZW50cnkpLT5kX2lub2RlLg0KVGhlcmUgYXJlIG9ubHkgMiBvZiB0aG9zZSBpbiB0aGUg
dmljaW5pdHkgb2YgbmZzX2xvb2t1cF9yZXZhbGlkYXRlKzB4MmQ6DQpvbmUgaXMgYSBkZXJlZmVy
ZW5jZSBvZiBwYXJlbnQtPmRfaW5vZGUsIHRoZSBvdGhlciBpcyBkZW50cnktPmRfaW5vZGUuLi4N
Cg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpO
ZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
