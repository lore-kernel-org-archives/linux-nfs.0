Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
	"smayhew@redhat.com" <smayhew@redhat.com>
CC: bcodding redhat <bcodding@redhat.com>, "fsorenso@redhat.com"
	<fsorenso@redhat.com>, "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>, "dwysocha@redhat.com" <dwysocha@redhat.com>
Subject: Re: [PATCH v2] nfs/pnfs: fix nfs_direct_req ref leak when i/o falls
 back to the mds
Date: Thu, 11 Jan 2018 13:20:13 +0000
Message-ID: <1515676811.3463.0.camel@primarydata.com>
References: <20171213182220.lrfbvkaj65fg6abk@tonberry.usersys.redhat.com>
	 <20171215211232.18942-1-smayhew@redhat.com>
	 <20180111131038.vi25s2rvmjgqr3l6@tonberry.usersys.redhat.com>
In-Reply-To: <20180111131038.vi25s2rvmjgqr3l6@tonberry.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE4LTAxLTExIGF0IDA4OjEwIC0wNTAwLCBTY290dCBNYXloZXcgd3JvdGU6DQo+
IFRyb25kLCBBbm5hLA0KPiANCj4gQW55IGNvbmNlcm5zIHdpdGggdGhpcyBwYXRjaD8NCj4gDQo+
IFdlIGxlZnQgdGhpcyBydW4gb24gbXVsdGlwbGUgbWFjaGluZXMgdGhyb3VnaCB0aGUgaG9saWRh
eXMuLi4gYWxsDQo+IGRvaW5nDQo+IGRpcmVjdCBJL08gdG8gYSBOZXRhcHAgZmlsZXIgd2hpbGUg
ZG9pbmcgc3RvcmFnZSBmYWlsb3ZlcnMgb24gYW4NCj4gaG91cmx5DQo+IGJhc2lzIG9uIHRoZSBm
aWxlci4gIE5vIG1vcmUgaXNzdWVzIHdpdGggcHJvY2Vzc2VzIGdldHRpbmcgc3R1Y2sgaW4NCj4g
aW5vZGVfZGlvX3dhaXQuDQoNCkknbSBmaW5lIHdpdGggdGhpcyB2ZXJzaW9uLiBTaG91bGQgaXQg
YmUgYSBzdGFibGUgZml4PyBJZiBzbywgZG8gd2UNCmhhdmUgYSAiRml4ZXM6IiBjb21taXQgZm9y
IGl0Pw0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVy
LCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K
