Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8232 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756336Ab2D3SQw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 14:16:52 -0400
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q3UIGpXP000483
	for <linux-nfs@vger.kernel.org>; Mon, 30 Apr 2012 11:16:51 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>
Subject: Re: [PATCH] NFS: Define dummy nfs_init_cinfo() and
 nfs_init_cinfo_from_inode()
Date: Mon, 30 Apr 2012 18:16:50 +0000
Message-ID: <1335809816.11828.2.camel@lade.trondhjem.org>
References: <1335808129-6750-1-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335808129-6750-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA0LTMwIGF0IDEzOjQ4IC0wNDAwLCBianNjaHVtYUBuZXRhcHAuY29tIHdy
b3RlOg0KPiBGcm9tOiBCcnlhbiBTY2h1bWFrZXIgPGJqc2NodW1hQG5ldGFwcC5jb20+DQo+IA0K
PiBUaGVzZSBhcmUgbmVlZGVkIHdoZW4gdjMgYW5kIHY0IGFyZSBub3QgZW5hYmxlZC4NCj4gDQo+
IFNpZ25lZC1vZmYtYnk6IEJyeWFuIFNjaHVtYWtlciA8YmpzY2h1bWFAbmV0YXBwLmNvbT4NCj4g
LS0tDQo+ICBmcy9uZnMvd3JpdGUuYyB8ICAgMTIgKysrKysrKysrKysrDQo+ICAxIGZpbGUgY2hh
bmdlZCwgMTIgaW5zZXJ0aW9ucygrKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2ZzL25mcy93cml0ZS5j
IGIvZnMvbmZzL3dyaXRlLmMNCj4gaW5kZXggMzYzNjE5MS4uZjAwNDVlMCAxMDA2NDQNCj4gLS0t
IGEvZnMvbmZzL3dyaXRlLmMNCj4gKysrIGIvZnMvbmZzL3dyaXRlLmMNCj4gQEAgLTU2Nyw2ICs1
NjcsMTggQEAgaW50IG5mc193cml0ZV9uZWVkX2NvbW1pdChzdHJ1Y3QgbmZzX3dyaXRlX2RhdGEg
KmRhdGEpDQo+ICB9DQo+ICANCj4gICNlbHNlDQo+ICtzdGF0aWMgdm9pZCBuZnNfaW5pdF9jaW5m
b19mcm9tX2lub2RlKHN0cnVjdCBuZnNfY29tbWl0X2luZm8gKmNpbmZvLA0KPiArCQkJCSAgICAg
IHN0cnVjdCBpbm9kZSAqaW5vZGUpDQo+ICt7DQo+ICt9DQo+ICsNCj4gK3ZvaWQgbmZzX2luaXRf
Y2luZm8oc3RydWN0IG5mc19jb21taXRfaW5mbyAqY2luZm8sDQo+ICsJCSAgICBzdHJ1Y3QgaW5v
ZGUgKmlub2RlLA0KPiArCQkgICAgc3RydWN0IG5mc19kaXJlY3RfcmVxICpkcmVxKQ0KPiArew0K
PiArfQ0KPiArRVhQT1JUX1NZTUJPTF9HUEwobmZzX2luaXRfY2luZm8pOw0KPiArDQoNCldlIHNo
b3VsZG4ndCBuZWVkIHRvIGV4cG9ydCB0aGlzLiBUaGVyZSBzaG91bGQgYmUgbm8gc3VibW9kdWxl
cyB3aGVuDQp3ZSdyZSBkb2luZyBORlN2MiBvbmx5Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0K
TGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5l
dGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
