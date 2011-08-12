Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:31657 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636Ab1HLCLI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 22:11:08 -0400
From: <tao.peng@emc.com>
To: <bharrosh@panasas.com>, <bergwolf@gmail.com>
CC: <Trond.Myklebust@netapp.com>, <benny@tonian.com>,
        <linux-nfs@vger.kernel.org>
Date: Thu, 11 Aug 2011 22:07:25 -0400
Subject: RE: [PATCH 1/5] pNFS: recoalesce when ld write pagelist fails
Message-ID: <F19688880B763E40B28B2B462677FBF805BF0EAD77@MX09A.corp.emc.com>
References: <1312685635-1593-1-git-send-email-bergwolf@gmail.com>
 <4E42C564.7070504@panasas.com>
 <CA+a=Yy4WXD64A3anw7f-wSWcs4A4-6W18QQs=YyYC0285_W_qg@mail.gmail.com>
 <4E442512.7080904@panasas.com>
 <CA+a=Yy4g09b_AEf2px1Cjfmr_ud3PFuAbEwdez1cbsiYJ0mmgA@mail.gmail.com>
 <4E446F63.5080707@panasas.com>
In-Reply-To: <4E446F63.5080707@panasas.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBCb2F6IEhhcnJvc2ggW21haWx0
bzpiaGFycm9zaEBwYW5hc2FzLmNvbV0NCj4gU2VudDogRnJpZGF5LCBBdWd1c3QgMTIsIDIwMTEg
ODoxMCBBTQ0KPiBUbzogUGVuZyBUYW8NCj4gQ2M6IFRyb25kIE15a2xlYnVzdDsgQmVubnkgSGFs
ZXZ5OyBsaW51eC1uZnNAdmdlci5rZXJuZWwub3JnOyBQZW5nLCBUYW8NCj4gU3ViamVjdDogUmU6
IFtQQVRDSCAxLzVdIHBORlM6IHJlY29hbGVzY2Ugd2hlbiBsZCB3cml0ZSBwYWdlbGlzdCBmYWls
cw0KPiANCj4gT24gMDgvMTEvMjAxMSAwNDo1MyBQTSwgUGVuZyBUYW8gd3JvdGU6DQo+ID4+DQo+
ID4+IFlvdSBzaG91bGQgc2VlIGlmIHdoYXQgSSBzYXkgaXMgcG9zc2libGUgZm9yIHdyaXRlLiBB
bmQgdGhlbiBtYXliZSBzb21lDQo+ID4+IHRoaW5nIHdpbGwgY29tZSB1cCBhbHNvIGZvciByZWFk
LiBUaGV5IGRvIG5vdCBuZWNlc3NhcmlseSBuZWVkIHRvIGJlIHRoZQ0KPiA+PiBzYW1lLiAoSSB0
aGluaykNCj4gPiBJIGFncmVlIHRoYXQgaXQgaXMgcG9zc2libGUgZm9yIHdyaXRlLiBXZSBjYW4g
cmUtZGlydHkgdGhlIHBhZ2VzIGFuZA0KPiA+IHJlbHkgb24gbmV4dCBmbHVzaCB0byB3cml0ZSBp
dCBvdXQgdG8gTURTLiBUaGlzIGlzIG1lbnRpb25lZCBieSBUcm9uZA0KPiA+IGJlZm9yZS4gSG93
ZXZlciwgdGhlIG1ldGhvZCB3b24ndCB3b3JrIGZvciByZWFkIGZhaWx1cmVzLiBJIGRvbid0IHNl
ZQ0KPiA+IGhvdyB3ZSBjYW4gcXVldWUgZmFpbGVkIHJlYWQgcGFnZXMgYW5kIGxldCBzb21lb25l
IGVsc2UgcmUtc2VuZCBpdA0KPiA+IGxhdGVyLg0KPiA+DQo+IA0KPiBMZXRzIGxlYXZlIHRoZSBy
ZWFkIHBhdGNoIGFzIGlzIGZvciBub3cuIExldHMgdHJ5IHRvIGRvIGl0IG9ubHkgZm9yDQo+IHdy
aXRlcy4NCj4gDQo+IEl0IGlzIE9LIHRvIGhhdmUgd3JpdGUgZG8gb25lIHdheSBhbmQgcmVhZCBk
byBhbm90aGVyIHdheSwgSSB0aGluay4NCj4gDQo+IE1heWJlIGxhdGVyIHdlIGNhbiBmaW5kIGEg
YmV0dGVyIHNvbHV0aW9uIGZvciByZWFkcyBhcyB3ZWxsLg0KDQpPSy4gSSB3aWxsIHRyeSB0byBy
ZXdyaXRlIHRoZSBwYXRjaCBhcyB5b3Ugc3VnZ2VzdGVkLg0KDQpUaGFua3MsDQpUYW8NCgTvv717
Lm7vv70r77+977+977+977+977+977+977+9KyXvv73vv71sendt77+977+9Yu+/veunsu+/ve+/
vXLvv73vv716WO+/ve+/vRnfsinvv73vv73vv713Kh9qZ++/ve+/ve+/vR7vv73vv73vv73vv73v
v73domov77+977+977+9eu+/vd6W77+977+9Mu+/vd6Z77+977+977+9Ju+/vSnfoe+/vWHvv73v
v71/77+977+9Hu+/vUfvv73vv73vv71o77+9D++/vWo6K3bvv73vv73vv71377+92aU=
