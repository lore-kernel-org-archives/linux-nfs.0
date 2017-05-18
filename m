Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:45334 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751782AbdERQJR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 18 May 2017 12:09:17 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "stefanha@redhat.com" <stefanha@redhat.com>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "SteveD@redhat.com" <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: EXCHANGE_ID with same network address but different server owner
Date: Thu, 18 May 2017 16:09:10 +0000
Message-ID: <1495123747.13396.4.camel@primarydata.com>
References: <1494601295.10434.1.camel@primarydata.com>
         <021509A5-FA89-4289-B190-26DC317A09F6@oracle.com>
         <20170515144306.GB16013@stefanha-x1.localdomain>
         <20170515160248.GD9697@parsley.fieldses.org>
         <20170516131142.GA12711@fieldses.org>
         <20170518133441.GC4155@stefanha-x1.localdomain>
         <A720C1BD-D218-43A2-B6FD-C72B1E58D98C@oracle.com>
         <1495119887.11859.1.camel@primarydata.com>
         <20170518150850.GB16256@parsley.fieldses.org>
         <1495120629.13396.1.camel@primarydata.com>
         <20170518152822.GA9725@fieldses.org>
In-Reply-To: <20170518152822.GA9725@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE3LTA1LTE4IGF0IDExOjI4IC0wNDAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3
cm90ZToNCj4gT24gVGh1LCBNYXkgMTgsIDIwMTcgYXQgMDM6MTc6MTFQTSArMDAwMCwgVHJvbmQg
TXlrbGVidXN0IHdyb3RlOg0KPiA+IEZvciB0aGUgY2FzZSB0aGF0IFN0ZWZhbiBpcyBkaXNjdXNz
aW5nIChrdm0pIGl0IHdvdWxkIGxpdGVyYWxseSBiZQ0KPiA+IGENCj4gPiBzaW5nbGUgcHJvY2Vz
cyB0aGF0IGlzIGJlaW5nIG1pZ3JhdGVkLiBGb3IgbHhjIGFuZA0KPiA+IGRvY2tlci9rdWJlcm5l
dGVzLQ0KPiA+IHN0eWxlIGNvbnRhaW5lcnMsIGl0IHdvdWxkIGJlIGEgY29sbGVjdGlvbiBvZiBw
cm9jZXNzZXMuDQo+ID4gDQo+ID4gVGhlIG1vdW50cG9pbnRzIHVzZWQgYnkgdGhlc2UgY29udGFp
bmVycyBhcmUgb2Z0ZW4gb3duZWQgYnkgdGhlDQo+ID4gaG9zdDsNCj4gPiB0aGV5IGFyZSB0eXBp
Y2FsbHkgc2V0IHVwIGJlZm9yZSBzdGFydGluZyB0aGUgY29udGFpbmVyaXNlZA0KPiA+IHByb2Nl
c3Nlcy4NCj4gPiBGdXJ0aGVybW9yZSwgdGhlcmUgaXMgdHlwaWNhbGx5IG5vICJzdGFydCBjb250
YWluZXIiIHN5c3RlbSBjYWxsDQo+ID4gdGhhdA0KPiA+IHdlIGNhbiB1c2UgdG8gaWRlbnRpZnkg
d2hpY2ggc2V0IG9mIHByb2Nlc3NlcyAob3IgY2dyb3VwcykgYXJlDQo+ID4gY29udGFpbmVyaXNl
ZCwgYW5kIHNob3VsZCBzaGFyZSBhIGNsaWVudGlkLg0KPiANCj4gSXMgdGhhdCBzdWNoIGEgaGFy
ZCBwcm9ibGVtPw0KPiANCg0KRXJyLCB5ZXMuLi4gaXNuJ3QgaXQ/IEhvdyBkbyBJIGlkZW50aWZ5
IGEgY29udGFpbmVyIGFuZCBrbm93IHdoZXJlIHRvDQpzZXQgdGhlIGxlYXNlIGJvdW5kYXJ5Pw0K
DQpCZWFyIGluIG1pbmQgdGhhdCB0aGUgZGVmaW5pdGlvbiBvZiAiY29udGFpbmVyIiBpcyBub24t
ZXhpc3RlbnQgYmV5b25kDQp0aGUgb2J2aW91cyAiYSBsb29zZSBjb2xsZWN0aW9uIG9mIHByb2Nl
c3NlcyIuIEl0IHZhcmllcyBmcm9tIHRoZQ0KZG9ja2VyL2x4Yy92aXJ0dW96em8gc3R5bGUgY29u
dGFpbmVyLCB3aGljaCB1c2VzIG5hbWVzcGFjZXMgdG8gYm91bmQNCnRoZSBwcm9jZXNzZXMsIHRv
IHRoZSBHb29nbGUgdHlwZSBvZiAiY29udGFpbmVyIiB0aGF0IGlzIGFjdHVhbGx5IGp1c3QNCmEg
c2V0IG9mIGNncm91cHMgYW5kIHRvIHRoZSBrdm0vcWVtdSBzaW5nbGUgcHJvY2Vzcy4NCg0KPiBJ
biBhbnkgY2FzZSwgZnJvbSB0aGUgcHJvdG9jb2wgcG9pbnQgb2YgdmlldyB0aGVzZSBhbGwgc291
bmQgbGlrZQ0KPiBjbGllbnQNCj4gaW1wbGVtZW50YXRpb24gZGV0YWlscy4NCg0KSWYgeW91IGFy
ZSBzZWVpbmcgYW4gb2J2aW91cyBhcmNoaXRlY3R1cmUgZm9yIHRoZSBjbGllbnQsIHRoZW4gcGxl
YXNlDQpzaGFyZS4uLg0KDQo+IFRoZSBvbmx5IHByb2JsZW0gSSBzZWUgd2l0aCBtdWx0aXBsZSBj
bGllbnQgSUQncyBpcyB0aGF0IHlvdSdkIGxpa2UNCj4gdG8NCj4ga2VlcCB0aGVpciBkZWxlZ2F0
aW9ucyBmcm9tIGNvbmZsaWN0aW5nIHdpdGggZWFjaCBvdGhlciBzbyB0aGV5IGNhbg0KPiBzaGFy
ZSBjYWNoZS4NCj4gDQo+IEJ1dCwgbWF5YmUgSSdtIG1pc3Npbmcgc29tZXRoaW5nIGVsc2UuDQoN
CkhhdmluZyB0byBhbiBFWENIQU5HRV9JRCArIENSRUFURV9TRVNTSU9OIG9uIGV2ZXJ5IGNhbGwg
dG8NCmZvcmsoKS9jbG9uZSgpIGFuZCBhIERFU1RST1lfU0VTU0lPTi9ERVNUUk9ZX0VYQ0hBTkdF
SUQgaW4gZWFjaCBwcm9jZXNzDQpkZXN0cnVjdG9yPyBMZWFzZSByZW5ld2FsIHBpbmdzIGZyb20g
MTAwMCBwcm9jZXNzZXMgcnVubmluZyBvbiAxMDAwDQpjbGllbnRzPw0KDQpUaGlzIGlzIHdoYXQg
SSBtZWFuIGFib3V0IGNvbnRhaW5lciBib3VuZGFyaWVzLiBJZiB0aGV5IGFyZW4ndCB3ZWxsDQpk
ZWZpbmVkLCB0aGVuIHdlJ3JlIGRvd24gdG8gZG9pbmcgcHJlY2lzZWx5IHRoZSBhYm92ZS4NCg0K
LS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgUHJpbWFy
eURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

