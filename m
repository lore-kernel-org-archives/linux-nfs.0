Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58411 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487Ab2CQP2X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Mar 2012 11:28:23 -0400
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q2HFSN7W002285
	for <linux-nfs@vger.kernel.org>; Sat, 17 Mar 2012 08:28:23 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Isaman, Fred" <Fred.Isaman@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 1/2] NFSv4.1: Clean ups and bugfixes for the pNFS
 read/writeback/commit code
Date: Sat, 17 Mar 2012 15:28:22 +0000
Message-ID: <1331998102.2974.11.camel@lade.trondhjem.org>
References: <1331932941-15034-1-git-send-email-Trond.Myklebust@netapp.com>
	 <7725B048-5E76-477A-8C4E-052DB43A1F84@netapp.com>
	 <1331997345.2974.6.camel@lade.trondhjem.org>
In-Reply-To: <1331997345.2974.6.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU2F0LCAyMDEyLTAzLTE3IGF0IDExOjE1IC0wNDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IE9uIFNhdCwgMjAxMi0wMy0xNyBhdCAxMDo1NSAtMDQwMCwgRnJlZCBJc2FtYW4gd3JvdGU6
DQo+ID4gT24gTWFyIDE2LCAyMDEyLCBhdCA1OjIyIFBNLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+ID4gPiANCj4gPiA+ICtzdGF0aWMgaW50DQo+ID4gPiArZmlsZWxheW91dF9zY2FuX2RzX2Nv
bW1pdF9saXN0KHN0cnVjdCBuZnM0X2ZsX2NvbW1pdF9idWNrZXQgKmJ1Y2tldCwgaW50IG1heCkN
Cj4gPiA+ICt7DQo+ID4gPiArCXN0cnVjdCBsaXN0X2hlYWQgKnNyYyA9ICZidWNrZXQtPndyaXR0
ZW47DQo+ID4gPiArCXN0cnVjdCBsaXN0X2hlYWQgKmRzdCA9ICZidWNrZXQtPmNvbW1pdHRpbmc7
DQo+ID4gPiArCXN0cnVjdCBuZnNfcGFnZSAqcmVxLCAqdG1wOw0KPiA+ID4gKwlpbnQgcmV0ID0g
MDsNCj4gPiA+ICsNCj4gPiANCj4gPiBuZWVkIHNvbWV0aGluZyBoZXJlIGxpa2U6DQo+ID4gDQo+
ID4gaWYgKG1heCA9PSAwKQ0KPiA+ICAgIHJldHVybiAwOw0KPiANCj4gSSdsbCBwdXQgdGhhdCBp
biB0aGUgY2FsbGVyIGluc3RlYWQuDQo+IA0KDQpPSy4gRG9uZSBhbmQgcHVzaGVkIG91dCB0byBu
ZnMtZm9yLW5leHQuLi4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQg
bWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0
YXBwLmNvbQ0KDQo=
