Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53999 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964932Ab2HHSDx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 14:03:53 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Isaman, Fred" <Fred.Isaman@netapp.com>
CC: "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>,
        Boaz Harrosh <bharrosh@panasas.com>, Benny Halevy <bhalevy@tonian.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: client kernel panic on server restart
Date: Wed, 8 Aug 2012 18:03:49 +0000
Message-ID: <1344449028.8925.12.camel@lade.trondhjem.org>
References: <CAGue13pvN_-wBqQVoNdkLO+pexF1hrs+d3exPCCSzOO8ZD4WRw@mail.gmail.com>
	 <1344447279.8925.5.camel@lade.trondhjem.org>
	 <CADnza47D=j2jh+AHR9vs36HqpCmcES02v4FkDNufepdS3c-CDQ@mail.gmail.com>
In-Reply-To: <CADnza47D=j2jh+AHR9vs36HqpCmcES02v4FkDNufepdS3c-CDQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTA4LTA4IGF0IDEzOjUxIC0wNDAwLCBGcmVkIElzYW1hbiB3cm90ZToNCj4g
T24gV2VkLCBBdWcgOCwgMjAxMiBhdCAxOjM0IFBNLCBNeWtsZWJ1c3QsIFRyb25kDQo+IDxUcm9u
ZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbT4gd3JvdGU6DQo+ID4gT24gV2VkLCAyMDEyLTA4LTA4IGF0
IDE4OjQ4ICswMjAwLCBUaWdyYW4gTWtydGNoeWFuIHdyb3RlOg0KPiA+PiBIaSwNCj4gPj4NCj4g
Pj4gSXQncyBxdWl0ZSBzb21lIHRpbWUgd2l0aG91dCBrZXJuZWwgcGFuaWMgcmVwb3J0cyBmcm9t
IG1lIC4uLi4NCj4gPj4NCj4gPj4gT2JzZXJ2ZXIgb24gTURTIGFuZCBEUyBzaHV0ZG93biBkdXJp
bmcgSU8uDQo+ID4+DQo+ID4+IFRoaXMgaXMgd2l0aCAgMy41LjAtMi5mYzE3Lng4Nl82NCBrZXJu
ZWwuIExpbmUgaW4gY29kZToNCj4gPj4NCj4gPj4gbmZzNHByb2MuYzo2MjUyIDogICBCVUdfT04o
IWxpc3RfZW1wdHkoJmxvLT5wbGhfc2VncykpOw0KPiA+Pg0KPiA+DQo+ID4gSWYgdGhlIHNlcnZl
ciBkb2Vzbid0IHJldHVybiBhIHN0YXRlaWQsIHRoZW4gdGhhdCBpcyBzdXBwb3NlZCB0bw0KPiA+
IGluZGljYXRlIHRoYXQgaXQgdGhpbmtzIHRoYXQgaXQgZG9lc24ndCBob2xkIGFueSBtb3JlIGxh
eW91dCBzZWdtZW50cw0KPiA+IGZvciB0aGlzIGZpbGUuDQo+ID4gVG8gbWUsIHRoYXQgaW5kaWNh
dGVzIHRoYXQgd2Ugc2hvdWxkIGJlIGNhbGxpbmcNCj4gPiBtYXJrX21hdGNoaW5nX2xzZWdzX2lu
dmFsaWQoKSByYXRoZXIgdGhhbiBPb3BzaW5nLg0KPiA+DQo+ID4gQW55IGRpc3NlbnRpbmcgdm9p
Y2VzIGZyb20gdGhlIHBORlMgY3Jvd2Q/DQo+ID4NCj4gDQo+IEJ1dCB0aGlzIGltcGxpZXMgdGhh
dCB0aGUgY2xpZW50IHRoaW5rcyBpdCBoYXMgYSBsYXlvdXQgd2hpY2ggdGhlDQo+IHNlcnZlciBk
b2VzIG5vdCBiZWxpZXZlIGl0IGhhcywgd2hpY2ggc2VlbXMgdG8gbWUgdG8gaW1wbHkgYW4gZWFy
bGllcg0KPiBidWcuICBJZiB5b3UgY2hhbmdlIHRvIG1hcmtfbWF0Y2hpbmdfbHNlZ3NfaW52YWxp
ZCwgSSB3b3VsZCBzdWdnZXN0DQo+IGtlZXBpbmcgYSBXQVJOX09OLg0KDQpXZSBjb3VsZCBwb3Nz
aWJseSBhZGQgYSBwcmludGssIGJ1dCBJIGRvbid0IHNlZSB3aGF0IHZhbHVlIGEgV0FSTl9PTg0K
d291bGQgaGF2ZSBoZXJlOiBob3cgaXMgYSBzdGFjayBkdW1wIGdvaW5nIHRvIGJlIHVzZWZ1bCBp
biBkZWJ1Z2dpbmcNCnRoaXMgaXNzdWU/DQoNCkFsc28sIGRvbid0IHdlIHNvbWV0aW1lcyBleHBl
Y3QgdGhpcyBzb3J0IG9mIHRoaW5nIHRvIGhhcHBlbiBvbg0Kb2NjYXNpb24/IFdoYXQgaWYgb3Vy
IGxheW91dHJldHVybiBlbmRzIHVwIHJhY2luZyB3aXRoIHRoZSBsYXlvdXQgcmVjYWxsDQpmb2xs
b3dpbmcgYSBEUyBzaHV0ZG93bj8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBj
bGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3
d3cubmV0YXBwLmNvbQ0KDQo=
