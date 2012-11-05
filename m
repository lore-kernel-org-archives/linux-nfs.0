Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hop-nat-141.emc.com ([168.159.213.141]:30169 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750919Ab2KEMmm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 07:42:42 -0500
From: "faibish, sorin" <faibish_sorin@emc.com>
To: "Peng, Tao" <tao.peng@emc.com>
CC: Jun Xiao <xiaojuntime@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jason Glasgow <jglasgow@aya.yale.edu>
Date: Mon, 5 Nov 2012 07:42:25 -0500
Subject: Re: pNFS Block layout issues / questions
Message-ID: <B99990FD-D4C5-43D1-8096-CDAEE90BECB8@emc.com>
References: <loom.20110328T230906-552@post.gmane.org>
 <4D977456.1040303@panasas.com> <loom.20121103T072206-631@post.gmane.org>
 <1882637210201641A747464075FFC6490291C9@MX101CL02.corp.emc.com>
In-Reply-To: <1882637210201641A747464075FFC6490291C9@MX101CL02.corp.emc.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNClNlbnQgZnJvbSBTb3JpbidzIGlQYWQNCg0KT24gTm92IDQsIDIwMTIsIGF0IDk6MzMgUE0s
ICJQZW5nLCBUYW8iIDx0YW8ucGVuZ0BlbWMuY29tPiB3cm90ZToNCg0KPiBIaSwNCj4gDQo+IEkn
bGwgYW5zd2VyIHlvdXIgcXVlc3Rpb25zIGFzIGZhciBhcyBJIGNhbiwgYnV0IEkgbXlzZWxmIGFt
IG5vdCBmYW1pbGlhciB3aXRoIExpbnV4IHBuZnMgYmxvY2sgc2VydmVyIGltcGxlbWVudGF0aW9u
Lg0KPiANCj4+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+PiBGcm9tOiBsaW51eC1uZnMt
b3duZXJAdmdlci5rZXJuZWwub3JnIFttYWlsdG86bGludXgtbmZzLW93bmVyQHZnZXIua2VybmVs
Lm9yZ10gT24gQmVoYWxmIE9mIEp1biBYaWFvDQo+PiBTZW50OiBTYXR1cmRheSwgTm92ZW1iZXIg
MDMsIDIwMTIgMzoyOCBQTQ0KPj4gVG86IGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmcNCj4+IFN1
YmplY3Q6IFJlOiBwTkZTIEJsb2NrIGxheW91dCBpc3N1ZXMgLyBxdWVzdGlvbnMNCj4+IA0KPj4g
U2VlbXMgdGhlIHRocmVhZCBkaWRuJ3QgZ2V0IGFueSByZXBseSBmb3IgcXVpdGUgYSBsb25nIHRp
bWUuDQo+PiANCj4+IEknbSB0cnlpbmcgdG8gc2V0IHVwIHBORlMgYmxvY2sgbGF5b3V0IE1EUy9E
UyBzZXJ2ZXIsIGFuZCBzb21lDQo+PiBzaW1pbGFyIHF1ZXN0aW9ucyBhcyBQaGlsLg0KPj4gDQo+
PiAtIEZvciBibG9jayBsYXlvdXQsIGlzIGl0IG5lY2Vzc2FyeSB0byBtYWtlIERTIGV4cG9ydCBu
ZnMgc2hhcmU/DQo+IE5vLiBKdXN0IGV4cG9ydCB5b3VyIGRhdGEgY29ubmVjdGlvbiBpcyBlbm91
Z2gsIHdoaWNoIGZvciBwbmZzIGJsb2NrIGNhbiBiZSBpc2NzaS9GUyBldGMuDQpTaG91bGQgYmUg
aVNDU0kgLyBGQyBmaWJlciBjaGFubmVsLg0KDQo+IA0KPj4gLSBIb3cgY291bGQgYWRkIGEgYmxv
Y2sgbGF5b3V0IERTIGludG8gcE5GUyBzZXJ2ZXI/DQo+IEkgZG9uJ3QgdGhpbmsgTGludXggcG5m
cyBibG9jayBzZXJ2ZXIgaW1wbGVtZW50cyBzZXBhcmF0ZSBEU2VzLiBTbyBNRFMvRFMgaGFzIHRv
IGJlIG9uIHRoZSBzYW1lIG1hY2hpbmUgZm9yIGl0Lg0KTWF5YmUgSmFzb24gR2xhc2dvdyByZW1l
bWJlcnM/DQoNCj4gDQo+PiAtIERvZXMgc3BuZnMgYWxzbyB3b3JrIGZvciBibG9jayBsYXlvdXQv
DQo+IExhcmdlbHkgeWVzLiBUaGUgd2lraSBwYWdlIGhhcyBpdCB0aGF0IHBuZnMgYmxvY2sgc2Vy
dmVyIGlzIGJhc2VkIG9uIHNwbmZzLg0KPiBodHRwOi8vbGludXgtbmZzLm9yZy93aWtpL2luZGV4
LnBocC9QTkZTX0Jsb2NrX1NlcnZlcl9TZXR1cF9JbnN0cnVjdGlvbnMNCj4gDQo+IEJ1dCBJJ20g
bm90IHN1cmUgaWYgdGhlIGNvZGUgc3RpbGwgd29ya3MuDQo+IA0KPiBDaGVlcnMsDQo+IFRhbw0K
PiANCj4gE++/ve+/vey5uxzvv70m77+9fu+/vSbvv70Y77+977+9Ky3vv73vv73dthfvv73vv713
77+977+9y5vvv73vv73vv71t77+9Yu+/ve+/vWd+yKfvv70X77+977+93Kh977+977+977+9xqB6
77+9Jmo6K3bvv73vv73vv70H77+977+977+977+9elor77+977+9K3pm77+977+977+9aO+/ve+/
ve+/vX7vv73vv73vv73vv71p77+977+977+9eu+/vR7vv71377+977+977+9P++/ve+/ve+/ve+/
vSbvv70p36IbZg0K
