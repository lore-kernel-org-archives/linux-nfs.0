Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:9636 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754633Ab2G3Vyz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 17:54:55 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Sachin Prabhu <sprabhu@redhat.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Fix array overflow in __nfs4_get_acl_uncached
Date: Mon, 30 Jul 2012 21:54:20 +0000
Message-ID: <1343685259.28035.2.camel@lade.trondhjem.org>
References: <1343129785-4538-1-git-send-email-sprabhu@redhat.com>
In-Reply-To: <1343129785-4538-1-git-send-email-sprabhu@redhat.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA3LTI0IGF0IDEyOjM2ICswMTAwLCBTYWNoaW4gUHJhYmh1IHdyb3RlOg0K
PiBUaGlzIGZpeGVzIGEgYnVnIGludHJvZHVjZWQgYnkgY29tbWl0DQo+IDVhMDA2ODk5MzBhYjk3
NWZkZDFiMzdiMDM0NDc1MDE3ZTQ2MGNmMmENCj4gDQo+IEJydWNlIEZpZWxkcyBwb2ludGVkIG91
dCB0aGF0IHRoZSBjaGFuZ2VzIGludHJvZHVjZWQgYnkgdGhlIHBhdGNoIHdpbGwNCj4gY2F1c2Ug
dGhlIGFycmF5IG5wYWdlcyB0byBvdmVyZmxvdyBpZiBhIHNpemUgcmVxdWVzdGVkIGlzID49DQo+
IFhBVFRSX1NJWkVfTUFYLg0KPiANCj4gVGhlIHBhdGNoIGFsc28gZml4ZXMgdGhlIGNoZWNrIGZv
ciB0aGUgbGVuZ3RoIG9mIHRoZSBBQ0wgcmV0dXJuZWQuIFRoZQ0KPiBmbGFnIEFDTF9MRU5fUkVR
VUVTVCBoYXMgYmVlbiByZW5hbWVkIHRvIE5GUzRfQUNMX0xFTl9PTkxZIGFuZCBhcGFydA0KPiBm
cm9tIGluZGljYXRpbmcgdGhhdCB0aGUgdXNlciBpcyBqdXN0IGludGVyZXN0ZWQgaW4gdGhlIEFD
TCBsZW5ndGggd2hlbg0KPiBtYWtpbmcgYSByZXF1ZXN0LCBpdCBpcyBhbHNvIHVzZWQgdG8gaW5k
aWNhdGUgaWYgdGhlIHhkciBwYWdlcyBidWZmZXINCj4gcmV0dXJuZWQgaW4gcmVzcG9uc2UgaG9s
ZHMgdGhlIGNvbXBsZXRlIEFDTCBvciBqdXN0IHRoZSBsZW5ndGguDQo+IA0KPiBTaWduZWQtb2Zm
LWJ5OiBTYWNoaW4gUHJhYmh1IDxzcHJhYmh1QHJlZGhhdC5jb20+DQoNCklmIHRoaXMgZml4IGlz
IGdvaW5nIGludG8gc3RhYmxlLCB0aGVuIHRoZSBwYXRjaCBuZWVkcyB0byBiZSBzcGxpdCB1cC4N
ClRoZSByZW5hbWUgb2YgQUNMX0xFTl9SRVFVRVNUIHRvIE5GUzRfQUNMX0xFTl9PTkxZIGlzIGEg
Y2xlYW51cCBhbmQNCnNob3VsZCBub3QgYmUgcHJvcGFnYXRlZCB0byBzdGFibGUuLi4NCg0KQ2hl
ZXJzDQogIFRyb25kDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWlu
dGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAu
Y29tDQoNCg==
