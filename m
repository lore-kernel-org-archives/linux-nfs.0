Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:42348 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752835AbcFJOCu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2016 10:02:50 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Deepa Dinamani <deepa.kernel@gmail.com>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "y2038@lists.linaro.org" <y2038@lists.linaro.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 18/21] fs: nfs: Make nfs boot time y2038 safe
Date: Fri, 10 Jun 2016 14:02:41 +0000
Message-ID: <A2A02BB9-44BD-4EB8-B48D-CCDA829E1E5D@primarydata.com>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
 <1465448705-25055-19-git-send-email-deepa.kernel@gmail.com>
 <89EF59F9-52D2-4F37-A7A8-52BD0FF7E98E@primarydata.com>
 <CABeXuvoLr7amTYBs5AbMv15Vqx2CQib9F8Qr4GzX9RoZZ9ZnpQ@mail.gmail.com>
 <d135d52c-be6d-8d89-a619-03210774ec42@Netapp.com>
In-Reply-To: <d135d52c-be6d-8d89-a619-03210774ec42@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCk9uIDYvMTAvMTYsIDA5OjEyLCAiQW5uYSBTY2h1bWFrZXIiIDxBbm5hLlNjaHVtYWtlckBu
ZXRhcHAuY29tPiB3cm90ZToNCg0KPk9uIDA2LzA5LzIwMTYgMDU6MTAgUE0sIERlZXBhIERpbmFt
YW5pIHdyb3RlOg0KPj4+PiBib290X3RpbWUgaXMgcmVwcmVzZW50ZWQgYXMgYSBzdHJ1Y3QgdGlt
ZXNwZWMuDQo+Pj4+IHN0cnVjdCB0aW1lc3BlYyBhbmQgQ1VSUkVOVF9USU1FIGFyZSBub3QgeTIw
Mzggc2FmZS4NCj4+Pj4gT3ZlcmFsbCwgdGhlIHBsYW4gaXMgdG8gdXNlIHRpbWVzcGVjNjQgZm9y
IGFsbCBpbnRlcm5hbA0KPj4+PiBrZXJuZWwgcmVwcmVzZW50YXRpb24gb2YgdGltZXN0YW1wcy4N
Cj4+Pj4gQ1VSUkVOVF9USU1FIHdpbGwgYWxzbyBiZSByZW1vdmVkLg0KPj4+PiBVc2Ugc3RydWN0
IHRpbWVzcGVjNjQgdG8gcmVwcmVzZW50IGJvb3RfdGltZS4NCj4+Pj4gQW5kLCBrdGltZV9nZXRf
cmVhbF90czY0KCkgZm9yIHRoZSBib290X3RpbWUgdmFsdWUuDQo+Pj4+DQo+Pj4+IGJvb3RfdGlt
ZSBpcyB1c2VkIHRvIGNvbnN0cnVjdCB0aGUgbmZzIGNsaWVudCBib290IHZlcmlmaWVyLg0KPj4+
PiBUaGlzIHdpbGwgbm93IHdyYXAgaW4gMjEwNiBpbnN0ZWFkIG9mIDIwMzggb24gMzItYml0IHN5
c3RlbXMuDQo+Pj4+IFRoZSBzZXJ2ZXIgb25seSByZWxpZXMgb24gdGhlIHZhbHVlIGJlaW5nIHBl
cnNpc3RlbnQgdW50aWwNCj4+Pj4gcmVib290IHNvIHRoZSB3cmFwcGluZyBzaG91bGQgYmUgZmlu
ZS4NCj4+Pg0KPj4+IFdlIHJlYWxseSBkbyBub3QgZ2l2ZSBhIGRhbW4gYWJvdXQgd3JhcGFyb3Vu
ZCBoZXJlLCBzaW5jZSB0aGUgYm9vdCB0aW1lIGlzDQo+Pj4gb25seSBldmVyIGNvbXBhcmVkIGZv
ciBhbiBleGFjdCBtYXRjaCwgYW5kIHRoZSBvZGRzIG9mIHR3byByZWJvb3RzIG9jY3VycmluZw0K
Pj4+IGV4YWN0bHkgMl4zMiAqIDEwXjkgbmFub3NlY29uZHMgYXBhcnQgYXJlIGNvc21pY2FsbHkg
c21hbGwuLi4NCj4+PiBJZiBzdHJ1Y3QgdGltZXNwZWMgaXMgZ29pbmcgYXdheSwgY2FuIHdlIGp1
c3QgY29udmVydCB0aGlzIGludG8gYSBrdGltZV90Pw0KPj4gDQo+PiB0aW1lc3BlYzY0IGlzIHRo
ZSBzYW1lIGFzIHRpbWVzcGVjIGFscmVhZHkgb24gNjQgYml0IG1hY2hpbmVzLg0KPj4gQnV0LCB5
ZXMsIHdlIGNhbiB1c2Uga3RpbWVfdCBoZXJlLg0KPj4gDQo+PiBEaWQgeW91IG1lYW4gdGhlIGlu
dGVybmFsIHN0b3JhZ2UgdmFsdWUgb3IgdGhlIHdpcmUgYm9vX3RpbWUgdXNlZCBmb3IgdmVyaWZp
ZXI/DQo+PiBJbiBjYXNlIHlvdSBkb24ndCB3YW50IHRvIGNoYW5nZSB0aGUgd2lyZSB2YWx1ZSwg
dGhlbiB3ZSB3aWxsIGhhdmUgYSBkaXZpc2lvbg0KPj4gb3BlcmF0aW9uLCBldmVyeSB0aW1lIHRo
ZSB2ZXJpZmllciBuZWVkcyB0byBiZSBzZW50Lg0KPg0KPlRoZSB2ZXJpZmllciBpcyBtb3N0bHkg
dXNlZCBkdXJpbmcgbW91bnRpbmcsIHNvIHdlIGRvbid0IHNlbmQgdG9vIG1hbnkgb2YgdGhlbS4g
IEkgZG9uJ3QgdGhpbmsgd2UgbmVlZCB0byB3b3JyeSBhYm91dCBhZGRpbmcgYW4gZXh0cmEgZGl2
aXNpb24gb3BlcmF0aW9uIGhlcmUsIHRoZXkncmUgcHJldHR5IGNoZWFwIGNvbXBhcmVkIHRvIG1h
a2luZyBSUEMgY2FsbHMhIDopDQo+DQoNClRoZSBvbmx5IHJlcXVpcmVtZW50IGZvciB0aGUgdmVy
aWZpZXIgaXMgdGhhdCBpdCBiZSB1bmlxdWUsIHNvIGNoYW5naW5nIHRoZSBmb3JtYXQgaXMgbm90
IGEgcHJvYmxlbSBlaXRoZXIuIA0KDQpDaGVlcnMNCiAgVHJvbmQNCg0K

