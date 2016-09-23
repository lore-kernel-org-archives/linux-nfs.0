Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:40189 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1035314AbcIWSed (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2016 14:34:33 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Kornievskaia Olga <aglo@umich.edu>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: reuse of slot and seq# when RPC was interrupted
Date: Fri, 23 Sep 2016 18:34:28 +0000
Message-ID: <B8C98E5E-F9F5-4468-8E52-A3A4A550C1E3@primarydata.com>
References: <CAN-5tyFQ2PiSHp41mOMHa=DSJ8SmXBo=Nk=v-k1hASPKRbbhzQ@mail.gmail.com>
 <AE6F91D9-2D4E-4AA0-A1F3-EB511E53F990@primarydata.com>
 <CAN-5tyF3HrY9+xWO7HDnN_dv13vS9nqcp0vZpA29T=i3cJMSZg@mail.gmail.com>
 <AE31C3DC-40B8-4BBE-A5A1-A62CB656268A@primarydata.com>
 <CAN-5tyHgJ9K7=RChVt=sLHQbjTCRj8MhEmMipreMKWzef4Wscw@mail.gmail.com>
In-Reply-To: <CAN-5tyHgJ9K7=RChVt=sLHQbjTCRj8MhEmMipreMKWzef4Wscw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIFNlcCAyMywgMjAxNiwgYXQgMTQ6MjUsIE9sZ2EgS29ybmlldnNrYWlhIDxhZ2xvQHVt
aWNoLmVkdT4gd3JvdGU6DQo+IA0KPiBPbiBGcmksIFNlcCAyMywgMjAxNiBhdCAyOjA4IFBNLCBU
cm9uZCBNeWtsZWJ1c3QNCj4gPHRyb25kbXlAcHJpbWFyeWRhdGEuY29tPiB3cm90ZToNCj4+IA0K
Pj4+IE9uIFNlcCAyMywgMjAxNiwgYXQgMTM6NTksIE9sZ2EgS29ybmlldnNrYWlhIDxhZ2xvQHVt
aWNoLmVkdT4gd3JvdGU6DQo+Pj4gDQo+Pj4gT24gRnJpLCBTZXAgMjMsIDIwMTYgYXQgMTo0NSBQ
TSwgVHJvbmQgTXlrbGVidXN0DQo+Pj4gPHRyb25kbXlAcHJpbWFyeWRhdGEuY29tPiB3cm90ZToN
Cj4+Pj4gDQo+Pj4+PiBPbiBTZXAgMjMsIDIwMTYsIGF0IDEzOjQwLCBPbGdhIEtvcm5pZXZza2Fp
YSA8YWdsb0B1bWljaC5lZHU+IHdyb3RlOg0KPj4+Pj4gDQo+Pj4+PiBJZiB3ZSBpbnN0ZWFkIGJ1
bXAgdGhlIHNlcXVlbmNlIG51bWJlciBpbiB0aGUgY2FzZSBvZiBpbnRlcnJ1cHRlZCBhbmQgZG86
DQo+Pj4+IA0KPj4+PiBZb3UgaGF2ZSBubyBndWFyYW50ZWVzIHRoYXQgdGhlIHNlcnZlciBoYXMg
c2VlbiBhbmQgcHJvY2Vzc2VkIHRoZSBvcGVyYXRpb24uDQo+Pj4gDQo+Pj4gVGhhdCBpcyBjb3Jy
ZWN0LCBpIGhhdmUgdGVzdGVkIHRoZSBwYXRjaCBhbmQgbWFkZSBzZXJ2ZXIgbmV2ZXIgdG8NCj4+
PiByZWNlaXZlIHRoZSBvcGVyYXRpb24gYW5kIGNsaWVudCBoYXZlIGFuIGludGVycnVwdGVkIHNs
b3QuIE9uIHRoZSBuZXh0DQo+Pj4gb3BlcmF0aW9uIHRoZSBzZXJ2ZXIgd2lsbCBjb21wbGFpbiBi
YWNrIHdpdGggU0VRX01JU09SREVSRUQuIENsaWVudA0KPj4+IGNhbiByZWNvdmVyIGZyb20gdGhp
cyBvcGVyYXRpb24uIENsaWVudCBjYW4gbm90IHJlY292ZXIgZnJvbSAiUmVtb3RlDQo+Pj4gRUlP
4oCdLg0KPj4+IA0KPj4gDQo+PiBXaHkgbm90Pw0KPiANCj4gV2hlbiBYRFIgbGF5ZXIgcmV0dXJu
cyBFUkVNT1RFSU8gaXQncyBub3QgaGFuZGxlZCBieSB0aGUgTkZTIGVycm9yDQo+IHJlY292ZXJ5
IChhcmUgeW91IHN1Z2dlc3Rpbmcgd2Ugc2hvdWxkPykgIGFuZCByZXR1cm5zIHRoYXQgdG8gdGhl
DQo+IGFwcGxpY2F0aW9uLg0KPiANCg0KSeKAmW0gc2F5aW5nIHRoYXQgaWYgd2UgZ2V0IGEgU0VR
X01JU09SREVSRUQgZHVlIHRvIGEgcHJldmlvdXMgaW50ZXJydXB0IG9uIHRoYXQgc2xvdCwgdGhl
biB3ZSBzaG91bGQgaWdub3JlIHRoZSBlcnJvciBpbiB0YXNrLT50a19zdGF0dXMsIGFuZCBqdXN0
IHJldHJ5IGFmdGVyIGJ1bXBpbmcgdGhlIHNsb3Qgc2VxaWQuDQoNCg==

