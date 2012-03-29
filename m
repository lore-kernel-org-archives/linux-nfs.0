Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14267 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751630Ab2C2QRQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Mar 2012 12:17:16 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Kevin Graham <mahargk@yahoo-inc.com>
CC: Jim Rees <rees@umich.edu>, Vivek Trivedi <vtrivedi018@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Namjae Jeon <linkinjeon@gmail.com>,
        "amit.sahrawat83@gmail.com" <amit.sahrawat83@gmail.com>
Subject: Re: NFS: low read/stat performance on small files
Date: Thu, 29 Mar 2012 16:16:52 +0000
Message-ID: <1333037819.5547.23.camel@lade.trondhjem.org>
References: <CAKX=r8A90b25VKXC1qtAota9DqDrj37xFT511DuvrZ=1Eux6Xw@mail.gmail.com>
	 <20120323114913.GB24489@umich.edu>
	 <1332505002.20500.14.camel@lade.trondhjem.org>
	 <8E325A03-6EE9-4303-AB52-8BA252E39325@corp.yahoo.com>
In-Reply-To: <8E325A03-6EE9-4303-AB52-8BA252E39325@corp.yahoo.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTAzLTI5IGF0IDA4OjUyIC0wNzAwLCBLZXZpbiBHcmFoYW0gd3JvdGU6DQo+
IE9uIE1hciAyMywgMjAxMiwgYXQgNToxNiBBTSwgTXlrbGVidXN0LCBUcm9uZCB3cm90ZToNCj4g
DQo+ID4gQWxsIHRoZXNlIHRhc2tzIGhhdmUgdG8gYmUgZG9uZSBpbiBzZXJpZXMgKHlvdSBjYW5u
b3QgZG8gdGhlbSBpbiBwYXJhbGxlbCksIGFuZCBzbyB0aGUNCj4gPiBsYXRlbmN5IG9mIGVhY2gg
dGFzayBpcyBsaW1pdGVkIGJ5IHRoZSByb3VuZC10cmlwIHRpbWUgdG8gdGhlIHNlcnZlci4NCj4g
DQo+IA0KPiBXaWxsIHRoZSB2NCBjbGllbnQgYXQgbGVhc3QgY29sbGFwc2UgdGhlbSBpbnRvIGEg
c2luZ2xlIGNvbXBvdW5kIG9wPw0KPiANCg0KV2hlcmUgcG9zc2libGUsIHllcywgYnV0IHRoZXJl
IGlzIHBsZW50eSBvZiBzdHVmZiB3aGVyZSB0aGUgTkZTIGNsaWVudA0Kc2ltcGx5IGRvZXNuJ3Qg
aGF2ZSBlbm91Z2ggaW5mb3JtYXRpb24gdG8gZG8gdGhhdC4gRm9yIGluc3RhbmNlLCB3ZQ0KZG9u
J3QgeWV0IGhhdmUgdGhlIGNhcGFiaWxpdHkgaW4gdGhlIFZGUyB0byBhc2sgTkZTIHRvIGxvb2sg
dXAgc2V2ZXJhbA0KcGF0aCBjb21wb25lbnRzIGF0IHRoZSBzYW1lIHRpbWUuDQoNCkZ1cnRoZXJt
b3JlLCBzb21lIG9mIHRoZXNlIHRoaW5ncyBhcmUgc2VwYXJhdGUgc3lzdGVtIGNhbGxzLiBUaGUN
CmZpbGVzeXN0ZW0gY2FuJ3QganVzdCBhc3N1bWUgdGhhdCBvcGVuKE9fUkRPTkxZKSBtZWFucyB0
aGF0IHdlIHNob3VsZA0Kc3RhcnQgcmVhZCBhaGVhZCwgYW5kIHRoZW4gY2xvc2UgdGhlIGZpbGUs
IHNvIEkgZG9uJ3QgZXZlciBzZWUgdXMgYmVpbmcNCmFibGUgdG8gY29sbGFwc2UgT1BFTitSRUFE
K0NMT1NFIGludG8gYSBzaW5nbGUgY29tcG91bmQuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpM
aW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
