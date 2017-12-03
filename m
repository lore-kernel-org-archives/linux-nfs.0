Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:47428 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752094AbdLCUY5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Dec 2017 15:24:57 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "chucklever@gmail.com" <chucklever@gmail.com>
CC: "Anna.Schumaker@Netapp.com" <Anna.Schumaker@Netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Fix a race in the receive code path
Date: Sun, 3 Dec 2017 20:24:52 +0000
Message-ID: <1512332690.28811.3.camel@primarydata.com>
References: <20171203185012.24473-1-trond.myklebust@primarydata.com>
         <9F7B84A7-B241-49D3-8F9D-36338669C827@gmail.com>
         <1512331965.24703.5.camel@primarydata.com>
         <0CE894EE-2CB0-4716-BEFA-C946FBE3A27A@gmail.com>
In-Reply-To: <0CE894EE-2CB0-4716-BEFA-C946FBE3A27A@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU3VuLCAyMDE3LTEyLTAzIGF0IDE1OjE5IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBEZWMgMywgMjAxNywgYXQgMzoxMiBQTSwgVHJvbmQgTXlrbGVidXN0IDx0cm9uZG15QHBy
aW1hcnlkYXRhLmNvDQo+ID4gbT4gd3JvdGU6DQo+ID4gDQo+ID4gT24gU3VuLCAyMDE3LTEyLTAz
IGF0IDEzOjU0IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4gPiA+ID4gT24gRGVjIDMsIDIw
MTcsIGF0IDE6NTAgUE0sIFRyb25kIE15a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QHByDQo+ID4g
PiA+IGltYXINCj4gPiA+ID4geWRhdGEuY29tPiB3cm90ZToNCj4gPiA+ID4gDQo+ID4gPiA+IFdl
IG11c3QgZW5zdXJlIHRoYXQgdGhlIGNhbGwgdG8gcnBjX3NsZWVwX29uKCkgaW4NCj4gPiA+ID4g
eHBydF90cmFuc21pdCgpDQo+ID4gPiA+IGNhbm5vdA0KPiA+ID4gPiByYWNlIHdpdGggdGhlIGNh
bGwgdG8geHBydF9jb21wbGV0ZV9ycXN0KCkuDQo+ID4gPiANCj4gPiA+IDotKCB0aGlzIHdpbGwg
a2lsbCBzY2FsYWJpbGl0eSwgd2UgbWlnaHQgYXMgd2VsbCBqdXN0IGdvIGJhY2sNCj4gPiA+IHRv
IHRoZSBvbGQgbG9ja2luZyBzY2hlbWUuDQo+ID4gDQo+ID4gSXQgc2hvdWxkbid0IG1ha2UgYSBo
dWdlIGRpZmZlcmVuY2UsIGJ1dCBJIGFncmVlIHRoYXQgd2UgZG8gd2FudCB0bw0KPiA+IGdldA0K
PiA+IHJpZCBvZiB0aGF0IHRyYW5zcG9ydCBsb2NrLg0KPiA+IA0KPiA+IEhvdyBhYm91dCB0aGUg
Zm9sbG93aW5nLCB0aGVuPw0KPiANCj4gVGhpcyBsb29rcyBiZXR0ZXIsIEknbGwgZ2l2ZSBpdCBh
IHRyeSENCj4gDQo+IEJ1dCB0b3VjaGluZyB0aGUgcmVjdl9sb2NrIGluIHRoZSB0cmFuc21pdCBw
YXRoIGlzIHdoYXQgSSdkIGxpa2UNCj4gdG8gYXZvaWQgY29tcGxldGVseSwgaWYgcG9zc2libGUu
IEknbSBub3QgY2xlYXIgb24gd2h5IHRoZSBwZW5kaW5nDQo+IHdhaXRxdWV1ZSBpcyB1bnByb3Rl
Y3RlZC4gRG9lc24ndCBpdCBoYXZlIGEgbG9jayBvZiBpdHMgb3duPw0KDQpUaGUgcmVjdl9sb2Nr
IGVuc3VyZXMgdGhhdCB0aGUgY2hlY2sgb2YgcmVxLT5ycV9yZXBseV9ieXRlc19yZWN2ZCBpcw0K
YXRvbWljIHdpdGggdGhlIGNhbGwgdG8gcnBjX3NsZWVwX29uKCkuDQoNCi0tIA0KVHJvbmQgTXlr
bGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5t
eWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

