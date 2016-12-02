Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:29901 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751175AbcLBR3S (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Dec 2016 12:29:18 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/5] NFSv4: Don't ask for the change attribute when
 reclaiming state
Date: Fri, 2 Dec 2016 17:28:27 +0000
Message-ID: <B06178AC-10FF-42D4-8309-93D9882721DC@primarydata.com>
References: <20161201220632.12754-1-trond.myklebust@primarydata.com>
 <20161201220632.12754-2-trond.myklebust@primarydata.com>
 <20161201220632.12754-3-trond.myklebust@primarydata.com>
 <f8904106-2bb4-2fdb-1fdd-fb60ff352531@gmail.com>
In-Reply-To: <f8904106-2bb4-2fdb-1fdd-fb60ff352531@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIERlYyAyLCAyMDE2LCBhdCAxMjowNSwgQW5uYSBTY2h1bWFrZXIgPHNjaHVtYWtlci5h
bm5hQGdtYWlsLmNvbT4gd3JvdGU6DQo+IA0KPiBIaSBUcm9uZCwNCj4gDQo+IE9uIDEyLzAxLzIw
MTYgMDU6MDYgUE0sIFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4+IFdlIGRvbid0IG5lZWQgdG8g
YXNrIGZvciB0aGUgY2hhbmdlIGF0dHJpYnV0ZSB3aGVuIHJldHVybmluZyBhIGRlbGVnYXRpb24N
Cj4+IG9yIHJlY292ZXJpbmcgZnJvbSBhIHNlcnZlciByZWJvb3QsIGFuZCBpdCBjb3VsZCBhY3R1
YWxseSBjYXVzZSB1cyB0bw0KPj4gb2J0YWluIGFuIGluY29ycmVjdCB2YWx1ZSBpZiB3ZSdyZSB1
c2luZyBhIHBORlMgZmxhdm91ciB0aGF0IHJlcXVpcmVzDQo+PiBMQVlPVVRDT01NSVQuDQo+PiAN
Cj4+IFNpZ25lZC1vZmYtYnk6IFRyb25kIE15a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QHByaW1h
cnlkYXRhLmNvbT4NCj4+IC0tLQ0KPj4gZnMvbmZzL25mczRwcm9jLmMgfCAxIC0NCj4+IDEgZmls
ZSBjaGFuZ2VkLCAxIGRlbGV0aW9uKC0pDQo+PiANCj4+IGRpZmYgLS1naXQgYS9mcy9uZnMvbmZz
NHByb2MuYyBiL2ZzL25mcy9uZnM0cHJvYy5jDQo+PiBpbmRleCBiNTgyZGY4OWMwODMuLmMwNjI4
Zjc4ZWQ5OCAxMDA2NDQNCj4+IC0tLSBhL2ZzL25mcy9uZnM0cHJvYy5jDQo+PiArKysgYi9mcy9u
ZnMvbmZzNHByb2MuYw0KPj4gQEAgLTIyNiw3ICsyMjYsNiBAQCBzdGF0aWMgY29uc3QgdTMyIG5m
czRfcG5mc19vcGVuX2JpdG1hcFszXSA9IHsNCj4+IA0KPj4gc3RhdGljIGNvbnN0IHUzMiBuZnM0
X29wZW5fbm9hdHRyX2JpdG1hcFszXSA9IHsNCj4+IAlGQVRUUjRfV09SRDBfVFlQRQ0KPj4gLQl8
IEZBVFRSNF9XT1JEMF9DSEFOR0UNCj4gDQo+IERvIHRoZXNlIHBhdGNoZXMgZGVwZW5kIG9uIGFu
b3RoZXIgcGF0Y2ggc2VyaWVzPyAgSSdtIGhhdmluZyB0cm91YmxlIGFwcGx5aW5nIHRoaXMgcGF0
Y2ggc2luY2UgbXkgdHJlZSBkb2Vzbid0IGhhdmUgRkFUVFI0X1dPUkQwX0NIQU5HRSB5ZXQuICBJ
J20gaGF2aW5nIHRyb3VibGUgd2l0aCBwYXRjaCA0LCB0b28uDQo+IA0KDQpJ4oCZdmUgcHVzaGVk
IG91dCB0aGUgbGludXgtbmV4dCBicmFuY2ggaHR0cDovL2dpdC5saW51eC1uZnMub3JnLz9wPXRy
b25kbXkvbGludXgtbmZzLmdpdDthPXNob3J0bG9nO2g9cmVmcy9oZWFkcy9saW51eC1uZXh0DQoN
Cj4gVGhhbmtzLA0KPiBBbm5hDQo+IA0KPj4gCXwgRkFUVFI0X1dPUkQwX0ZJTEVJRCwNCj4+IH07
DQoNCg==

