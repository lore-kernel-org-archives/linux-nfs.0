Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1864 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752568Ab1BPP6V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 10:58:21 -0500
Content-Type: text/plain;
	charset="utf-8"
Subject: RE: [PATCH 11/16] pnfs: wave 3: generic read
Date: Wed, 16 Feb 2011 10:57:47 -0500
Message-ID: <7A6A58246D5F0B4EA127BEA555B3A9AD0BCD0F1B@RTPMVEXC1-PRD.hq.netapp.com>
In-Reply-To: <4D5BF2B5.2020502@panasas.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>	 <1297711116-3139-12-git-send-email-andros@netapp.com>	 <4D5B4192.4090107@panasas.com>	 <21F5A956-5830-4BB1-8F91-92C3121510BD@netapp.com> <1297868955.6596.24.camel@heimdal.trondhjem.org> <4D5BF2B5.2020502@panasas.com>
From: "Sager, Mike" <Mike.Sager@netapp.com>
To: "Benny Halevy" <bhalevy@panasas.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>
Cc: <linux-nfs@vger.kernel.org>, "Andy Adamson" <andros@citi.umich.edu>,
        "Boaz Harrosh" <bharrosh@panasas.com>,
        "Dean Hildebrand" <dhildeb@us.ibm.com>,
        "Fred Isaman" <iisaman@citi.umich.edu>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Mingyang Guo" <guomingyang@nrchpc.ac.cn>,
        "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

QSBsb3Qgb2YgdGhlIGVhcmx5IHBhdGNoZXMgaGF2ZSBteSBuYW1lIG9uIGl0IGJlY2F1c2UgSSB3
YXMgaGVscGluZyB3aXRoIGEgcG9ydGluZyBlZmZvcnQuICBSYWh1bCBJeWVyIChhbmQgc2V2ZXJh
bCBvdGhlcnMpIGF1dGhvcmVkIGEgZ29vZCBjaHVuayBvZiB0aGF0IGNvZGUuDQoNCk1pa2UNCg0K
PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBCZW5ueSBIYWxldnkgW21haWx0
bzpiaGFsZXZ5QHBhbmFzYXMuY29tXQ0KPiBTZW50OiBXZWRuZXNkYXksIEZlYnJ1YXJ5IDE2LCAy
MDExIDEwOjUyIEFNDQo+IFRvOiBNeWtsZWJ1c3QsIFRyb25kOyBBZGFtc29uLCBBbmR5DQo+IENj
OiBsaW51eC1uZnNAdmdlci5rZXJuZWwub3JnOyBBbmR5IEFkYW1zb247IEJvYXogSGFycm9zaDsg
RGVhbg0KPiBIaWxkZWJyYW5kOyBGcmVkIElzYW1hbjsgSXNhbWFuLCBGcmVkOyBKLiBCcnVjZSBG
aWVsZHM7IFNhZ2VyLCBNaWtlOw0KPiBNaW5neWFuZyBHdW87IExhYmlhZ2EsIFJpY2FyZG8NCj4g
U3ViamVjdDogUmU6IFtQQVRDSCAxMS8xNl0gcG5mczogd2F2ZSAzOiBnZW5lcmljIHJlYWQNCj4g
DQo+IE9uIDIwMTEtMDItMTYgMTA6MDksIFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4gPiBPbiBX
ZWQsIDIwMTEtMDItMTYgYXQgMDk6NTMgLTA1MDAsIEFuZHkgQWRhbXNvbiB3cm90ZToNCj4gPj4g
T24gRmViIDE1LCAyMDExLCBhdCAxMDoxNiBQTSwgQmVubnkgSGFsZXZ5IHdyb3RlOg0KPiA+Pg0K
PiA+Pj4gT24gMjAxMS0wMi0xNCAxNDoxOCwgYW5kcm9zQG5ldGFwcC5jb20gd3JvdGU6DQo+ID4+
Pj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gPj4+DQo+ID4+PiBB
bmR5LCB0YWtpbmcgaW50byBhY2NvdW50IHRoZSBtYW55IGNvbnRyaWJ1dG9ycyB0byB0aGlzIHBh
dGNoDQo+ID4+PiB0aGUgYXV0aG9yIHNob3VsZCBiZSAiVGhlIHBORlMgVGVhbSIgSU1PLg0KPiA+
Pg0KPiA+PiBUaGUgYXV0aG9yIGNhbid0IGJlICJUaGUgcE5GUyBUZWFtIi4gIFNvbWVib2R5IG5l
ZWRzIHRvIGJlIHRoZQ0KPiBhdXRob3IuIEkgYXNrZWQgZm9yIHZvbHVudGVlcnMgYW5kIHNhaWQg
SSB3b3VsZCBiZSB0aGUgZGVmYXVsdC4gRG8geW91DQo+IHdhbnQgdG8gYmUgdGhlIGF1dGhvcj8N
Cj4gPg0KPiA+IFJpZ2h0LiBQYXRjaGVzIGF1dGhvcmVkIGJ5ICdUaGUgcE5GUyBUZWFtJyB3aWxs
IGJlIHJlamVjdGVkLCBhcw0KPiA+IGRpc2N1c3NlZCBpbiBIb3BraW50b24gbGFzdCBhdXR1bW4u
DQo+ID4NCj4gDQo+IE9LLiBJJ20gbm90IHRoZSBvcmlnaW5hbCBhdXRob3Igc28gSSBjYW4ndCBj
bGFpbSBhdXRob3JzaGlwIGZvciB0aGlzDQo+IHBhdGNoLg0KPiBGV0lXLCBUaGUgZWFybGllc3Qg
cmVjb3JkIEkgaGF2ZSBpbiBteSB0cmVlIGZvciB0aGUgZWFybGllc3QgdmVyc2lvbnMNCj4gb2Yg
dGhpcyBjb2RlIGlzDQo+IGF1dGhvcmVkIGJ5IEFuZHkgYW4gTWlrZSBTYWdlci4uLg0KPiANCj4g
QmVubnkNCj4gLS0NCj4gVG8gdW5zdWJzY3JpYmUgZnJvbSB0aGlzIGxpc3Q6IHNlbmQgdGhlIGxp
bmUgInVuc3Vic2NyaWJlIGxpbnV4LW5mcyIgaW4NCj4gdGhlIGJvZHkgb2YgYSBtZXNzYWdlIHRv
IG1ham9yZG9tb0B2Z2VyLmtlcm5lbC5vcmcNCj4gTW9yZSBtYWpvcmRvbW8gaW5mbyBhdCAgaHR0
cDovL3ZnZXIua2VybmVsLm9yZy9tYWpvcmRvbW8taW5mby5odG1sDQoT77+977+97Lm7HO+/vSbv
v71+77+9Ju+/vRjvv73vv70rLe+/ve+/vd22F++/ve+/vXfvv73vv73Lm++/ve+/ve+/vW3vv71i
77+977+9Z37Ip++/vRfvv73vv73cqH3vv73vv73vv73GoHrvv70majordu+/ve+/ve+/vQfvv73v
v73vv73vv716Wivvv73vv70rembvv73vv73vv71o77+977+977+9fu+/ve+/ve+/ve+/vWnvv73v
v73vv71677+9Hu+/vXfvv73vv73vv70/77+977+977+977+9Ju+/vSnfohtm
