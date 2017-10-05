Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:59849 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751280AbdJENj3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Oct 2017 09:39:29 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "jack@suse.cz" <jack@suse.cz>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
Subject: Re: Why is NFS using a_ops->freepage?
Date: Thu, 5 Oct 2017 13:39:23 +0000
Message-ID: <1507210761.20822.2.camel@primarydata.com>
References: <20171005083657.GA28132@quack2.suse.cz>
In-Reply-To: <20171005083657.GA28132@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SGkgSmFuLA0KDQpPbiBUaHUsIDIwMTctMTAtMDUgYXQgMTA6MzYgKzAyMDAsIEphbiBLYXJhIHdy
b3RlOg0KPiBIZWxsbywNCj4gDQo+IEknbSBkb2luZyBzb21lIHdvcmsgaW4gcGFnZSBjYWNoZSBo
YW5kbGluZyBhbmQgSSBoYXZlIG5vdGljZWQgdGhhdA0KPiBORlMgaXMNCj4gdGhlIG9ubHkgdXNl
ciBvZiBtYXBwaW5nLT5hX29wcy0+ZnJlZXBhZ2UgY2FsbGJhY2suIEZyb20gYSBxdWljayBsb29r
DQo+IEkNCj4gZG9uJ3Qgc2VlIHdoeSBpc24ndCBORlMgdXNpbmcgLT5yZWxlYXNlcGFnZSAvIC0+
aW52YWxpZGF0ZXBhZ2UNCj4gY2FsbGJhY2sgYXMNCj4gYWxsIG90aGVyIGZpbGVzeXN0ZW1zIGRv
PyBJIGFncmVlIHlvdSB3b3VsZCBoYXZlIHRvIHNldCBQYWdlUHJpdmF0ZQ0KPiBiaXQgZm9yDQo+
IHRob3NlIHRvIGdldCBjYWxsZWQgZm9yIHRoZSBkaXJlY3RvcnkgbWFwcGluZyBob3dldmVyIHRo
YXQgd291bGQgc2VlbQ0KPiBsaWtlDQo+IGEgY2xlYW5lciB0aGluZyB0byBkbyBhbnl3YXkgLSBp
biBmYWN0IHlvdSBkbyBoYXZlIHByaXZhdGUgZGF0YSBpbg0KPiB0aGUNCj4gcGFnZS4gIEp1c3Qg
dGhleSBhcmUgbm90IHBvaW50ZWQgdG8gYnkgcGFnZS0+cHJpdmF0ZSBidXQgaW5zdGVhZCBhcmUN
Cj4gc3RvcmVkDQo+IGFzIHBhZ2UgZGF0YS4uLiBBbSBJIG1pc3Npbmcgc29tZXRoaW5nPw0KPiAN
Cj4gCQkJCQkJCQlIb256YQ0KDQpJJ20gbm90IHVuZGVyc3RhbmRpbmcgeW91ciBwb2ludC4gZGVs
ZXRlX2Zyb21fcGFnZV9jYWNoZSgpIGRvZXNuJ3QgY2FsbA0KcmVsZWFzZXBhZ2UgQUZBSUNTLg0K
DQpUaGUgcG9pbnQgb2YgZnJlZXBhZ2UgaXMgdGhhdCBpdCBpcyBjYWxsZWQgYWZ0ZXIgdGhlIHBh
Z2UgaGFzIGJlZW4NCnJlbW92ZWQgZnJvbSB0aGUgcGFnZSBjYWNoZS4NCg0KLS0gDQpUcm9uZCBN
eWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgUHJpbWFyeURhdGENCnRyb25k
Lm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

