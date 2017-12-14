Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:35212 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752718AbdLNUhb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 15:37:31 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "Anna.Schumaker@Netapp.com" <Anna.Schumaker@Netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] SUNRPC: Fix a race in the receive code path
Date: Thu, 14 Dec 2017 20:37:26 +0000
Message-ID: <1513283844.11150.11.camel@primarydata.com>
References: <20171204001726.5747-1-trond.myklebust@primarydata.com>
         <17932F80-EF03-48BA-AD6C-90A441B286EF@oracle.com>
         <C5351D4D-2E01-4B6D-AF19-EE6BABD46CCF@oracle.com>
         <BF7A22EC-55D9-4545-9F48-93A143A658DB@oracle.com>
         <1513253779.6553.7.camel@primarydata.com>
         <42B23A9B-3566-4E0F-9E3D-53BB2C39C0E9@oracle.com>
         <1513278198.5198.3.camel@primarydata.com>
         <2E949D1D-AD89-448B-B263-B53FB66C9766@oracle.com>
In-Reply-To: <2E949D1D-AD89-448B-B263-B53FB66C9766@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE3LTEyLTE0IGF0IDE0OjIyIC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBEZWMgMTQsIDIwMTcsIGF0IDI6MDMgUE0sIFRyb25kIE15a2xlYnVzdCA8dHJvbmRteUBw
cmltYXJ5ZGF0YS5jDQo+ID4gb20+IHdyb3RlOg0KPiA+IA0KPiA+IERvZXMgdGhlIFJETUEgY29k
ZSB1cGRhdGUgdGhlIGNvbm5lY3QgY29va2llIHdoZW4gdGhlIGNvbm5lY3Rpb24NCj4gPiBicmVh
a3M/IEl0IGxvb2tzIHRvIG1lIGFzIGlmIGl0IG9ubHkgZG9lcyB0aGF0IHdoZW4gdGhlIGNvbm5l
Y3Rpb24NCj4gPiBpcw0KPiA+IHJlLWVzdGFibGlzaGVkLiBXZSByZWFsbHkgd2FudCBib3RoLg0K
PiA+IA0KPiA+ID4gSSBpbWFnaW5lIHRoaXMgaXNzdWUgY291bGQgYWxzbyBpbXBhY3Qgd3JpdGUg
YnVmZmVyIGV4aGF1c3Rpb24NCj4gPiA+IG9uIFRDUC4NCj4gPiANCj4gPiBTZWUgbmV0L3N1bnJw
Yy94cHJ0c29jay5jOnhzX3RjcF9zdGF0ZV9jaGFuZ2UoKQ0KPiANCj4geHBydHJkbWEgbWFuaXB1
bGF0ZXMgdGhlIGNvbm5lY3RfY29va2llIGluIGl0cyBjb25uZWN0IHdvcmtlciwNCj4gc2VlIHJw
Y3JkbWFfY29ubmVjdF93b3JrZXIuIFRoaXMgd2FzIGFkZGVkIGJ5Og0KPiANCj4gY29tbWl0IDU3
NTQ0OGJkMzYyMDhmOTlmZTBkZDU1NGE0MzUxOGQ3OTg5NjY3NDANCj4gQXV0aG9yOiAgICAgVG9t
IFRhbHBleSA8dGFscGV5QG5ldGFwcC5jb20+DQo+IEF1dGhvckRhdGU6IFRodSBPY3QgOSAxNTow
MDo0MCAyMDA4IC0wNDAwDQo+IENvbW1pdDogICAgIFRyb25kIE15a2xlYnVzdCA8VHJvbmQuTXlr
bGVidXN0QG5ldGFwcC5jb20+DQo+IENvbW1pdERhdGU6IEZyaSBPY3QgMTAgMTU6MTA6MzYgMjAw
OCAtMDQwMA0KPiANCj4gICAgIFJQQy9SRE1BOiBzdXBwcmVzcyByZXRyYW5zbWl0IG9uIFJQQy9S
RE1BIGNsaWVudHMuDQo+IA0KPiBXb3VsZCBpdCBiZSBtb3JlIGNvcnJlY3QgdG8gYnVtcCB0aGUg
Y29va2llIGluIHJwY3JkbWFfY29ubl91cGNhbGwsDQo+IHdoaWNoIGlzIHRoZSBlcXVpdmFsZW50
IHRvIHhzX3RjcF9zdGF0ZV9jaGFuZ2U/IChpZiBzbywgd2h5LCBzbw0KPiBJIGNhbiBjb21wb3Nl
IGEgcmVhc29uYWJsZSBwYXRjaCBkZXNjcmlwdGlvbikNCj4gDQo+IEl0IGNvdWxkIGJlIGJ1bXBl
ZCBpbiB0aGUgUkRNQV9DTV9FVkVOVF9FU1RBQkxJU0hFRCBhbmQgdGhlDQo+IFJETUFfQ01fRVZF
TlRfRElTQ09OTkVDVEVEIGNhc2VzLCBmb3IgZXhhbXBsZS4gSSdtIG5vdCBzdXJlDQo+IFJETUEg
cHJvdmlkZXMgYSBkaXN0aW5jdGlvbiBiZXR3ZWVuICJzZXJ2ZXIgZGlzY29ubmVjdGVkIg0KPiBh
bmQgImNsaWVudCBkaXNjb25uZWN0ZWQiIGFsdGhvdWdoIHRoYXQgcHJvYmFibHkgZG9lcyBub3QN
Cj4gbWF0dGVyIGZvciB0aGlzIHB1cnBvc2UuDQo+IA0KPiBCdXQsIHdoeSB3b3VsZCB0aGUgYWRk
aXRpb25hbCBjb29raWUgdXBkYXRlIGhlbHA/IFRoZSB0cmFuc3BvcnQNCj4gaXMgbm90IGRpc2Nv
bm5lY3RpbmcgYmVmb3JlIHRoZSBkZWFkbG9jay4NCj4gDQoNClRoZSBjb25uZWN0aW9uIGNvb2tp
ZSdzIHB1cnBvc2UgaXMgdHdvZm9sZDoNCg0KMSkgSXQgdHJhY2tzIHdoZXRoZXIgb3Igbm90IGEg
cmVxdWVzdCBoYXMgYmVlbiB0cmFuc21pdHRlZCBvbiB0aGUNCmN1cnJlbnQgY29ubmVjdGlvbiBv
ciBub3QuDQoNCjIpIEl0IGVuc3VyZXMgdGhhdCB3aGVuIHNldmVyYWwgcmVxdWVzdHMgd2l0aCB0
aGUgc2FtZSBjb25uZWN0aW9uDQpjb29raWUgYWxsIGNhbGwgeHBydF9jb25kaXRpb25hbF9kaXNj
b25uZWN0KCksIHRoZW4gdGhhdCByZXN1bHRzIGluIGENCnNpbmdsZSBkaXNjb25uZWN0aW9uIGV2
ZW50LiBUbyBkbyBzbywgaXQgYXNzdW1lcyB0aGF0IHhwcnRfYXV0b2Nsb3NlKCkNCndpbGwgY2hh
bmdlIHRoZSBjb29raWUgaWYgdGhlIGRpc2Nvbm5lY3Rpb24gYXR0ZW1wdCBpcyBzdWNjZXNzZnVs
Lg0KDQpJbiBUQ1Agd2UgZG8gc28gaW4gdGhlIHhzX3RjcF9zdGF0ZV9jaGFuZ2UoKS4gSWYgdGhl
IFJETUEgdHJhbnNwb3J0IGNhbg0KZ3VhcmFudGVlIHRoYXQgdGhlIGNhbGwgdG8geHBydC0+b3Bz
LT5jbG9zZSh4cHJ0KSBpcyBhbHdheXMgc3VjY2Vzc2Z1bCwNCnRoZW4geW91IGNvdWxkIGRvIHNv
IHRoZXJlLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFp
bmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K

