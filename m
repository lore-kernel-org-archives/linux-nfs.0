Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:33003 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932465Ab3GVSdv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 14:33:51 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 01/19] NFS: Never use user credentials for lease
 renewal
Date: Mon, 22 Jul 2013 18:33:50 +0000
Message-ID: <1374518026.7972.12.camel@leira.trondhjem.org>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
	 <20130712163135.1444.68565.stgit@seurat.1015granger.net>
In-Reply-To: <20130712163135.1444.68565.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEzLTA3LTEyIGF0IDEyOjMxIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
RG9uJ3QgdHJ5IHRvIHVzZSBhIG5vbi1VSUQtMCB1c2VyIGNyZWRlbnRpYWwgZm9yIGxlYXNlIG1h
bmFnZW1lbnQsDQo+IGFzIHRoYXQgY3JlZGVudGlhbCBjYW4gY2hhbmdlIG91dCBmcm9tIHVuZGVy
IHVzLiAgVGhlIHNlcnZlciB3aWxsDQo+IGJsb2NrIE5GU3Y0IGxlYXNlIHJlY292ZXJ5IHdpdGgg
TkZTNEVSUl9DTElEX0lOVVNFLg0KPiANCj4gUmVwbGFjZSBtaW5vciB2ZXJzaW9uLXNwZWNpZmlj
IGNhbGxvdXRzIHdpdGggYSBzaW5nbGUgZnVuY3Rpb24uDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBD
aHVjayBMZXZlciA8Y2h1Y2subGV2ZXJAb3JhY2xlLmNvbT4NCj4gLS0tDQo+ICBmcy9uZnMvbmZz
NF9mcy5oICAgICB8ICAgIDQgKy0tLQ0KPiAgZnMvbmZzL25mczRwcm9jLmMgICAgfCAgICA2ICst
LS0tDQo+ICBmcy9uZnMvbmZzNHNlc3Npb24uYyB8ICAgIDIgKy0NCj4gIGZzL25mcy9uZnM0c3Rh
dGUuYyAgIHwgICA1NSArKysrKystLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLQ0KPiAgNCBmaWxlcyBjaGFuZ2VkLCAxMCBpbnNlcnRpb25zKCspLCA1NyBkZWxldGlv
bnMoLSkNCg0KVGhpcyB3b24ndCBhcHBseSB0byB1cHN0cmVhbSBrZXJuZWxzLg0KDQotLSANClRy
b25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJv
bmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQo=
