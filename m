Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:43855 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S967967AbeCBQwU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2018 11:52:20 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "smayhew@redhat.com" <smayhew@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: nfs_commit_inode should redirty inode if the inode
 has outstanding requests
Date: Fri, 2 Mar 2018 16:52:15 +0000
Message-ID: <1520009534.6669.3.camel@primarydata.com>
References: <20180302160038.1598-1-smayhew@redhat.com>
In-Reply-To: <20180302160038.1598-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE4LTAzLTAyIGF0IDExOjAwIC0wNTAwLCBTY290dCBNYXloZXcgd3JvdGU6DQo+
IEl0IHNlZW1zIHRoYXQgbmZzX2NvbW1pdF9pbm9kZSBjYW4gYmUgY2FsbGVkIHdoZXJlIHRoZSBu
ZnNfaW5vZGUgaGFzDQo+IG91dHN0YW5kaW5nIHJlcXVlc3RzIGFuZCB0aGUgY29tbWl0IGxpc3Rz
IGFyZSBlbXB0eS4gIFRoYXQgY2FuIGxlYWQNCj4gdG8NCj4gaW52YWxpZGF0ZV9jb21wbGV0ZV9w
YWdlMiBmYWlsaW5nIGR1ZSB0byB0aGUgYXNzb2NpYXRlZCBwYWdlIGhhdmluZw0KPiBwcml2YXRl
IGRhdGEgd2hpY2ggaW4gdHVybiBsZWFkcyB0byBpbnZhbGlkYXRlX2lub2RlX3BhZ2VzMl9yYW5n
ZQ0KPiByZXR1cm5pbmcgLUVCVVNZLg0KPiANCj4gSW5zdGVhZCBvZiBoYXZpbmcgbmZzX2NvbW1p
dF9pbm9kZSBleGl0IGVhcmx5IHdoZW4gdGhlIGNvbW1pdCBsaXN0cw0KPiBhcmUNCj4gZW1wdHks
IG9ubHkgZG8gc28gaWYgbnJlcXVlc3RzIGlzIGFsc28gMC4NCj4gDQo+IA0KDQpJJ20gbm90IHNl
ZWluZyBob3cgdGhpcyBmYWlsdXJlIHdvdWxkIGhhcHBlbi4gSXMgdGhlcmUgYSBidWcgaW4NCm5m
c19sYXVuZGVyX3BhZ2UoKSBhbmQvb3IgbmZzX3diX3BhZ2UoKT8NCg0KLS0gDQpUcm9uZCBNeWts
ZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15
a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

