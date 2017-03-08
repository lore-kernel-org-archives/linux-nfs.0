Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:33403 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752177AbdCHU2E (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Mar 2017 15:28:04 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        "kolga@netapp.com" <kolga@netapp.com>
CC: "hch@infradead.org" <hch@infradead.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
Date: Wed, 8 Mar 2017 20:18:31 +0000
Message-ID: <1489004308.3098.10.camel@primarydata.com>
References: <20170302160123.30375-1-kolga@netapp.com>
         <20170302160123.30375-2-kolga@netapp.com>
         <20170302162221.GA6854@infradead.org> <20170303204747.GE13877@fieldses.org>
         <20170307234051.GA29977@infradead.org> <20170308170521.GA1020@fieldses.org>
         <20170308172549.GA32011@infradead.org>
         <7FDA8E80-3C62-48BB-9E2B-195B4BA340C0@netapp.com>
         <20170308195327.GA3492@fieldses.org>
         <85310DA6-7270-49AE-A310-76D73678B1B1@netapp.com>
In-Reply-To: <85310DA6-7270-49AE-A310-76D73678B1B1@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE3LTAzLTA4IGF0IDE1OjAwIC0wNTAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gPiBPbiBNYXIgOCwgMjAxNywgYXQgMjo1MyBQTSwgSi4gQnJ1Y2UgRmllbGRzIDxiZmll
bGRzQGZpZWxkc2VzLm9yZz4NCj4gPiB3cm90ZToNCj4gPiANCj4gPiBPbiBXZWQsIE1hciAwOCwg
MjAxNyBhdCAxMjozMjoxMlBNIC0wNTAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90ZToNCj4gPiA+
IA0KPiA+ID4gPiBPbiBNYXIgOCwgMjAxNywgYXQgMTI6MjUgUE0sIENocmlzdG9waCBIZWxsd2ln
IDxoY2hAaW5mcmFkZWFkLm8NCj4gPiA+ID4gcmc+DQo+ID4gPiA+IHdyb3RlOg0KPiA+ID4gPiAN
Cj4gPiA+ID4gT24gV2VkLCBNYXIgMDgsIDIwMTcgYXQgMTI6MDU6MjFQTSAtMDUwMCwgSi4gQnJ1
Y2UgRmllbGRzDQo+ID4gPiA+IHdyb3RlOg0KPiA+ID4gPiA+IFNpbmNlIGNvcHkgaXNuJ3QgYXRv
bWljIHRoYXQgY2hlY2sgaXMgbmV2ZXIgZ29pbmcgdG8gYmUNCj4gPiA+ID4gPiByZWxpYWJsZS4N
Cj4gPiA+ID4gDQo+ID4gPiA+IFRoYXQncyB0cnVlIGZvciBldmVyeXRoaW5nIHRoYXQgQ09QWSBk
b2VzLsKgwqBCeSB0aGF0IGxvZ2ljIHdlDQo+ID4gPiA+IHNob3VsZA0KPiA+ID4gPiBub3QgaW1w
bGVtZW50IGl0IGF0IGFsbCAoYSBsb2dpYyB0aGF0IEknZCBmdWxseSBzdXBwb3J0KQ0KPiA+ID4g
DQo+ID4gPiBJZiB5b3Ugd2VyZSB0byBvbmx5IGtlZXAgQ0xPTkUgdGhlbiB5b3XigJlkIGxvc2Ug
YSBodWdlIHBlcmZvcm1hbmNlDQo+ID4gPiBnYWluDQo+ID4gPiB5b3UgZ2V0IGZyb20gc2VydmVy
LXRvLXNlcnZlciBDT1BZLsKgDQo+ID4gDQo+ID4gWWVzLsKgwqBBbHNvLCBJIHRoaW5rIGNvcHkt
bGlrZSBjb3B5IGltcGxlbWVudGF0aW9ucyBoYXZlIHJlYXNvbmFibGUNCj4gPiBzZW1hbnRpY3Mg
dGhhdCBhcmUgYmFzaWNhbGx5IHRoZSBzYW1lIGFzIHJlYWQ6DQo+ID4gDQo+ID4gCS0gY29weSBj
YW4gcmV0dXJuIHN1Y2Nlc3NmdWxseSB3aXRoIGxlc3MgY29waWVkIHRoYW4gcmVxdWVzdGVkLg0K
PiA+IAktIGl0J3MgZmluZSBmb3IgdGhlIGNvcGllZCByYW5nZSB0byBzdGFydCBhbmQvb3IgZW5k
IHBhc3QgZW5kDQo+ID4gb2YNCj4gPiAJwqDCoGZpbGUsIGl0J2xsIGp1c3QgcmV0dXJuIGEgc2hv
cnQgcmVhZC4NCj4gPiAJLSBBIGNvcHkgb2YgbW9yZSB0aGFuIDAgYnl0ZXMgcmV0dXJuaW5nIDAg
bWVhbnMgeW91J3JlIGF0IGVuZA0KPiA+IG9mDQo+ID4gCcKgwqBmaWxlLg0KPiA+IA0KPiA+IFRo
ZSBwYXJ0aWN1bGFyIHByb2JsZW0gaGVyZSBpcyB0aGF0IHRoYXQgZG9lc24ndCBmaXQgaG93IGNs
b25lDQo+ID4gd29ya3MgYXQNCj4gPiBhbGwuDQo+ID4gDQo+ID4gSXQgZmVlbHMgbGlrZSB3aGF0
IGhhcHBlbmVkIGlzIHRoYXQgY29weV9maWxlX3JhbmdlKCkgd2FzIG1hZGUNCj4gPiBtYWlubHkN
Cj4gPiBmb3IgdGhlIGNsb25lIGNhc2UsIHdpdGggdGhlIGlkZWEgdGhhdCBjb3B5IG1pZ2h0IGJl
IHJlbHVjdGFudGx5DQo+ID4gYWNjZXB0ZWQgYXMgYSBzZWNvbmQtY2xhc3MgaW1wbGVtZW50YXRp
b24uDQoNCkhpc3RvcmljYWxseT8gTm8uLi4gQ2hyaXN0b3BoIGFkZGVkIGNsb25lIGFzIGEgdmFs
aWQgaW1wbGVtZW50YXRpb24gb2YNCmNvcHlfZmlsZV9yYW5nZSgpIGFsbW9zdCBhIHllYXIgYWZ0
ZXIgWmFjaCBhbmQgQW5uYSBkZWZpbmVkIHRoZQ0Kc2VtYW50aWNzIG9mIHZmc19jb3B5X2ZpbGVf
cmFuZ2UoKS4gZ2l0IGJsYW1lIGlzIHlvdXIgZnJpZW5kLi4uDQoNCj4gPiANCj4gPiBCdXQgdGhl
IHBlcmZvcm1hbmNlIGdhaW4gb2YgY29weSBvZmZsb2FkIGlzIHRvbyBiaWcgdG8ganVzdCBpZ25v
cmUsDQo+ID4gYW5kDQo+ID4gaW4gZmFjdCBpdCdzIHdoYXQgY29weV9maWxlX3JhbmdlIGRvZXMg
b24gZXZlcnkgZmlsZXN5c3RlbSBidXQNCj4gPiBidHJmcyBhbmQNCj4gPiBvY2ZzMiAoYW5kIG1h
eWJlIGNpZnM/KSwgc28gSSBkb24ndCB0aGluayB3ZSBjYW4ganVzdCBpZ25vcmUgaXQuDQo+ID4g
DQo+ID4gSWYgd2UgaGFkIHNlcGFyYXRlIGNvcHlfZmlsZV9yYW5nZSBhbmQgY2xvbmVfZmlsZV9y
YW5nZSwgSSAqdGhpbmsqDQo+ID4gaXQNCj4gPiBjb3VsZCBhbGwgYmUgbWFkZSBzZW5zaWJsZS7C
oMKgQW0gSSBtaXNzaW5nIHNvbWV0aGluZz8NCj4gPiANCj4gDQo+IEhvdyB3b3VsZCB0aGUgYXBw
bGljYXRpb24gKGNwKSBrbm93IHdoZW4gdG8gY2FsbCB0aGUgY2xvbmVfZmlsZV9yYW5nZQ0KPiBh
bmQgd2hlbiB0byBjYWxsIGNvcHlfZmlsZV9yYW5nZT8NCg0KY3AgY2FuIHByb2JhYmx5IGNhbGwg
Y29weV9maWxlX3JhbmdlKCksIGJ1dCBhbnkgYXBwbGljYXRpb24gdGhhdCBuZWVkcw0KYXRvbWlj
IHNlbWFudGljcyAoaS5lLiBhIGJpbmFyeSBvcGVyYXRpb24gc3VjY2Vzcy9mYWlsKSBtdXN0IGNh
bGwNCmNsb25lX2ZpbGVfcmFuZ2UoKS4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5G
UyBjbGllbnQgbWFpbnRhaW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5
ZGF0YS5jb20NCg==

