Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:55086 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752310Ab3G3QJI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Jul 2013 12:09:08 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] rpc.nfsd: Allow v4.2 server support with the -V
 option
Date: Tue, 30 Jul 2013 16:09:06 +0000
Message-ID: <1375200538.2468.3.camel@leira.trondhjem.org>
References: <1375036598-31090-1-git-send-email-steved@redhat.com>
	 <1375036598-31090-2-git-send-email-steved@redhat.com>
	 <20130730155921.GE1443@fieldses.org>
In-Reply-To: <20130730155921.GE1443@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEzLTA3LTMwIGF0IDExOjU5IC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIFN1biwgSnVsIDI4LCAyMDEzIGF0IDAyOjM2OjM4UE0gLTA0MDAsIFN0ZXZlIERpY2tz
b24gd3JvdGU6DQo+ID4gU2lnbmVkLW9mZi1ieTogU3RldmUgRGlja3NvbiA8c3RldmVkQHJlZGhh
dC5jb20+DQo+IA0KPiBJIGFncmVlIHRoYXQgd2Ugd2FudCB0byBiZSBhYmxlIHRvIHR1cm4gb24g
NC4yIHN1cHBvcnQgd2l0aCAtViwgYnV0IHRoaXMNCj4gZG9lcyBtb3JlIHRoYW4gdGhhdDoNCj4g
DQo+ID4gLQlpZiAobWlub3J2ZXJzNDEpDQo+ID4gLQkJb2ZmICs9IHNucHJpbnRmKHB0citvZmYs
IHNpemVvZihidWYpIC0gb2ZmLCAiJWM0LjEiLA0KPiA+IC0JCQkJbWlub3J2ZXJzNDEgPiAwID8g
JysnIDogJy0nKTsNCj4gPiArCWZvciAobiA9IE5GUzRfTUlOTUlOT1I7IG4gPD0gTkZTNF9NQVhN
SU5PUjsgbisrKSB7DQo+ID4gKwkJaWYgKE5GU0NUTF9WRVJJU1NFVChtaW5vcnZlcnMsIG4pKSAN
Cj4gPiArCQkJb2ZmICs9IHNucHJpbnRmKHB0citvZmYsIHNpemVvZihidWYpIC0gb2ZmLCAiKzQu
JWQgIiwgbik7DQo+ID4gKwkJZWxzZQkJCQ0KPiA+ICsJCQlvZmYgKz0gc25wcmludGYocHRyK29m
Ziwgc2l6ZW9mKGJ1ZikgLSBvZmYsICItNC4lZCAiLCBuKTsNCj4gPiArCX0NCj4gPiAgCWZvciAo
biA9IE5GU0RfTUlOVkVSUzsgbiA8PSBORlNEX01BWFZFUlM7IG4rKykgew0KPiA+ICAJCWlmIChO
RlNDVExfVkVSSVNTRVQoY3RsYml0cywgbikpDQo+ID4gIAkJICAgIG9mZiArPSBzbnByaW50Zihw
dHIrb2ZmLCBzaXplb2YoYnVmKSAtIG9mZiwgIislZCAiLCBuKTsNCj4gDQo+IFByZXZpb3VzbHkg
bWlub3J2ZXJzNDEgY291bGQgYmUgc2V0IHRvOg0KPiANCj4gCSAxOiB0dXJuIG9uIDQuMQ0KPiAJ
LTE6IHR1cm4gb2ZmIDQuMQ0KPiAJIDA6IGtlZXAga2VybmVsIGRlZmF1bHQgKHVzZXIgZGlkbid0
IHNwZWNpZnkpDQo+IA0KPiBUaGlzIHBhdGNoIHJlbW92ZXMgdGhlICIwIiBjYXNlLCB3aGljaCBJ
IGxpa2VkLg0KDQpXaHkgc2hvdWxkIE5GU3Y0IG1pbm9yIHZlcnNpb25zIGJlIHRyZWF0ZWQgYW55
IGRpZmZlcmVudGx5IGZyb20gbWFqb3INCnZlcnNpb25zIGhlcmU/IFdlIGRvbid0IGhhdmUgYSAn
a2VybmVsIGRlZmF1bHQnIGZvciBORlN2MiBvciB2MyBvciB2NC4wLg0KDQotLSANClRyb25kIE15
a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlr
bGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQo=
