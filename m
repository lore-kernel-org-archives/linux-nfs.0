Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:53416 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751029AbdCQObY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Mar 2017 10:31:24 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "elena.reshetova@intel.com" <elena.reshetova@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>
CC: "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "ralf@linux-mips.org" <ralf@linux-mips.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "ishkamiel@gmail.com" <ishkamiel@gmail.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
        "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jreuter@yaina.de" <jreuter@yaina.de>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>,
        "dwindsor@gmail.com" <dwindsor@gmail.com>,
        "zyan@redhat.com" <zyan@redhat.com>,
        "sage@redhat.com" <sage@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "vyasevich@gmail.com" <vyasevich@gmail.com>,
        "linux-x25@vger.kernel.org" <linux-x25@vger.kernel.org>,
        "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>,
        "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>
Subject: Re: [PATCH 01/23] net, sunrpc: convert rpc_cred.cr_count from
 atomic_t to refcount_t
Date: Fri, 17 Mar 2017 14:28:37 +0000
Message-ID: <1489760913.8441.1.camel@primarydata.com>
References: <1489752646-8749-1-git-send-email-elena.reshetova@intel.com>
         <1489752646-8749-2-git-send-email-elena.reshetova@intel.com>
         <1489755011.6453.1.camel@primarydata.com>
         <1489755736.2810.10.camel@poochiereds.net>
