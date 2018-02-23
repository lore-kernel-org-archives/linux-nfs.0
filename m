Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:48156 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754475AbeBWTJn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Feb 2018 14:09:43 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: SteveD redhat <steved@redhat.com>,
        "aglo@umich.edu" <aglo@umich.edu>
CC: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kolga@netapp.com" <kolga@netapp.com>
Subject: Re: [PATCH 1/1] NFS guard against incorrect vers inputs from
 nfs-utils
Date: Fri, 23 Feb 2018 19:09:36 +0000
Message-ID: <1519412975.8738.3.camel@primarydata.com>
References: <20180222192806.67911-1-kolga@netapp.com>
         <034fb5f1-eba5-030b-aad2-6ac5e87f2066@RedHat.com>
         <CAN-5tyE2wqrgkQuHSFy7=EDricmx6jPKA9=PnqSdf8rr_0rxwQ@mail.gmail.com>
         <6e314995-964f-e70d-cc45-fc1716b4ec81@RedHat.com>
In-Reply-To: <6e314995-964f-e70d-cc45-fc1716b4ec81@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE4LTAyLTIzIGF0IDEzOjQ1IC0wNTAwLCBTdGV2ZSBEaWNrc29uIHdyb3RlOg0K
PiANCj4gT24gMDIvMjMvMjAxOCAxMjowNSBQTSwgT2xnYSBLb3JuaWV2c2thaWEgd3JvdGU6DQo+
ID4gT24gRnJpLCBGZWIgMjMsIDIwMTggYXQgMTE6MjQgQU0sIFN0ZXZlIERpY2tzb24gPFN0ZXZl
REByZWRoYXQuY29tPg0KPiA+IHdyb3RlOg0KPiA+ID4gSGV5IE9sZ2EsDQo+ID4gPiANCj4gPiA+
IE9uIDAyLzIyLzIwMTggMDI6MjggUE0sIE9sZ2EgS29ybmlldnNrYWlhIHdyb3RlOg0KPiA+ID4g
PiBJdCBpcyBwb3NzaWJsZSB0aGF0IHVzZXJsYW5kIGNhbiBwYXNzIHRvIHRoZSBrZXJuZWwgbWlz
bWF0Y2hpbmcNCj4gPiA+ID4gaW5wdXRzIGZvciB0aGUgbWlub3J2ZXJzaW9uLiBsaWtlIHZlcnM9
NC4xLG1pbm9ydmVyc2lvbj0wLg0KPiA+ID4gPiBJbnN0ZWFkDQo+ID4gPiA+IG9mIG1ha2luZyB0
aGUga2VybmVsIHJlc3BvbnBvc2libGUgZm9yICdjaG9vc2luZycgdGhlDQo+ID4gPiA+IG1pbm9y
dmVyc2lvbiwNCj4gPiA+ID4gbWFrZSB0aGUgdXNlcmxhbmQgYWx3YXlzIHJlc3BvbnNpYmxlIGZv
ciBub3Qgc2VuZGluZyBhDQo+ID4gPiA+IG1pc21hdGNoLg0KPiA+ID4gDQo+ID4gPiBJJ20gdGhp
bmtpbmcgdGhpcyBpcyBwcm9iYWJseSBtb3JlIG9mIG1vdW50IHByb2JsZW0uLi4NCj4gPiANCj4g
PiBZZXMgdGhlIHByb2JsZW0gaXMgYSBicm9rZW4gdXNlciBsYW5kIHNlbmRpbmcgaW5jb3JyZWN0
IGFyZ3VtZW50cw0KPiA+IGJ1dA0KPiA+IEkgc3RpbGwgdGhpbmsgdGhlIGtlcm5lbCBuZWVkcyB0
byBkbyBzYW5pdHkgY2hlY2tpbmcgb24gYXJndW1lbnRzDQo+ID4gdG8NCj4gPiBwcmV2ZW50IHRo
aXMgZnJvbSBoYXBwZW5pbmcgYWdhaW4uDQo+ID4gDQo+ID4gPiBtb3VudCAtdCBuZnM0IC1vIG1p
bm9ydmVyc2lvbj0wIHNlcnZlcjovZXhwb3J0IC9tbnQNCj4gPiA+IA0KPiA+ID4gc2hvdWxkbid0
IHRoaXMgYmUgYSAgdjQuMCBtb3VudCBpbnN0ZWFkIG9mIGEgNC4yIG1vdW50Pw0KPiA+IA0KPiA+
IFllcyBJIHdvdWxkIHRoaW5rIHRoaXMgc2hvdWxkIGNyZWF0ZSBhIHY0LjAgbW91bnQuDQo+IA0K
PiBXYXkgYmFjayB3aGVuLi4uIHRoZXJlIHdhcyBzb21lIHRhbGsgYWJvdXQgZGVwcmVjYXRpbmcg
DQo+IG1pbm9ydmVyc2lvbj0gZmxhZy4uLiBTaW5jZSBpdCBpcyBicm9rZW4sIG1heWJlIHRoaXMg
aXMgDQo+IGEgZ29vZCB0aW1lIHRvIGRvIGl0Pw0KPiANCj4gVGhvdWdodHM/DQoNCkkndmUgbmV2
ZXIgbGlrZWQgdGhlIHNlcGFyYXRlIHY0LW9ubHkgJ21pbm9ydmVyc2lvbicga2V5d29yZCwgd2hp
Y2ggaXMNCndoeSBJIGludHJvZHVjZWQgdGhlICd2ZXJzaW9uPTQueCcgZm9ybWF0LiBNeSBwcmVm
ZXJlbmNlIGlzIHRoZXJlZm9yZQ0KdGhhdCB3ZSBjb250aW51ZSB0byBkZXByZWNhdGUgdXNlIG9m
ICdtaW5vcnZlcnNpb24nIHdpdGggYSB2aWV3IHRvDQpraWxsaW5nIGl0IG9mZiBjb21wbGV0ZWx5
Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBQ
cmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K

