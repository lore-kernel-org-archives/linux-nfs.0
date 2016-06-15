Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:34192 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753293AbcFOO3t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 10:29:49 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/12] NFS: Do not serialise O_DIRECT reads and writes
Date: Wed, 15 Jun 2016 14:29:42 +0000
Message-ID: <755A2A14-C6A9-4737-8335-0A6785490F6D@primarydata.com>
References: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-4-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-7-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-8-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
 <20160615071343.GC4318@infradead.org>
In-Reply-To: <20160615071343.GC4318@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCk9uIDYvMTUvMTYsIDAzOjEzLCAiQ2hyaXN0b3BoIEhlbGx3aWciIDxoY2hAaW5mcmFkZWFk
Lm9yZz4gd3JvdGU6DQoNCj4+ICt2b2lkDQo+PiArbmZzX2xvY2tfYmlvKHN0cnVjdCBuZnNfaW5v
ZGUgKm5mc2kpDQo+DQo+YmlvIHN0YW5kcyBmb3IgYnVmZmVyZWQgSS9PPyAgVGhpcyBjb3VsZCBy
ZWFsbHkgdXNlIGEgbW9yZSBkZXNjcmlwdGl2ZQ0KPm5hbWUgYW5kL29yIGEgY29tbWVudC4uDQo+
DQo+PiArew0KPj4gKwkvKiBCZSBhbiBvcHRpbWlzdCEgKi8NCj4+ICsJZG93bl9yZWFkKCZuZnNp
LT5pb19sb2NrKTsNCj4+ICsJaWYgKHRlc3RfYml0KE5GU19JTk9fT0RJUkVDVCwgJm5mc2ktPmZs
YWdzKSA9PSAwKQ0KPj4gKwkJcmV0dXJuOw0KPj4gKwl1cF9yZWFkKCZuZnNpLT5pb19sb2NrKTsN
Cj4NCj5TbyBpZiBubyBkaXJlY3QgSS9PIGlzIGdvaW5nIG9uIHRoaXMgbG9ja3Mgc2hhcmVkPw0K
Pg0KPj4gKwkvKiBTbG93IHBhdGguLi4uICovDQo+PiArCWRvd25fd3JpdGUoJm5mc2ktPmlvX2xv
Y2spOw0KPj4gKwljbGVhcl9iaXQoTkZTX0lOT19PRElSRUNULCAmbmZzaS0+ZmxhZ3MpOw0KPj4g
Kwlkb3duZ3JhZGVfd3JpdGUoJm5mc2ktPmlvX2xvY2spOw0KPg0KPlRoZSB3aG9sZSBsb2NraW5n
IGhlcmUgc2VlbXMgcmF0aGVyIGNvbmZ1c2luZy4gIFdoeSBub3QgdXNlIHRoZSBYRlMNCj5sb2Nr
aW5nIG1vZGVsOg0KDQpUaGUgbG9ja2luZyBpcyBhY3R1YWxseSBzaW1wbGVyIHRoYW4gWEZTLiBX
ZSBoYXZlIDIgSS9PIG1vZGVzOiBidWZmZXJlZCBJL08gYW5kIGRpcmVjdCBJL08uIFRoZSB3cml0
ZSBsb2NrIGlzIHRoZXJlIHRvIGVuc3VyZSBzYWZlIHRyYW5zaXRpb25zIGJldHdlZW4gdGhvc2Ug
MiBtb2RlcywgYnV0IG9uY2UgdGhlIG1vZGUgaXMgc2V0LCB3ZSBfb25seV8gdXNlIHNoYXJlZCBs
b2NrcyBpbiBvcmRlciB0byBhbGxvdyBwYXJhbGxlbGlzbS4NCg0KPg0KPmJ1ZmZlcmVkIHdyaXRl
OgkJZXhjbHVzaXZlDQo+YnVmZmVyZWQgcmVhZDoJCXNoYXJlZA0KPmRpcmVjdCB3cml0ZToJCXNo
YXJlZCAoZXhjbHVzaXZlIGZvciBwYWdlY2FjaGUgaW52YWxpZGF0ZSkNCj5kaXJlY3QgcmVhZDoJ
CXNoYXJlZCAoZXhjbHVzaXZlIGZvciBwYWdlY2FjaGUgaW52YWxpZGF0ZSkNCj4NCj5UaGUgbmlj
ZSB0aGluZyBpcyB0aGFuIGluIDQuNy1yYyBpX211dGV4IGhhcyBiZWVuIHJlcGxhY2VkIHdpdGgg
YQ0KPnJ3X211dGV4IHNvIHlvdSBjYW4ganVzdCB1c2UgdGhhdCBpbiBzaGFyZWQgbW9kZSBmb3Ig
ZGlyZWN0IEkvTw0KPmFzLWlzIHdpdGhvdXQgbmVlZGluZyBhbnkgbmV3IGxvY2suDQoNCldlIHdv
dWxkIGVuZCB1cCBzZXJpYWxpc2luZyByZWFkcyBhbmQgd3JpdGVzLCBzaW5jZSB0aGUgbGF0dGVy
IGdyYWIgYW4gZXhjbHVzaXZlIGxvY2sgaW4gZ2VuZXJpY19maWxlX3dyaXRlKCkuIFdoeSBkbyB0
aGF0IGlmIHdlIGRvbuKAmXQgaGF2ZSB0bz8NCgkNCkNoZWVycw0KICBUcm9uZA0KDQo=

