Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4347 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756202Ab2CECEK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Mar 2012 21:04:10 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
Date: Mon, 5 Mar 2012 02:04:08 +0000
Message-ID: <1330913047.14357.19.camel@lade.trondhjem.org>
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>
	   <4F2BC1C0.8070900@panasas.com> <20120203231623.442fefde@notabene.brown>
	   <20120203142945.GA31805@us.ibm.com> <4F2E620F.5090100@panasas.com>
	   <20120207204401.GA31752@us.ibm.com> <4F511B21.1020907@RedHat.com>
	   <20120302192758.GA28389@us.ibm.com> <4F513429.1050209@RedHat.com>
	   <20120302220108.GA17119@us.ibm.com> <4F525741.2060404@RedHat.com>
	  <1330801976.2781.19.camel@lade.trondhjem.org>
	 <4F53ED3C.2020209@RedHat.com>  <4F53F39E.9050802@RedHat.com>
	 <1330903600.14357.10.camel@lade.trondhjem.org>
	 <4F5402E4.4030506@RedHat.com>
In-Reply-To: <4F5402E4.4030506@RedHat.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU3VuLCAyMDEyLTAzLTA0IGF0IDE5OjAzIC0wNTAwLCBTdGV2ZSBEaWNrc29uIHdyb3RlOg0K
PiANCj4gT24gMDMvMDQvMjAxMiAwNjoyNiBQTSwgTXlrbGVidXN0LCBUcm9uZCB3cm90ZToNCj4g
PiBPbiBTdW4sIDIwMTItMDMtMDQgYXQgMTc6NTggLTA1MDAsIFN0ZXZlIERpY2tzb24gd3JvdGU6
DQo+ID4+IFNvIHRvIHJlc3RhdGUuLi4gdGhpcyBub3JtYWxpemluZyBvZiB0aGUgcGF0aCBuYW1l
cyAoYWthIHN0cmlwaW5nIA0KPiA+PiBtdWx0aXBsZSBzbGFzaGVzIG9yIGFkZGVkIHRoZSBsZWFk
aW5nIHNsYXNoKSBvbmx5IG5lZWQgdG8gb2NjdXIgb24gDQo+ID4+IChzdWNjZXNzZnVsKSB2NCBt
b3VudHMuLi4gQWx0aG91Z2ggdGhlIGZvcm1lciB3b3VsZCBub3QgYmUgYW4gDQo+ID4+IHByb2Js
ZW0gd2l0aCB2Mi92MyBtb3VudHMgYnV0IGl0cyBub3QgbmVlZGVkLi4uLg0KPiA+IA0KPiA+IE5v
cm1hbGlzaW5nIGZvciB2NCBvbmx5IGlzIE9LIGFzIGZhciBhcyBJJ20gY29uY2VybmVkLCBidXQg
YXMgYW4NCj4gPiBhbHRlcm5hdGl2ZTogaXMgdGhlcmUgYW55IHJlYXNvbiB3aHkgeW91IGNhbid0
IGp1c3QgZ3JhYiB0aGUgcGF0aCBmcm9tDQo+ID4gJy9wcm9jL21vdW50cyc/DQo+ID4gDQo+IFdl
bGwgaW4gc29tZSBkaXN0cm9zIC9ldGMvbXRhYiBpcyBzeW1ib2xpY2FsbHkgbGlua2VkIHRvIC9w
cm9jL21vdW50cw0KPiBzbyB0aGlzIHByb2JsZW0gZG9lcyBub3QgZXhpc3QuIEJ1dCBmcm9tIHdo
YXQgSSd2ZSBiZWVuIHRvbGQgbm90DQo+IGFsbCBkaXN0cm9zIGRvIHRoYXQuIFBsdXMgYmVpbmcg
YmFja3dhcmQgY29tcGF0aWJsZSB3aXRoIG9sZGVyIA0KPiByZWxlYXNlIG9mIGRpc3RybyBpcyBh
IGdvb2QgdGhpbmcuLi4gSU1ITy4uLg0KDQpXaGljaCBpcyB3aHkgSSdtIGFza2luZyB5b3UgaWYg
eW91IGNhbid0IGNvcHkgZnJvbSAvcHJvYy9tb3VudHMuIERpc3Ryb3MNCndoaWNoIGFscmVhZHkg
aGF2ZSBhIHN5bWxpbmsgYmV0d2VlayAvZXRjL210YWIgYW5kIC9wcm9jL21vdW50cyBkb24ndA0K
aGF2ZSBhbnkgb2YgdGhlc2UgcHJvYmxlbXMuLi4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxp
bnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRh
cHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
