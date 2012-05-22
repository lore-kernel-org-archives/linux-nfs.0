Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26397 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753968Ab2EVPAm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 11:00:42 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] NFS: init client before declaration
Date: Tue, 22 May 2012 15:00:17 +0000
Message-ID: <1337698816.4269.15.camel@lade.trondhjem.org>
References: <20120522124018.338.20817.stgit@localhost.localdomain>
	 <1337696984.4269.4.camel@lade.trondhjem.org>
In-Reply-To: <1337696984.4269.4.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA1LTIyIGF0IDEwOjI5IC0wNDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IE9uIFR1ZSwgMjAxMi0wNS0yMiBhdCAxNjo0MCArMDQwMCwgU3RhbmlzbGF2IEtpbnNidXJz
a3kgd3JvdGU6DQo+ID4gQ2xpZW50IGhhdmUgdG8gYmUgaW5pdGlhbGl6ZWQgcHJpb3IgdG8gYWRk
aW5nIGl0IHRvIHBlci1uZXQgY2xpZW50cyBsaXN0LA0KPiA+IGJlY2F1c2Ugb3RoZXJ3aXNlIHRo
ZXJlIGFyZSByYWNlcywgc2hvd24gYmVsb3c6DQo+ID4gDQo+ID4gQ1BVIzAJCQkJCUNQVSMxDQo+
ID4gX19fX18JCQkJCV9fX19fDQo+ID4gDQo+ID4gbmZzX2dldF9jbGllbnQNCj4gPiBuZnNfYWxs
b2NfY2xpZW50DQo+ID4gbGlzdF9hZGQoLi4uLCBuZnNfY2xpZW50X2xpc3QpDQo+ID4gCQkJCQly
cGNfZmlsbF9zdXBlcg0KPiA+IAkJCQkJcnBjX3BpcGVmc19ldmVudA0KPiA+IAkJCQkJbmZzX2dl
dF9jbGllbnRfZm9yX2V2ZW50DQo+ID4gCQkJCQlfX3JwY19waXBlZnNfZXZlbnQNCj4gPiAJCQkJ
CShjbHAtPmNsX3JwY2NsaWVudCBpcyB1bmluaXRpYWxpemVkKQ0KPiA+IAkJCQkJQlVHKCkNCj4g
PiBpbml0X2NsaWVudA0KPiA+IGNscC0+Y2xfcnBjY2xpZW50ID0gLi4uDQo+ID4gDQo+IA0KPiBX
aHkgbm90IHNpbXBseSBjaGFuZ2UgbmZzX2dldF9jbGllbnRfZm9yX2V2ZW50KCkgc28gdGhhdCBp
dCBkb2Vzbid0DQo+IHRvdWNoIG5mc19jbGllbnRzIHRoYXQgaGF2ZSBjbHAtPmNsX2NvbnNfc3Rh
dGUhPU5GU19DU19SRUFEWT8NCj4gDQo+IFRoYXQgc2hvdWxkIGVuc3VyZSB0aGF0IGl0IGRvZXNu
J3QgdG91Y2ggbmZzX2NsaWVudHMgdGhhdCBmYWlsZWQgdG8NCj4gaW5pdGlhbGlzZSBhbmQvb3Ig
YXJlIHN0aWxsIGluIHRoZSBwcm9jZXNzIG9mIGJlaW5nIGluaXRpYWxpc2VkLg0KDQouLi5hY3R1
YWxseSwgY29tZSB0byB0aGluayBvZiBpdC4gV2h5IG5vdCBqdXN0IGFkZCBhIGhlbHBlciBmdW5j
dGlvbg0KImJvb2wgbmZzX2NsaWVudF9hY3RpdmUoY29uc3Qgc3RydWN0IG5mc19jbGllbnQgKmNs
cCkiIHRvDQpmcy9uZnMvY2xpZW50LmMgdGhhdCBkb2VzIGEgY2FsbCB0bw0KCXdhaXRfZXZlbnRf
a2lsbGFibGUobmZzX2NsaWVudF9hY3RpdmVfd3EsIGNscC0+Y2xfY29uc19zdGF0ZSA8IE5GU19D
U19JTklUSU5HKTsNCmFuZCBjaGVja3MgdGhlIHJlc3VsdGluZyB2YWx1ZSBvZiBjbHAtPmNsX2Nv
bnNfc3RhdGU/DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50
YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5j
b20NCg0K
