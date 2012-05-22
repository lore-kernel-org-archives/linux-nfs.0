Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30728 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752960Ab2EVO3n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 10:29:43 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] NFS: init client before declaration
Date: Tue, 22 May 2012 14:29:44 +0000
Message-ID: <1337696984.4269.4.camel@lade.trondhjem.org>
References: <20120522124018.338.20817.stgit@localhost.localdomain>
In-Reply-To: <20120522124018.338.20817.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA1LTIyIGF0IDE2OjQwICswNDAwLCBTdGFuaXNsYXYgS2luc2J1cnNreSB3
cm90ZToNCj4gQ2xpZW50IGhhdmUgdG8gYmUgaW5pdGlhbGl6ZWQgcHJpb3IgdG8gYWRkaW5nIGl0
IHRvIHBlci1uZXQgY2xpZW50cyBsaXN0LA0KPiBiZWNhdXNlIG90aGVyd2lzZSB0aGVyZSBhcmUg
cmFjZXMsIHNob3duIGJlbG93Og0KPiANCj4gQ1BVIzAJCQkJCUNQVSMxDQo+IF9fX19fCQkJCQlf
X19fXw0KPiANCj4gbmZzX2dldF9jbGllbnQNCj4gbmZzX2FsbG9jX2NsaWVudA0KPiBsaXN0X2Fk
ZCguLi4sIG5mc19jbGllbnRfbGlzdCkNCj4gCQkJCQlycGNfZmlsbF9zdXBlcg0KPiAJCQkJCXJw
Y19waXBlZnNfZXZlbnQNCj4gCQkJCQluZnNfZ2V0X2NsaWVudF9mb3JfZXZlbnQNCj4gCQkJCQlf
X3JwY19waXBlZnNfZXZlbnQNCj4gCQkJCQkoY2xwLT5jbF9ycGNjbGllbnQgaXMgdW5pbml0aWFs
aXplZCkNCj4gCQkJCQlCVUcoKQ0KPiBpbml0X2NsaWVudA0KPiBjbHAtPmNsX3JwY2NsaWVudCA9
IC4uLg0KPiANCg0KV2h5IG5vdCBzaW1wbHkgY2hhbmdlIG5mc19nZXRfY2xpZW50X2Zvcl9ldmVu
dCgpIHNvIHRoYXQgaXQgZG9lc24ndA0KdG91Y2ggbmZzX2NsaWVudHMgdGhhdCBoYXZlIGNscC0+
Y2xfY29uc19zdGF0ZSE9TkZTX0NTX1JFQURZPw0KDQpUaGF0IHNob3VsZCBlbnN1cmUgdGhhdCBp
dCBkb2Vzbid0IHRvdWNoIG5mc19jbGllbnRzIHRoYXQgZmFpbGVkIHRvDQppbml0aWFsaXNlIGFu
ZC9vciBhcmUgc3RpbGwgaW4gdGhlIHByb2Nlc3Mgb2YgYmVpbmcgaW5pdGlhbGlzZWQuDQoNCkNo
ZWVycw0KICBUcm9uZA0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBt
YWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRh
cHAuY29tDQoNCg==
