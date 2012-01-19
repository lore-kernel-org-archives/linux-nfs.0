Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38645 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932440Ab2ASReQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jan 2012 12:34:16 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Subject: RE: [PATCH 0/5] SUNRPC: make caches network namespace aware
Date: Thu, 19 Jan 2012 09:34:11 -0800
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430CE01F0E@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20120119154731.GB527@fieldses.org>
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6> <1326986392.6114.1.camel@lade.trondhjem.org> <4F18376C.9090504@parallels.com> <20120119154731.GB527@fieldses.org>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: <bfields@fieldses.org>, "Stanislav Kinsbursky" <skinsbursky@parallels.com>
Cc: "Dr James Bruce Fields" <bfields@redhat.com>, <linux-nfs@vger.kernel.org>,
        "Pavel Emelianov" <xemul@parallels.com>, <neilb@suse.de>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        "James Bottomley" <jbottomley@parallels.com>, <davem@davemloft.net>,
        <devel@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBiZmllbGRzQGZpZWxkc2VzLm9y
ZyBbbWFpbHRvOmJmaWVsZHNAZmllbGRzZXMub3JnXQ0KPiBTZW50OiBUaHVyc2RheSwgSmFudWFy
eSAxOSwgMjAxMiAxMDo0OCBBTQ0KPiBUbzogU3RhbmlzbGF2IEtpbnNidXJza3kNCj4gQ2M6IE15
a2xlYnVzdCwgVHJvbmQ7IERyIEphbWVzIEJydWNlIEZpZWxkczsgbGludXgtbmZzQHZnZXIua2Vy
bmVsLm9yZzsNCj4gUGF2ZWwgRW1lbGlhbm92OyBuZWlsYkBzdXNlLmRlOyBuZXRkZXZAdmdlci5r
ZXJuZWwub3JnOyBsaW51eC0NCj4ga2VybmVsQHZnZXIua2VybmVsLm9yZzsgSmFtZXMgQm90dG9t
bGV5OyBkYXZlbUBkYXZlbWxvZnQubmV0Ow0KPiBkZXZlbEBvcGVudnoub3JnDQo+IFN1YmplY3Q6
IFJlOiBbUEFUQ0ggMC81XSBTVU5SUEM6IG1ha2UgY2FjaGVzIG5ldHdvcmsgbmFtZXNwYWNlIGF3
YXJlDQo+IA0KPiBPbiBUaHUsIEphbiAxOSwgMjAxMiBhdCAwNzozMTo1NlBNICswNDAwLCBTdGFu
aXNsYXYgS2luc2J1cnNreSB3cm90ZToNCj4gPiAxOS4wMS4yMDEyIDE5OjE5LCBUcm9uZCBNeWts
ZWJ1c3Qg0L/QuNGI0LXRgjoNCj4gPiA+T24gVGh1LCAyMDEyLTAxLTE5IGF0IDE4OjQ4ICswNDAw
LCBTdGFuaXNsYXYgS2luc2J1cnNreSB3cm90ZToNCj4gPiA+Pk9uZSBtb3JlIHN0ZXAgdG93YXJk
cyB0byAiTkZTIGluIGNvbnRhaW5lciIuDQo+ID4gPj5XaXRoIHRoaXMgcGF0Y2ggc2V0IGNhY2hl
cyBhcmUgYWxsb2NhdGVkIHBlciBuZXR3b3JrIG5hbWVzcGFjZS4NCj4gPiA+Pg0KPiA+ID4+VGhl
IGZvbGxvd2luZyBzZXJpZXMgY29uc2lzdHMgb2Y6DQo+ID4gPj4NCj4gPiA+Pi0tLQ0KPiA+ID4+
DQo+ID4gPj5TdGFuaXNsYXYgS2luc2J1cnNreSAoNSk6DQo+ID4gPj4gICAgICAgU1VOUlBDOiBj
YWNoZSBjcmVhdGlvbiBhbmQgZGVzdHJ1Y3Rpb24gcm91dGluZXMgaW50cm9kdWNlZA0KPiA+ID4+
ICAgICAgIFNVTlJQQzogY3JlYXRlIHVuaXggZ2lkIGNhY2hlIHBlciBuZXR3b3JrIG5hbWVzcGFj
ZQ0KPiA+ID4+ICAgICAgIFNVTlJQQzogY3JlYXRlIEdTUyBhdXRoIGNhY2hlIHBlciBuZXR3b3Jr
IG5hbWVzcGFjZQ0KPiA+ID4+ICAgICAgIFNVTlJQQzogaXAgbWFwIGNhY2hlIHBlciBuZXR3b3Jr
IG5hbWVzcGFjZSBjbGVhbnVwDQo+ID4gPj4gICAgICAgU1VOUlBDOiBnZW5lcmljIGNhY2hlIHJl
Z2lzdGVyIHJvdXRpbmVzIHJlbW92ZWQNCj4gPiA+DQo+ID4gPlRoZSBwYXRjaGVzIGxvb2sgZ29v
ZCwgYW5kIEkndmUgYXBwbGllZCB0aGVtIGZvciBub3cgaW4gbXkgJ2RldmVsJw0KPiA+ID5icmFu
Y2ggc28gd2UgY2FuIHRlc3QgdGhlbSwgYnV0IEknZCBsaWtlIHRvIGdldCBhbiBBY2svTmFjayBm
cm9tDQo+ID4gPkJydWNlIGJlZm9yZSBjb21taXR0aW5nIHRvIG1lcmdpbmcgdGhlbS4NCj4gPiA+
DQo+ID4NCj4gPiBDb29sLCB0aGFua3MuDQo+ID4gQlRXLCB0aGVzZSBwYXRjaGVzIGRlcGVuZHMg
b24gcGF0Y2ggIk5GU2Q6IHVzZSBuZXR3b3JrLW5hbWVzcGFjZS0NCj4gYXdhcmUNCj4gPiBjYWNo
ZSByZWdpc3RlcmluZyByb3V0aW5lcyIsIHdoaWNoIEJydWNlIHRvb2sgYWxyZWFkeSAoYW5kIGl0
J3MgZXZlbg0KPiA+IGluIGxpbnV4LW5leHQgYWxyZWFkeSksIGJ1dCBub3QgaW4geW91ciBkZXZl
bCB0cmVlIGZvciBzb21lIHJlYXNvbi4NCj4gDQo+IEFuZCBMaW51cyBoYXMgcHVsbGVkIHRob3Nl
LCBzbyBpZiBUcm9uZCBiYXNlcyBoaXMgdHJlZSBvbiAtcmMxLCBoZSdsbCBoYXZlDQo+ICJORlNk
OiB1c2UgbmV0d29yay1uYW1lc3BhY2UtYXdhcmUgY2FjaGUgcmVnaXN0ZXJpbmcgcm91dGluZXMi
Lg0KDQpPSy4gSW4gdGhhdCBjYXNlIEkgc2hvdWxkIGhhdmUgdGhlbS4uLiANCg0K
