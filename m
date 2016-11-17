Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:42473 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751532AbcKQRqU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2016 12:46:20 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        "tibbs@math.uh.edu" <tibbs@math.uh.edu>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
Date: Thu, 17 Nov 2016 17:45:52 +0000
Message-ID: <1479404750.33885.1.camel@primarydata.com>
References: <ufafuwhlr72.fsf@epithumia.math.uh.edu>
         <20160225195827.GC23315@fieldses.org>
         <ufaegbvdslg.fsf@epithumia.math.uh.edu>
         <20160301004844.GA11952@fieldses.org>
         <ufay4a3c938.fsf@epithumia.math.uh.edu>
         <20160301010120.GB11952@fieldses.org>
         <ufapovfc8m4.fsf@epithumia.math.uh.edu>
         <ufa1syb402e.fsf@epithumia.math.uh.edu>
         <20161117163101.GA19161@fieldses.org>
In-Reply-To: <20161117163101.GA19161@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE2LTExLTE3IGF0IDExOjMxIC0wNTAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIFdlZCwgTm92IDE2LCAyMDE2IGF0IDAyOjU1OjA1UE0gLTA2MDAsIEphc29uIEwgVGli
Yml0dHMgSUlJIHdyb3RlOg0KPiA+IA0KPiA+IEknbSByZXBseWluZyB0byBhIHJhdGhlciBvbGQg
bWVzc2FnZSwgYnV0IHRoZSBpc3N1ZSBoYXMganVzdCBub3cNCj4gPiBwb3BwZWQNCj4gPiBiYWNr
IHVwIGFnYWluLg0KPiA+IA0KPiA+IFRvIHJlY2FwLCBhIGNsaWVudCBzdG9wcyBiZWluZyBhYmxl
IHRvIGFjY2VzcyBfYW55XyBtb3VudCBvbiBhDQo+ID4gcGFydGljdWxhciBzZXJ2ZXIsIGFuZCAi
TkZTOiBuZnM0X3JlY2xhaW1fb3Blbl9zdGF0ZTogTG9jayByZWNsYWltDQo+ID4gZmFpbGVkISIg
YXBwZWFycyBzZXZlcmFsIGh1bmRyZWQgdGltZXMgcGVyIHNlY29uZCBpbiB0aGUga2VybmVsDQo+
ID4gbG9nLg0KPiA+IFRoZSBsb2FkIGdvZXMgdXAgYnkgb25lIGZvciBldmVyIHByb2Nlc3MgYXR0
ZW1wdGluZyB0byBhY2Nlc3MgYW55DQo+ID4gbW91bnQNCj4gPiBmcm9tIHRoYXQgcGFydGljdWxh
ciBzZXJ2ZXIuwqDCoE1vdW50cyB0byBvdGhlciBzZXJ2ZXJzIGFyZSBmaW5lLCBhbmQNCj4gPiBv
dGhlciBjbGllbnRzIGNhbiBtb3VudCB0aGluZ3MgZnJvbSB0aGF0IG9uZSBzZXJ2ZXIgd2l0aG91
dA0KPiA+IHByb2JsZW1zLg0KPiA+IA0KPiA+IFdoZW4gSSBraWxsIGV2ZXJ5IHByb2Nlc3Mga2Vl
cGluZyB0aGF0IHBhcnRpY3VsYXIgbW91bnQgYWN0aXZlIGFuZA0KPiA+IHRoZW4NCj4gPiB1bW91
bnQgaXQsIEkgc2VlOg0KPiA+IA0KPiA+IE5GUzogbmZzNF9yZWNsYWltX29wZW5fc3RhdGU6IHVu
aGFuZGxlZCBlcnJvciAtMTAwNjgNCj4gDQo+IE5GUzRFUlJfUkVUUllfVU5DQUNIRURfUkVQLg0K
PiANCj4gU28sIHlvdSdyZSB1c2luZyBORlN2NC4xIG9yIDQuMiwgYW5kIHRoZSBzZXJ2ZXIgdGhp
bmtzIHRoYXQgdGhlDQo+IGNsaWVudA0KPiBoYXMgcmV1c2VkIGEgKHNsb3QsIHNlcXVlbmNlIG51
bWJlcikgcGFpciwgYnV0IHRoZSBzZXJ2ZXIgZG9lc24ndA0KPiBoYXZlIGENCj4gY2FjaGVkIHJl
c3BvbnNlIHRvIHJldHVybi4NCj4gDQo+IEhhcmQgdG8ga25vdyBob3cgdGhhdCBoYXBwZW5lZCwg
YW5kIGl0J3Mgbm90IHNob3duIGluIHRoZSBiZWxvdy4NCj4gU291bmRzIGxpa2UgYSBidWcsIHRo
b3VnaC4NCg0KLi4ub3IgYSBDdHJsLUMuLi4uDQoNCg==

