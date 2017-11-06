Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: "Anna.Schumaker@Netapp.com" <Anna.Schumaker@Netapp.com>, bcodding redhat
	<bcodding@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v7 07/10] pNFS: Retry NFS4ERR_OLD_STATEID errors in
 layoutreturn-on-close
Date: Mon, 6 Nov 2017 20:26:09 +0000
Message-ID: <1509999967.53077.1.camel@primarydata.com>
References: <20171106152726.13755-1-trond.myklebust@primarydata.com>
	 <20171106152726.13755-2-trond.myklebust@primarydata.com>
	 <20171106152726.13755-3-trond.myklebust@primarydata.com>
	 <20171106152726.13755-4-trond.myklebust@primarydata.com>
	 <20171106152726.13755-5-trond.myklebust@primarydata.com>
	 <20171106152726.13755-6-trond.myklebust@primarydata.com>
	 <20171106152726.13755-7-trond.myklebust@primarydata.com>
	 <20171106152726.13755-8-trond.myklebust@primarydata.com>
	 <056582c3-b9ef-eadf-b433-db86779b1c56@Netapp.com>
In-Reply-To: <056582c3-b9ef-eadf-b433-db86779b1c56@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDE3LTExLTA2IGF0IDE0OjI3IC0wNTAwLCBBbm5hIFNjaHVtYWtlciB3cm90ZToN
Cj4gSGkgVHJvbmQsDQo+IA0KPiBPbiAxMS8wNi8yMDE3IDEwOjI3IEFNLCBUcm9uZCBNeWtsZWJ1
c3Qgd3JvdGU6DQo+ID4gK2Jvb2wgbmZzNF9yZWZyZXNoX2xheW91dF9zdGF0ZWlkKG5mczRfc3Rh
dGVpZCAqZHN0LCBzdHJ1Y3QgaW5vZGUNCj4gPiAqaW5vZGUpDQo+ID4gK3sNCj4gPiArCXJldHVy
biBmYWxzZTsNCj4gPiArfQ0KPiANCj4gU2hvdWxkbid0IHRoaXMgYmUgc3RhdGljICYgaW5saW5l
PyAgSSdtIHNlZWluZyBhIGJ1bmNoIG9mICJtdWx0aXBsZQ0KPiBkZWZpbml0aW9ucyIgZXJyb3Jz
IHdpdGggdjQuMSBkaXNhYmxlZC4NCj4gDQoNCkkgY2xlYXJseSBuZWVkIGEgdmFjYXRpb24uLi4g
4pi6DQpGaW5hbCByZXNlbmQsIEkgaG9wZS4uLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGlu
dXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHBy
aW1hcnlkYXRhLmNvbQ0K
