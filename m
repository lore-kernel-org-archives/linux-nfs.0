Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:57394 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752842AbcJYTev (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Oct 2016 15:34:51 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Fields Bruce James <bfields@fieldses.org>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Rusty Russell <rusty@rustcorp.com.au>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: don't pass on-stack memory to sg_set_buf
Date: Tue, 25 Oct 2016 19:34:43 +0000
Message-ID: <A4086E5B-B808-4828-A25D-4AAB2504EC57@primarydata.com>
References: <20161025184538.GA4612@fieldses.org>
In-Reply-To: <20161025184538.GA4612@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIE9jdCAyNSwgMjAxNiwgYXQgMTQ6NDUsIEouIEJydWNlIEZpZWxkcyA8YmZpZWxkc0Bm
aWVsZHNlcy5vcmc+IHdyb3RlOg0KPiANCj4gRnJvbTogIkouIEJydWNlIEZpZWxkcyIgPGJmaWVs
ZHNAcmVkaGF0LmNvbT4NCj4gDQo+IEFzIG9mIGFjNGU5N2FiY2U5YiAic2NhdHRlcmxpc3Q6IHNn
X3NldF9idWYoKSBhcmd1bWVudCBtdXN0IGJlIGluIGxpbmVhcg0KPiBtYXBwaW5nIiwgc2dfc2V0
X2J1ZiBoaXRzIGEgQlVHIHdoZW4gbWFrZV9jaGVja3N1bV92Mi0+eGRyX3Byb2Nlc3NfYnVmLA0K
PiBhbW9uZyBvdGhlciBjYWxsZXJzLCBwYXNzZXMgaXQgbWVtb3J5IG9uIHRoZSBzdGFjay4NCj4g
DQo+IFdlIG9ubHkgbmVlZCBhIHNjYXR0ZXJsaXN0IHRvIHBhc3MgdGhpcyB0byB0aGUgY3J5cHRv
IGNvZGUsIGFuZCBpdCBzZWVtcw0KPiBsaWtlIG92ZXJraWxsIHRvIHJlcXVpcmUga21hbGxvYydk
IG1lbW9yeSBqdXN0IHRvIGVuY3J5cHQgYSBmZXcgYnl0ZXMsDQo+IGJ1dCBmb3Igbm93IHRoaXMg
c2VlbXMgdGhlIGJlc3QgZml4Lg0KPiANCj4gTm90ZSBtYW55IG9mIHRoZXNlIGNhbGxlcnMgYXJl
IGluIHRoZSBORlMgd3JpdGUgcGF0aHMsIHNvIHdlIHNob3VsZG4ndA0KPiByZWFsbHkgYmUgYWxs
b2NhdGluZyBHRlBfS0VSTkVMLiAgQnV0IHdlIGFscmVhZHkgaGF2ZSBvdGhlciBhbGxvY2F0aW9u
cw0KPiBpbiB0aGVzZSBjb2RlIHBhdGhzLiAgQSBsYXJnZXIgcmVkZXNpZ24gbWF5IGJlIG5lY2Vz
c2FyeSB0byBhbGxvdw0KPiBhbGxvY2F0aW9ucyB0byBiZSBkb25lIGVhcmxpZXIuDQoNCk5BQ0vi
gKYgIEkgYWdyZWUgdGhhdCB0aGVyZSBtYXkgYWxyZWFkeSBiZSBib3JrYWdlIGluIFJQQ1NFQ19H
U1MtbGFuZCwgYnV0IHRoYXTigJlzIG5vdCBhIHJlYXNvbiB0byBiZSBhZGRpbmcgdG8gdGhlIHBp
bGUgb2YgdGhpbmdzIHRoYXQgbmVlZCB0byBiZSBmaXhlZOKApiBUaGUgYWxsb2NhdGlvbnMgdGhh
dCBsaWUgaW4gdGhlIFJQQyBjbGllbnTigJlzIGVuY29kZS9kZWNvZGUgcGF0aCBkbyBuZWVkIHRv
IGJlIEdGUF9OT0ZT4oCmLg0KDQo=

