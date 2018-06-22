Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr730137.outbound.protection.outlook.com ([40.107.73.137]:21088
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751377AbeFVWbh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Jun 2018 18:31:37 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        "chucklever@gmail.com" <chucklever@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "manjunath.b.patil@oracle.com" <manjunath.b.patil@oracle.com>
Subject: Re: [PATCH 2/2] nfsd: return ENOSPC if unable to allocate a session
 slot
Date: Fri, 22 Jun 2018 22:31:34 +0000
Message-ID: <180d25ce5474539f15a84a23258d15c71ec11ad9.camel@hammerspace.com>
References: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
         <1529598933-16506-2-git-send-email-manjunath.b.patil@oracle.com>
         <20180622175416.GA7119@fieldses.org>
         <148E65CF-D3D4-4E43-A190-822C5F7824B9@gmail.com>
In-Reply-To: <148E65CF-D3D4-4E43-A190-822C5F7824B9@gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE4LTA2LTIyIGF0IDE3OjQ5IC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
SGkgQnJ1Y2UtDQo+IA0KPiANCj4gPiBPbiBKdW4gMjIsIDIwMTgsIGF0IDE6NTQgUE0sIEouIEJy
dWNlIEZpZWxkcyA8YmZpZWxkc0BmaWVsZHNlcy5vcmc+DQo+ID4gd3JvdGU6DQo+ID4gDQo+ID4g
T24gVGh1LCBKdW4gMjEsIDIwMTggYXQgMDQ6MzU6MzNQTSArMDAwMCwgTWFuanVuYXRoIFBhdGls
IHdyb3RlOg0KPiA+ID4gUHJlc2VudGx5IG5mc2Vycl9qdWtlYm94IGlzIGJlaW5nIHJldHVybmVk
IGJ5IG5mc2QgZm9yDQo+ID4gPiBjcmVhdGVfc2Vzc2lvbg0KPiA+ID4gcmVxdWVzdCBpZiBzZXJ2
ZXIgaXMgdW5hYmxlIHRvIGFsbG9jYXRlIGEgc2Vzc2lvbiBzbG90LiBUaGlzIG1heQ0KPiA+ID4g
YmUNCj4gPiA+IHRyZWF0ZWQgYXMgTkZTNEVSUl9ERUxBWSBieSB0aGUgY2xpZW50cyBhbmQgd2hp
Y2ggbWF5IGNvbnRpbnVlIHRvDQo+ID4gPiByZS10cnkNCj4gPiA+IGNyZWF0ZV9zZXNzaW9uIGlu
IGxvb3AgbGVhZGluZyBORlN2NC4xKyBtb3VudHMgaW4gaHVuZyBzdGF0ZS4NCj4gPiA+IG5mc2QN
Cj4gPiA+IHNob3VsZCByZXR1cm4gbmZzZXJyX25vc3BjIGluIHRoaXMgY2FzZSBhcyBwZXIgcmZj
NTY2MShzZWN0aW9uLQ0KPiA+ID4gMTguMzYuNA0KPiA+ID4gc3VicG9pbnQgNC4gU2Vzc2lvbiBj
cmVhdGlvbikuDQo+ID4gDQo+ID4gSSBkb24ndCB0aGluayB0aGUgc3BlYyBhY3R1YWxseSBnaXZl
cyB1cyBhbiBlcnJvciB0aGF0IHdlIGNhbiB1c2UNCj4gPiB0byBzYXkNCj4gPiBhIENSRUFURV9T
RVNTSU9OIGZhaWxlZCBwZXJtYW5lbnRseSBmb3IgbGFjayBvZiByZXNvdXJjZXMuDQo+IA0KPiBU
aGUgY3VycmVudCBzaXR1YXRpb24gaXMgdGhhdCB0aGUgc2VydmVyIHJlcGxpZXMgTkZTNEVSUl9E
RUxBWSwNCj4gYW5kIHRoZSBjbGllbnQgcmV0cmllcyBpbmRlZmluaXRlbHkuIFRoZSBnb2FsIGlz
IHRvIGxldCB0aGUNCj4gY2xpZW50IGNob29zZSB3aGV0aGVyIGl0IHdhbnRzIHRvIHRyeSB0aGUg
Q1JFQVRFX1NFU1NJT04gYWdhaW4sDQo+IHRyeSBhIGRpZmZlcmVudCBORlMgdmVyc2lvbiwgb3Ig
ZmFpbCB0aGUgbW91bnQgcmVxdWVzdC4NCj4gDQo+IEJpbGwgYW5kIEkgYm90aCBsb29rZWQgYXQg
dGhpcyBzZWN0aW9uIG9mIFJGQyA1NjYxLiBJdCBzZWVtcyB0bw0KPiB1cyB0aGF0IHRoZSB1c2Ug
b2YgTkZTNEVSUl9OT1NQQyBpcyBhcHByb3ByaWF0ZSBhbmQgdW5hbWJpZ3VvdXMNCj4gaW4gdGhp
cyBzaXR1YXRpb24sIGFuZCBpdCBpcyBhbiBhbGxvd2VkIHN0YXR1cyBmb3IgdGhlDQo+IENSRUFU
RV9TRVNTSU9OIG9wZXJhdGlvbi4gTkZTNEVSUl9ERUxBWSBPVE9IIGlzIG5vdCBoZWxwZnVsLg0K
DQpUaGVyZSBhcmUgYSByYW5nZSBvZiBlcnJvcnMgd2hpY2ggd2UgbWF5IG5lZWQgdG8gaGFuZGxl
IGJ5IGRlc3Ryb3lpbmcNCnRoZSBzZXNzaW9uLCBhbmQgdGhlbiBjcmVhdGluZyBhIG5ldyBvbmUg
KG1haW5seSB0aGUgb25lcyB3aGVyZSB0aGUNCmNsaWVudCBhbmQgc2VydmVyIHNsb3QgaGFuZGxp
bmcgZ2V0IG91dCBvZiBzeW5jKS4gVGhhdCdzIHdoeSByZXR1cm5pbmcNCk5GUzRFUlJfTk9TUEMg
aW4gcmVzcG9uc2UgdG8gQ1JFQVRFX1NFU1NJT04gaXMgdW5oZWxwZnVsLCBhbmQgaXMgd2h5DQp0
aGUgb25seSBzYW5lIHJlc3BvbnNlIGJ5IHRoZSBjbGllbnQgd2lsbCBiZSB0byB0cmVhdCBpcyBh
cyBhIHRlbXBvcmFyeQ0KZXJyb3IuDQoNCklPVzogdGhlc2UgcGF0Y2hlcyB3aWxsIG5vdCBiZSBh
Y2NlcHRhYmxlLCBldmVuIHdpdGggYSByZXdyaXRlLCBhcyB0aGV5DQphcmUgYmFzZWQgb24gYSBm
bGF3ZWQgYXNzdW1wdGlvbi4NCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50
IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29t
DQoNCg==
