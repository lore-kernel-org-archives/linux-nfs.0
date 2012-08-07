Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10833 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034Ab2HGPTD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 11:19:03 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Joerg Roedel <joro@8bytes.org>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Joerg Roedel <joerg.roedel@amd.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "wdauchy@gmail.com" <wdauchy@gmail.com>
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
Date: Tue, 7 Aug 2012 15:19:01 +0000
Message-ID: <1344352739.5781.12.camel@lade.trondhjem.org>
References: <20120807134156.GP1996@amd.com> <50211E42.6040808@netapp.com>
	 <20120807141548.GG1917@8bytes.org> <5021237D.1010107@netapp.com>
	 <20120807142707.GH1917@8bytes.org> <502127EF.3030209@netapp.com>
	 <20120807145019.GI1917@8bytes.org>
In-Reply-To: <20120807145019.GI1917@8bytes.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA4LTA3IGF0IDE2OjUwICswMjAwLCBKb2VyZyBSb2VkZWwgd3JvdGU6DQo+
IE9uIFR1ZSwgQXVnIDA3LCAyMDEyIGF0IDEwOjM2OjMxQU0gLTA0MDAsIEJyeWFuIFNjaHVtYWtl
ciB3cm90ZToNCj4gPiBZb3VyIHN0YWNrIHRyYWNlIGlzIHNob3dpbmcgdjQgY2FsbHMgb24gdGhl
IGZhaWxpbmcgYm94LCB0aG9zZQ0KPiA+IGRlZmluaXRlbHkgc2hvdWxkbid0IGJlIGhhcHBlbmlu
ZyBpZiB5b3UncmUgdXNpbmcgdjMuICBDYW4geW91IGRvdWJsZQ0KPiA+IGNoZWNrIC9ldGMvZnN0
YWIgYW5kIC9wcm9jL21vdW50cyBvbiBhIHdvcmtpbmcga2VybmVsIHRvIGJlIHN1cmU/DQo+IA0K
PiBTbyB0aGUgYnVnIGlzIHByb2JhYmx5IChmb3Igd2hhdGV2ZXIgcmVhc29uKSB0aGF0IHRoZSBu
ZnM0IHBhdGggaXMNCj4gY2FsbGVkIGZvciBhbiBuZnMzIG1vdW50IDopDQoNCklmIHlvdXIgL2V0
Yy9uZnNtb3VudC5jb25mIGRvZXNuJ3QgY29udGFpbiBhIGxpbmUgb2YgdGhlIGZvcm0NCg0KRGVm
YXVsdHZlcnM9NA0KDQp0aGVuIHRoZSBtb3VudCB1dGlsaXR5IHdpbGwgdHJ5IE5GU3Y0IGJ5IGRl
ZmF1bHQuIFRoYXQgaXMgbm90IGEgYnVnLCBpdA0KaXMgYSBkZWxpYmVyYXRlIGZlYXR1cmUgb2Yg
cmVjZW50IHZlcnNpb25zIG9mIG5mcy11dGlscy4NCg0KPiBBbnl3YXksIEkgYXR0YWNoIC9wcm9j
L21vdW50cyBhbmQgL2V0Yy9mc3RhYiBmcm9tIHRoYXQgYm94IHJ1bm5pbmcgYQ0KPiB2My41LXJj
NSBrZXJuZWwgKHdoZXJlIGl0IHdvcmtzKS4NCg0KSSdtIGd1ZXNzaW5nIHRoYXQgdGhlIGZhY3Qg
eW91IGFyZSBub3QgcnVubmluZyBpZG1hcHBlciBpcyBjYXVzaW5nIHRoZQ0KTkZTdjQgbW91bnQg
dG8gZmFpbCBvbiB0aGUgb2xkZXIga2VybmVscywgYW5kIHNvIHRoZSBtb3VudCBwcm9ncmFtIGlz
DQpmYWxsaW5nIGJhY2sgdG8gYW4gTkZTdjMgbW91bnQuDQoNCldlIG5lZWQgdG8gZml4IHYzLjYg
c28gdGhhdCBpdCBkb2VzIHRoZSBzYW1lLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5j
b20NCnd3dy5uZXRhcHAuY29tDQoNCg==
