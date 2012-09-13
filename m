Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44849 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754347Ab2IMNcQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Sep 2012 09:32:16 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Yan-Pai Chen <yanpai.chen@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [3.2.5] NFSv3 CLOSE_WAIT hang
Date: Thu, 13 Sep 2012 13:32:15 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908FA24DB@SACEXCMBX04-PRD.hq.netapp.com>
References: <loom.20120905T093214-245@post.gmane.org>
	  <4FA345DA4F4AE44899BD2B03EEEC2FA908F86381@SACEXCMBX04-PRD.hq.netapp.com>
	  <6cb9.5049fd40.b47c1@altium.nl> <6cb9.5049fd40.b47c1@altium.nl>
	  <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E302@SACEXCMBX04-PRD.hq.netapp.com>
	  <447c.504a05c9.dd0a9@altium.nl> <447c.504a05c9.dd0a9@altium.nl>
	  <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E833@SACEXCMBX04-PRD.hq.netapp.com>
	  <74c7.504b9d45.a5956@altium.nl> <loom.20120910T105944-416@post.gmane.org>
	  <20120911194051.GB11160@hostway.ca>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F9BDDD@SACEXCMBX04-PRD.hq.netapp.com>
	 <loom.20120913T072025-998@post.gmane.org>
In-Reply-To: <loom.20120913T072025-998@post.gmane.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTA5LTEzIGF0IDA1OjIyICswMDAwLCBZYW4tUGFpIENoZW4gd3JvdGU6DQo+
IE15a2xlYnVzdCwgVHJvbmQgPFRyb25kLk15a2xlYnVzdEAuLi4+IHdyaXRlczoNCj4gDQo+ID4g
PiANCj4gPiA+IEkgc3VwcG9zZSB3ZSBjb3VsZCB0cnkgMy41IGF0IHRoaXMgcG9pbnQuDQo+ID4g
DQo+ID4gSWYgeW91J3ZlIGJlZW4ga2VlcGluZyB1cCB3aXRoIHRoZSAzLjIgc3RhYmxlIHJlbGVh
c2VzLCB0aGVuIEkgd291bGRuJ3QNCj4gPiBleHBlY3QgYW55IG1ham9yIGRpZmZlcmVuY2VzIHRv
IHRoZSBzdW5ycGMgY29kZSwgYnV0IGl0IG1pZ2h0IGJlIHdvcnRoIGENCj4gPiB0cnkgaW4gY2Fz
ZSB0aGUgbmV0d29ya2luZyBsYXllciBoYXMgY2hhbmdlZC4NCj4gPiANCj4gDQo+IEhpIFRyb25k
LA0KPiANCj4gSSBnb3QgdGhlIHNhbWUgcHJvYmxlbSBvbiBrZXJuZWwgMy41IHdoZW4gdXNpbmcg
VENQIG1vdW50cy4NCj4gVGhlIGh1bmcgdGFzayBpbmZvIGFuZCBycGNfZGVidWcgbWVzc2FnZXMg
d2VyZSBqdXN0IHRoZSBzYW1lIGFzIHdoYXQNCj4gSSBnb3Qgb24ga2VybmVsIDMuMy4NCg0KVGhh
bmtzLiBDYW4geW91IHRyeSB1c2luZyB0aGUgcGF0Y2ggdGhhdCBJIHBvc3RlZCBvbiB0aGUgbGlz
dCB5ZXN0ZXJkYXk/DQpJdCBzaG91bGQgYXBwbHkgY2xlYW5seSB0byB0aGUgbGF0ZXN0IDMuNS54
IGtlcm5lbC4NCg0KQ2hlZXJzDQogIFRyb25kDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5j
b20NCnd3dy5uZXRhcHAuY29tDQo=
