Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:59854 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735Ab2E1ENr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 00:13:47 -0400
From: <tao.peng@emc.com>
To: <Trond.Myklebust@netapp.com>
CC: <bergwolf@gmail.com>, <linux-nfs@vger.kernel.org>
Date: Mon, 28 May 2012 00:13:02 -0400
Subject: RE: [PATCH 1/3] NFS41: add pnfs_dio_begin/dio_end
Message-ID: <F19688880B763E40B28B2B462677FBF805F0BADF5C@MX09A.corp.emc.com>
References: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>
	 <1338096780-2763-2-git-send-email-bergwolf@gmail.com>
	 <1338136170.3044.7.camel@lade.trondhjem.org>
	 <F19688880B763E40B28B2B462677FBF805F0BADF35@MX09A.corp.emc.com>
 <1338176574.2265.7.camel@lade.trondhjem.org>
In-Reply-To: <1338176574.2265.7.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBNeWtsZWJ1c3QsIFRyb25kIFtt
YWlsdG86VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb21dDQo+IFNlbnQ6IE1vbmRheSwgTWF5IDI4
LCAyMDEyIDExOjQzIEFNDQo+IFRvOiBQZW5nLCBUYW8NCj4gQ2M6IGJlcmd3b2xmQGdtYWlsLmNv
bTsgbGludXgtbmZzQHZnZXIua2VybmVsLm9yZw0KPiBTdWJqZWN0OiBSRTogW1BBVENIIDEvM10g
TkZTNDE6IGFkZCBwbmZzX2Rpb19iZWdpbi9kaW9fZW5kDQo+IA0KPiBPbiBTdW4sIDIwMTItMDUt
MjcgYXQgMjI6MzAgLTA0MDAsIHRhby5wZW5nQGVtYy5jb20gd3JvdGU6DQo+ID4gSSdtIGFmcmFp
ZCB0aGVyZSBpcy4gVGhlcmUgaXMgbm8gd2F5IHRvIHBhc3Mgc3RydWN0IGJsa19wbHVnIGFyb3Vu
ZCBwZ19pbml0L3BnX2RvaW8sIHVubGVzcyB3ZSBwdXQNCj4gaXQgaW4gc3RydWN0IG5mc19wYWdl
aW9fZGVzY3JpcHRvciwgd2hpY2ggSSB0aGluayBpcyBtb3JlIGludHJ1c2l2ZSBhbmQgbGVzcyBl
ZmZpY2llbnQgYXMgaXQgaXMgb25seQ0KPiB1c2VmdWwgZm9yIGJsb2NrIGxheW91dCBkcml2ZXIg
aW4gRElPIGNhc2UuDQo+IA0KPiBUaGVuIGFkZCBhICd2b2lkICpwZ19sYXlvdXRfcHJpdmF0ZScg
ZmllbGQgdG8gbmZzX3BhZ2Vpb19kZXNjcmlwdG9yIGFuZA0KPiBhbGxvY2F0ZSB0aGUgc3RydWN0
IGJsa19wbHVnIGR5bmFtaWNhbGx5Lg0KPiANCk9LLiBJIHRob3VnaHQgZGF0YSBzdHJ1Y3R1cmUg
Y2hhbmdlIGlzIG1vcmUgaW50cnVzaXZlIGJlY2F1c2UgaXQgYWZmZWN0cyBhbGwgbGF5b3V0IGRy
aXZlcnMgYW5kIGdlbmVyaWMgTkZTIGFzIHdlbGwuIEJ1dCBzaW5jZSB5b3UgdGhpbmsgaXQgaXMg
T0ssIEkgd2lsbCBjaGFuZ2UgaXQgYXMgeW91IHN1Z2dlc3RlZC4NCg0KVGhhbmtzLA0KVGFvDQoN
Cg==
