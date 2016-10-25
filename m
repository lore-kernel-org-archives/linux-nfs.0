Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:60890 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754214AbcJYVrW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Oct 2016 17:47:22 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Fields Bruce James <bfields@fieldses.org>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Rusty Russell <rusty@rustcorp.com.au>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: don't pass on-stack memory to sg_set_buf
Date: Tue, 25 Oct 2016 21:47:16 +0000
Message-ID: <DB39073B-8C4B-48BC-8D46-7B6173966037@primarydata.com>
References: <20161025184538.GA4612@fieldses.org>
 <A4086E5B-B808-4828-A25D-4AAB2504EC57@primarydata.com>
 <20161025195930.GB5129@fieldses.org>
In-Reply-To: <20161025195930.GB5129@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIE9jdCAyNSwgMjAxNiwgYXQgMTU6NTksIEZpZWxkcyBCcnVjZSBKYW1lcyA8YmZpZWxk
c0BmaWVsZHNlcy5vcmc+IHdyb3RlOg0KPiANCj4gT24gVHVlLCBPY3QgMjUsIDIwMTYgYXQgMDc6
MzQ6NDNQTSArMDAwMCwgVHJvbmQgTXlrbGVidXN0IHdyb3RlOg0KPj4gDQo+Pj4gT24gT2N0IDI1
LCAyMDE2LCBhdCAxNDo0NSwgSi4gQnJ1Y2UgRmllbGRzIDxiZmllbGRzQGZpZWxkc2VzLm9yZz4g
d3JvdGU6DQo+Pj4gDQo+Pj4gRnJvbTogIkouIEJydWNlIEZpZWxkcyIgPGJmaWVsZHNAcmVkaGF0
LmNvbT4NCj4+PiANCj4+PiBBcyBvZiBhYzRlOTdhYmNlOWIgInNjYXR0ZXJsaXN0OiBzZ19zZXRf
YnVmKCkgYXJndW1lbnQgbXVzdCBiZSBpbiBsaW5lYXINCj4+PiBtYXBwaW5nIiwgc2dfc2V0X2J1
ZiBoaXRzIGEgQlVHIHdoZW4gbWFrZV9jaGVja3N1bV92Mi0+eGRyX3Byb2Nlc3NfYnVmLA0KPj4+
IGFtb25nIG90aGVyIGNhbGxlcnMsIHBhc3NlcyBpdCBtZW1vcnkgb24gdGhlIHN0YWNrLg0KPj4+
IA0KPj4+IFdlIG9ubHkgbmVlZCBhIHNjYXR0ZXJsaXN0IHRvIHBhc3MgdGhpcyB0byB0aGUgY3J5
cHRvIGNvZGUsIGFuZCBpdCBzZWVtcw0KPj4+IGxpa2Ugb3ZlcmtpbGwgdG8gcmVxdWlyZSBrbWFs
bG9jJ2QgbWVtb3J5IGp1c3QgdG8gZW5jcnlwdCBhIGZldyBieXRlcywNCj4+PiBidXQgZm9yIG5v
dyB0aGlzIHNlZW1zIHRoZSBiZXN0IGZpeC4NCj4+PiANCj4+PiBOb3RlIG1hbnkgb2YgdGhlc2Ug
Y2FsbGVycyBhcmUgaW4gdGhlIE5GUyB3cml0ZSBwYXRocywgc28gd2Ugc2hvdWxkbid0DQo+Pj4g
cmVhbGx5IGJlIGFsbG9jYXRpbmcgR0ZQX0tFUk5FTC4gIEJ1dCB3ZSBhbHJlYWR5IGhhdmUgb3Ro
ZXIgYWxsb2NhdGlvbnMNCj4+PiBpbiB0aGVzZSBjb2RlIHBhdGhzLiAgQSBsYXJnZXIgcmVkZXNp
Z24gbWF5IGJlIG5lY2Vzc2FyeSB0byBhbGxvdw0KPj4+IGFsbG9jYXRpb25zIHRvIGJlIGRvbmUg
ZWFybGllci4NCj4+IA0KPj4gTkFDS+KApiAgSSBhZ3JlZSB0aGF0IHRoZXJlIG1heSBhbHJlYWR5
IGJlIGJvcmthZ2UgaW4gUlBDU0VDX0dTUy1sYW5kLCBidXQgdGhhdOKAmXMgbm90IGEgcmVhc29u
IHRvIGJlIGFkZGluZyB0byB0aGUgcGlsZSBvZiB0aGluZ3MgdGhhdCBuZWVkIHRvIGJlIGZpeGVk
4oCmIFRoZSBhbGxvY2F0aW9ucyB0aGF0IGxpZSBpbiB0aGUgUlBDIGNsaWVudOKAmXMgZW5jb2Rl
L2RlY29kZSBwYXRoIGRvIG5lZWQgdG8gYmUgR0ZQX05PRlPigKYuDQo+IA0KPiBPSy4gIEFueSBk
aXNhZHZhbnRhZ2UgdG8ga2VlcGluZyB0aGlzIHBhdGNoIHdpdGgganVzdCBHRlBfTk9GUw0KPiBh
bGxvY2F0aW9ucyBldmVyeXdoZXJlIHRoYXQgbWlnaHQgYmUgaW4gdGhlIHdyaXRlIHBhdGg/DQoN
Ckl04oCZcyB3aGF0IHdlIGhhdmUgdG8gZG8gZXZlcnl3aGVyZSBlbHNlIGluIHRoZSBSUEMgY2xp
ZW50LCBzbyBJIGNhbuKAmXQgc2VlIHdoeSBpdCBzaG91bGQgYmUgYSBwcm9ibGVtLg0KDQo=

