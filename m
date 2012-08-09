Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32568 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030363Ab2HIOZn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 10:25:43 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>
Subject: Re: [PATCH 1/2] NFSv41: fix DIO write_io calculation
Date: Thu, 9 Aug 2012 14:25:41 +0000
Message-ID: <1344522340.23523.0.camel@lade.trondhjem.org>
References: <1344390577-1602-1-git-send-email-bergwolf@gmail.com>
	 <1344452605.8925.31.camel@lade.trondhjem.org>
	 <CA+a=Yy5cTSZy2Hboxt177Tc+8pvkuP_yMmKUFG5c74DpAxHr5w@mail.gmail.com>
In-Reply-To: <CA+a=Yy5cTSZy2Hboxt177Tc+8pvkuP_yMmKUFG5c74DpAxHr5w@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTA4LTA5IGF0IDEwOjM2ICswODAwLCBQZW5nIFRhbyB3cm90ZToNCj4gT24g
VGh1LCBBdWcgOSwgMjAxMiBhdCAzOjAzIEFNLCBNeWtsZWJ1c3QsIFRyb25kDQo+IDxUcm9uZC5N
eWtsZWJ1c3RAbmV0YXBwLmNvbT4gd3JvdGU6DQo+ID4gT24gV2VkLCAyMDEyLTA4LTA4IGF0IDA5
OjQ5ICswODAwLCBQZW5nIFRhbyB3cm90ZToNCj4gPj4gcG5mc193aXRoaW5fbWRzdGhyZXNob2xk
KCkgaXMgY2FsbGVkIGluc2lkZSBwZ19pbml0LiBXZSBuZWVkDQo+ID4+IHRvIHNldCByZWFkX2lv
L3dyaXRlX2lvIGJlZm9yZSB0aGF0Lg0KPiA+DQo+ID4gV2h5Pw0KPiBJZiB3ZSBkb24ndCBzZXQg
cmVhZF9pby93cml0ZV9pbyBiZWZvcmUgY2FsbGluZyBwZ19pbml0LCB3ZSBmYWlsDQo+IHBuZnNf
d2l0aGluX21kc3RocmVzaG9sZCgpIGFuZCBJTyBnb2VzIHRvIE1EUy4NCj4gQSBzaW1wbGUgdGVz
dCBjYXNlOg0KPiBkZCBpZj1mb28gb2Y9L21udC9wbmZzL2JhciBicz0xME0gY291bnQ9MSBvZmxh
Zz1kaXJlY3QNCj4gDQoNCk15IHBvaW50IHdhcyB0aGF0IHRoaXMgZXhwbGFuYXRpb24gbmVlZHMg
dG8gZ28gaW50byB0aGUgY2hhbmdlbG9nIG9mIHRoZQ0KY29tbWl0Lg0KDQotLSANClRyb25kIE15
a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlr
bGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
