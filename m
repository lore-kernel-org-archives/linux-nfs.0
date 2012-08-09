Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hop-nat-141.emc.com ([168.159.213.141]:29316 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757188Ab2HIJBI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 05:01:08 -0400
From: "Peng, Tao" <tao.peng@emc.com>
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Bryan Schumaker <bjschuma@netapp.com>
Date: Thu, 9 Aug 2012 05:00:50 -0400
Subject: RE: [PATCH-v2] NFS41: fix error of setting blocklayoutdriver
Message-ID: <5DFC6BE3BA248842867E85C73BF94B050B17B698D0@MX41A.corp.emc.com>
References: <1344437845-2356-1-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344437845-2356-1-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBQZW5nIFRhbyBbbWFpbHRvOmJl
cmd3b2xmQGdtYWlsLmNvbV0NCj4gU2VudDogV2VkbmVzZGF5LCBBdWd1c3QgMDgsIDIwMTIgMTA6
NTcgUE0NCj4gVG86IFRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQo+IENjOiBsaW51eC1uZnNA
dmdlci5rZXJuZWwub3JnOyBCcnlhbiBTY2h1bWFrZXI7IFBlbmcsIFRhbw0KPiBTdWJqZWN0OiBb
UEFUQ0gtdjJdIE5GUzQxOiBmaXggZXJyb3Igb2Ygc2V0dGluZyBibG9ja2xheW91dGRyaXZlcg0K
PiANCj4gQWZ0ZXIgY29tbWl0IGUzOGViNjUwIChORlM6IHNldF9wbmZzX2xheW91dGRyaXZlcigp
IGZyb20NCj4gbmZzNF9wcm9jX2ZzaW5mbygpKSwgc2V0X3BuZnNfbGF5b3V0ZHJpdmVyKCkgaXMg
Y2FsbGVkIGluc2lkZQ0KPiBuZnM0X3Byb2NfZnNpbmZvKCksIGJ1dCBwbmZzX2Jsa3NpemUgaXMg
bm90IHNldC4gSXQgY2F1c2VzIHNldHRpbmcNCj4gYmxvY2tsYXlvdXRkcml2ZXIgZmFpbHVyZSBh
bmQgcG5mc2Jsb2NrIG1vdW50IGZhaWx1cmUuDQo+IA0KSnVzdCBub3RpY2VkIHRoYXQgdGhlIGNv
bW1pdCBlMzhlYjY1MCBoYXMgYmVlbiBtZXJnZWQgaW4gMy41IHJlbGVhc2UuIFRyb25kLCBwbGVh
c2UgYWRkIGEgbGluZSB0byBzdGFibGUgd2hlbiB5b3UgbWVyZ2UgdGhlIHBhdGNoLiBUaGFua3Mg
dmVyeSBtdWNoIQ0KQ2M6IHN0YWJsZUB2Z2VyLmtlcm5lbC5vcmcgW3YzLjVdDQoNCkNoZWVycywN
ClRhbyANCg0K
