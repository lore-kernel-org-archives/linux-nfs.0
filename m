Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:39812 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751378AbdITSiL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Sep 2017 14:38:11 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        SteveD redhat <steved@redhat.com>,
        "jlayton@redhat.com" <jlayton@redhat.com>,
        "ffilzlnx@mindspring.com" <ffilzlnx@mindspring.com>,
        "berrange@redhat.com" <berrange@redhat.com>,
        "mbenjami@redhat.com" <mbenjami@redhat.com>,
        "stefanha@redhat.com" <stefanha@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Date: Wed, 20 Sep 2017 18:38:06 +0000
Message-ID: <1505932684.10427.5.camel@primarydata.com>
References: <20170919164427.GV9536@redhat.com>
         <E94E2759-1734-4C52-838F-8906B3F969C0@oracle.com>
         <20170919204224.GA14329@fieldses.org>
         <37604438-9848-47CA-8884-8FD6292EAFC9@oracle.com>
         <20170920131641.GC14329@fieldses.org>
         <E8E404FD-420A-45C6-B46B-F1E2A4133F17@oracle.com>
         <20170920144557.GD14329@fieldses.org>
         <202BF722-77BC-4EF2-BD75-9AA42CBF4A94@oracle.com>
         <015601d33224$b7770b40$266521c0$@mindspring.com>
         <1505931425.10427.2.camel@primarydata.com>
         <20170920183404.GI14329@fieldses.org>
