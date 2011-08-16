Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:31857 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab1HPHUl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 03:20:41 -0400
From: <tao.peng@emc.com>
To: <bharrosh@panasas.com>, <bergwolf@gmail.com>
CC: <Trond.Myklebust@netapp.com>, <benny@tonian.com>,
        <linux-nfs@vger.kernel.org>
Date: Tue, 16 Aug 2011 03:20:16 -0400
Subject: RE: [PATCH 1/5] pNFS: recoalesce when ld write pagelist fails
Message-ID: <F19688880B763E40B28B2B462677FBF805BF0EB0A3@MX09A.corp.emc.com>
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

SGksIEJvYXosDQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQm9heiBI
YXJyb3NoIFttYWlsdG86YmhhcnJvc2hAcGFuYXNhcy5jb21dDQo+IFNlbnQ6IEZyaWRheSwgQXVn
dXN0IDEyLCAyMDExIDg6MTAgQU0NCj4gVG86IFBlbmcgVGFvDQo+IENjOiBUcm9uZCBNeWtsZWJ1
c3Q7IEJlbm55IEhhbGV2eTsgbGludXgtbmZzQHZnZXIua2VybmVsLm9yZzsgUGVuZywgVGFvDQo+
IFN1YmplY3Q6IFJlOiBbUEFUQ0ggMS81XSBwTkZTOiByZWNvYWxlc2NlIHdoZW4gbGQgd3JpdGUg
cGFnZWxpc3QgZmFpbHMNCj4gDQo+IE9uIDA4LzExLzIwMTEgMDQ6NTMgUE0sIFBlbmcgVGFvIHdy
b3RlOg0KPiA+Pg0KPiA+PiBZb3Ugc2hvdWxkIHNlZSBpZiB3aGF0IEkgc2F5IGlzIHBvc3NpYmxl
IGZvciB3cml0ZS4gQW5kIHRoZW4gbWF5YmUgc29tZQ0KPiA+PiB0aGluZyB3aWxsIGNvbWUgdXAg
YWxzbyBmb3IgcmVhZC4gVGhleSBkbyBub3QgbmVjZXNzYXJpbHkgbmVlZCB0byBiZSB0aGUNCj4g
Pj4gc2FtZS4gKEkgdGhpbmspDQo+ID4gSSBhZ3JlZSB0aGF0IGl0IGlzIHBvc3NpYmxlIGZvciB3
cml0ZS4gV2UgY2FuIHJlLWRpcnR5IHRoZSBwYWdlcyBhbmQNCj4gPiByZWx5IG9uIG5leHQgZmx1
c2ggdG8gd3JpdGUgaXQgb3V0IHRvIE1EUy4gVGhpcyBpcyBtZW50aW9uZWQgYnkgVHJvbmQNCj4g
PiBiZWZvcmUuIEhvd2V2ZXIsIHRoZSBtZXRob2Qgd29uJ3Qgd29yayBmb3IgcmVhZCBmYWlsdXJl
cy4gSSBkb24ndCBzZWUNCj4gPiBob3cgd2UgY2FuIHF1ZXVlIGZhaWxlZCByZWFkIHBhZ2VzIGFu
ZCBsZXQgc29tZW9uZSBlbHNlIHJlLXNlbmQgaXQNCj4gPiBsYXRlci4NCj4gPg0KPiANCj4gTGV0
cyBsZWF2ZSB0aGUgcmVhZCBwYXRjaCBhcyBpcyBmb3Igbm93LiBMZXRzIHRyeSB0byBkbyBpdCBv
bmx5IGZvcg0KPiB3cml0ZXMuDQo+IA0KPiBJdCBpcyBPSyB0byBoYXZlIHdyaXRlIGRvIG9uZSB3
YXkgYW5kIHJlYWQgZG8gYW5vdGhlciB3YXksIEkgdGhpbmsuDQo+IA0KPiBNYXliZSBsYXRlciB3
ZSBjYW4gZmluZCBhIGJldHRlciBzb2x1dGlvbiBmb3IgcmVhZHMgYXMgd2VsbC4NCg0KSSB0cmll
ZCB0byByZXdyaXRlIHRoZSB3cml0ZSBwYXRjaCB0byBoYW5kbGUgZmFpbHVyZXMgaW5zaWRlIG1k
c19vcHMtPnJwY19yZWxlYXNlLiBIb3dldmVyLCBJIGdldCBhIHByb2JsZW0gdy5yLnQuICJyZWRp
cnR5IGFuZCByZWx5IG9uIG5leHQgZmx1c2giLiBJZiB0aGUgZmFpbGVkIHdyaXRlIGlzIHRoZSAq
bGFzdCBmbHVzaCosIHdlIGVuZCB1cCB3aXRoIHJlbHlpbmcgbm8gb25lIGFuZCB0aGUgZGlydHkg
cGFnZXMgYXJlIHNpbXBseSBkcm9wcGVkLiBEbyB5b3UgaGF2ZSBhbnkgc3VnZ2VzdGlvbnMgaG93
IHRvIGhhbmRsZSBpdD8NCg0KVGhhbmtzLA0KVGFvDQoNCg0KDQoNCg0KDQoNCg0KDQoNCgTvv717
Lm7vv70r77+977+977+977+977+977+977+9KyXvv73vv71sendt77+977+9Yu+/veunsu+/ve+/
vXLvv73vv716WO+/ve+/vRnfsinvv73vv73vv713Kh9qZ++/ve+/ve+/vR7vv73vv73vv73vv73v
v73domov77+977+977+9eu+/vd6W77+977+9Mu+/vd6Z77+977+977+9Ju+/vSnfoe+/vWHvv73v
v71/77+977+9Hu+/vUfvv73vv73vv71o77+9D++/vWo6K3bvv73vv73vv71377+92aU=
