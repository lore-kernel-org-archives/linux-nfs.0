Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:30698 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508Ab1IULE2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 07:04:28 -0400
From: <tao.peng@emc.com>
To: <bharrosh@panasas.com>
CC: <bhalevy@tonian.com>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>, <honey@citi.umich.edu>, <rees@umich.edu>
Date: Wed, 21 Sep 2011 07:04:12 -0400
Subject: RE: [PATCH 2/3] pnfs: introduce pnfs private workqueue
Message-ID: <F19688880B763E40B28B2B462677FBF805C4952A33@MX09A.corp.emc.com>
References: <1316488728-24912-1-git-send-email-rees@umich.edu>
 <1316488728-24912-3-git-send-email-rees@umich.edu>
 <1316558461.15093.4.camel@lade.trondhjem.org>
 <20110921002917.GA30770@merit.edu>
 <F19688880B763E40B28B2B462677FBF805C4952916@MX09A.corp.emc.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480226@SACMVEXC2-PRD.hq.netapp.com>
 <F19688880B763E40B28B2B462677FBF805C495295A@MX09A.corp.emc.com>
 <4E798C93.40409@tonian.com>
 <F19688880B763E40B28B2B462677FBF805C4952A24@MX09A.corp.emc.com>
 <4E79BE96.1070905@panasas.com>
In-Reply-To: <4E79BE96.1070905@panasas.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

SGksIEJvYXosDQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IGxpbnV4LW5m
cy1vd25lckB2Z2VyLmtlcm5lbC5vcmcgW21haWx0bzpsaW51eC1uZnMtb3duZXJAdmdlci5rZXJu
ZWwub3JnXQ0KPiBPbiBCZWhhbGYgT2YgQm9heiBIYXJyb3NoDQo+IFNlbnQ6IFdlZG5lc2RheSwg
U2VwdGVtYmVyIDIxLCAyMDExIDY6MzggUE0NCj4gVG86IFBlbmcsIFRhbw0KPiBDYzogYmhhbGV2
eUB0b25pYW4uY29tOyBUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbTsgbGludXgtbmZzQHZnZXIu
a2VybmVsLm9yZzsNCj4gaG9uZXlAY2l0aS51bWljaC5lZHU7IHJlZXNAdW1pY2guZWR1DQo+IFN1
YmplY3Q6IFJlOiBbUEFUQ0ggMi8zXSBwbmZzOiBpbnRyb2R1Y2UgcG5mcyBwcml2YXRlIHdvcmtx
dWV1ZQ0KPiANCj4gT24gMDkvMjEvMjAxMSAwMToyMyBQTSwgdGFvLnBlbmdAZW1jLmNvbSB3cm90
ZToNCj4gPg0KPiA+IFVubGVzcyB3ZSBkbyBmb2xsb3dpbmc6DQo+ID4gMS4gcHJlYWxsb2NhdGUg
bWVtb3J5IGZvciBleHRlbnQgc3RhdGUgY29udmVydGlvbg0KPiA+IDIuIHVzZSBuZnNpb2QvcnBj
aW9kIHRvIGhhbmRsZSBibF93cml0ZV9jbGVhbnVwDQo+ID4gMy4gZm9yIHBuZnMgZXJyb3IgY2Fz
ZSwgY3JlYXRlIGEga3RocmVhZCB0byByZWNvbGxhcHNlIGFuZCByZXNlbmQgdG8gTURTDQo+ID4N
Cj4gPiBub3Qgc3VyZSBpZiBpdCB3b3J0aCB0aGUgY29tcGxleGl0eSB0aG91Z2guLi4NCj4gPg0K
PiA+IENoZWVycywNCj4gPiBUYW8NCj4gPg0KPiANCj4gUGxlYXNlIGZvcmdpdmUgbXkgaWdub3Jh
bmNlIGJ1dCB3aGF0IGlzIHRoZSBiaWcgZGlmZmVyZW5jZSBiZXR3ZWVuDQo+IGEga3RocmVhZCBh
bmQgYSB3b3JrcXVldWU/IEkgdGhvdWdodCBhIHdvcmtxdWV1ZSBpcyBqdXN0IGEga3RocmVhZA0K
PiBhbmQgc29tZSBtZW1vcnkgc3RydWN0dXJlcyAobGlzdCkuDQpTb3JyeSBmb3IgYmVpbmcgbm90
IGNsZWFyLi4uDQpCeSBrdGhyZWFkLCBJIG1lYW4gYSB0aHJlYWQgdGhhdCBydW5zIG9ubHkgb25j
ZSBhbmQgZG9lcyB3aGF0IHdlIG5lZWQgYW5kIHRoZW4gZXhpdHMsIGlmIEkgcmVhZCBjb2RlIGNv
cnJlY3RseSwganVzdCBsaWtlIHRoZSBzdGF0ZSByZWNvdmVyeSB0aHJlYWQgdGhhdCBUcm9uZCBt
ZW50aW9uZWQgYWJvdmUuIEFuZCBhcyBUcm9uZCBleHBsYWluZWQsIHNpbmNlIHRoZSBlcnJvciBj
YXNlIHNob3VsZCBiZSByYXJlLCBpdCBpcyBub3QgbmVjZXNzYXJ5IHRvIGtlZXAgYSB0aHJlYWQg
dXAgYW5kIHdhaXRpbmcgZm9yIGl0IGFsbCB0aGUgdGltZS4NCkFuZCBieSB3b3JrcXVldWUsIEkg
dGhpbmsgeW91IGtub3cgZXhhY3RseSB3aGF0IGl0IGlzIDopDQoNCkNoZWVycywNClRhbw0KPiAN
Cj4gSSBhZ3JlZSB3aXRoICJrZWVwIHRoaW5ncyBzaW1wbGUiDQo+IA0KPiBCdXQgd2hhdCBkbyBJ
IGtub3cgOy0pDQo+IA0KPiBUaGFua3MNCj4gQm9heg0KPiAtLQ0KPiBUbyB1bnN1YnNjcmliZSBm
cm9tIHRoaXMgbGlzdDogc2VuZCB0aGUgbGluZSAidW5zdWJzY3JpYmUgbGludXgtbmZzIiBpbg0K
PiB0aGUgYm9keSBvZiBhIG1lc3NhZ2UgdG8gbWFqb3Jkb21vQHZnZXIua2VybmVsLm9yZw0KPiBN
b3JlIG1ham9yZG9tbyBpbmZvIGF0ICBodHRwOi8vdmdlci5rZXJuZWwub3JnL21ham9yZG9tby1p
bmZvLmh0bWwNCg0KTu+/ve+/ve+/ve+/ve+/vXLvv73vv71577+977+977+9Yu+/vVjvv73vv73H
p3bvv71e77+9Kd66ey5u77+9K++/ve+/ve+/ve+/vXvvv73vv73vv70i77+977+9Xm7vv71y77+9
77+977+9eu+/vRrvv73vv71o77+977+977+977+9Ju+/ve+/vR7vv71H77+977+977+9aO+/vQMo
77+96ZqO77+93aJqIu+/ve+/vRrvv70bbe+/ve+/ve+/ve+/ve+/vXrvv73elu+/ve+/ve+/vWbv
v73vv73vv71o77+977+977+9fu+/vW3vv70=