In-Reply-To: <20170920183404.GI14329@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE3LTA5LTIwIGF0IDE0OjM0IC0wNDAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3
cm90ZToNCj4gT24gV2VkLCBTZXAgMjAsIDIwMTcgYXQgMDY6MTc6MDdQTSArMDAwMCwgVHJvbmQg
TXlrbGVidXN0IHdyb3RlOg0KPiA+IE9uIFdlZCwgMjAxNy0wOS0yMCBhdCAwODoyNSAtMDcwMCwg
RnJhbmsgRmlseiB3cm90ZToNCj4gPiA+ID4gPiBPbiBTZXAgMjAsIDIwMTcsIGF0IDEwOjQ1IEFN
LCBKLiBCcnVjZSBGaWVsZHMgPGJmaWVsZHNAZmllbGRzDQo+ID4gPiA+ID4gZXMubw0KPiA+ID4g
PiA+IHJnPg0KPiA+ID4gDQo+ID4gPiB3cm90ZToNCj4gPiA+ID4gPiANCj4gPiA+ID4gPiBPbiBX
ZWQsIFNlcCAyMCwgMjAxNyBhdCAxMDo0MDo0NUFNIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToN
Cj4gPiA+ID4gPiA+IEZpbGUgaGFuZGxlcyBzdWRkZW5seSBjaGFuZ2UgYW5kIGxvY2sgc3RhdGUg
dmFuaXNoZXMgYWZ0ZXINCj4gPiA+ID4gPiA+IGENCj4gPiA+ID4gPiA+IGxpdmUNCj4gPiA+ID4g
PiA+IG1pZ3JhdGlvbiBldmVudCwgYm90aCBvZiB3aGljaCB3b3VsZCBiZSBjYXRhc3Ryb3BoaWMg
Zm9yDQo+ID4gPiA+ID4gPiBoeXBlcnZpc29yDQo+ID4gPiA+ID4gPiBtb3VudCBwb2ludHMuDQo+
ID4gPiA+ID4gDQo+ID4gPiA+ID4gVGhleSdyZSB0YWxraW5nIGFib3V0IGEgR2FuZXNoYS9DZXBo
IGJhY2tlbmQuICBJdCBzaG91bGQgYmUNCj4gPiA+ID4gPiBhYmxlDQo+ID4gPiA+ID4gdG8NCj4g
PiA+ID4gPiBwcmVzZXJ2ZSBmaWxlaGFuZGxlcy4NCj4gPiA+ID4gDQo+ID4gPiA+IFRoYXQncyBv
bmx5IG9uZSBwb3NzaWJsZSBpbXBsZW1lbnRhdGlvbi4gSSdtIHRoaW5raW5nIGluIHRlcm1zDQo+
ID4gPiA+IG9mDQo+ID4gPiA+IHdoYXQNCj4gPiA+IA0KPiA+ID4gbmVlZHMNCj4gPiA+ID4gdG8g
YmUgZG9jdW1lbnRlZCBmb3IgaW50ZXJvcGVyYWJpbGl0eSBwdXJwb3Nlcy4NCj4gPiA+IA0KPiA+
ID4gSXQgc2VlbXMgbGlrZSBsaXZlIG1pZ3JhdGlvbiBwcmV0dHkgbXVjaCByZXF1aXJlcyBhIGJh
Y2sgZW5kIHRoYXQNCj4gPiA+IHdpbGwNCj4gPiA+IHByZXNlcnZlIGZpbGUgaGFuZGxlcy4NCj4g
PiA+IA0KPiA+ID4gPiA+IExvY2sgbWlncmF0aW9uIHdpbGwgcmVxdWlyZSBzZXJ2ZXItc2lkZSBp
bXBsZW1lbnRhdGlvbiB3b3JrDQo+ID4gPiA+ID4gYnV0DQo+ID4gPiA+ID4gbm90DQo+ID4gPiA+
ID4gcHJvdG9jb2wgY2hhbmdlcyB0aGF0IEknbSBhd2FyZSBvZi4NCj4gPiA+ID4gPiANCj4gPiA+
ID4gPiBJdCBjb3VsZCBiZSBhIGxvdCBvZiBpbXBsZW1lbnRhdGlvbiB3b3JrLCB0aG91Z2guDQo+
ID4gPiA+IA0KPiA+ID4gPiBBZ3JlZWQuDQo+ID4gPiANCj4gPiA+IEkgdGhpbmsgdGhlIGxvY2sg
bWlncmF0aW9uIGNhbiBiZSBoYW5kbGVkIHRoZSB3YXkgd2UgaGFuZGxlIHN0YXRlDQo+ID4gPiBt
aWdyYXRpb24NCj4gPiA+IGluIGFuIEhBIGVudmlyb25tZW50IC0gd2hlcmUgd2UgdHJlYXQgaXQg
YXMgYSBzZXJ2ZXIgcmVib290IHRvDQo+ID4gPiB0aGUNCj4gPiA+IGNsaWVudA0KPiA+ID4gKHNv
IFNNX05PVElGWSB0byB2MyBjbGllbnRzLCB0aGUgdmFyaW91cyBlcnJvcnMgdjQgdXNlcyB0byBz
aWduYWwNCj4gPiA+IHNlcnZlcg0KPiA+ID4gcmVib290LCBpbiBlaXRoZXIgY2FzZSwgdGhlIGNs
aWVudCB3aWxsIGluaXRpYXRlIGxvY2sgcmVjbGFpbSkuDQo+ID4gPiANCj4gPiANCj4gPiBNaW5k
IHNob3dpbmcgdXMgYW4gYXJjaGl0ZWN0dXJlIGZvciB0aGF0PyBBcyBmYXIgYXMgSSBjYW4gc2Vl
LCB0aGUNCj4gPiBsYXllcmluZyBpcyBhcyBmb2xsb3dzOg0KPiA+IA0KPiA+IFZNIGNsaWVudA0K
PiA+IC0tLS0tLS0tLS0tLS0tDQo+ID4gaG9zdCBrbmZzZA0KPiA+IC0tLS0tLS0tLS0tLS0tDQo+
ID4gaG9zdCBjbGllbnQNCj4gPiAtLS0tLS0tLS0tLS0tLQ0KPiA+IFN0b3JhZ2Ugc2VydmVyDQo+
ID4gDQo+ID4gU28gaG93IHdvdWxkIHlvdSBub3RpZnkgdGhlIFZNIGNsaWVudCB0aGF0IGl0cyBs
b2NrcyBoYXZlIGJlZW4NCj4gPiBtaWdyYXRlZD8NCj4gDQo+IEFsbCBJJ3ZlIHNlZW4gbWVudGlv
bmVkIGluIHRoaXMgdGhyZWFkIGlzDQo+IA0KPiAgIFZNIGNsaWVudA0KPiAgIC0tLS0tLS0tLQ0K
PiAgIGhvc3QgR2FuZXNoYQ0KPiAgIC0tLS0tLS0tLQ0KPiAgIENlcGggb3IgR2x1c3Rlcg0KPiAN
Cj4gRGlkIEkgbWlzdW5kZXJzdGFuZD8NCj4gDQo+IE5GUyBwcm94eWluZyB3b3VsZCBjZXJ0YWlu
bHkgbWFrZSBpdCBhbGwgbW9yZSBlbnRlcnRhaW5pbmcuDQo+IA0KDQpQcmV0dHkgc3VyZSBJJ3Zl
IG1lbnRpb25lZCBpdCBiZWZvcmUgaW4gdGhlc2UgVlNPQ0sgdGhyZWFkcy4gSQ0KcGVyc29uYWxs
eSBzZWUgdGhhdCBhcyBhIGxvdCBtb3JlIGludGVyZXN0aW5nIHRoYW4gcmUtZXhwb3J0aW5nIGNl
cGgNCmFuZCBnbHVzdHJlLi4uDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xp
ZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEu
Y29tDQo=

