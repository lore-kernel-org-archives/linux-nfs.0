Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20934 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860Ab2E2Pnl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 11:43:41 -0400
Received: from vmwexceht02-prd.hq.netapp.com (vmwexceht02-prd.hq.netapp.com [10.106.76.240])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4TFhfXE020134
	for <linux-nfs@vger.kernel.org>; Tue, 29 May 2012 08:43:41 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/8] NFSv4.1: Move NFSPROC4_CLNT_BIND_CONN_TO_SESSION to
 the end of the operations
Date: Tue, 29 May 2012 15:43:40 +0000
Message-ID: <1338306221.5433.27.camel@lade.trondhjem.org>
References: <1337983402-24677-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1337983402-24677-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1337983402-24677-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1337983402-24677-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1337983402-24677-5-git-send-email-Trond.Myklebust@netapp.com>
	 <ACF824E6-0473-4E05-9350-8808A180AC15@netapp.com>
In-Reply-To: <ACF824E6-0473-4E05-9350-8808A180AC15@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA1LTI5IGF0IDE1OjA1ICswMDAwLCBBZGFtc29uLCBEcm9zIHdyb3RlOg0K
PiBPbiBNYXkgMjUsIDIwMTIsIGF0IDY6MDMgUE0sIFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4g
DQo+ID4gRm9yIGJhY2t3YXJkIGNvbXBhdGliaWxpdHkgd2l0aCBuZnMtdXRpbHMuDQo+IA0KPiBD
YW4geW91IGV4cGFuZCBvbiB0aGF0IGEgYml0PyBJIHB1dCB0aGVtIHdoZXJlIHRoZXkgYXJlIGJl
Y2F1c2UgdGhleSBhcmUgaW4gb3JkZXIgb2Ygb3BlcmF0aW9uIGlkIChiaW5kX2Nvbm5fdG9fc2Vz
c2lvbiA9IDQxLCBleGNoYW5nZV9pZCA9IDQyKS4NCg0KbmZzNF9wcm9jZWR1cmVzIGlzbid0IChh
bmQgcmVhbGx5IGNhbid0IGJlKSBvcmRlcmVkIGJ5IG9wZXJhdGlvbi4gSXQgaXMNCmEgc2V0IG9m
IENPTVBPVU5EcywgZWFjaCBvZiB3aGljaCByZWZsZWN0cyBhIGNlcnRhaW4gZnVuY3Rpb25hbGl0
eQ0KcmF0aGVyIHRoYW4gYSBzcGVjaWZpYyBvcGVyYXRpb24uDQoNCj4gSWYgd2UgcmVhbGx5IG11
c3Qgb25seSBhZGQgdG8gdGhlIGVuZCBvZiB0aGUgbGlzdCwgd2UgcmVhbGx5IHNob3VsZCBoYXZl
IGEgY29tbWVudCBhYm92ZSBuZnM0X3Byb2NlZHVyZXMsIGV0Yy4NCg0KVGhlIHdob2xlIG5mc3N0
YXQgaXMgY3VycmVudGx5IHByb2JsZW1hdGljIGJlY2F1c2Ugd2Ugb2NjYXNpb25hbGx5IGRvDQp3
YW50IHRvIGJlIGFibGUgdG8gYWRkIHRvIHRoZSBORlN2NC4wIHByb2NlZHVyZXMgKGFib3ZlIHRo
ZSAjaWZkZWYNCkNPTkZJR19ORlNfVjRfMSkgYXMgd2VsbCBhcyB0aGUgTkZTdjQuMSBwcm9jZWR1
cmVzLg0KDQpBcHBlbmRpbmcgaXMgdXN1YWxseSB0aGUgcmlnaHQgdGhpbmcgdG8gZG8sIGJ1dCB0
aGF0ICNpZmRlZiBtYWtlcyBpdA0KcHJvYmxlbWF0aWMgc2luY2UgaWYgd2Ugd2VyZSB0byBhcHBl
bmQgTkZTdjQuMCByb3V0aW5lcywgdGhlbiB0aGV5IHdvdWxkDQptb3ZlIGRlcGVuZGluZyBvbiB3
aGV0aGVyIG9yIG5vdCB3ZSBjb21waWxlIGluIE5GU3Y0LjEgb3Igbm90Lg0KDQpBZGRpbmcgaW4g
TkZTdjQuMiB3aWxsIGdpdmUgcmlzZSB0byBldmVuIG1vcmUgJ2ludGVyZXN0aW5nJyBzaXR1YXRp
b25zDQpzaG91bGQgd2Ugc3RhcnQgcHJvdGVjdGluZyBpdCB3aXRoIHlldCBtb3JlICNpZmRlZnMu
Li4NCg0KVGhlIHNvbHV0aW9uIG1heSBiZSB0byBqdXN0IGFjY2VwdCB0aGF0IHdlIGNhbm5vdCBr
ZWVwIHNlcGFyYXRpbmcNCk5GU3Y0LjAgYW5kIE5GU3Y0LjEgcm91dGluZXMsIGFuZCB0byBqdXN0
IGdldCByaWQgb2YgdGhlICNpZmRlZnMgc28gdGhhdA0Kd2UgY2FuIGFsd2F5cyBhcHBlbmQgdG8g
bmZzNF9wcm9jZWR1cmVzW10uIEhvd2V2ZXIgd2UgaGF2ZW4ndCB5ZXQgZG9uZQ0KdGhpcywgYW5k
IHNvIHRoZXJlIGlzIG5vIGdvb2QgJ29mZmljaWFsJyBkb2N1bWVudGVkIHBvbGljeS4NCg0KLS0g
DQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHAN
ClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
