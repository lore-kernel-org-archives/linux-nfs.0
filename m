Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hop-nat-141.emc.com ([168.159.213.141]:33137 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933594Ab2KFCUR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 21:20:17 -0500
From: "Peng, Tao" <tao.peng@emc.com>
To: "faibish, sorin" <faibish_sorin@emc.com>, Jun Xiao <xiaojuntime@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jason Glasgow <jglasgow@aya.yale.edu>
Subject: RE: pNFS Block layout issues / questions
Date: Tue, 6 Nov 2012 02:19:55 +0000
Message-ID: <1882637210201641A747464075FFC64902A5D4@MX101CL02.corp.emc.com>
References: <loom.20110328T230906-552@post.gmane.org>
 <4D977456.1040303@panasas.com> <loom.20121103T072206-631@post.gmane.org>
 <1882637210201641A747464075FFC6490291C9@MX101CL02.corp.emc.com>
 <B99990FD-D4C5-43D1-8096-CDAEE90BECB8@emc.com>
In-Reply-To: <B99990FD-D4C5-43D1-8096-CDAEE90BECB8@emc.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IGZhaWJpc2gsIHNvcmluDQo+
IFNlbnQ6IE1vbmRheSwgTm92ZW1iZXIgMDUsIDIwMTIgODo0MiBQTQ0KPiBUbzogUGVuZywgVGFv
DQo+IENjOiBKdW4gWGlhbzsgbGludXgtbmZzQHZnZXIua2VybmVsLm9yZzsgSmFzb24gR2xhc2dv
dw0KPiBTdWJqZWN0OiBSZTogcE5GUyBCbG9jayBsYXlvdXQgaXNzdWVzIC8gcXVlc3Rpb25zDQo+
IA0KPiANCj4gDQo+IFNlbnQgZnJvbSBTb3JpbidzIGlQYWQNCj4gDQo+IE9uIE5vdiA0LCAyMDEy
LCBhdCA5OjMzIFBNLCAiUGVuZywgVGFvIiA8dGFvLnBlbmdAZW1jLmNvbT4gd3JvdGU6DQo+IA0K
PiA+IEhpLA0KPiA+DQo+ID4gSSdsbCBhbnN3ZXIgeW91ciBxdWVzdGlvbnMgYXMgZmFyIGFzIEkg
Y2FuLCBidXQgSSBteXNlbGYgYW0gbm90IGZhbWlsaWFyIHdpdGggTGludXggcG5mcyBibG9jaw0K
PiBzZXJ2ZXIgaW1wbGVtZW50YXRpb24uDQo+ID4NCj4gPj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdl
LS0tLS0NCj4gPj4gRnJvbTogbGludXgtbmZzLW93bmVyQHZnZXIua2VybmVsLm9yZyBbbWFpbHRv
OmxpbnV4LW5mcy1vd25lckB2Z2VyLmtlcm5lbC5vcmddIE9uIEJlaGFsZiBPZiBKdW4NCj4gWGlh
bw0KPiA+PiBTZW50OiBTYXR1cmRheSwgTm92ZW1iZXIgMDMsIDIwMTIgMzoyOCBQTQ0KPiA+PiBU
bzogbGludXgtbmZzQHZnZXIua2VybmVsLm9yZw0KPiA+PiBTdWJqZWN0OiBSZTogcE5GUyBCbG9j
ayBsYXlvdXQgaXNzdWVzIC8gcXVlc3Rpb25zDQo+ID4+DQo+ID4+IFNlZW1zIHRoZSB0aHJlYWQg
ZGlkbid0IGdldCBhbnkgcmVwbHkgZm9yIHF1aXRlIGEgbG9uZyB0aW1lLg0KPiA+Pg0KPiA+PiBJ
J20gdHJ5aW5nIHRvIHNldCB1cCBwTkZTIGJsb2NrIGxheW91dCBNRFMvRFMgc2VydmVyLCBhbmQg
c29tZQ0KPiA+PiBzaW1pbGFyIHF1ZXN0aW9ucyBhcyBQaGlsLg0KPiA+Pg0KPiA+PiAtIEZvciBi
bG9jayBsYXlvdXQsIGlzIGl0IG5lY2Vzc2FyeSB0byBtYWtlIERTIGV4cG9ydCBuZnMgc2hhcmU/
DQo+ID4gTm8uIEp1c3QgZXhwb3J0IHlvdXIgZGF0YSBjb25uZWN0aW9uIGlzIGVub3VnaCwgd2hp
Y2ggZm9yIHBuZnMgYmxvY2sgY2FuIGJlIGlzY3NpL0ZTIGV0Yy4NCj4gU2hvdWxkIGJlIGlTQ1NJ
IC8gRkMgZmliZXIgY2hhbm5lbC4NCj4gDQpZZXMuIGFuZCBzb3JyeSBmb3IgdGhlIHR5cG8uLi4N
Cg0KPiA+DQo+ID4+IC0gSG93IGNvdWxkIGFkZCBhIGJsb2NrIGxheW91dCBEUyBpbnRvIHBORlMg
c2VydmVyPw0KPiA+IEkgZG9uJ3QgdGhpbmsgTGludXggcG5mcyBibG9jayBzZXJ2ZXIgaW1wbGVt
ZW50cyBzZXBhcmF0ZSBEU2VzLiBTbyBNRFMvRFMgaGFzIHRvIGJlIG9uIHRoZSBzYW1lDQo+IG1h
Y2hpbmUgZm9yIGl0Lg0KPiBNYXliZSBKYXNvbiBHbGFzZ293IHJlbWVtYmVycz8NCj4gDQpGb3Ig
c3BuZnMsIE1EUy9EUyBoYXMgdG8gYmUgb24gdGhlIHNhbWUgbWFjaGluZS4gRm9yIGJsb2NrIGxh
eW91dCBzZXJ2ZXIsIHRoZXJlIGlzIG5vdCBtdWNoIGNvbmNlcHQgb2YgRFNlcy4gVGhlIG9ubHkg
cmVxdWlyZW1lbnQgaXMgdGhhdCBNRFMgYW5kIGNsaWVudHMgY2FuIGFjY2VzcyB0aGUgc2FtZSBz
dG9yYWdlLiBTbyBpdCBjYW4gYmUgZWl0aGVyIGlzY3NpIGV4cG9ydGVkIGZyb20gdGhlIHNhbWUg
TURTLCBvciBzb21lIHNoYXJlZCBzdG9yYWdlIGxpa2UgU0FOIGV0Yy4NCg0KQ2hlZXJzLA0KVGFv
DQoNCj4gPg0KPiA+PiAtIERvZXMgc3BuZnMgYWxzbyB3b3JrIGZvciBibG9jayBsYXlvdXQvDQo+
ID4gTGFyZ2VseSB5ZXMuIFRoZSB3aWtpIHBhZ2UgaGFzIGl0IHRoYXQgcG5mcyBibG9jayBzZXJ2
ZXIgaXMgYmFzZWQgb24gc3BuZnMuDQo+ID4gaHR0cDovL2xpbnV4LW5mcy5vcmcvd2lraS9pbmRl
eC5waHAvUE5GU19CbG9ja19TZXJ2ZXJfU2V0dXBfSW5zdHJ1Y3Rpb25zDQo+ID4NCj4gPiBCdXQg
SSdtIG5vdCBzdXJlIGlmIHRoZSBjb2RlIHN0aWxsIHdvcmtzLg0KPiA+DQo+ID4gQ2hlZXJzLA0K
PiA+IFRhbw0KPiA+DQo+ID4gE++/ve+/vey5uxzvv70m77+9fu+/vSbvv70Y77+977+9Ky0NCj4g
77+977+93bYX77+977+9d++/ve+/vcub77+977+977+9be+/vWLvv73vv71nfsin77+9F++/ve+/
vdyofe+/ve+/ve+/vcageu+/vSZqOit277+977+977+9De+/ve+/ve+/ve+/vXpaK++/ve+/vSt6
Zu+/ve+/ve+/vWjvv73vv73vv71+77+977+977+977+9ae+/ve+/ve+/vXrvv70e77+9d++/ve+/
ve+/vT/vv73vv73vv73vv70m77+9Kd+iG2YNCg==
