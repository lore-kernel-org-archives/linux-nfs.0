Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12666 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161197Ab2CPU6Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Mar 2012 16:58:16 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Alexandre Depoutovitch <adepoutovitch@vmware.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: About Direct I/O
Date: Fri, 16 Mar 2012 20:58:14 +0000
Message-ID: <1331931494.13255.1.camel@lade.trondhjem.org>
References: <CAAJC9VbxAcE+DqjqaZ-9K4HKpAWKgg0_B9_QFk64b5V-QdotQA@mail.gmail.com>
	 <6866525b.00001bd8.0000023d@aldep-VC.vmware.com>
	 <20120316203521.GA22929@fieldses.org>
In-Reply-To: <20120316203521.GA22929@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTAzLTE2IGF0IDE2OjM1IC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIEZyaSwgTWFyIDE2LCAyMDEyIGF0IDExOjE0OjA0QU0gLTA3MDAsIEFsZXhhbmRyZSBE
ZXBvdXRvdml0Y2ggd3JvdGU6DQo+ID4gSGVsbG8sDQo+ID4gSSBhbSB0cnlpbmcgdG8gZG8gcmFu
ZG9tIHNlY3RvciBhbGlnbmVkIHdyaXRlcyB0byBhbiBORlMgbW91bnRlZCBkaXNrLiBUaGUNCj4g
PiBwZXJmb3JtYW5jZSBpcyBvcmRlciBvZiBtYWduaXR1ZGUgd29yc2UgdGhhbiA0SyAoZmlsZSBz
eXN0ZW0gYmxvY2sgc2l6ZSkNCj4gPiBhbGlnbmVkIEkvTy4NCj4gPiBUaGUgcmVhc29uIGlzIHRo
YXQgTkZTIGRlbW9uIChMaW51eCBrZXJuZWwgMi42LjMyKSBvbiB0aGUgc2VydmVyIHNpZGUNCj4g
PiBhbHdheXMgZG9lcyBidWZmZXJlZCBJL08sIHdoaWNoIGJlaGF2ZXMgcG9vcmx5IGZvciBibG9j
ayB1bmFsaWduZWQNCj4gPiByZXF1ZXN0cy4NCj4gPiBJcyB0aGVyZSBhIHdheSB0byB0ZWxsIE5G
UyBkYWVtb24gdG8gdXNlIGRpcmVjdCBJL08/IA0KPiANCj4gTm8uDQo+IA0KPiA+IElmIG5vdCwg
aXMgaXQgYW4gaW1wbGVtZW50YXRpb24gbGltaXRhdGlvbiBvciB0aGVyZSBpcyBhIGZ1bmRhbWVu
dGFsDQo+ID4gcHJvYmxlbSB3aXRoIHVzaW5nIGRpcmVjdCBJL08gaW4gTkZTIHNlcnZlcj8NCj4g
DQo+IEknbSBzaGFtZWZ1bGx5IGlnbm9yYW50IG9mIERpcmVjdCBJTy4uLi4NCj4gDQo+IElmIHdl
IHN1cHBvcnRlZCBEaXJlY3QgSU8sIGFyZSB0aGVyZSBoZXVyaXN0aWNzIHRoYXQgd291bGQgbGV0
IHRoZQ0KPiBzZXJ2ZXIgZmlndXJlIG91dCBvbiBpdHMgb3duIHdoZW4gaXQgaGVscGVkIGFuZCB3
aGVuIGl0IGRpZG4ndD8gIE9yDQo+IHdvdWxkIHRoZSBhZG1pbmlzdHJhdG9yIGJlIHN0dWNrIHRy
eWluZyB0byBmaWd1cmUgdGhhdCBvdXQ/DQo+IA0KPiBJcyBEaXJlY3QgSU8gcG9zc2libGUgZnJv
bSBrZXJuZWwgYnVmZmVycyB0aGVzZSBkYXlzPyAgQXJlIHRoZXJlDQo+IGFsaWdubWVudCByZXN0
cmljdGlvbnM/DQoNCldvcmsgaXMgb24gaXRzIHdheSB0byBhbGxvdyBkaXJlY3QgaS9vIGZyb20g
a2VybmVsIGJ1ZmZlcnMsIGJ1dCBpdCBpcw0Kbm90IHBvc3NpYmxlIHdpdGggZXhpc3Rpbmcga2Vy
bmVscy4NCg0KSGF2ZSBwYXRpZW5jZS4NCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMg
Y2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0K
d3d3Lm5ldGFwcC5jb20NCg0K
