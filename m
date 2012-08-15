Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065Ab2HONiD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Aug 2012 09:38:03 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Richard Ems <richard.ems@cape-horn-eng.com>
CC: Jeff Layton <jlayton@redhat.com>, Al Viro <viro@ZenIV.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs_lookup_revalidate BUG ?
Date: Wed, 15 Aug 2012 13:38:00 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA93AB714@SACEXCMBX04-PRD.hq.netapp.com>
References: <502A21A1.7020206@cape-horn-eng.com>
	  <4FA345DA4F4AE44899BD2B03EEEC2FA93A4848@SACEXCMBX04-PRD.hq.netapp.com>
	  <20120814183512.GI23464@ZenIV.linux.org.uk>
	  <4FA345DA4F4AE44899BD2B03EEEC2FA93A4DFC@SACEXCMBX04-PRD.hq.netapp.com>
	  <20120814151143.30fb9ca9@tlielax.poochiereds.net>
	  <502B8E9A.9010601@cape-horn-eng.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA93AB5CB@SACEXCMBX04-PRD.hq.netapp.com>
	 <502BA2A0.6000208@cape-horn-eng.com>
In-Reply-To: <502BA2A0.6000208@cape-horn-eng.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTA4LTE1IGF0IDE1OjIyICswMjAwLCBSaWNoYXJkIEVtcyB3cm90ZToNCj4g
T24gMDgvMTUvMjAxMiAwMzoyMCBQTSwgTXlrbGVidXN0LCBUcm9uZCB3cm90ZToNCj4gPj4gKGdk
YikgbGlzdCAqKG5mc19sb29rdXBfcmV2YWxpZGF0ZSsweDJkKQ0KPiA+PiAweDU5Y2QgaXMgaW4g
bmZzX2xvb2t1cF9yZXZhbGlkYXRlICgvdXNyL3NyYy9kZWJ1Zy9rZXJuZWwtZGVmYXVsdC0zLjUu
MS9saW51eC0zLjUvZnMvbmZzL2Rpci5jOjExMjkpLg0KPiA+PiAxMTI0ICAgICAgICAgICAgc3Ry
dWN0IGRlbnRyeSAqcGFyZW50Ow0KPiA+PiAxMTI1ICAgICAgICAgICAgc3RydWN0IG5mc19maCAq
ZmhhbmRsZSA9IE5VTEw7DQo+ID4+IDExMjYgICAgICAgICAgICBzdHJ1Y3QgbmZzX2ZhdHRyICpm
YXR0ciA9IE5VTEw7DQo+ID4+IDExMjcgICAgICAgICAgICBpbnQgZXJyb3I7DQo+ID4+IDExMjgN
Cj4gPj4gMTEyOSAgICAgICAgICAgIGlmIChuZC0+ZmxhZ3MgJiBMT09LVVBfUkNVKQ0KPiA+IA0K
PiA+IEJ1bW1lci4uLiBXZSBjaGVjayBpZiAnbmQnIGlzIE5VTEwgZXZlcnl3aGVyZSBleGNlcHQg
aGVyZS4uLg0KPiA+IA0KPiA+IE9LLiBDaGFuZ2luZyB0aGUgYWJvdmUgbGluZSB0bw0KPiA+IA0K
PiA+IAlpZiAobmQgJiYgKG5kLT5mbGFncyAmIExPT0tVUF9SQ1UpKQ0KPiA+IA0KPiA+IHdpbGwg
Zml4IHRoZSBwcm9ibGVtLg0KPiANCj4gT2ssIGdyZWF0ICENCj4gRG8geW91IHRoaW5rIHRoaXMg
Zml4IHdpbGwgZ28gaW50byAzLjUuMiA/DQoNCkknbGwgdHJ5IHRvIGdldCBpdCBpbnRvIHN0YWJs
ZS4gMy42LXJjWCBpcyB1bmFmZmVjdGVkIGJ5IHRoZSBidWcgZHVlIHRvDQpyZWNlbnQgVkZTIGNo
YW5nZXMgdGhhdCBoYXZlIHJlbW92ZWQgdGhlICJzdHJ1Y3QgbmFtZWlkYXRhICoiIGFyZ3VtZW50
DQp0byBuZnNfbG9va3VwX3JldmFsaWRhdGUuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51
eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBw
LmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
