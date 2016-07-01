Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:32831 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932086AbcGAXCb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jul 2016 19:02:31 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Rostedt Steven <rostedt@goodmis.org>
CC: LKML <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "Eric Dumazet" <eric.dumazet@gmail.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Fields Bruce <bfields@fieldses.org>,
        Torvalds Linus <torvalds@linux-foundation.org>
Subject: Re: Revert: SUNRPC: xs_sock_mark_closed() does not need to trigger
 socket autoclose
Date: Fri, 1 Jul 2016 23:02:23 +0000
Message-ID: <CB98840B-1CEE-48C6-9ABB-82DA8D213BAF@primarydata.com>
References: <20160701172401.3ba89015@gandalf.local.home>
 <0A51DE9E-81B2-474A-BA07-55C3BE19629A@primarydata.com>
 <20160701183912.1f9d376b@gandalf.local.home>
In-Reply-To: <20160701183912.1f9d376b@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIEp1bCAxLCAyMDE2LCBhdCAxODozOSwgU3RldmVuIFJvc3RlZHQgPHJvc3RlZHRAZ29v
ZG1pcy5vcmc+IHdyb3RlOg0KPiANCj4gT24gRnJpLCAxIEp1bCAyMDE2IDIyOjM0OjAyICswMDAw
DQo+IFRyb25kIE15a2xlYnVzdCA8dHJvbmRteUBwcmltYXJ5ZGF0YS5jb20+IHdyb3RlOg0KPiAN
Cj4gDQo+PiBOQUNLLiBUaGlzIG9jZGUgd2FzIHJlbW92ZWQgb24gcHVycG9zZSBiZWNhdXNlIGl0
IGlzIGRhbmdlcm91cyB0bw0KPj4gaGF2ZSB0aGUgVENQIHN0YXRlIGNoYW5nZSBjYWxsYmFja3Mg
cXVldWUgdXAgYSBuZXcgY2xvc2UoKS4gVGhlDQo+PiBjb25uZWN0IGNvZGUgc29tZXRpbWVzIGhh
cyB0byBjbG9zZSBzb2NrZXRzIHRoYXQgYXJlIG1pc2JlaGF2aW5nLCBhbmQNCj4+IHNvIHdl4oCZ
dmUgc2VlbiByYWNlcyB3aGVyZWJ5IHRoZSBvbGQgc29ja2V0IGNsb3NlcyBhbmQgdHJpZ2dlcnMg
YW4NCj4+IGF1dG9jbG9zZSBmb3IgdGhlIG5ldyBzb2NrZXQgd2hpbGUgaXQgaXMgY29ubmVjdGlu
Zy4NCj4gDQo+IE9LIGZpbmUuIEJ1dCBjYW4gd2UgcGxlYXNlIGNvbWUgdXAgd2l0aCBhIHNvbHV0
aW9uIHRvIGdldCByaWQgb2YgdGhlDQo+IGhpZGRlbiBwb3J0IGlzc3VlLiBJdCdzIHZlcnkgYW5u
b3lpbmcgdGhhdCBJIGdldCBhIG1lc3NhZ2UgZnJvbQ0KPiBya2h1bnRlciBldmVyIG1vcm5pbmcg
dGVsbGluZyBtZSAiUGxlYXNlIGluc3BlY3QgdGhpcyBtYWNoaW5lLCBiZWNhdXNlDQo+IGl0IG1h
eSBiZSBpbmZlY3RlZC7igJ0NCj4gDQoNCkNhbiB3ZSBsb29rIGludG8gd2h5IHRoZSBzb2NrZXQg
ZGlzY29ubmVjdCBpcyBoYXBwZW5pbmcgaW4gdGhlIGZpcnN0IHBsYWNlPyBJdOKAmXMgcHJlc3Vt
YWJseSBub3QgdGhlIHNlcnZlciwgc2luY2UgdGhhdCBfd291bGRfIHRyaWdnZXIgYW4gYXV0b2Ns
b3NlIHdoZW4gdGhlIHNvY2tldCBoaXRzIFRDUF9DTE9TRV9XQUlULiBUaGF0IHB1dHMgdGhlIHR3
byB0b3Agc3VzcGVjdHMgYmVpbmcgdGhlIFRDUCBrZWVwYWxpdmUgYW5kIHRoZSBUQ1BfVVNFUl9U
SU1FT1VULiBBcmUgdGhlcmUgYW55IHRyYWNlcG9pbnRzIHdlIGNvdWxkIHVzZSB0byBsb29rIGF0
IHdoZXRoZXIgb3Igbm90IHRoZXkgYXJlIHRyaWdnZXJpbmcgYSBjbG9zZT8NCg0KVGhhbmtzDQog
IFRyb25kDQoNCg0K

