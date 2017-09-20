Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:50111 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751307AbdITSRQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Sep 2017 14:17:16 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        "ffilzlnx@mindspring.com" <ffilzlnx@mindspring.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "stefanha@redhat.com" <stefanha@redhat.com>,
        SteveD redhat <steved@redhat.com>,
        "mbenjami@redhat.com" <mbenjami@redhat.com>,
        "berrange@redhat.com" <berrange@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Date: Wed, 20 Sep 2017 18:17:07 +0000
Message-ID: <1505931425.10427.2.camel@primarydata.com>
References: <20170919093140.GF9536@redhat.com>
         <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com>
         <20170919151051.GS9536@redhat.com>
         <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
         <20170919164427.GV9536@redhat.com>
         <E94E2759-1734-4C52-838F-8906B3F969C0@oracle.com>
         <20170919204224.GA14329@fieldses.org>
         <37604438-9848-47CA-8884-8FD6292EAFC9@oracle.com>
         <20170920131641.GC14329@fieldses.org>
         <E8E404FD-420A-45C6-B46B-F1E2A4133F17@oracle.com>
         <20170920144557.GD14329@fieldses.org>
         <202BF722-77BC-4EF2-BD75-9AA42CBF4A94@oracle.com>
         <015601d33224$b7770b40$266521c0$@mindspring.com>
In-Reply-To: <015601d33224$b7770b40$266521c0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE3LTA5LTIwIGF0IDA4OjI1IC0wNzAwLCBGcmFuayBGaWx6IHdyb3RlOg0KPiA+
ID4gT24gU2VwIDIwLCAyMDE3LCBhdCAxMDo0NSBBTSwgSi4gQnJ1Y2UgRmllbGRzIDxiZmllbGRz
QGZpZWxkc2VzLm8NCj4gPiA+IHJnPg0KPiANCj4gd3JvdGU6DQo+ID4gPiANCj4gPiA+IE9uIFdl
ZCwgU2VwIDIwLCAyMDE3IGF0IDEwOjQwOjQ1QU0gLTA0MDAsIENodWNrIExldmVyIHdyb3RlOg0K
PiA+ID4gPiBGaWxlIGhhbmRsZXMgc3VkZGVubHkgY2hhbmdlIGFuZCBsb2NrIHN0YXRlIHZhbmlz
aGVzIGFmdGVyIGENCj4gPiA+ID4gbGl2ZQ0KPiA+ID4gPiBtaWdyYXRpb24gZXZlbnQsIGJvdGgg
b2Ygd2hpY2ggd291bGQgYmUgY2F0YXN0cm9waGljIGZvcg0KPiA+ID4gPiBoeXBlcnZpc29yDQo+
ID4gPiA+IG1vdW50IHBvaW50cy4NCj4gPiA+IA0KPiA+ID4gVGhleSdyZSB0YWxraW5nIGFib3V0
IGEgR2FuZXNoYS9DZXBoIGJhY2tlbmQuICBJdCBzaG91bGQgYmUgYWJsZQ0KPiA+ID4gdG8NCj4g
PiA+IHByZXNlcnZlIGZpbGVoYW5kbGVzLg0KPiA+IA0KPiA+IFRoYXQncyBvbmx5IG9uZSBwb3Nz
aWJsZSBpbXBsZW1lbnRhdGlvbi4gSSdtIHRoaW5raW5nIGluIHRlcm1zIG9mDQo+ID4gd2hhdA0K
PiANCj4gbmVlZHMNCj4gPiB0byBiZSBkb2N1bWVudGVkIGZvciBpbnRlcm9wZXJhYmlsaXR5IHB1
cnBvc2VzLg0KPiANCj4gSXQgc2VlbXMgbGlrZSBsaXZlIG1pZ3JhdGlvbiBwcmV0dHkgbXVjaCBy
ZXF1aXJlcyBhIGJhY2sgZW5kIHRoYXQNCj4gd2lsbA0KPiBwcmVzZXJ2ZSBmaWxlIGhhbmRsZXMu
DQo+IA0KPiA+ID4gTG9jayBtaWdyYXRpb24gd2lsbCByZXF1aXJlIHNlcnZlci1zaWRlIGltcGxl
bWVudGF0aW9uIHdvcmsgYnV0DQo+ID4gPiBub3QNCj4gPiA+IHByb3RvY29sIGNoYW5nZXMgdGhh
dCBJJ20gYXdhcmUgb2YuDQo+ID4gPiANCj4gPiA+IEl0IGNvdWxkIGJlIGEgbG90IG9mIGltcGxl
bWVudGF0aW9uIHdvcmssIHRob3VnaC4NCj4gPiANCj4gPiBBZ3JlZWQuDQo+IA0KPiBJIHRoaW5r
IHRoZSBsb2NrIG1pZ3JhdGlvbiBjYW4gYmUgaGFuZGxlZCB0aGUgd2F5IHdlIGhhbmRsZSBzdGF0
ZQ0KPiBtaWdyYXRpb24NCj4gaW4gYW4gSEEgZW52aXJvbm1lbnQgLSB3aGVyZSB3ZSB0cmVhdCBp
dCBhcyBhIHNlcnZlciByZWJvb3QgdG8gdGhlDQo+IGNsaWVudA0KPiAoc28gU01fTk9USUZZIHRv
IHYzIGNsaWVudHMsIHRoZSB2YXJpb3VzIGVycm9ycyB2NCB1c2VzIHRvIHNpZ25hbA0KPiBzZXJ2
ZXINCj4gcmVib290LCBpbiBlaXRoZXIgY2FzZSwgdGhlIGNsaWVudCB3aWxsIGluaXRpYXRlIGxv
Y2sgcmVjbGFpbSkuDQo+IA0KDQpNaW5kIHNob3dpbmcgdXMgYW4gYXJjaGl0ZWN0dXJlIGZvciB0
aGF0PyBBcyBmYXIgYXMgSSBjYW4gc2VlLCB0aGUNCmxheWVyaW5nIGlzIGFzIGZvbGxvd3M6DQoN
ClZNIGNsaWVudA0KLS0tLS0tLS0tLS0tLS0NCmhvc3Qga25mc2QNCi0tLS0tLS0tLS0tLS0tDQpo
b3N0IGNsaWVudA0KLS0tLS0tLS0tLS0tLS0NClN0b3JhZ2Ugc2VydmVyDQoNClNvIGhvdyB3b3Vs
ZCB5b3Ugbm90aWZ5IHRoZSBWTSBjbGllbnQgdGhhdCBpdHMgbG9ja3MgaGF2ZSBiZWVuDQptaWdy
YXRlZD8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5l
ciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

