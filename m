Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:29244 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755104AbdCTQQl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Mar 2017 12:16:41 -0400
From: "Reshetova, Elena" <elena.reshetova@intel.com>
To: Trond Myklebust <trondmy@primarydata.com>,
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
Subject: RE: [PATCH 01/23] net, sunrpc: convert rpc_cred.cr_count from
 atomic_t to refcount_t
Date: Mon, 20 Mar 2017 16:15:37 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B41C5B3C5@IRSMSX102.ger.corp.intel.com>
References: <1489752646-8749-1-git-send-email-elena.reshetova@intel.com>
         <1489752646-8749-2-git-send-email-elena.reshetova@intel.com>
         <1489755011.6453.1.camel@primarydata.com>
         <1489755736.2810.10.camel@poochiereds.net>
 <1489760913.8441.1.camel@primarydata.com>
In-Reply-To: <1489760913.8441.1.camel@primarydata.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiBPbiBGcmksIDIwMTctMDMtMTcgYXQgMDk6MDIgLTA0MDAsIEplZmYgTGF5dG9uIHdyb3RlOg0K
PiA+IE9uIEZyaSwgMjAxNy0wMy0xNyBhdCAxMjo1MCArMDAwMCwgVHJvbmQgTXlrbGVidXN0IHdy
b3RlOg0KPiA+ID4gT24gRnJpLCAyMDE3LTAzLTE3IGF0IDE0OjEwICswMjAwLCBFbGVuYSBSZXNo
ZXRvdmEgd3JvdGU6DQo+ID4gPiA+IHJlZmNvdW50X3QgdHlwZSBhbmQgY29ycmVzcG9uZGluZyBB
UEkgc2hvdWxkIGJlDQo+ID4gPiA+IHVzZWQgaW5zdGVhZCBvZiBhdG9taWNfdCB3aGVuIHRoZSB2
YXJpYWJsZSBpcyB1c2VkIGFzDQo+ID4gPiA+IGEgcmVmZXJlbmNlIGNvdW50ZXIuIFRoaXMgYWxs
b3dzIHRvIGF2b2lkIGFjY2lkZW50YWwNCj4gPiA+ID4gcmVmY291bnRlciBvdmVyZmxvd3MgdGhh
dCBtaWdodCBsZWFkIHRvIHVzZS1hZnRlci1mcmVlDQo+ID4gPiA+IHNpdHVhdGlvbnMuDQo+ID4g
PiA+DQo+ID4gPiA+IFNpZ25lZC1vZmYtYnk6IEVsZW5hIFJlc2hldG92YSA8ZWxlbmEucmVzaGV0
b3ZhQGludGVsLmNvbT4NCj4gPiA+ID4gU2lnbmVkLW9mZi1ieTogSGFucyBMaWxqZXN0cmFuZCA8
aXNoa2FtaWVsQGdtYWlsLmNvbT4NCj4gPiA+ID4gU2lnbmVkLW9mZi1ieTogS2VlcyBDb29rIDxr
ZWVzY29va0BjaHJvbWl1bS5vcmc+DQo+ID4gPiA+IFNpZ25lZC1vZmYtYnk6IERhdmlkIFdpbmRz
b3IgPGR3aW5kc29yQGdtYWlsLmNvbT4NCj4gPiA+ID4gLS0tDQo+ID4gPiA+IMKgaW5jbHVkZS9s
aW51eC9zdW5ycGMvYXV0aC5oIHzCoMKgOCArKysrLS0tLQ0KPiA+ID4gPiDCoG5ldC9zdW5ycGMv
YXV0aC5jwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHwgMTIgKysrKysrLS0tLS0tDQo+ID4gPiA+IMKg
MiBmaWxlcyBjaGFuZ2VkLCAxMCBpbnNlcnRpb25zKCspLCAxMCBkZWxldGlvbnMoLSkNCj4gPiA+
ID4NCj4gPiA+ID4gZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvc3VucnBjL2F1dGguaA0KPiA+
ID4gPiBiL2luY2x1ZGUvbGludXgvc3VucnBjL2F1dGguaA0KPiA+ID4gPiBpbmRleCBiMWJjNjJi
Li5iZDM2ZTBiIDEwMDY0NA0KPiA+ID4gPiAtLS0gYS9pbmNsdWRlL2xpbnV4L3N1bnJwYy9hdXRo
LmgNCj4gPiA+ID4gKysrIGIvaW5jbHVkZS9saW51eC9zdW5ycGMvYXV0aC5oDQo+ID4gPiA+IEBA
IC0xNSw3ICsxNSw3IEBADQo+ID4gPiA+IMKgI2luY2x1ZGUgPGxpbnV4L3N1bnJwYy9tc2dfcHJv
dC5oPg0KPiA+ID4gPiDCoCNpbmNsdWRlIDxsaW51eC9zdW5ycGMveGRyLmg+DQo+ID4gPiA+DQo+
ID4gPiA+IC0jaW5jbHVkZSA8bGludXgvYXRvbWljLmg+DQo+ID4gPiA+ICsjaW5jbHVkZSA8bGlu
dXgvcmVmY291bnQuaD4NCj4gPiA+ID4gwqAjaW5jbHVkZSA8bGludXgvcmN1cGRhdGUuaD4NCj4g
PiA+ID4gwqAjaW5jbHVkZSA8bGludXgvdWlkZ2lkLmg+DQo+ID4gPiA+IMKgI2luY2x1ZGUgPGxp
bnV4L3V0c25hbWUuaD4NCj4gPiA+ID4gQEAgLTY4LDcgKzY4LDcgQEAgc3RydWN0IHJwY19jcmVk
IHsNCj4gPiA+ID4gwqAjZW5kaWYNCj4gPiA+ID4gwqAJdW5zaWduZWQgbG9uZwkJY3JfZXhwaXJl
OwkvKiB3aGVuDQo+ID4gPiA+IHRvIGdjDQo+ID4gPiA+ICovDQo+ID4gPiA+IMKgCXVuc2lnbmVk
IGxvbmcJCWNyX2ZsYWdzOwkvKiB2YXJpb3VzDQo+ID4gPiA+IGZsYWdzICovDQo+ID4gPiA+IC0J
YXRvbWljX3QJCWNyX2NvdW50OwkvKiByZWYgY291bnQgKi8NCj4gPiA+ID4gKwlyZWZjb3VudF90
CQljcl9jb3VudDsJLyogcmVmIGNvdW50DQo+ID4gPiA+ICovDQo+ID4gPiA+DQo+ID4gPg0KPiA+
ID4gTkFDSy4gVGhhdCdzIGdvaW5nIHRvIGJlIGhpdHRpbmcNCj4gPiA+IFdBUk5fT05DRSghcmVm
Y291bnRfaW5jX25vdF96ZXJvKHIpLA0KPiA+ID4gInJlZmNvdW50X3Q6IGluY3JlbWVudCBvbiAw
OyB1c2UtYWZ0ZXItZnJlZS5cbiIpIGxpa2UgdGhlcmUncyBubw0KPiA+ID4gdG9tb3Jyb3cuLi4N
Cj4gPiA+DQo+ID4gPiBQbGVhc2Ugc3RvcCB3aXRoIHRoZXNlIGF1dG9tYXRlZCBjb252ZXJzaW9u
cy4gVGhleSBhcmUgZ29pbmcgdG8NCj4gPiA+IGNhdXNlIGENCj4gPiA+IGxvdCBtb3JlIGJ1Z3Mg
dGhhbiB0aGV5IGZpeC4NCj4gPiA+DQo+ID4NCj4gPiBBZ3JlZWQuIFRoZXNlIHBhdGNoc2V0cyBh
cmUgdG91Y2hpbmcgcGxhY2VzIHdoZXJlIHdlJ3ZlIGFscmVhZHkNCj4gPiBiYW5nZWQNCj4gPiBv
dXQgbW9zdCBvZiB0aGUgcmVmY291bnRpbmcgYnVncy4gSSdtIGFnYWluc3QgZG9pbmcgbGFyZ2Ug
c2NhbGUNCj4gPiBjb252ZXJzaW9ucyBsaWtlIHRoaXMgd2l0aG91dCBhIGRhbW5lZCBnb29kIHJl
YXNvbi4NCj4gPg0KPiA+IEkgdGhpbmsgaXQgbWF5IGJlIGJlc3QgdG8gZG8gdGhpcyBzb3J0IG9m
IHRoaW5nIGluIGEgbW9yZSBwaWVjZW1lYWwNCj4gPiBmYXNoaW9uLiBQaWNrIGEgc3Vic3lzdGVt
IG9yIHR3byBhbmQgZG8gdGhlIGNvbnZlcnNpb25zIHRoZXJlIHRvDQo+ID4gcHJvdmUNCj4gPiB0
aGF0IHRoZXkncmUgYmV0dGVyIHRoYW4gd2hhdCB3ZSBoYXZlLiBJZiB0aGUgc3Vic3lzdGVtIGFs
cmVhZHkgaGFzDQo+ID4gcHJvYmxlbXMgd2l0aCBpdHMgcmVmY291bnRpbmcsIHRoZW4gc28gbXVj
aCB0aGUgYmV0dGVyLiBQb2ludCB0byBidWdzDQo+ID4gdGhhdCB0aGlzIG5ldyBpbmZyYXN0cnVj
dHVyZSBoZWxwZWQgZmluZC4NCj4gPg0KPiA+IEVuY291cmFnZSBwZW9wbGUgdG8gYWRvcHQgeW91
ciBuZXcgaW5mcmFzdHJ1Y3R1cmUgYXMgbmV3IHJlZmNvdW50ZWQNCj4gPiBvYmplY3RzIGFyZSBp
bnRyb2R1Y2VkIGludG8gdGhlIGtlcm5lbC4gWW91IG1pZ2h0IGV2ZW4gY29uc2lkZXIgYSBMV04N
Cj4gPiBhcnRpY2xlIGFib3V0IHRoaXMuDQo+ID4NCj4gPiBFdmVudHVhbGx5IHdlJ2xsIGdldCBh
cm91bmQgdG8gY2hhbmdpbmcgZXhpc3RpbmcgY29kZSB0byB1c2UgaXQsIG9uY2UNCj4gPiB0aGVy
ZSBpcyBhIHN1ZmZpY2llbnQgYWR2YW50YWdlIHRvIGRvaW5nIHNvLiBNb3N0IGxpa2VseSB3aGVu
IHdlJ3JlDQo+ID4gcmV3b3JraW5nIHRoZSBjb2RlIGZvciBvdGhlciByZWFzb25zLCBvciB3aGVu
IHdlJ3JlIGNoYXNpbmcgc29tZQ0KPiA+IGhvcnJpZA0KPiA+IHJlZmNvdW50aW5nIGJ1ZyBhbmQg
dGhpbmsgdGhhdCB0aGlzIG1pZ2h0IGhlbHAgZmluZCBpdC4NCj4gDQo+IFRoZSBtYWluIGlzc3Vl
IGlzIHRoYXQgdGhpcyAicmVmY291bnRfdCIgaW1wbGVtZW50YXRpb24gYXBwZWFycyB0byBiZQ0K
PiBhc3N1bWluZyB0aGF0IHRoZXJlIGlzIG9uZSBhbmQgb25seSBvbmUgbW9kZWwgZm9yIHJlZmNv
dW50cyAodGhlIG9uZQ0KPiB3aGVyZSBhIHZhbHVlIG9mICIwIiBtZWFucyAiZnJlZSBtZSBpbW1l
ZGlhdGVseSIpLg0KPiANCj4gVGhlIGtlcm5lbCBoYXMgYSBwbGV0aG9yYSBvZiBvYmplY3QgY2Fj
aGluZyBpbXBsZW1lbnRhdGlvbnMgd2hlcmUgdGhpcw0KPiBpcyBzaW1wbHkgbm90IHRoZSBjYXNl
OyB0aGUgZGNhY2hlIGlzIGEgcHJpbWUgZXhhbXBsZSwgYW5kIHRoaXMgY2FjaGUNCj4gaXMgYW5v
dGhlci4gSW4gYm90aCB0aGVzZSBpbXBsZW1lbnRhdGlvbiwgdGhlIGF0b21pY190IHZhcmlhYmxl
IGlzDQo+IGJlaW5nIHVzZWQgbW9yZSBhcyBhIHNlbWFwaG9yZS1zdHlsZSBsb2NrIHRoYXQgcHJl
dmVudHMgZnJlZWluZyBvZiB0aGUNCj4gb2JqZWN0IHdoaWxlIGl0IGlzIGluIGFjdGl2ZSB1c2Ug
YXMgb3Bwb3NlZCB0byBiZWluZyBmcmVlYWJsZSwgYnV0DQo+IGNhY2hlZC4gVGhpcyBpcyB3aHkg
dGhlc2UgYXV0b21hdGVkIGNvbnZlcnNpb25zIGFyZSBhIG51aXNhbmNlIGFuZCBhDQo+IHNvdXJj
ZSBvZiBidWdzLg0KDQpPaywgaW4gdGhpcyBwYXJ0aWN1bGFyIHBhdGNoIEkgYWdyZWUgdGhhdCB3
ZSBtaXNzZWQgdGhhdCBvYmplY3QgaXMgYmVpbmcgcmV1c2VkIA0KKGFuZCB5ZXMgdGhlcmUgYXJl
IG1hbnkgcGFydHMgaW4ga2VybmVsIHdoZXJlIHNpbWlsYXIgdGhpbmcgaGFwcGVucyBhcyB3ZSBs
ZWFybmVkIGZyb20gdGhpcyBleGVyY2lzZSkuIA0KTm90ZSB0aGF0IHJlZmNvdW50X3QgaW1wbGVt
ZW50YXRpb24gaXMgZmluZSB3aXRoIHlvdSAiY29ycmVjdGx5IiByZXVzaW5nIHlvdXIgb2JqZWN0
Og0KaS5lLiB3aGVuIGNvdW50ZXIgcmVhY2hlcyB6ZXJvLCB5b3UgdGFrZSB0aGUgb2JqZWN0IGF3
YXkgZnJvbSBhY3RpdmUgdXNlLCBidXQgaXQgbWlnaHQgc3RpbGwgc3RheSBpbiBjYWNoZS4gDQpC
VVQgd2hlbiB5b3UgZ2V0IGEgbmV3IG9iamVjdCBmcm9tIGNhY2hlIHlvdSBzaG91bGQgaW5pdGlh
bGl6ZSByZWZjb3VudGVyIHByb3Blcmx5OiBzZXQgaXQgdG8gb25lIHZzLiBqdXN0IGRvIGEgImlu
YyIgb24gaXQuIA0KUHJvYmxlbSByZWFsbHkgY29tZXMgZnJvbSB0aGlzICJpbmNyZW1lbnQgbWUg
ZnJvbSB6ZXJvIi4gDQoNCkFuZCB0aGUgZ29hbCB3aXRoIHRoZXNlIGNvbnZlcnNpb25zIGlzIHRv
IHRha2UgYSBsb29rIGJyb2FkbHkgb24gdGhlIGtlcm5lbCBzb3VyY2UgYW5kIGRldGVybWluZSAo
d2l0aCB0aGUgZmVlZGJhY2sgZnJvbSBtYWludGFpbmVycyB3aG8ga25vdyBjb2RlIGJlc3QsIGxp
a2UgeW91ciBmZWVkYmFjayBub3cpIHdoYXQgY2FuIGJlIGNvbnZlcnRlZCBhbHJlYWR5IG5vdy4g
DQpNYWludGFpbmVycyBrbm93IHRoZWlyIGNvZGUgYW5kIHRoZWlyIHVzYWdlIG9mIGNvdW50ZXJz
LCBzbyBpZiBpdCBkb2Vzbid0IG1ha2Ugc2Vuc2UgdG8gZG8gaXQgaW4gYSBwYXJ0aWN1bGFyIHBs
YWNlIChiZWNhdXNlIG9mIGVycm9ycyBvciBvdGhlciByZWFzb25zKSwgdGhlbiBpdCBkb2Vzbid0
LiANCkJ1dCBtb3JlIHdlIGNvdmVyIHdpdGggbmV3IHJlZmNvdW50X3QsIGxlc3MgY2hhbmNlcyB3
ZSBoYXZlIHdpdGggZXZlciBoaXR0aW5nIHJlZmNvdW50ZXIgYnVncyBhbnl3aGVyZSBpbiB0aGUg
ZnV0dXJlLiANCg0KQmVzdCBSZWdhcmRzLA0KRWxlbmEuDQoNCj4gDQo+IC0tDQo+IFRyb25kIE15
a2xlYnVzdA0KPiBMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQo+IHRy
b25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==
