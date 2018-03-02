Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:48186 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1163227AbeCBREM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2018 12:04:12 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "smayhew@redhat.com" <smayhew@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: nfs_commit_inode should redirty inode if the inode
 has outstanding requests
Date: Fri, 2 Mar 2018 17:04:06 +0000
Message-ID: <1520010245.6669.7.camel@primarydata.com>
References: <20180302160038.1598-1-smayhew@redhat.com>
         <1520009534.6669.3.camel@primarydata.com>
In-Reply-To: <1520009534.6669.3.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE4LTAzLTAyIGF0IDE2OjUyICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IE9uIEZyaSwgMjAxOC0wMy0wMiBhdCAxMTowMCAtMDUwMCwgU2NvdHQgTWF5aGV3IHdyb3Rl
Og0KPiA+IEl0IHNlZW1zIHRoYXQgbmZzX2NvbW1pdF9pbm9kZSBjYW4gYmUgY2FsbGVkIHdoZXJl
IHRoZSBuZnNfaW5vZGUNCj4gPiBoYXMNCj4gPiBvdXRzdGFuZGluZyByZXF1ZXN0cyBhbmQgdGhl
IGNvbW1pdCBsaXN0cyBhcmUgZW1wdHkuICBUaGF0IGNhbiBsZWFkDQo+ID4gdG8NCj4gPiBpbnZh
bGlkYXRlX2NvbXBsZXRlX3BhZ2UyIGZhaWxpbmcgZHVlIHRvIHRoZSBhc3NvY2lhdGVkIHBhZ2Ug
aGF2aW5nDQo+ID4gcHJpdmF0ZSBkYXRhIHdoaWNoIGluIHR1cm4gbGVhZHMgdG8gaW52YWxpZGF0
ZV9pbm9kZV9wYWdlczJfcmFuZ2UNCj4gPiByZXR1cm5pbmcgLUVCVVNZLg0KPiA+IA0KPiA+IElu
c3RlYWQgb2YgaGF2aW5nIG5mc19jb21taXRfaW5vZGUgZXhpdCBlYXJseSB3aGVuIHRoZSBjb21t
aXQgbGlzdHMNCj4gPiBhcmUNCj4gPiBlbXB0eSwgb25seSBkbyBzbyBpZiBucmVxdWVzdHMgaXMg
YWxzbyAwLg0KPiA+IA0KPiA+IA0KPiANCj4gSSdtIG5vdCBzZWVpbmcgaG93IHRoaXMgZmFpbHVy
ZSB3b3VsZCBoYXBwZW4uIElzIHRoZXJlIGEgYnVnIGluDQo+IG5mc19sYXVuZGVyX3BhZ2UoKSBh
bmQvb3IgbmZzX3diX3BhZ2UoKT8NCj4gDQo+IA0KQWguLi4gSXQgbG9va3MgYXMgaWYgZG9fbGF1
bmRlcl9wYWdlKCkgb25seSBjaGVja3MgZm9yIFBhZ2VEaXJ0eSgpLCBzbw0KaXQgd29uJ3QgY2F0
Y2ggdGhlIHVuc3RhYmxlIHdyaXRlIHN0YXRlLiBDYW4ndCB3ZSBmaXggdGhhdD8gSXQgbG9va3Mg
YXMNCmlmIGFsbCB0aGUgb3RoZXIgZmlsZXN5c3RlbSBsYXVuZGVyX3BhZ2UoKSBoYW5kbGVycyB3
b3VsZCBiZSBzYWZlIHdpdGgNCmEgY2hlY2sgZm9yIFBhZ2VEaXJ0eSB8fCBQYWdlUHJpdmF0ZS4N
Cg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgUHJp
bWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

