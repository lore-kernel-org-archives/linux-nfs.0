Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8214 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755937Ab2EVQY1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 12:24:27 -0400
Received: from vmwexceht05-prd.hq.netapp.com (vmwexceht05-prd.hq.netapp.com [10.106.77.35])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4MGORXH022238
	for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 09:24:27 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSv4.1 do not release page on commit mismatch
Date: Tue, 22 May 2012 16:24:27 +0000
Message-ID: <1337703865.4269.21.camel@lade.trondhjem.org>
References: <1337688569-1515-1-git-send-email-andros@netapp.com>
	 <1337688569-1515-5-git-send-email-andros@netapp.com>
In-Reply-To: <1337688569-1515-5-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA1LTIyIGF0IDA4OjA5IC0wNDAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IFNpZ25l
ZC1vZmYtYnk6IEFuZHkgQWRhbXNvbiA8YW5kcm9zQG5ldGFwcC5jb20+DQo+IC0tLQ0KPiAgZnMv
bmZzL3dyaXRlLmMgfCAgICAyICsrDQo+ICAxIGZpbGVzIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygr
KSwgMCBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9mcy9uZnMvd3JpdGUuYyBiL2Zz
L25mcy93cml0ZS5jDQo+IGluZGV4IGU2ZmUzZDYuLmM3Mjk1ZGUgMTAwNjQ0DQo+IC0tLSBhL2Zz
L25mcy93cml0ZS5jDQo+ICsrKyBiL2ZzL25mcy93cml0ZS5jDQo+IEBAIC0xNTU1LDYgKzE1NTUs
OCBAQCBzdGF0aWMgdm9pZCBuZnNfY29tbWl0X3JlbGVhc2VfcGFnZXMoc3RydWN0IG5mc19jb21t
aXRfZGF0YSAqZGF0YSkNCj4gIAkJLyogV2UgaGF2ZSBhIG1pc21hdGNoLiBXcml0ZSB0aGUgcGFn
ZSBhZ2FpbiAqLw0KPiAgCQlkcHJpbnRrKCIgbWlzbWF0Y2hcbiIpOw0KPiAgCQluZnNfbWFya19y
ZXF1ZXN0X2RpcnR5KHJlcSk7DQo+ICsJCW5mc191bmxvY2tfcmVxdWVzdChyZXEpOw0KPiArCQlj
b250aW51ZTsNCj4gIAluZXh0Og0KPiAgCQluZnNfdW5sb2NrX2FuZF9yZWxlYXNlX3JlcXVlc3Qo
cmVxKTsNCj4gIAl9DQoNCldoYXQgaXMgdGhpcyBwYXRjaCB0cnlpbmcgdG8gZml4PyBBcyBmYXIg
YXMgSSBjYW4gc2VlIGl0IHdpbGwgbGVhZCB0byBhDQpyZWZlcmVuY2UgbGVhay4NCg0KLS0gDQpU
cm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRy
b25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
