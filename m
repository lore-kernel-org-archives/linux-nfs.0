Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10185 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751484Ab2DTUAT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 16:00:19 -0400
Received: from vmwexceht03-prd.hq.netapp.com (vmwexceht03-prd.hq.netapp.com [10.106.76.241])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q3KK01an028727
	for <linux-nfs@vger.kernel.org>; Fri, 20 Apr 2012 13:00:19 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Isaman, Fred" <Fred.Isaman@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 00/25] directio rewrite
Date: Fri, 20 Apr 2012 20:00:12 +0000
Message-ID: <1334952012.3295.19.camel@lade.trondhjem.org>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTA0LTIwIGF0IDE0OjQ3IC0wNDAwLCBGcmVkIElzYW1hbiB3cm90ZToNCj4g
dmVyc2lvbiAyIG9mIHRoZXNlIHBhdGNoZXMgaGFkIHNvbWUgcGF0Y2ggZnJhZ21lbnRzIHRoYXQg
d2VyZSBsZWZ0DQo+IHVuc3F1YXNoZWQuICBUaGlzIHZlcnNpb24gbWVyZWx5IHNxdWFzaGVzIHRo
b3NlIGluLg0KPiANCj4gDQo+IA0KPiBUaGVzZSBwYXRjaGVzIHJld3JpdGUgdGhlIGRpcmVjdGlv
IGNvZGUgdG8gdXNlIHRoZSBzYW1lIGNvYWxlc2NlDQo+IGFuZCBSUEMgc2VuZG9mZiBjb2RlIGFz
IGNhY2hlZCBpby4gIFRoaXMgYWxsb3dzIGRpcmVjdGlvIHRvIG1ha2UNCj4gdXNlIG9mIHRoZSBw
cmVleGlzdGluZyBwbmZzIGNvZGUuDQo+IA0KPiBUaGVyZSBhcmUgc29tZSBsaW1pdGF0aW9ucyBh
dCB0aGUgbW9tZW50IHRoYXQgbmVlZCB0byBiZSBmaXhlZCwgYnV0DQo+IGdpdmVuIHRoZSBhbW91
bnQgb2YgY2hhbmdlIHRoaXMgcGF0Y2hzZXQgaW50cm9kdWNlcyBJJ20NCj4gdHJ5aW5nIHRvIHB1
dCBvdXQgYXMgc21hbGwgYSBiYXNlIHNldCBvZiBwYXRjaGVzIGFzIHBvc3NpYmxlLg0KPiANCj4g
VGhlIHByaW1hcnkgVE9ET3MgYXJlOg0KPiAtIENvYWxlc2Npbmcgb2YgYnNpemU8UEFHRVNJWkUs
IHdoaWxlIHRlY2huaWNhbGx5IGNvcnJlY3QsIGlzIHN1Ym9wdGltYWwuDQo+ICAgVG8gZml4IHRo
aXMgSSdsbCBuZWVkIHRvIGFkanVzdCB0aGUgKl9tdWx0aSBmdW5jdGlvbnMgdG8gaGFuZGxlDQo+
ICAgbW9yZSB0aGFuIGEgc2luZ2xlIHJlcQ0KPiANCj4gLSBVbmFsaWduZWQgaW8gaXMgbm90IHNl
bnQgdG8gcG5mcywgYXMgdGhlcmUgaXMgbm8gZXhpc3RpbmcgY29kZSB0byBkZWFsDQo+ICAgd2l0
aCBhIGxheW91dCBib3VuZGFyeSAodGhpbmsgc3RyaXBlIGVkZ2UpIG9jY3VycmluZyBpbiB0aGUg
bWlkZGxlDQo+ICAgb2YgYSBuZnNfcGFnZS4NCg0KVGhpcyBub3cgbG9va3MgZ29vZCB0byBtZS4u
Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoN
Ck5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
