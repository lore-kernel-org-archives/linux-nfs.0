Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52192 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753815Ab2EHN36 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 May 2012 09:29:58 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Daniel Pocock <daniel@pocock.com.au>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: extremely slow nfs when sync enabled
Date: Tue, 8 May 2012 13:29:40 +0000
Message-ID: <1336483786.2861.8.camel@lade.trondhjem.org>
References: <4FA5E950.5080304@pocock.com.au>
	 <1336328594.2593.14.camel@lade.trondhjem.org>
	 <4FA6EBD4.7040308@pocock.com.au>
	 <1336340993.2600.11.camel@lade.trondhjem.org>
	 <4FA6F75E.6090300@pocock.com.au>
	 <1336344160.2600.30.camel@lade.trondhjem.org>
	 <4FA793AB.70107@pocock.com.au> <4FA7D54E.9080309@pocock.com.au>
	 <20120507171759.GA10137@fieldses.org> <4FA90C63.7000505@pocock.com.au>
	 <20120508124559.GA15448@fieldses.org>
In-Reply-To: <20120508124559.GA15448@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA1LTA4IGF0IDA4OjQ1IC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIFR1ZSwgTWF5IDA4LCAyMDEyIGF0IDEyOjA2OjU5UE0gKzAwMDAsIERhbmllbCBQb2Nv
Y2sgd3JvdGU6DQo+ID4gDQo+ID4gDQo+ID4gT24gMDcvMDUvMTIgMTc6MTgsIEouIEJydWNlIEZp
ZWxkcyB3cm90ZToNCj4gPiA+IEhvdyBtYW55IGZpbGUgY3JlYXRlcyBwZXIgc2Vjb25kPw0KPiA+
ID4gDQo+ID4gDQo+ID4gSSByYW46DQo+ID4gbmZzc3RhdCAtcyAtbyBhbGwgLWwgLVo1DQo+ID4g
YW5kIGR1cmluZyB0aGUgdGVzdCAodW5wYWNraW5nIHRoZSB0YXJiYWxsKSwgSSBzZWUgbnVtYmVy
cyBsaWtlIHRoZXNlDQo+ID4gZXZlcnkgNSBzZWNvbmRzIGZvciBhYm91dCAyIG1pbnV0ZXM6DQo+
ID4gDQo+ID4gbmZzIHYzIHNlcnZlciAgICAgICAgdG90YWw6ICAgICAgMzE5DQo+ID4gLS0tLS0t
LS0tLS0tLSAtLS0tLS0tLS0tLS0tIC0tLS0tLS0tDQo+ID4gbmZzIHYzIHNlcnZlciAgICAgIGdl
dGF0dHI6ICAgICAgICAxDQo+ID4gbmZzIHYzIHNlcnZlciAgICAgIHNldGF0dHI6ICAgICAgMTI2
DQo+ID4gbmZzIHYzIHNlcnZlciAgICAgICBhY2Nlc3M6ICAgICAgICA2DQo+ID4gbmZzIHYzIHNl
cnZlciAgICAgICAgd3JpdGU6ICAgICAgIDYxDQo+ID4gbmZzIHYzIHNlcnZlciAgICAgICBjcmVh
dGU6ICAgICAgIDYxDQo+ID4gbmZzIHYzIHNlcnZlciAgICAgICAgbWtkaXI6ICAgICAgICAzDQo+
ID4gbmZzIHYzIHNlcnZlciAgICAgICBjb21taXQ6ICAgICAgIDYxDQo+IA0KPiBPSywgc28gaXQn
cyBwcm9iYWJseSBjcmVhdGluZyBhYm91dCA2MCBuZXcgZmlsZXMsIGVhY2ggcmVxdWlyaW5nIGEN
Cj4gY3JlYXRlLCB3cml0ZSwgY29tbWl0LCBhbmQgdHdvIHNldGF0dHJzPw0KPiANCj4gRWFjaCBv
ZiB0aG9zZSBvcGVyYXRpb25zIGlzIHN5bmNocm9ub3VzLCBzbyBwcm9iYWJseSBoYXMgdG8gd2Fp
dCBmb3IgYXQNCj4gbGVhc3Qgb25lIGRpc2sgc2Vlay4gIEFib3V0IDMwMCBzdWNoIG9wZXJhdGlv
bnMgZXZlcnkgNSBzZWNvbmRzIGlzIGFib3V0DQo+IDYwIHBlciBzZWNvbmQsIG9yIGFib3V0IDE2
bXMgZWFjaC4gIFRoYXQgZG9lc24ndCBzb3VuZCBzbyBmYXIgb2ZmLg0KPiANCj4gKEkgd29uZGVy
IHdoeSBpdCBuZWVkcyB0d28gc2V0YXR0cnM/KQ0KDQpJdCBpcyBhbiB1bnRhciB3b3JrbG9hZCwg
c28gaXQgbmVlZHMgdG8gcmVzZXQgdGhlIGF0aW1lL210aW1lIGFmdGVyDQp3cml0aW5nIHRoZSBm
aWxlLg0KDQpOb3RlIHRoYXQgdGhlIGFib3ZlIHdvcmtsb2FkIGlzIGV4YWN0bHkgdGhlIG9uZSBJ
IHdhcyB0YXJnZXRpbmcgd2l0aCB0aGUNCnVuc3RhYmxlIGZpbGUgY3JlYXRpb24gZHJhZnQ6DQoN
Cmh0dHA6Ly90b29scy5pZXRmLm9yZy9odG1sL2RyYWZ0LW15a2xlYnVzdC1uZnN2NC11bnN0YWJs
ZS1maWxlLWNyZWF0aW9uLTAxDQoNCkknbSBnb2luZyB0byB0cnkgcHVzaGluZyB0aGF0IGFnYWlu
IGZvciBORlN2NC4zLi4uDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50
IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5l
dGFwcC5jb20NCg0K
