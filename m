Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: "aweits@rit.edu" <aweits@rit.edu>
CC: bcodding redhat <bcodding@redhat.com>, "anna.schumaker@netapp.com"
	<anna.schumaker@netapp.com>, "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 00/11] Fix OPEN/CLOSE races
Date: Tue, 7 Nov 2017 23:44:48 +0000
Message-ID: <1510098286.109352.0.camel@primarydata.com>
References: <20171106202811.70202-1-trond.myklebust@primarydata.com>
	 <m2vainowk1.fsf@discipline.rit.edu>
	 <1510008607.3861.1.camel@primarydata.com>
	 <m2y3ninhxs.fsf@discipline.rit.edu>
	 <1510079753.7834.7.camel@primarydata.com>
	 <1510081247.7834.9.camel@primarydata.com>
	 <m2inelofnk.fsf@discipline.rit.edu>
In-Reply-To: <m2inelofnk.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE3LTExLTA3IGF0IDE4OjAzIC0wNTAwLCBBbmRyZXcgVyBFbGJsZSB3cm90ZToN
Cj4gVHJvbmQgTXlrbGVidXN0IDx0cm9uZG15QHByaW1hcnlkYXRhLmNvbT4gd3JpdGVzOg0KPiAN
Cj4gPiBPbiBUdWUsIDIwMTctMTEtMDcgYXQgMTg6MzUgKzAwMDAsIFRyb25kIE15a2xlYnVzdCB3
cm90ZToNCj4gPiA+IA0KPiA+ID4gQWgsIEkgc2VlLiBDYW4gd2UgaW4gdGhhdCBjYXNlIHBsZWFz
ZSByYXRoZXIgZG8gdGhlIGZvbGxvd2luZz8NCj4gPiA+IA0KPiA+ID4gDQo+ID4gDQo+ID4gLi4u
YW5kIHRoZW4gZm9sbG93IHVwIHdpdGg6DQo+ID4gDQo+ID4gODwtLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KPiA+IEZyb20gNTQ1
ZTJmZGRiNzIyNjhmNWM1OWEzOTg2MTY5YWY5NmE0MGE2YWFiMCBNb24gU2VwIDE3IDAwOjAwOjAw
DQo+ID4gMjAwMQ0KPiA+IEZyb206IFRyb25kIE15a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QHBy
aW1hcnlkYXRhLmNvbT4NCj4gPiBEYXRlOiBUdWUsIDcgTm92IDIwMTcgMTI6Mzk6NDQgLTA1MDAN
Cj4gPiBTdWJqZWN0OiBbUEFUQ0ggMi8yXSBORlN2NDogUmVwbGFjZSBjbG9zZWQgc3RhdGVpZHMg
d2l0aCB0aGUNCj4gPiAiaW52YWxpZCBzcGVjaWFsDQo+ID4gIHN0YXRlaWQiDQo+ID4gDQo+ID4g
V2hlbiBkZWNvZGluZyBhIENMT1NFLCByZXBsYWNlIHRoZSBzdGF0ZWlkIHJldHVybmVkIGJ5IHRo
ZSBzZXJ2ZXINCj4gPiB3aXRoIHRoZSAiaW52YWxpZCBzcGVjaWFsIHN0YXRlaWQiIGRlc2NyaWJl
ZCBpbiBSRkM1NjYxLCBTZWN0aW9uDQo+ID4gOC4yLjMuDQo+ID4gDQo+ID4gSW4gbmZzX3NldF9v
cGVuX3N0YXRlaWRfbG9ja2VkLCBpZ25vcmUgc3RhdGVpZHMgZnJvbSBjbG9zZWQgc3RhdGUuDQo+
ID4gDQo+ID4gU2lnbmVkLW9mZi1ieTogVHJvbmQgTXlrbGVidXN0IDx0cm9uZC5teWtsZWJ1c3RA
cHJpbWFyeWRhdGEuY29tPg0KPiANCj4gTG9va3MgZ29vZCEgVGhhbmtzIQ0KDQpUaGFuayB5b3Ug
Zm9yIHRlc3RpbmchIEl0IGhhcyBiZWVuIHZlcnkgaGVscGZ1bC4uLg0KDQotLSANClRyb25kIE15
a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQu
bXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K
