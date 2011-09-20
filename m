Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29053 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751643Ab1ITOiw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 10:38:52 -0400
Content-Type: text/plain;
	charset="utf-8"
Subject: RE: [PATCH v4 1/8] SUNRPC: introduce helpers for reference counted rpcbind clients
Date: Tue, 20 Sep 2011 07:38:53 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD2B@SACMVEXC2-PRD.hq.netapp.com>
In-reply-to: <4E78A4AF.1020303@parallels.com>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6> <20110920101341.9861.51453.stgit@localhost6.localdomain6> <4E788F8C.20103@netapp.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD10@SACMVEXC2-PRD.hq.netapp.com> <4E789679.1060601@parallels.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD22@SACMVEXC2-PRD.hq.netapp.com> <4E78A4AF.1020303@parallels.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Stanislav Kinsbursky" <skinsbursky@parallels.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, "Pavel Emelianov" <xemul@parallels.com>,
        <neilb@suse.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <bfields@fieldses.org>,
        <davem@davemloft.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBTdGFuaXNsYXYgS2luc2J1cnNr
eSBbbWFpbHRvOnNraW5zYnVyc2t5QHBhcmFsbGVscy5jb21dDQo+IFNlbnQ6IFR1ZXNkYXksIFNl
cHRlbWJlciAyMCwgMjAxMSAxMDozNSBBTQ0KPiBUbzogTXlrbGVidXN0LCBUcm9uZA0KPiBDYzog
U2NodW1ha2VyLCBCcnlhbjsgbGludXgtbmZzQHZnZXIua2VybmVsLm9yZzsgUGF2ZWwgRW1lbGlh
bm92Ow0KPiBuZWlsYkBzdXNlLmRlOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBsaW51eC1rZXJu
ZWxAdmdlci5rZXJuZWwub3JnOw0KPiBiZmllbGRzQGZpZWxkc2VzLm9yZzsgZGF2ZW1AZGF2ZW1s
b2Z0Lm5ldA0KPiBTdWJqZWN0OiBSZTogW1BBVENIIHY0IDEvOF0gU1VOUlBDOiBpbnRyb2R1Y2Ug
aGVscGVycyBmb3IgcmVmZXJlbmNlDQo+IGNvdW50ZWQgcnBjYmluZCBjbGllbnRzDQo+IA0KPiAy
MC4wOS4yMDExIDE4OjE0LCBNeWtsZWJ1c3QsIFRyb25kINC/0LjRiNC10YI6DQo+IA0KPiA+Pj4N
Cj4gPj4+IERvZXNuJ3QgaXQgIG5lZWQgdG8gYmUgcHJvdGVjdGVkIGJ5IHJwY2JfY2xudF9sb2Nr
IHRvbz8NCj4gPj4+DQo+ID4+DQo+ID4+IE5vcGUgZnJvbSBteSBwb3cuIEl0J3MgcHJvdGVjdGVk
IGJ5IHJwY2JfY3JlYXRlX2xvY2FsX211dGV4LiBJLmUuIG5vDQo+ID4+IG9uZSB3aWxsIGNoYW5n
ZSBycGNiX3VzZXJzIHNpbmNlIGl0J3MgemVyby4gSWYgaXQncyBub24gemVybyAtIHdlDQo+ID4+
IHdpbGxuJ3QgZ2V0IHRvIHJwY2Jfc2V0X2xvY2FsKCkuDQo+ID4NCj4gPiBPSywgc28geW91IGFy
ZSBzYXlpbmcgdGhhdCB0aGUgcnBjYl91c2VycysrIGJlbG93IGNvdWxkIGJlIHJlcGxhY2VkIGJ5
DQo+IHJwY2JfdXNlcnM9MT8NCj4gPg0KPiANCj4gWWVzLCB5b3UgcmlnaHQuDQo+IA0KPiA+IElu
IHRoYXQgY2FzZSwgZG9uJ3QgeW91IG5lZWQgYSBzbXBfd21iKCkgYmV0d2VlbiB0aGUgc2V0dGlu
ZyBvZg0KPiBycGNiX2xvY2FsX2NsbnQvNCBhbmQgdGhlIHNldHRpbmcgb2YgcnBjYl91c2Vycz8g
T3RoZXJ3aXNlLCBob3cgZG8geW91DQo+IGd1YXJhbnRlZSB0aGF0IHJwY2JfdXNlcnMgIT0gMCBp
bXBsaWVzIHJwYmNfbG9jYWxfY2xudC80ICE9IE5VTEw/DQo+ID4NCj4gDQo+IFdlIGNoZWNrIHJw
Y2JfdXNlcnMgdW5kZXIgc3BpbmxvY2suIEdhaW4gc3BpbmxvY2sgZm9yY2VzIG1lbW9yeSBiYXJy
aWVyLA0KPiBkb2Vzbid0IGl0Pw0KDQpZZXMsIGFuZCBzbyB5b3UgZG9uJ3QgbmVlZCBhbiBzbXBf
cm1iKCkgb24gdGhlIHJlYWRlciBzaWRlLiBIb3dldmVyLCB5b3Ugc3RpbGwgbmVlZCB0byBlbnN1
cmUgdGhhdCB0aGUgcHJvY2Vzc29yIHdoaWNoIF9zZXRzXyB0aGUgcnBjYl91c2VycyBhbmQgcnBj
Yl9sb2NhbF9jbG50LzQgYWN0dWFsbHkgd3JpdGVzIHRoZW0gaW4gdGhlIGNvcnJlY3Qgb3JkZXIu
DQoNCkNoZWVycw0KICBUcm9uZA0KDQoT77+977+97Lm7HO+/vSbvv71+77+9Ju+/vRjvv73vv70r
Le+/ve+/vd22F++/ve+/vXfvv73vv73Lm++/ve+/ve+/vW3vv71i77+977+9Z37Ip++/vRfvv73v
v73cqH3vv73vv73vv73GoHrvv70majordu+/ve+/ve+/vQfvv73vv73vv73vv716Wivvv73vv70r
embvv73vv73vv71o77+977+977+9fu+/ve+/ve+/ve+/vWnvv73vv73vv71677+9Hu+/vXfvv73v
v73vv70/77+977+977+977+9Ju+/vSnfohtm
