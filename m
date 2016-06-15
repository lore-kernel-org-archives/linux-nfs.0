Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:50200 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932752AbcFOPJ3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 11:09:29 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "xfs@oss.sgi.com" <xfs@oss.sgi.com>
Subject: Re: [PATCH 10/12] NFS: Do not serialise O_DIRECT reads and writes
Date: Wed, 15 Jun 2016 15:09:23 +0000
Message-ID: <02DCF6B5-AFDF-4E33-A8F2-DBFE67A87E91@primarydata.com>
References: <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-7-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-8-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
 <20160615071343.GC4318@infradead.org>
 <755A2A14-C6A9-4737-8335-0A6785490F6D@primarydata.com>
 <20160615144801.GB18524@infradead.org>
 <C13D01C1-4B83-442A-A0EA-D7624BE8A782@primarydata.com>
 <20160615145638.GC5297@infradead.org>
In-Reply-To: <20160615145638.GC5297@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCk9uIDYvMTUvMTYsIDEwOjU2LCAiQ2hyaXN0b3BoIEhlbGx3aWciIDxoY2hAaW5mcmFkZWFk
Lm9yZz4gd3JvdGU6DQoNCj5PbiBXZWQsIEp1biAxNSwgMjAxNiBhdCAwMjo1MjoyNFBNICswMDAw
LCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+PiA+QnV0IFhGUyBhbGxvd3MgZnVsbCBwYXJhbGxl
bGlzbSBmb3IgZGlyZWN0IHJlYWRzIGFuZCB3cml0ZXMgYXMgbG9uZw0KPj4gPmFzIHRoZXJlIGlz
IG5vIG1vcmUgcGFnZWNhY2hlIHRvIGZsdXNoLiAgQnV0IGlmIHlvdSBoYXZlIHBhZ2VzIGluDQo+
PiA+dGhlIHBhZ2VjYWNoZSB5b3UgbmVlZCB0aGUgZXhjbHVzaXZlIGxvY2sgdG8gcHJldmVudCBh
Z2FpbnN0IG5ldw0KPj4gPnBhZ2VjYWNoZSBwYWdlcyBiZWluZyBhZGRlZC4NCj4+IA0KPj4gRXhh
Y3RseS4gU28gZG9lcyB0aGlzLg0KPg0KPlNvIGxldCdzIGF2b2lkIGJsb2F0aW5nIHRoZSBpbm9k
ZSB3aXRoIGFub3RoZXIgcndfc2VtYXBob3JlLCBhbmQgbWFrZQ0KPmV2ZXJ5b25lcyBsaWZlIGVh
c2llciBieSB1c2luZyB0aGUgZXhpc3RpbmcgbG9jay4NCg0KQXMgSSBzYWlkIGVhcmxpZXIsIHRo
ZSBwcm9ibGVtIHdpdGggdGhhdCBpcyB5b3UgZW5kIHVwIGFydGlmaWNpYWxseSBzZXJpYWxpc2lu
ZyBidWZmZXJlZCByZWFkcyBhbmQgYnVmZmVyZWQgd3JpdGVzLg0KDQrigKIgVGhlIHJlYWRzIG9u
bHkgbmVlZCBhIHNoYXJlZCBsb2NrIGluIG9yZGVyIHRvIHByb3RlY3QgdGhlIEkvTyBtb2RlIGZy
b20gZmxpcHBpbmcgdG8gT19ESVJFQ1QgKGFuZCByZWx5aW5nIG9uIHBhZ2UgbG9ja3MgdG8gcHJv
dGVjdCBhZ2FpbnN0IGJ1ZmZlcmVkIHdyaXRlcykuDQrigKIgVGhlIHdyaXRlcyBuZWVkIHByb3Rl
Y3Rpb24gYWdhaW5zdCBPX0RJUkVDVCwgdGhleSBkb27igJl0IG5lZWQgc2VyaWFsaXNhdGlvbiB3
aXRoIG90aGVyIHJlYWRzLCBidXQgdGhleSBkbyBuZWVkIHRvIGJlIHNlcmlhbGlzZWQgYWdhaW5z
dCBvdGhlciBidWZmZXJlZCB3cml0ZXMuDQoNCg0KDQo=

