Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:42436 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752901AbdHKPMV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Aug 2017 11:12:21 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "jlayton@redhat.com" <jlayton@redhat.com>,
        "kolga@netapp.com" <kolga@netapp.com>
CC: "dhowells@redhat.com" <dhowells@redhat.com>,
        "neilb@suse.com" <neilb@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [RFC 1/1] destroy_creds.2: new page documenting destroy_creds()
Date: Fri, 11 Aug 2017 15:12:13 +0000
Message-ID: <1502464329.5352.1.camel@primarydata.com>
References: <20170807212355.29127-1-kolga@netapp.com>
         <20170807212355.29127-3-kolga@netapp.com>
         <1502281848.12841.2.camel@redhat.com>
         <87378yr2sx.fsf@notabene.neil.brown.name>
         <1502450305.4950.4.camel@redhat.com>
         <E127503D-3DFC-4FD3-99F6-012D100C168B@netapp.com>
         <1502461341.4762.1.camel@redhat.com>
In-Reply-To: <1502461341.4762.1.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE3LTA4LTExIGF0IDEwOjIyIC0wNDAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
SSB0aGluayBJIHdhc24ndCBjbGVhciBoZXJlLiBJJ20gbm90IHByb3Bvc2luZyB0aGF0IHlvdSBt
b3ZlIGV2ZXJ5b25lDQo+IHRvDQo+IEtFWVJJTkc6IGNyZWRjYWNoZXMuIFRoaXMgd291bGQgbm90
IGJlIGEgdmlzaWJsZSBjaGFuZ2UgdG8gdXNlcmxhbmQuDQo+IFdlJ2Qgc3RpbGwgdXNlIHJwYy5n
c3NkIHRvIHVwY2FsbCBmb3IgY3JlZHMuDQo+IA0KPiBXaGF0IEknbSBzYXlpbmcgaXMgdGhhdCBp
bnN0ZWFkIG9mIHN0b3JpbmcgdGhlIGNyZWRzIGluIGEgaGFzaHRhYmxlDQo+IGxpa2UNCj4gd2Ug
ZG8gdG9kYXksIHdlJ2QganVzdCBzdGFzaCB0aGVtIGluIG9uZSBvZiB0aGUga2V5cmluZ3MgaGFu
Z2luZyBvZmYNCj4gb2YNCj4gc3RydWN0IGNyZWQuDQo+IA0KPiBDaGFuZ2UgYWxsIG9mIHRoZSBh
dXRoZ3NzX29wcyBvcGVyYXRpb25zIHRvIGRvIHF1ZXJ5L3N0b3JlIGZyb20gdGhlDQo+IGFwcHJv
cHJpYXRlIGtleXJpbmcgZGlyZWN0bHkuIFdpdGggdGhhdCwgdGhlIGVmZmVjdGl2ZSBsaWZldGlt
ZSBvZg0KPiBHU1NBUEkgY3JlZHMgd291bGQgYmUgYm91bmRlZCBieSB0aGUgbGlmZXRpbWUgb2Yg
dGhlIGtleXJpbmdzIHRoYXQNCj4gaG9sZA0KPiByZWZlcmVuY2VzIHRvIGl0Lg0KPiANCj4gV2Un
ZCBwcm9iYWJseSBuZWVkIGEgbmV3IGtleV90eXBlIGZvciB0aGlzIHRvIGVuc3VyZSB0aGF0IHRo
aXMNCj4gY291bGRuJ3QNCj4gYmUgbWFuaXB1bGF0ZWQgZGlyZWN0bHkgZnJvbSB1c2VybGFuZC4g
T3IuLi5tYXliZSB5b3UnZCBzdGlsbCB3YW50IHRvDQo+IGFsbG93IHVzZXJsYW5kIHRvIGRlc3Ry
b3kgdGhlIGNyZWRzPyBObyBuZWVkIGZvciBhIG5ldyBzeXNjYWxsIHdpdGgNCj4gdGhhdA0KPiAt
LSB0aGV5IGNhbiBqdXN0IGRvIGEgImtleWN0bCB1bmxpbmsiLiBUaGVyZSBhcmUgYSBsb3Qgb2Yg
b3B0aW9ucw0KPiBoZXJlLg0KPiANCj4gSXQncyBhIG5vbi10cml2aWFsIGFtb3VudCBvZiB3b3Jr
IHRob3VnaCAocnBjYXV0aF9sb29rdXBjcmVkKCkgb24NCj4gZG93bg0KPiB3b3VsZCBwcm9iYWJs
eSBuZWVkIHRvIGJlIHJld29ya2VkKSBhbmQgSSBoYXZlbid0IGxvb2tlZCBhdCBpdA0KPiBkZXRh
aWwuDQo+IFN0aWxsLCBpdCBzZWVtcyBsaWtlIGl0IGNvdWxkIGJlIGEgbW9yZSBtb2Rlcm4gYW5k
IGNsZWFuZXIgZGVzaWduDQo+IHRoYW4NCj4gd2hhdCB3ZSBoYXZlIHRvZGF5Lg0KPiANCg0KVGhl
IG1haW4gYW5ub3lhbmNlIHdpdGggZ29pbmcgZnJvbSBhIGdsb2JhbCB0byBhIGxvY2FsIGNhY2hl
IHN1Y2ggYXMNCnRoZSBrZXlyaW5ncyBpcyB0aGF0IGl0IG1ha2VzIGNvbXBhcmluZyBjcmVkZW50
aWFscyBhIGxvdCBtb3JlIHdvcmsuDQpUb2RheSwgYmVjYXVzZSB0aGUgY3JlZGVudGlhbHMgYXJl
IGVzc2VudGlhbGx5IHVuaXF1ZSBwZXIgc2VydmVyLCB3ZQ0KanVzdCBkbyBwb2ludGVyIGNvbXBh
cmlzb25zLiBPbmNlIHdlIGhhdmUgbm9uLWdsb2JhbCBjYWNoZXMsIHdlIHdvdWxkDQpuZWVkIHRv
IGRvIG1vcmUgZWxhYm9yYXRlIGNvbXBhcmlzb25zIHRvIGVuc3VyZSB0aGF0IHRoZSB1aWQsIGdp
ZCwgYW5kDQpsaXN0IG9mIGdyb3VwcyBtYXRjaC4NClRoYXQncyBhbHNvIHdoeSB3ZSBuZXZlciBt
YWRlIHRoZSBsZWFwIHRvIHVzaW5nICdzdHJ1Y3QgY3JlZCcsIGJ0dy4uLg0KDQotLSANClRyb25k
IE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJv
bmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K

