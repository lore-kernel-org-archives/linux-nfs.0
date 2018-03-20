Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:39950 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753429AbeCTNqZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 09:46:25 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "bfields@redhat.com" <bfields@redhat.com>,
        "dhowells@redhat.com" <dhowells@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 10/10] nfsd: clients don't need to break their own
 delegations
Date: Tue, 20 Mar 2018 13:46:20 +0000
Message-ID: <1521553578.10293.4.camel@primarydata.com>
References: <1521470194-24840-11-git-send-email-bfields@redhat.com>
         <1521470194-24840-1-git-send-email-bfields@redhat.com>
         <29167.1521552951@warthog.procyon.org.uk>
In-Reply-To: <29167.1521552951@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE4LTAzLTIwIGF0IDEzOjM1ICswMDAwLCBEYXZpZCBIb3dlbGxzIHdyb3RlOg0K
PiBKLiBCcnVjZSBGaWVsZHMgPGJmaWVsZHNAcmVkaGF0LmNvbT4gd3JvdGU6DQo+IA0KPiA+IEBA
IC0xMzksNiArMTM5LDkgQEAgc3RydWN0IGNyZWQgew0KPiA+ICAJc3RydWN0IGtleQkqdGhyZWFk
X2tleXJpbmc7IC8qIGtleXJpbmcgcHJpdmF0ZSB0bw0KPiA+IHRoaXMgdGhyZWFkICovDQo+ID4g
IAlzdHJ1Y3Qga2V5CSpyZXF1ZXN0X2tleV9hdXRoOyAvKiBhc3N1bWVkDQo+ID4gcmVxdWVzdF9r
ZXkgYXV0aG9yaXR5ICovDQo+ID4gICNlbmRpZg0KPiA+ICsjaWZkZWYgQ09ORklHX0ZJTEVfTE9D
S0lORw0KPiA+ICsJdm9pZAkJKmxlYXNlX2JyZWFrZXI7IC8qIGlkZW50aWZ5IE5GUyBjbGllbnQN
Cj4gPiBicmVha2luZyBhIGRlbGVnYXRpb24gKi8NCj4gPiArI2VuZGlmDQo+ID4gICNpZmRlZiBD
T05GSUdfU0VDVVJJVFkNCj4gPiAgCXZvaWQJCSpzZWN1cml0eTsJLyogc3ViamVjdGl2ZSBMU00N
Cj4gPiBzZWN1cml0eSAqLw0KPiA+ICAjZW5kaWYNCj4gDQo+IFNvcnJ5LCBidXQgZXd3dy4NCj4g
DQo+IFR3byByZWFzb25zIGZvciB0aGF0IGNvbW1lbnQ6DQo+IA0KPiAgKDEpIFRoZSBjcmVkIHN0
cnVjdCBtYXkgZ2V0IHJldGFpbmVkIGxvbmcgcGFzdCB3aGVyZSB5b3UgZXhwZWN0IGlmDQo+IGl0
IGdldHMNCj4gICAgICBhdHRhY2hlZCB0byBhbm90aGVyIHByb2Nlc3Mgb3IgYSBmaWxlIGRlc2Ny
aXB0b3IuDQo+IA0KPiAgKDIpIFRoZSAtPmxlYXNlX2JyZWFrZXIgcG9pbnRlciBuZWVkcyBsaWZl
dGltZSBtYW5hZ2VtZW50IGluDQo+IGNyZWQuYy4gIEl0IHdpbGwNCj4gICAgICBwb3RlbnRpYWxs
eSBnZXQgY29waWVkIGFyb3VuZCBhbmQgbWF5IG5lZWQgY2xlYW5pbmcgdXAuDQo+IA0KPiBDYW4g
eW91IHN0aWNrIHlvdXIgYnJlYWtlciBpZGVudGl0eSBpbiBhIGtleSBzdHJ1Y3QgYXMgSmVmZg0K
PiBzdWdnZXN0ZWQ/DQo+IA0KDQpCcnVjZSwNCg0KRG8geW91IHJlYWxseSBuZWVkIHRvIGRvIG1v
cmUgdGhhbiBqdXN0IGlkZW50aWZ5IHRoYXQgdGhpcyBpcyBhIGtuZnNkDQp0aHJlYWQgdnMgbm90
IGEga25mc2QgdGhyZWFkPyBJJ20gYXNzdW1pbmcgdGhhdCBhIGtuZnNkIHRocmVhZCB3aWxsDQp1
c3VhbGx5IGJlIGluIGEgcG9zaXRpb24gdG8gcmVjYWxsIGRlbGVnYXRpb25zIGJlZm9yZSBpdCBl
dmVuIGluaXRpYXRlcw0KYW4gb3BlcmF0aW9uIG9uIHRoZSBpbm9kZSBpbiBxdWVzdGlvbiwgd29u
J3QgaXQ/DQoNCklPVzogd2hhdCBpZiB5b3Ugd2VyZSB0byBtb2RpZnkgdGhlIGxlYXNlIGNvZGUg
dG8gYWxsb3cga25mc2QgdGhyZWFkcw0KdG8gcmV0dXJuIGEgInBsZWFzZSBpZ25vcmUgbWUsIGFu
ZCBwcm9jZWVkIHdpdGggdGhlIG9wZXJhdGlvbiB0aGF0DQp0cmlnZ2VyZWQgdGhlIGxlYXNlIGJy
ZWFrIiByZXBseSwgYW5kIHRoZW4gaGFuZGxlIGNvbmZsaWN0cyBiZXR3ZWVuIE5GUw0KY2xpZW50
cyBvdXRzaWRlIHRoZSBsZWFzZSBjYWxsYmFjayBjb2RlIGFsdG9nZXRoZXI/DQoNCkNoZWVycw0K
ICBUcm9uZA0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5l
ciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

