Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42379 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758935Ab2INRif (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Sep 2012 13:38:35 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] lockd: use per-net refrence-counted NSM clients
Date: Fri, 14 Sep 2012 17:38:18 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908FA7F55@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120914140811.10835.81465.stgit@localhost.localdomain>
	 <4030B8F9-5C67-4AE7-826E-B4B6AD4FAD01@oracle.com>
In-Reply-To: <4030B8F9-5C67-4AE7-826E-B4B6AD4FAD01@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTA5LTE0IGF0IDEzOjAxIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
V2hhdCBoYXBwZW5zIGlmIHN0YXRkIGlzIHJlc3RhcnRlZD8NCg0KTm90aGluZyB1bnVzdWFsLiBX
aHk/DQoNCj4gU2VudCBmcm9tIG15IGlQaG9uZQ0KPiANCj4gT24gU2VwIDE0LCAyMDEyLCBhdCAx
MDoyNSBBTSwgU3RhbmlzbGF2IEtpbnNidXJza3kgPHNraW5zYnVyc2t5QHBhcmFsbGVscy5jb20+
IHdyb3RlOg0KPiANCj4gPiBUaGlzIGlzIGEgYnVnIGZpeCBmb3IgaHR0cHM6Ly9idWd6aWxsYS5y
ZWRoYXQuY29tL3Nob3dfYnVnLmNnaT9pZD04MzA4NjIuDQo+ID4gDQo+ID4gVGhlIHByb2JsZW0g
aXMgdGhhdCB3aXRoIE5GU3Y0IG1vdW50IGluIGNvbnRhaW5lciAod2l0aCBzZXBhcmF0ZWQgbW91
bnQNCj4gPiBuYW1lc2FwY2UpIGFuZCBhY3RpdmUgbG9jayBvbiBpdCwgZHlpbmcgY2hpbGQgcmVh
cGVkIG9mIHRoaXMgY29udGFpbmVyIHdpbGwNCj4gPiB0cnkgdG8gdW1vdW50IE5GUyBhbmQgZG9p
bmcgdGhpcyB3aWxsIHRyeSB0byBjcmVhdGUgUlBDIGNsaWVudCB0byBzZW5kDQo+ID4gdW5tb25p
dG9yIHJlcXVlc3QgdG8gc3RhdGQuDQo+ID4gQnV0IGNyZWF0aW9uIG9mIFJDUCBjbGllbnQgcmVx
dWlyZXMgdmFsaWQgY3VycmVudC0+bnNwcm94eSAoZm9yIG9wZXJhdGlvbiB3aXRoDQo+ID4gdXRz
bmFtZSgpKSBhbmQgZHVyaW5nIHVtb3VudCBvbiBjaGlsZCByZWFwZXIgZXhpdCBpdCdzIGVxdWFs
IHRvIHplcm8uDQo+ID4gDQo+ID4gUHJvcG9zZWQgc29sdXRpb24gaXMgdG8gaW50cm9kdWNlIHJl
ZnJlbmNlLWNvdW50ZXIgcGVyLW5ldCBOU00gY2xpZW50LCB3aGljaA0KPiA+IGlzIGNyZWF0ZWQg
b24gZmlzdCBtb25pdG9yIGNhbGwgYW5kIGRlc3Ryb3llZCBhZnRlciB0aGUgbHN0IG1vbml0b3Ig
Y2FsbC4NCj4gPiANCj4gPiBUaGUgZm9sbG93aW5nIHNlcmllcyBpbXBsZW1lbnRzLi4uDQo+ID4g
DQo+ID4gLS0tDQo+ID4gDQo+ID4gU3RhbmlzbGF2IEtpbnNidXJza3kgKDMpOg0KPiA+ICAgICAg
bG9ja2Q6IHVzZSBycGMgY2xpZW50J3MgY2xfbm9kZW5hbWUgZm9yIGlkIGVuY29kaW5nDQo+ID4g
ICAgICBsb2NrZDogcGVyLW5ldCBOU00gY2xpZW50IGNyZWF0aW9uIGFuZCBkZXN0cnVjdGlvbiBo
ZWxwZXJzIGludHJvZHVjZWQNCj4gPiAgICAgIGxvY2tkOiBjcmVhdGUgYW5kIHVzZSBwZXItbmV0
IE5TTSBSUEMgY2xpZW50cyBvbiBNT04vVU5NT04gcmVxdWVzdHMNCj4gPiANCj4gPiANCj4gPiBm
cy9sb2NrZC9tb24uYyAgIHwgICA5MSArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrLS0tLS0tLS0tLS0NCj4gPiBmcy9sb2NrZC9uZXRucy5oIHwgICAgNCArKw0KPiA+
IGZzL2xvY2tkL3N2Yy5jICAgfCAgICAxICsNCj4gPiAzIGZpbGVzIGNoYW5nZWQsIDc3IGluc2Vy
dGlvbnMoKyksIDE5IGRlbGV0aW9ucygtKQ0KPiA+IA0KPiA+IA0KPiA+IC0tDQo+ID4gVG8gdW5z
dWJzY3JpYmUgZnJvbSB0aGlzIGxpc3Q6IHNlbmQgdGhlIGxpbmUgInVuc3Vic2NyaWJlIGxpbnV4
LW5mcyIgaW4NCj4gPiB0aGUgYm9keSBvZiBhIG1lc3NhZ2UgdG8gbWFqb3Jkb21vQHZnZXIua2Vy
bmVsLm9yZw0KPiA+IE1vcmUgbWFqb3Jkb21vIGluZm8gYXQgIGh0dHA6Ly92Z2VyLmtlcm5lbC5v
cmcvbWFqb3Jkb21vLWluZm8uaHRtbA0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZT
IGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20N
Cnd3dy5uZXRhcHAuY29tDQo=
