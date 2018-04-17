Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-cys01nam02hn0225.outbound.protection.outlook.com ([104.47.37.225]:10880
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752606AbeDQVyl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Apr 2018 17:54:41 -0400
From: Trond Myklebust <trondmy@hammer.space>
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        "syzbot+4b98281f2401ab849f4b@syzkaller.appspotmail.com"
        <syzbot+4b98281f2401ab849f4b@syzkaller.appspotmail.com>
CC: "syzkaller-bugs@googlegroups.com" <syzkaller-bugs@googlegroups.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: general protection fault in encode_rpcb_string
Date: Tue, 17 Apr 2018 21:54:36 +0000
Message-ID: <1524002074.63751.5.camel@hammer.space>
References: <f4f5e80803d08f47b9056a0366dd@google.com>
         <20180417213308.GC18217@fieldses.org>
In-Reply-To: <20180417213308.GC18217@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE4LTA0LTE3IGF0IDE3OjMzIC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIE1vbiwgQXByIDE2LCAyMDE4IGF0IDA5OjAyOjAxUE0gLTA3MDAsIHN5emJvdCB3cm90
ZToNCj4gPiBzeXpib3QgaGl0IHRoZSBmb2xsb3dpbmcgY3Jhc2ggb24gYnBmLW5leHQgY29tbWl0
DQo+ID4gNWQxMzY1OTQwYTY4ZGQ1N2IwMzFiNmUzYzA3ZDdkNDUxY2Q2OWRhZiAoVGh1IEFwciAx
MiAxODowOTowNSAyMDE4DQo+ID4gKzAwMDApDQo+ID4gTWVyZ2UgZ2l0Oi8vZ2l0Lmtlcm5lbC5v
cmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L2RhdmVtL25ldA0KPiA+IHN5emJvdCBkYXNoYm9h
cmQgbGluazoNCj4gPiBodHRwczovL3N5emthbGxlci5hcHBzcG90LmNvbS9idWc/ZXh0aWQ9NGI5
ODI4MWYyNDAxYWI4NDlmNGINCj4gPiANCj4gPiBTbyBmYXIgdGhpcyBjcmFzaCBoYXBwZW5lZCAy
IHRpbWVzIG9uIGJwZi1uZXh0Lg0KPiA+IEMgcmVwcm9kdWNlcjogaHR0cHM6Ly9zeXprYWxsZXIu
YXBwc3BvdC5jb20veC9yZXByby5jP2lkPTY0MzM4MzU2MzMNCj4gPiA4Njg4MDANCj4gPiBzeXpr
YWxsZXIgcmVwcm9kdWNlcjoNCj4gPiBodHRwczovL3N5emthbGxlci5hcHBzcG90LmNvbS94L3Jl
cHJvLnN5ej9pZD02NDA3MzExNzk0ODk2ODk2DQo+ID4gUmF3IGNvbnNvbGUgb3V0cHV0Og0KPiA+
IGh0dHBzOi8vc3l6a2FsbGVyLmFwcHNwb3QuY29tL3gvbG9nLnR4dD9pZD01ODYxNTExMTc2MTI2
NDY0DQo+IA0KPiBCYXNlZCBvbiB0aGF0LCBsb29rcyBsaWtlIGl0J3MgYXR0ZW1wdGluZyBhbiBu
ZnMgbW91bnQgd2hpbGUgY2F1c2luZw0KPiBrbWFsbG9jIGZhaWx1cmVzPw0KPiANCj4gUHJvYmFi
bHkgb25lIG9mIHJwY2ItPnJfbmV0aWQsIHJfYWRkciwgb3Igcl9vd25lciB3YXMgYmFkIGluDQo+
IHJwY2JfZW5jX2dldGFkZHIuDQo+IA0KPiBIbSwgYW5kIHByZXZpb3VzIGxvZyBtYWtlcyBpdCBs
b29rIGxpa2UgaXQgd2FzIGFuDQo+IHJwY19zb2NrYWRkcjJ1YWRkcigpDQo+IGluIHJwY2JfZ2V0
cG9ydF9hc3luYygpIHRoYXQgd2FzIG1hZGUgdG8gZmFpbC4gIERvIHdlIG5lZWQgdG8gY2hlY2sN
Cj4gZm9yDQo+IGZhaWx1cmUgb2Y6DQo+IA0KPiAJbWFwLT5yX2FkZHIgPSBycGNfc29ja2FkZHIy
dWFkZHIoc2FwLCBHRlBfQVRPTUlDKTsNCj4gDQo+ID8NCg0KWWVzLCBhbmQgd2UgY2FuIHByb2Jh
Ymx5IGNvbnZlcnQgaXQsIGFuZCB0aGUgb3RoZXIgR0ZQX0FUT01JQw0KYWxsb2NhdGlvbnMgaW4g
dGhlIHJwY2JpbmQgY2xpZW50IHRvIHVzZSBHRlBfTk9GUyBpbiBvcmRlciB0byBpbXByb3ZlDQpy
ZWxpYWJpbGl0eS4NCg0KQ2hlZXJzDQogIFRyb25kDQotLSANClRyb25kIE15a2xlYnVzdA0KTGlu
dXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhh
bW1lci5zcGFjZQ0K