In-Reply-To: <1489755736.2810.10.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE3LTAzLTE3IGF0IDA5OjAyIC0wNDAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
T24gRnJpLCAyMDE3LTAzLTE3IGF0IDEyOjUwICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+ID4gT24gRnJpLCAyMDE3LTAzLTE3IGF0IDE0OjEwICswMjAwLCBFbGVuYSBSZXNoZXRvdmEg
d3JvdGU6DQo+ID4gPiByZWZjb3VudF90IHR5cGUgYW5kIGNvcnJlc3BvbmRpbmcgQVBJIHNob3Vs
ZCBiZQ0KPiA+ID4gdXNlZCBpbnN0ZWFkIG9mIGF0b21pY190IHdoZW4gdGhlIHZhcmlhYmxlIGlz
IHVzZWQgYXMNCj4gPiA+IGEgcmVmZXJlbmNlIGNvdW50ZXIuIFRoaXMgYWxsb3dzIHRvIGF2b2lk
IGFjY2lkZW50YWwNCj4gPiA+IHJlZmNvdW50ZXIgb3ZlcmZsb3dzIHRoYXQgbWlnaHQgbGVhZCB0
byB1c2UtYWZ0ZXItZnJlZQ0KPiA+ID4gc2l0dWF0aW9ucy4NCj4gPiA+IA0KPiA+ID4gU2lnbmVk
LW9mZi1ieTogRWxlbmEgUmVzaGV0b3ZhIDxlbGVuYS5yZXNoZXRvdmFAaW50ZWwuY29tPg0KPiA+
ID4gU2lnbmVkLW9mZi1ieTogSGFucyBMaWxqZXN0cmFuZCA8aXNoa2FtaWVsQGdtYWlsLmNvbT4N
Cj4gPiA+IFNpZ25lZC1vZmYtYnk6IEtlZXMgQ29vayA8a2Vlc2Nvb2tAY2hyb21pdW0ub3JnPg0K
PiA+ID4gU2lnbmVkLW9mZi1ieTogRGF2aWQgV2luZHNvciA8ZHdpbmRzb3JAZ21haWwuY29tPg0K
PiA+ID4gLS0tDQo+ID4gPiDCoGluY2x1ZGUvbGludXgvc3VucnBjL2F1dGguaCB8wqDCoDggKysr
Ky0tLS0NCj4gPiA+IMKgbmV0L3N1bnJwYy9hdXRoLmPCoMKgwqDCoMKgwqDCoMKgwqDCoMKgfCAx
MiArKysrKystLS0tLS0NCj4gPiA+IMKgMiBmaWxlcyBjaGFuZ2VkLCAxMCBpbnNlcnRpb25zKCsp
LCAxMCBkZWxldGlvbnMoLSkNCj4gPiA+IA0KPiA+ID4gZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGlu
dXgvc3VucnBjL2F1dGguaA0KPiA+ID4gYi9pbmNsdWRlL2xpbnV4L3N1bnJwYy9hdXRoLmgNCj4g
PiA+IGluZGV4IGIxYmM2MmIuLmJkMzZlMGIgMTAwNjQ0DQo+ID4gPiAtLS0gYS9pbmNsdWRlL2xp
bnV4L3N1bnJwYy9hdXRoLmgNCj4gPiA+ICsrKyBiL2luY2x1ZGUvbGludXgvc3VucnBjL2F1dGgu
aA0KPiA+ID4gQEAgLTE1LDcgKzE1LDcgQEANCj4gPiA+IMKgI2luY2x1ZGUgPGxpbnV4L3N1bnJw
Yy9tc2dfcHJvdC5oPg0KPiA+ID4gwqAjaW5jbHVkZSA8bGludXgvc3VucnBjL3hkci5oPg0KPiA+
ID4gwqANCj4gPiA+IC0jaW5jbHVkZSA8bGludXgvYXRvbWljLmg+DQo+ID4gPiArI2luY2x1ZGUg
PGxpbnV4L3JlZmNvdW50Lmg+DQo+ID4gPiDCoCNpbmNsdWRlIDxsaW51eC9yY3VwZGF0ZS5oPg0K
PiA+ID4gwqAjaW5jbHVkZSA8bGludXgvdWlkZ2lkLmg+DQo+ID4gPiDCoCNpbmNsdWRlIDxsaW51
eC91dHNuYW1lLmg+DQo+ID4gPiBAQCAtNjgsNyArNjgsNyBAQCBzdHJ1Y3QgcnBjX2NyZWQgew0K
PiA+ID4gwqAjZW5kaWYNCj4gPiA+IMKgCXVuc2lnbmVkIGxvbmcJCWNyX2V4cGlyZTsJLyogd2hl
bg0KPiA+ID4gdG8gZ2MNCj4gPiA+ICovDQo+ID4gPiDCoAl1bnNpZ25lZCBsb25nCQljcl9mbGFn
czsJLyogdmFyaW91cw0KPiA+ID4gZmxhZ3MgKi8NCj4gPiA+IC0JYXRvbWljX3QJCWNyX2NvdW50
OwkvKiByZWYgY291bnQgKi8NCj4gPiA+ICsJcmVmY291bnRfdAkJY3JfY291bnQ7CS8qIHJlZiBj
b3VudA0KPiA+ID4gKi8NCj4gPiA+IA0KPiA+IA0KPiA+IE5BQ0suIFRoYXQncyBnb2luZyB0byBi
ZSBoaXR0aW5nDQo+ID4gV0FSTl9PTkNFKCFyZWZjb3VudF9pbmNfbm90X3plcm8ociksDQo+ID4g
InJlZmNvdW50X3Q6IGluY3JlbWVudCBvbiAwOyB1c2UtYWZ0ZXItZnJlZS5cbiIpIGxpa2UgdGhl
cmUncyBubw0KPiA+IHRvbW9ycm93Li4uDQo+ID4gDQo+ID4gUGxlYXNlIHN0b3Agd2l0aCB0aGVz
ZSBhdXRvbWF0ZWQgY29udmVyc2lvbnMuIFRoZXkgYXJlIGdvaW5nIHRvDQo+ID4gY2F1c2UgYQ0K
PiA+IGxvdCBtb3JlIGJ1Z3MgdGhhbiB0aGV5IGZpeC4NCj4gPiANCj4gDQo+IEFncmVlZC4gVGhl
c2UgcGF0Y2hzZXRzIGFyZSB0b3VjaGluZyBwbGFjZXMgd2hlcmUgd2UndmUgYWxyZWFkeQ0KPiBi
YW5nZWQNCj4gb3V0IG1vc3Qgb2YgdGhlIHJlZmNvdW50aW5nIGJ1Z3MuIEknbSBhZ2FpbnN0IGRv
aW5nIGxhcmdlIHNjYWxlDQo+IGNvbnZlcnNpb25zIGxpa2UgdGhpcyB3aXRob3V0IGEgZGFtbmVk
IGdvb2QgcmVhc29uLg0KPiANCj4gSSB0aGluayBpdCBtYXkgYmUgYmVzdCB0byBkbyB0aGlzIHNv
cnQgb2YgdGhpbmcgaW4gYSBtb3JlIHBpZWNlbWVhbA0KPiBmYXNoaW9uLiBQaWNrIGEgc3Vic3lz
dGVtIG9yIHR3byBhbmQgZG8gdGhlIGNvbnZlcnNpb25zIHRoZXJlIHRvDQo+IHByb3ZlDQo+IHRo
YXQgdGhleSdyZSBiZXR0ZXIgdGhhbiB3aGF0IHdlIGhhdmUuIElmIHRoZSBzdWJzeXN0ZW0gYWxy
ZWFkeSBoYXMNCj4gcHJvYmxlbXMgd2l0aCBpdHMgcmVmY291bnRpbmcsIHRoZW4gc28gbXVjaCB0
aGUgYmV0dGVyLiBQb2ludCB0byBidWdzDQo+IHRoYXQgdGhpcyBuZXcgaW5mcmFzdHJ1Y3R1cmUg
aGVscGVkIGZpbmQuDQo+IA0KPiBFbmNvdXJhZ2UgcGVvcGxlIHRvIGFkb3B0IHlvdXIgbmV3IGlu
ZnJhc3RydWN0dXJlIGFzIG5ldyByZWZjb3VudGVkDQo+IG9iamVjdHMgYXJlIGludHJvZHVjZWQg
aW50byB0aGUga2VybmVsLiBZb3UgbWlnaHQgZXZlbiBjb25zaWRlciBhIExXTg0KPiBhcnRpY2xl
IGFib3V0IHRoaXMuDQo+IA0KPiBFdmVudHVhbGx5IHdlJ2xsIGdldCBhcm91bmQgdG8gY2hhbmdp
bmcgZXhpc3RpbmcgY29kZSB0byB1c2UgaXQsIG9uY2UNCj4gdGhlcmUgaXMgYSBzdWZmaWNpZW50
IGFkdmFudGFnZSB0byBkb2luZyBzby4gTW9zdCBsaWtlbHkgd2hlbiB3ZSdyZQ0KPiByZXdvcmtp
bmcgdGhlIGNvZGUgZm9yIG90aGVyIHJlYXNvbnMsIG9yIHdoZW4gd2UncmUgY2hhc2luZyBzb21l
DQo+IGhvcnJpZA0KPiByZWZjb3VudGluZyBidWcgYW5kIHRoaW5rIHRoYXQgdGhpcyBtaWdodCBo
ZWxwIGZpbmQgaXQuDQoNClRoZSBtYWluIGlzc3VlIGlzIHRoYXQgdGhpcyAicmVmY291bnRfdCIg
aW1wbGVtZW50YXRpb24gYXBwZWFycyB0byBiZQ0KYXNzdW1pbmcgdGhhdCB0aGVyZSBpcyBvbmUg
YW5kIG9ubHkgb25lIG1vZGVsIGZvciByZWZjb3VudHMgKHRoZSBvbmUNCndoZXJlIGEgdmFsdWUg
b2YgIjAiIG1lYW5zICJmcmVlIG1lIGltbWVkaWF0ZWx5IikuDQoNClRoZSBrZXJuZWwgaGFzIGEg
cGxldGhvcmEgb2Ygb2JqZWN0IGNhY2hpbmcgaW1wbGVtZW50YXRpb25zIHdoZXJlIHRoaXMNCmlz
IHNpbXBseSBub3QgdGhlIGNhc2U7IHRoZSBkY2FjaGUgaXMgYSBwcmltZSBleGFtcGxlLCBhbmQg
dGhpcyBjYWNoZQ0KaXMgYW5vdGhlci4gSW4gYm90aCB0aGVzZSBpbXBsZW1lbnRhdGlvbiwgdGhl
IGF0b21pY190IHZhcmlhYmxlIGlzDQpiZWluZyB1c2VkIG1vcmUgYXMgYSBzZW1hcGhvcmUtc3R5
bGUgbG9jayB0aGF0IHByZXZlbnRzIGZyZWVpbmcgb2YgdGhlDQpvYmplY3Qgd2hpbGUgaXQgaXMg
aW4gYWN0aXZlIHVzZSBhcyBvcHBvc2VkIHRvIGJlaW5nIGZyZWVhYmxlLCBidXQNCmNhY2hlZC4g
VGhpcyBpcyB3aHkgdGhlc2UgYXV0b21hdGVkIGNvbnZlcnNpb25zIGFyZSBhIG51aXNhbmNlIGFu
ZCBhDQpzb3VyY2Ugb2YgYnVncy4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBj
bGllbnQgbWFpbnRhaW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0
YS5jb20NCg==

