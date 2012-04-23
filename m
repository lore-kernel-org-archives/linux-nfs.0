Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:56983 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754546Ab2DWVca (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Apr 2012 17:32:30 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4: Ensure we do not reuse open owner names
Date: Mon, 23 Apr 2012 21:32:28 +0000
Message-ID: <1335216748.11427.38.camel@lade.trondhjem.org>
References: <1335213414-20826-1-git-send-email-Trond.Myklebust@netapp.com>
	 <418AC7C0-6289-40D0-85DB-092C29BA40D3@oracle.com>
	 <1335214124.11427.23.camel@lade.trondhjem.org>
	 <537D97FE-BB59-4541-A705-C01178025C48@oracle.com>
In-Reply-To: <537D97FE-BB59-4541-A705-C01178025C48@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA0LTIzIGF0IDE2OjU3IC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
T24gQXByIDIzLCAyMDEyLCBhdCA0OjQ4IFBNLCBNeWtsZWJ1c3QsIFRyb25kIHdyb3RlOg0KPiAN
Cj4gPiBPbiBNb24sIDIwMTItMDQtMjMgYXQgMTY6NDQgLTA0MDAsIENodWNrIExldmVyIHdyb3Rl
Og0KPiA+PiBIaS0NCj4gPj4gDQo+ID4+IEkgd2lzaCB5b3UgaGFkIHRvbGQgbWUgeW91IHdlcmUg
Z29pbmcgdG8gZml4IHRoaXMgdG9vLiAgSSd2ZSBiZWVuIHRlc3RpbmcgYSBmaXggZm9yIHRoaXMg
Zm9yIGEgY291cGxlIHdlZWtzLiAgV2FzIGdvaW5nIHRvIHBvc3QgdGhpcyBhZnRlcm5vb24uICBT
aGFsbCBJIHRvc3MgbWluZT8NCj4gPiANCj4gPiBJIHdhcyBoaXR0aW5nIHRoYXQgQkFEX1NFUUlE
IHN0b3JtIGR1cmluZyB0ZXN0aW5nIG9mIHRoZSBvdGhlciBvcGVuDQo+ID4gZml4ZXMgbGFzdCB3
ZWVrLg0KPiANCj4gRmFpciBlbm91Z2gsIGJ1dCBJIGFubm91bmNlZCBJIGhhZCBhIGZpeCBpbiBt
eSBBcHJpbCAxNSBzdGF0dXMgcmVwb3J0LiAgT2ggd2VsbC4NCj4gDQo+IFNvLCBJIGRlY2lkZWQg
dGhhdCBhIHRpbWVzdGFtcCB3b3VsZCBsZWFrIGluZm9ybWF0aW9uIGFib3V0IHRoZSBjbGllbnQs
IHNvIEknbSB1c2luZyBhIHNpbXBsZSBjb3VudGVyIGluc3RlYWQuICBXb3VsZCB5b3UgY29uc2lk
ZXIgdGhhdCBmb3IgeW91ciBwYXRjaD8NCg0KSG93IHdvdWxkIGEgdGltZXN0YW1wIGxlYWsgdXNl
ZnVsIGluZm9ybWF0aW9uPyBUaGUgc2VydmVyIGFuZCBhbnlvbmUNCm1vbml0b3JpbmcgdGhlIE5G
UyB0cmFmZmljIGFscmVhZHkga25vd3MgYXQgd2hhdCB0aW1lIHRoZSBvcGVuIG93bmVyIHdhcw0K
Y3JlYXRlZCB0byB3aXRoaW4gYSBmZXcgbWlsbGlzZWNvbmRzLg0KDQoNCi0tIA0KVHJvbmQgTXlr
bGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWts
ZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
