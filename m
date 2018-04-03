Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:34627 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755300AbeDCMC2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Apr 2018 08:02:28 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "hch@infradead.org" <hch@infradead.org>,
        bcodding redhat <bcodding@redhat.com>
CC: "fstests@vger.kernel.org" <fstests@vger.kernel.org>,
        "Anna.Schumaker@Netapp.com" <Anna.Schumaker@Netapp.com>,
        "smayhew@redhat.com" <smayhew@redhat.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH xfstests] generic/035: Override output for NFS testing
Date: Tue, 3 Apr 2018 12:02:21 +0000
Message-ID: <1522756939.3428.4.camel@primarydata.com>
References: <e82df2bc4db926b051307ba4066d77b616c79b0c.1522337478.git.bcodding@redhat.com>
         <20180403094540.GA2254@infradead.org>
In-Reply-To: <20180403094540.GA2254@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE4LTA0LTAzIGF0IDAyOjQ1IC0wNzAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gT24gVGh1LCBNYXIgMjksIDIwMTggYXQgMTE6MzQ6MzlBTSAtMDQwMCwgQmVuamFtaW4g
Q29kZGluZ3RvbiB3cm90ZToNCj4gPiBXZSdkIGxpa2UgdG8gcnVuIGdlbmVyaWMgdGVzdHMgZm9y
IE5GUywgYnV0IG9mdGVuIGhhdmUgc2xpZ2h0bHkNCj4gPiBkaWZmZXJlbnQNCj4gPiBvdXRwdXQg
Zm9yIG91ciByZXN1bHRzLiAgT25lIGluc3RhbmNlIGlzIHRoYXQgZm9yIHRoZSBORlMgY2xpZW50
DQo+ID4gdGhlDQo+ID4gcmVtb3ZhbCBvZiBhbiBvcGVuIGZpbGUgb3IgZGlyZWN0b3J5IGlzIGhh
bmRsZWQgZGlmZmVyZW50bHkgdGhhbg0KPiA+IGZvciBhDQo+ID4gbG9jYWwgZmlsZXN5c3RlbS4g
IFdlIGNhbiBleHBlY3QgbmxpbmsgdG8gYmUgMSBmb3IgZmlsZXMsIGFuZCB0bw0KPiA+IHJlY2Vp
dmUNCj4gPiAtRVNUQUxFIGZvciBvcGVyYXRpb25zIG9uIGRlbGV0ZWQgZGlyZWN0b3JpZXMsIGlz
bid0IHRoYXQgc2lsbHk/DQo+IA0KPiBORlMgaXMgc2ltcGx5IGJ1Z2d5IGluIHRoaXMgY2FzZSwg
YW5kIHdlIHNob3VsZCBhdCBsZWFzdCB4ZmFpbCB0aGUNCj4gdGVzdA0KPiBjYXNlLCBub3QgbWFr
ZSBpdCBsb29rIGZpbmUuDQo+IA0KPiBJJ2QgcmF0aGVyIGhhdmUgYSBmaWxlIHRoYXQgbGlzdHMg
ZXhwZWN0ZWQgZmFpbHMgcGVyIGZpbGUgc3lzdGVtIHdpdGgNCj4gYW4NCj4gZXhwbGFuYXRpb24g
dGhhbiBhIGhhY2sgbGlrZSB0aGlzIHRoYXQgcGFwZXJzIG92ZXIgdGhlIGlzc3VlLg0KDQpJSVJD
IHRoYXQgRVNUQUxFIHRlc3QgaXMgaGl0dGluZyBhIHByb3RvY29sIGlzc3VlOiBORlMgZG9lc24n
dCBoYXZlDQpzdGF0ZWZ1bCByZWFkZGlyKCkgKG9yIGFueSBzdGF0ZWZ1bCBkaXJlY3Rvcnkgb3Bl
cmF0aW9ucyksIGFuZCBzbyB0aGVyZQ0KaXMgbm90aGluZyB0byB0ZWxsIHRoZSBzZXJ2ZXIgdG8g
cGluIHRoZSByZW1vdmVkIGRpcmVjdG9yeSB3aGlsZSB3ZQ0KaGF2ZSBpdCBvcGVuIGluIHRoZSBW
RlMgbGF5ZXIgb24gdGhlIGNsaWVudC4NCg0KSSdtIGZpbmUgZWl0aGVyIHdheSwgYnV0IGlmIHdl
IG1ha2UgdGhlIGRlY2lzaW9uIHRvIGNhbGwgb3V0IHByb3RvY29sDQppc3N1ZXMgYXMgJ2V4cGVj
dGVkIGZhaWx1cmUnIHRoZW4gd2UgbmVlZCB0byBtYWtlIHRoYXQgYSBjb25zaXN0ZW50DQpwb2xp
Y3kgZm9yIGFsbCB4ZnN0ZXN0cy4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBj
bGllbnQgbWFpbnRhaW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0
YS5jb20NCg==

