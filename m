Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44471 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752041Ab2JMDFP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Oct 2012 23:05:15 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Larry McVoy <lm@bitmover.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Date: Sat, 13 Oct 2012 03:05:11 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9091FE78E@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121012211701.GA8301@bitmover.com>
	 <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
	 <20121013002100.GB23247@bitmover.com>
	 <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDED5@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121013023147.GJ23247@bitmover.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FE478@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121013025600.GL23247@bitmover.com>
In-Reply-To: <20121013025600.GL23247@bitmover.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTEwLTEyIGF0IDE5OjU2IC0wNzAwLCBMYXJyeSBNY1ZveSB3cm90ZToNCj4g
T24gU2F0LCBPY3QgMTMsIDIwMTIgYXQgMDI6NTI6NTFBTSArMDAwMCwgTXlrbGVidXN0LCBUcm9u
ZCB3cm90ZToNCj4gPiBPbiBGcmksIDIwMTItMTAtMTIgYXQgMTk6MzEgLTA3MDAsIExhcnJ5IE1j
Vm95IHdyb3RlOg0KPiA+ID4gQXMgSSd2ZSBzYWlkLCBkZWJ1Z2dpbmcgdGhpcyBpcyBnb2luZyB0
byBiZSBoYXJkLCBpdCBtZWFucyBzdG9wcGluZyBteQ0KPiA+ID4gY29tcGFueS4gIFdlIGNhbiBk
byBvbmUgbW9yZSBjcmFzaCwgeW91IGd1eXMgY2FuIHRlbGwgbWUgd2hhdCB0byBkbywNCj4gPiA+
IGJ1dCB0aGF0J3MgYWJvdXQgaXQuDQo+ID4gDQo+ID4gRG8geW91IGhhdmUgYSByZXByb2R1Y2Vy
PyANCj4gDQo+IE9oIHllYWgsIGl0IGhhcHBlbnMgZXZlcnkgdGltZS4gIFJ1biBza3lwZSBvbiBh
IG1hYyB3LyB5b3VyIGhvbWUgZGlyIE5GUw0KPiBtb3VudGVkLiAgU2t5cGUgdHJpZXMgdG8gZG8g
c29tZSBsb2NrIG9wZXJhdGlvbiBhbmQgdGhlIG1hY2hpbmUgcGFuaWNzLg0KPiANCj4gV2UndmUg
ZG9uZSBpdCA0IHRpbWVzIGluIGEgcm93IHRvIGJlIHN1cmUgd2Ugd2VyZW4ndCBzbW9raW5nIGNy
YWNrLiAgTm8NCj4gY3JhY2suICBKdXN0IHBhbmljcy4NCg0KVGhhbmtzISBUaGF0IHNob3VsZCBi
ZSBlYXN5IHRvIGR1cGxpY2F0ZS4NCg0KSSdsbCBnaXZlIGl0IGEgc2hvdCB0b21vcnJvdywgYW5k
IHNlZSBpZiBJIGNhbiBnZXQgYSB3aXJlc2hhcmsgdHJhY2UuLi4NCg0KLS0gDQpUcm9uZCBNeWts
ZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xl
YnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
