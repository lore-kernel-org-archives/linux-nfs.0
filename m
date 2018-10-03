Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-cys01nam02on0102.outbound.protection.outlook.com ([104.47.37.102]:19840
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726884AbeJDAvq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 Oct 2018 20:51:46 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 13/15] knfsd: Simplify NFS duplicate replay cache
Date: Wed, 3 Oct 2018 18:01:36 +0000
Message-ID: <15f0759d1fd9b6442d8634b1cb46fb59cbdf8c95.camel@hammerspace.com>
References: <20181001144157.3515-5-trond.myklebust@hammerspace.com>
         <20181001144157.3515-6-trond.myklebust@hammerspace.com>
         <20181001144157.3515-7-trond.myklebust@hammerspace.com>
         <20181001144157.3515-8-trond.myklebust@hammerspace.com>
         <20181001144157.3515-9-trond.myklebust@hammerspace.com>
         <20181001144157.3515-10-trond.myklebust@hammerspace.com>
         <20181001144157.3515-11-trond.myklebust@hammerspace.com>
         <20181001144157.3515-12-trond.myklebust@hammerspace.com>
         <20181001144157.3515-13-trond.myklebust@hammerspace.com>
         <20181001144157.3515-14-trond.myklebust@hammerspace.com>
         <20181003171424.GG17517@fieldses.org>
In-Reply-To: <20181003171424.GG17517@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE4LTEwLTAzIGF0IDEzOjE0IC0wNDAwLCBKIC4gQnJ1Y2UgRmllbGRzIHdyb3Rl
Og0KPiBPbiBNb24sIE9jdCAwMSwgMjAxOCBhdCAxMDo0MTo1NUFNIC0wNDAwLCBUcm9uZCBNeWts
ZWJ1c3Qgd3JvdGU6DQo+ID4gU2ltcGxpZnkgdGhlIGR1cGxpY2F0ZSByZXBsYXkgY2FjaGUgYnkg
aW5pdGlhbGlzaW5nIHRoZQ0KPiA+IHByZWFsbG9jYXRlZA0KPiA+IGNhY2hlIGVudHJ5LCBzbyB0
aGF0IHdlIGNhbiB1c2UgaXQgYXMgYSBrZXkgZm9yIHRoZSBjYWNoZSBsb29rdXAuDQo+ID4gDQo+
ID4gTm90ZSB0aGF0IHRoZSA5OS45OTklIGNhc2Ugd2Ugd2FudCB0byBvcHRpbWlzZSBmb3IgaXMg
c3RpbGwgdGhlIG9uZQ0KPiA+IHdoZXJlIHRoZSBsb29rdXAgZmFpbHMsIGFuZCB3ZSBoYXZlIHRv
IGFkZCB0aGlzIGVudHJ5IHRvIHRoZSBjYWNoZSwNCj4gPiBzbyBwcmVpbml0aWFsaXNpbmcgc2hv
dWxkIG5vdCBjYXVzZSBhIHBlcmZvcm1hbmNlIHBlbmFsdHkuDQo+ID4gDQo+ID4gU2lnbmVkLW9m
Zi1ieTogVHJvbmQgTXlrbGVidXN0IDx0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tPg0K
PiA+IC0tLQ0KPiA+ICBmcy9uZnNkL2NhY2hlLmggICAgfCAgNiArLS0NCj4gPiAgZnMvbmZzZC9u
ZnNjYWNoZS5jIHwgOTQgKysrKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0tLS0tLS0tLQ0K
PiA+IC0tLS0tLQ0KPiA+ICAyIGZpbGVzIGNoYW5nZWQsIDQ3IGluc2VydGlvbnMoKyksIDUzIGRl
bGV0aW9ucygtKQ0KPiA+IA0KPiA+IGRpZmYgLS1naXQgYS9mcy9uZnNkL2NhY2hlLmggYi9mcy9u
ZnNkL2NhY2hlLmgNCj4gPiBpbmRleCBiNzU1OWM2ZjJiOTcuLmJkNzdkNWY2ZmU1MyAxMDA2NDQN
Cj4gPiAtLS0gYS9mcy9uZnNkL2NhY2hlLmgNCj4gPiArKysgYi9mcy9uZnNkL2NhY2hlLmgNCj4g
PiBAQCAtMjQsMTMgKzI0LDEzIEBAIHN0cnVjdCBzdmNfY2FjaGVyZXAgew0KPiA+ICAJdW5zaWdu
ZWQgY2hhcgkJY19zdGF0ZSwJLyogdW51c2VkLCBpbnByb2csDQo+ID4gZG9uZSAqLw0KPiA+ICAJ
CQkJY190eXBlLAkJLyogc3RhdHVzLCBidWZmZXINCj4gPiAqLw0KPiA+ICAJCQkJY19zZWN1cmUg
OiAxOwkvKiByZXEgY2FtZSBmcm9tDQo+ID4gcG9ydCA8IDEwMjQgKi8NCj4gPiAtCXN0cnVjdCBz
b2NrYWRkcl9pbjYJY19hZGRyOw0KPiA+ICAJX19iZTMyCQkJY194aWQ7DQo+ID4gLQl1MzIJCQlj
X3Byb3Q7DQo+ID4gKwlfX3dzdW0JCQljX2NzdW07DQo+ID4gIAl1MzIJCQljX3Byb2M7DQo+ID4g
Kwl1MzIJCQljX3Byb3Q7DQo+ID4gIAl1MzIJCQljX3ZlcnM7DQo+ID4gIAl1bnNpZ25lZCBpbnQJ
CWNfbGVuOw0KPiA+IC0JX193c3VtCQkJY19jc3VtOw0KPiA+ICsJc3RydWN0IHNvY2thZGRyX2lu
NgljX2FkZHI7DQo+ID4gIAl1bnNpZ25lZCBsb25nCQljX3RpbWVzdGFtcDsNCj4gPiAgCXVuaW9u
IHsNCj4gPiAgCQlzdHJ1Y3Qga3ZlYwl1X3ZlYzsNCj4gDQo+IFVubGVzcyBJJ3ZlIG1pc3NlZCBz
b21ldGhpbmcgc3VidGxlLS1JJ2xsIG1vdmUgdGhpcyBjaHVuayBpbnRvIHRoZQ0KPiBuZXh0DQo+
IHBhdGNoLi0tYi4NCg0KTm90aGluZyB0b28gc3VidGxlLiBUaGUgb25seSByZWFzb24gZm9yIGtl
ZXBpbmcgaXQgaW4gdGhpcyBwYXRjaCBpcw0KYmVjYXVzZSBldmVuIHdpdGggdGhlIGN1cnJlbnQg
Y29kZSwgbW9zdCBvZiB0aGUgY29tcGFyaXNvbnMgaGl0IHRoZQ0KY194aWQgYW5kIHBvc3NpYmx5
IHNvbWV0aW1lcyB0aGUgY19jc3VtLCBzbyB0aG9zZSBhcmUgdGhlIG1haW4gZmllbGRzDQp0aGF0
IHlvdSB3YW50IHRvIHRyeSB0byBrZWVwIGluIHRoZSBzYW1lIGNhY2hlIGxpbmUuDQoNCg0KLS0g
DQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3Bh
Y2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
