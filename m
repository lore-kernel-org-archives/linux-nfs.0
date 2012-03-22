Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47237 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751900Ab2CVAbV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 20:31:21 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Greg KH <gregkh@linuxfoundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        "keyrings@linux-nfs.org" <keyrings@linux-nfs.org>,
        "linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg Kroah-Hartman <gregkh@suse.de>
Subject: Re: [PATCHSET 0/4] kmod: Optional timeout on the wait in
 call_usermodehelper_exec
Date: Thu, 22 Mar 2012 00:31:17 +0000
Message-ID: <1332376277.12332.22.camel@lade.trondhjem.org>
References: <4F691059.30405@panasas.com> <20120321153519.GB30250@kroah.com>
	 <4F6A6FB9.7010508@panasas.com>
In-Reply-To: <4F6A6FB9.7010508@panasas.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTAzLTIxIGF0IDE3OjE4IC0wNzAwLCBCb2F6IEhhcnJvc2ggd3JvdGU6DQo+
IE9uIDAzLzIxLzIwMTIgMDg6MzUgQU0sIEdyZWcgS0ggd3JvdGU6DQo+ID4gT24gVHVlLCBNYXIg
MjAsIDIwMTIgYXQgMDQ6MTg6NDlQTSAtMDcwMCwgQm9heiBIYXJyb3NoIHdyb3RlOg0KPiA+PiBB
bmRyZXcgSGkNCj4gPj4NCj4gPj4gSSdtIHBpY2tpbmcgb24geW91IGJlY2F1c2UgSSBkb24ndCBo
YXZlIGFueSBvbmUgZWxzZSB0byBwaWNrIG9uLg0KPiA+PiBUaGUgMyBmaXJzdCBwYXRjaGVzIGhl
cmUsIGFyZSBqdXN0IGdvb2QgZm9yIHRvZGF5LiBQbGVhc2Ugc2VlIGlmDQo+ID4+IHlvdSB3b3Vs
ZCBsaWtlIHRvIHRha2UgdGhlbT8gb3IgdGVsbCBtZSB3aG8gc2hvdWxkIHRha2UgdGhlbT8NCj4g
Pj4NCj4gPj4gVGhlIDR0aCBwYXRjaCBpcyBhbiBSRkMsIHdoaWNoIGdvdCBtZSBsb29raW5nIGlu
dG8gdGhpcy4NCj4gPj4NCj4gPj4gTXkgbW90aXZhdGlvbiBpcyB0aGF0IEkgYWRkZWQgeWV0IGFu
b3RoZXIgS2VybmVsIGRlcGVuZGVuY3kgb24gdGhlDQo+ID4+IGNhbGxfdXNlcm1vZGVoZWxwZXIo
KSBmdW5jdGlvbiBhbmQgYW0gbm90IGNvbXBsZXRlbHkgaGFwcHkgd2l0aCB0aGUNCj4gPj4gZXJy
b3IgY2FzZSBvZiBoYXZpbmcgdGhlIHVzZXItbW9kZSBwcm9ncmFtIHN0dWNrIGZvcmV2ZXIuIElu
IHN1Y2gNCj4gPj4gY2FzZSBJIHdvdWxkIGxpa2UgdGhlIEtlcm5lbCBwYXJ0IHRvIHRpbWVvdXQg
YW5kIHByb3Blcmx5IGVycm9yIHJlY292ZXINCj4gPj4gYW5kIGNsZWFuIHVwLiBTbyB0aGVyZWZv
ciB0aGUgcHJvcG9zZWQgNHRoIHBhdGNoLg0KPiA+IA0KPiA+IFdoYXQgaXMgdGhpcyBuZXcgdXNl
IG9mIGNhbGxfdXNlcm1vZGhlbHBlciB0aGF0IHlvdSBhcmUgZG9pbmcgdGhpcyB3b3JrDQo+ID4g
Zm9yPyAgSWRlYWxseSwgeW91IG5ldmVyIHdhbnQgdG8gbWFrZSB0aGlzIGNhbGwsIGFzIGl0J3Mg
c2xvdyBhbmQgbWVzc3ksDQo+ID4gYXMgeW91IGhhdmUgZm91bmQgb3V0LiAgSXMgdGhlcmUgYW4g
aW4ta2VybmVsIHVzZXIgdGhhdCB5b3UgaGF2ZQ0KPiA+IHJlY2VudGx5IGFkZGVkPw0KPiA+IA0K
PiA+IHRoYW5rcywNCj4gPiANCj4gPiBncmVnIGstaA0KPiANCj4gSSBhZ3JlZSBoZW5jZSBteSBj
b21tZW50IGluIHRoZSA0dGggcGF0Y2g6DQo+IAkiSW4gdGhlIGJsYXNwaGVtb3VzIG9jY2FzaW9u
cyB0aGF0IGEgdGhlIEtlcm5lbCBtdXN0IGNhbGwgYSB1c2VyLW1vZGUgcHJvZ3JhbSINCj4gDQo+
IEkgaGF2ZSBhZGRlZCBhIG5ldyBjYWxsZXIsIHRvIHRoZSBuZnMvb2JqZWN0bGF5b3V0ZHJpdmVy
LmtvIHRoYXQgdXNlcyB0aGlzDQo+IGZhY2lsaXR5IGZvciBhdXRvLWxvZ2luIGludG8gb3NkLXRh
cmdldHMgKGlzY3NpLXRhcmdldHMpIHdoZW4gbmV3IGFyZSByZXF1ZXN0ZWQNCj4gYnkgdGhlIGZp
bGVzeXN0ZW0uIFRoaXMgYXV0by1sb2dpbiBmYWNpbGl0eSBpcyBtYW5kYXRlZCBieSB0aGUgcG5m
cy1vYmplY3RzDQo+IHN0YW5kYXJkIGJlY2F1c2UgaW4gYSBsYXJnZSBjbHVzdGVyIGZpbGVzeXN0
ZW1zIGZvciB3aGljaCBwbmZzIHdhcyBpbnZlbnRlZCwgc3RvcmFnZQ0KPiBkZXZpY2VzIGJyZWFr
IGFuZCBjaGFuZ2VkIGV2ZXJ5ZGF5LCBhbmQgYSBtYW51YWwgbG9naW4gYnkgZXZlcnkgY2xpZW50
IGlzIG5vdA0KPiBmZWFzaWJsZS4NCj4gDQo+IFlvdSBjYW4gc2VlIHRoaXMgcGF0Y2ggYXMgcG9z
dGVkIHRvIHRoZSBtYWlsaW5nIGxpc3QgaGVyZToNCj4gCWh0dHA6Ly9hcnRpY2xlLmdtYW5lLm9y
Zy9nbWFuZS5saW51eC5uZnMvNDgwMjQvbWF0Y2g9bG9naW4NCj4gCVt0aXRsZTogcG5mcy1vYmo6
IGF1dG9sb2dpbjogQWRkIHN1cHBvcnQgZm9yIHByb3RvY29sIGF1dG9sb2dpbl0NCj4gDQo+IEl0
IHdvcmtzIHZlcnkgd2VsbCBhbmQgd2FzIGhlYXZpbHkgdGVzdGVkLCB3aXRoIGFsbCBlcnJvciBz
Y2VuYXJpb3MsIGJ1dA0KPiB0aGUgdGhlb3JldGljYWwgcG9zc2liaWxpdHkgdGhhdCB0aGUgdXNl
ci1tb2RlIHByb2dyYW0gY2FuIGJlIHN0dWNrIGZvcmV2ZXINCj4gYm90aGVycyBtZSBhbmQgSSB3
b3VsZCBsaWtlIHRvIGRvIHNvbWV0aGluZyBhYm91dCBpdC4gV2l0aCB0aGlzIHBhdGNoIHRoZQ0K
PiBLZXJuZWwgY2FuIHJlY292ZXIgY2xlYW5seSBhbmQgY29udGludWUuIEkgaGF2ZSBhY3R1YWxs
eSB0ZXN0ZWQgdGhpcyBwYXJ0DQo+IGFuZCBpdCB3b3JrcyBhcyBleHBlY3RlZC4NCg0KSGkgQm9h
eiwNCg0KQXMgYW4gYWx0ZXJuYXRpdmUgc3VnZ2VzdGlvbjogc2luY2UgeW91IGFyZSBhbHdheXMg
Y2FsbGluZyB0aGUNCnNhbWUgL3NiaW4vb3NkX2xvZ2luIHVzZXJzcGFjZSBwcm9ncmFtLCB3b3Vs
ZG4ndCBpdCBiZSBlYXNpZXIgdG8gYWRkIHRoZQ0KdGltZW91dCBzbWFydHMgaW50byB0aGF0IHBy
b2dyYW0/IElmIHlvdSBjYW4ndCBtb2RpZnkgdGhlIG9zZF9sb2dpbg0KcHJvZ3JhbSBpdHNlbGYs
IHRoZW4gaXQgc2hvdWxkIHN0aWxsIGJlIHRyaXZpYWwgdG8gd3JhcCBpdCB3aXRoIGEgc2NyaXB0
DQp0aGF0IGFkZHMgdGhlICd0aW1lb3V0JyBjb21tYW5kIHByZWZpeC4NCg0KQ2hlZXJzDQogIFRy
b25kDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoN
Ck5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
