Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4222 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754430Ab2IJUPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Sep 2012 16:15:07 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
CC: Jeff Layton <jlayton@redhat.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] RFC Avoid expired credential keys for buffered
 writes
Date: Mon, 10 Sep 2012 20:14:33 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908F97C34@SACEXCMBX04-PRD.hq.netapp.com>
References: <1346961251-2554-1-git-send-email-andros@netapp.com>
	 <20120910145732.4d800f5b@corrin.poochiereds.net>
	 <20120910195650.GA3095@umich.edu>
In-Reply-To: <20120910195650.GA3095@umich.edu>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA5LTEwIGF0IDE1OjU2IC0wNDAwLCBKaW0gUmVlcyB3cm90ZToNCj4gSmVm
ZiBMYXl0b24gd3JvdGU6DQo+IA0KPiAgIE15IG9ubHkgY29uY2VybiBpcyB0aGlzIGJlaGF2aW9y
IGRlc2NyaWJlZCBpbiB0aGUgbGFzdCBwYXRjaDoNCj4gICANCj4gICAiSWYgdGhlIGJ1ZmZlcmVk
IFdSSVRFIGlzIHVzaW5nIGEgY3JlZGVudGlhbCBrZXkgdGhhdCB3aWxsIGV4cGlyZQ0KPiAgIHdp
dGhpbiBsb3cgd2F0ZXJtYXJrIHNlY29uZHMsIGZhaWwgdGhlIFdSSVRFIGluIG5mc193cml0ZV9i
ZWdpbg0KPiAgIF9iZWZvcmVfIHRoZSBXUklURSBpcyBidWZmZXJlZCBhbmQgcmV0dXJuIC1FQUND
RVMgdG8gdGhlIGFwcGxpY2F0aW9uLiINCj4gICANCj4gICBTaG91bGRuJ3QgcmVqZWN0aW5nIHRo
ZSB3cml0ZSBhdHRlbXB0IGJlIHRoZSBwdXJ2aWV3IG9mIHRoZSBzZXJ2ZXI/DQo+ICAgDQo+ICAg
SXQgc2VlbXMgdG8gbWUgdGhhdCB3ZSdkIGJlIGJlc3Qgb2ZmIGp1c3Qgc3dpdGNoaW5nIHRvIHN5
bmNocm9ub3VzDQo+ICAgd3JpdGVzIHdoZW4gd2Ugc3RhcnQgYXBwcm9hY2hpbmcgY3JlZGVudGlh
bCBleHBpcmF0aW9uLCBhbmQgbGV0dGluZyB0aGUNCj4gICBzZXJ2ZXIgaGFuZGxlIHRoZSBjYXNl
IHdoZXJlIHRoZSBjcmVkZW50aWFsIGV4cGlyZXMuDQo+ICAgDQo+ICAgSXQgc2VlbXMgdG8gbWUg
dGhhdCB0aGUgY2xpZW50IHNob3VsZCBqdXN0IGJlIGluIHRoZSBidXNpbmVzcyBvZg0KPiAgIHJl
Y29nbml6aW5nIHdoZW4gdGhlIGNyZWRlbnRpYWwgbWlnaHQgYmUgYWJvdXQgdG8gZXhwaXJlIGFu
ZCBhdHRlbXB0IHRvDQo+ICAgZW5zdXJlIHRoYXQgd2UgZG9uJ3QgZW5kIHVwIHdpdGggYSBidW5j
aCBvZiBidWZmZXJlZCBkYXRhIGluIHRoYXQgY2FzZS4NCj4gDQo+IEkgZG9uJ3QgbGlrZSBpdC4g
IEl0J3MgZWFzeSB0byB1bmRlcnN0YW5kIHdoeSB3cml0ZXMgbWlnaHQgZmFpbCBpZiB0aGUgY3Jl
ZHMNCj4gYXJlIGdldHRpbmcgc3RhbGUuICBJdCdzIG5vdCBzbyBlYXN5IHRvIHVuZGVyc3RhbmQg
d2h5IGNsaWVudCBiZWhhdmlvcg0KPiBjaGFuZ2VzIGluIGEgc3VidGxlIHdheSwgd2l0aCBwZXJm
b3JtYW5jZSBpbXBsaWNhdGlvbnMuDQoNCldlIGRvbid0IGtub3cgdGhhdCB0aGUgY3JlZHMgYXJl
IHN0YWxlLiBXZSBqdXN0IGtub3cgdGhhdCB0aGUgR1NTDQpzZXNzaW9uIGlzIGFib3V0IHRvIGV4
cGlyZS4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5l
cg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
DQo=
