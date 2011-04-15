Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from seldrel01.sonyericsson.com ([212.209.106.2]:2472 "EHLO
	seldrel01.sonyericsson.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753090Ab1DOH3Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Apr 2011 03:29:16 -0400
From: "Finney, Sean" <Sean.Finney@sonyericsson.com>
To: "vovan@vovan.nl" <vovan@vovan.nl>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Fri, 15 Apr 2011 09:29:13 +0200
Subject: Re: [BUG] sec=krb5 mount problem with nfs-utils 1.2.3 on client side
Message-ID: <A50602A820F61543B29992A418BB321B66E18F8A72@seldmbx01.corpusers.net>
References: <20110415010913@it-loops.com>
 <1302840158.2447.5.camel@vovan.net.home>
 <A50602A820F61543B29992A418BB321B66E18F8A71@seldmbx01.corpusers.net>
 <20110415091555.15611t1y2vd6b3jf@vovan.nl>
In-Reply-To: <20110415091555.15611t1y2vd6b3jf@vovan.nl>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

SGkgVmxhZGltaXIsCgpPbiBGcmksIDIwMTEtMDQtMTUgYXQgMDk6MTUgKzAyMDAsIFZsYWRpbWly
IEVsaXNzZWV2IHdyb3RlOgo+IEknbSBwcmV0dHkgc3VyZSB0aGlzIGlzIG5vdCB0aGUgY2FzZSBm
b3IgbXkgZW52aXJvbm1lbnQsIGFzIHdlIGhhdmUgIAo+IGxlc3MgdGhlbiAxMDAgZ3JvdXBzIGlu
IHRvdGFsLgoKUmUtcmVhZGluZyB0aGUgbWFpbCwgSSByZWFsaXplIHlvdSBtaWdodCBiZSByaWdo
dC4gIFRoZSBFSU5WQUxJRCBvbiB0aGUKcnBjIGNoYW5uZWwgZmlsZSBqdW1wZWQgb3V0IGF0IG1l
IHRob3VnaCBzaW5jZSBpdCB3YXMgdGhlIHNhbWUgc3ltcHRvbQppbiBvdXIgY2FzZS4gIEFsc28s
IGluIG91ciBjYXNlIHdlIHNhdyB0aGUgcHJvYmxlbSBpbiBhbGwgdmVyc2lvbnMgb2YKbmZzLXV0
aWxzIGFuZCBub3QganVzdCB0aGUgbGF0ZXN0IG9uZSwgc28gaXQgY291bGQgYmUgdGhhdCBpdCdz
IGFuIGVycm9yCnNpbWlsYXIgaW4gbmF0dXJlIGJ1dCBub3QgdGhlIHNhbWUgdW5kZXJseWluZyBj
YXVzZS4KCkFueXdheSwgaW4gY2FzZSBpdCdzIGFueSBoZWxwIChhc3N1bWluZyB0aGF0IHRoZSBw
YXRjaCBkb2Vzbid0IGZpeCB0aGUKcHJvYmxlbSBmb3IgeW91KSwgdGhlIGtlcm5lbCByZXR1cm5z
IEVJTlZBTElEIG9uIHdyaXRlKCkncyB0byB0aGUgZmlsZQp3aGVuIGFueSBzaW5nbGUgd3JpdGUg
aXMgbm90IHByb3Blcmx5IGZvcm1hdHRlZCBhbmQgbmV3bGluZSB0ZXJtaW5hdGVkLgpJdCBzZWVt
cyB0byBiZSB2ZXJ5IHBpY2t5IGFib3V0IHRoYXQuICBJZiB5b3Ugc3RyYWNlIC1zMjA0OCB0aGUK
b2ZmZW5kaW5nIGRhZW1vbiwgaXQgc2hvdWxkIGJlIHByZXR0eSBjbGVhciB0aG91Z2gsIGVpdGhl
ciB5b3UnbGwgc2VlIGEKc2VyaWVzIG9mIHNwbGl0IHVwIEJVRlNaIHNpemVkIHdyaXRlcyAoZWFj
aCBnZXR0aW5nIEVJTlZBTElEKSBvciB5b3UnbGwKc2VlIGEgd3JpdGUgb3BlcmF0aW9uIHRoYXQn
cyBvdGhlcndpc2Ugc29tZWhvdyBpbXByb3Blcmx5IGZvcm1hdHRlZC4KCkhvcGUgdGhhdCdzIGF0
IGxlYXN0IGEgYml0IGhlbHBmdWwsCgoJU2VhbgoT77+977+97Lm7HO+/vSbvv71+77+9Ju+/vRjv
v73vv70rLe+/ve+/vd22F++/ve+/vXfvv73vv73Lm++/ve+/ve+/vW3vv71i77+977+9Z37Ip++/
vRfvv73vv73cqH3vv73vv73vv73GoHrvv70majordu+/ve+/ve+/vQfvv73vv73vv73vv716Wivv
v73vv70rembvv73vv73vv71o77+977+977+9fu+/ve+/ve+/ve+/vWnvv73vv73vv71677+9Hu+/
vXfvv73vv73vv70/77+977+977+977+9Ju+/vSnfohtm
