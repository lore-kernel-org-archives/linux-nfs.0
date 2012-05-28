Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:13559 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135Ab2E1E0r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 00:26:47 -0400
From: <tao.peng@emc.com>
To: <Trond.Myklebust@netapp.com>
CC: <bergwolf@gmail.com>, <linux-nfs@vger.kernel.org>
Date: Mon, 28 May 2012 00:26:20 -0400
Subject: RE: [PATCH 3/3] pnfsblock: bail out unaligned DIO
Message-ID: <F19688880B763E40B28B2B462677FBF805F0BADF5D@MX09A.corp.emc.com>
References: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>
	 <1338096780-2763-4-git-send-email-bergwolf@gmail.com>
	 <1338136717.3044.13.camel@lade.trondhjem.org>
	 <F19688880B763E40B28B2B462677FBF805F0BADF36@MX09A.corp.emc.com>
 <1338176720.2265.8.camel@lade.trondhjem.org>
In-Reply-To: <1338176720.2265.8.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBNeWtsZWJ1c3QsIFRyb25kIFtt
YWlsdG86VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb21dDQo+IFNlbnQ6IE1vbmRheSwgTWF5IDI4
LCAyMDEyIDExOjQ1IEFNDQo+IFRvOiBQZW5nLCBUYW8NCj4gQ2M6IGJlcmd3b2xmQGdtYWlsLmNv
bTsgbGludXgtbmZzQHZnZXIua2VybmVsLm9yZw0KPiBTdWJqZWN0OiBSRTogW1BBVENIIDMvM10g
cG5mc2Jsb2NrOiBiYWlsIG91dCB1bmFsaWduZWQgRElPDQo+IA0KPiBPbiBTdW4sIDIwMTItMDUt
MjcgYXQgMjI6MzAgLTA0MDAsIHRhby5wZW5nQGVtYy5jb20gd3JvdGU6DQo+ID4gQXMgZXhwbGFp
biBpbiB0aGUgb3RoZXIgbWFpbCwgaXQgaXMgbmVjZXNzYXJ5IHRvIGhhdmUgcG5mc19kaW9fYmVn
aW4vZW5kLCBzbyBJIHByZWZlciB0byBkbyB0aGUgdGVzdA0KPiBhcyBlYXJseSBhcyBwb3NzaWJs
ZSwgd2hpY2ggaXMgaW4gcG5mc19kaW9fYmVnaW4uDQo+IA0KPiBUaGVyZSBpcyBubyBwbmZzX2Rp
b19iZWdpbi9lbmQuDQpPSy4gSSB3aWxsIHB1dCBESU8gYWxpZ25tZW50IHRlc3RzIGluc2lkZSBw
Z19pbml0Lg0KDQpBbmQgYW55IGNvbW1lbnRzIG9uIGZvciBzdGFibGUgcGF0Y2ggaW4gdGhlIHRo
cmVhZCAoW1BBVENIXSBwbmZzYmxvY2s6IGJhaWwgb3V0IHBhZ2UgdW5hbGlnbmVkIElPKT8gSWYg
eW91IGFncmVlLCBJIHdpbGwgYmFzZSBESU8gY2hhbmdlcyBvbiB0b3Agb2YgaXQgdG8gYXZvaWQg
Y29uZmxpY3RzLg0KVGhlcmUgYXJlIHJlYXNvbnMgdG8gdGVzdCBhbGlnbm1lbnQgYXQgZGlmZmVy
ZW50IHBsYWNlIGZvciBidWZmZXIgSU8gYW5kIERJTy4gRm9yIGJ1ZmZlciBJTywgcGdfaW5pdCBp
c24ndCB0aGUgcmlnaHQgcGxhY2UgYmVjYXVzZSB3ZSBkb24ndCBoYXZlIG5mcyBwYWdlIHRoZXJl
LiBGb3IgRElPLCBwZ190ZXN0IGlzbid0IHRoZSByaWdodCBwbGFjZSBiZWNhdXNlIHdlIG5lZWQg
dG8gY2hlY2sgY3Jvc3MgcGFnZSBib3VuZGFyeS4NCg0KVGhhbmtzLA0KVGFvDQoNCg==
