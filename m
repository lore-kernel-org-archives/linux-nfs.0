Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:42104 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S945194AbcJaRyx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2016 13:54:53 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Vitaliy Gusev <gusev.vitaliy@gmail.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Schumaker Anna <anna.schumaker@netapp.com>
Subject: Re: [PATCH] NFSv41: fix NULL dereference in nfs40_setup_sequence
Date: Mon, 31 Oct 2016 17:54:40 +0000
Message-ID: <4E199BAA-DBDF-42CE-8B26-AF9787467796@primarydata.com>
References: <0A7143CE-0592-444D-BA53-9CBB33E4373F@gmail.com>
 <5D2E82C6-FBF5-4590-B674-B6C904CBB449@primarydata.com>
 <9CC2D174-84E5-4820-B6B7-AC885753AC91@gmail.com>
In-Reply-To: <9CC2D174-84E5-4820-B6B7-AC885753AC91@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIE9jdCAzMSwgMjAxNiwgYXQgMTM6MzEsIFZpdGFsaXkgR3VzZXYgPGd1c2V2LnZpdGFs
aXlAZ21haWwuY29tPiB3cm90ZToNCj4gDQo+IA0KPj4gT24gMzEgT2N0IDIwMTYsIGF0IDE4OjQ2
LCBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kbXlAcHJpbWFyeWRhdGEuY29tPiB3cm90ZToNCj4+IA0K
Pj4gDQo+Pj4gT24gT2N0IDMwLCAyMDE2LCBhdCAyMToxOCwgVml0YWxpeSBHdXNldiA8Z3VzZXYu
dml0YWxpeUBnbWFpbC5jb20+IHdyb3RlOg0KPj4+IA0KPj4+IEhpLg0KPj4+IA0KPj4+IER1cmlu
ZyBzb21lIHRlc3RzIEnigJl2ZSBzZWVuIG5mcy1jbGllbnQgY3Jhc2hlcy4gSXQgd2FzIGp1c3Qg
cmVhZGluZyBmaWxlIHZpYSBORlN2NC4xIHByb3RvY29sLiANCj4+PiANCj4+PiBUaGUgcGFuaWMg
bWVzc2FnZSBpcyBiZWxvdywgIGZpeGluZyBwYXRjaCBpcyBhdHRhY2hlZC4NCj4+IA0KPj4gV2h5
IGRvZXMgdGhpcyBuZWVkIHRvIGJlIGZpeGVkIG9uIHRoZSBjbGllbnQ/IEl0IGxvb2tzIGxpa2Ug
YSBzZXJ2ZXIgYnVn4oCmIEluIGFueSBjYXNlLCB0aGUgZml4IHlvdSBwcm9wb3NlIGlzIGdvaW5n
IHRvIGxlYXZlIHRoZSBjbGllbnQgd2l0aCBicm9rZW4gb3BlbiBzdGF0ZS4NCj4gDQo+IERvIHlv
dSBsaWtlIHRvIGdldCBjcmFzaCBldmVyeSB0aW1lIGEgcmVtb3RlIHNpZGUgc2VuZHMgaW1wcm9w
ZXIgZGF0YXM/IEkgYmVsaWV2ZSBub3QuDQoNClRoZXJlIGFyZSBhIG1pbGxpb24gb3RoZXIgd2F5
cyB0byBzY3JldyBhIGNsaWVudCBvdmVyIGlmIHlvdXIgc2VydmVyIGlzIGJ1Z2d5IG9yIGNvbXBy
b21pc2VkLg0KDQo+IA0KPiBJIHByb3Bvc2VkIGp1c3QgaWdub3JlIHRoZSBmbGFnIE9QRU40X1JF
U1VMVF9DT05GSVJNICBmb3IgbmZzNC4xKyBjbGllbnRzLg0KPiBSRkM1NjYxIGhhcyBkZXNjcmlw
dGlvbiB0aGF0IGFsbG93cyBhIGNsaWVudCB0byBkbyB0aGF0Og0KPiANCj4gICBvICBPUEVONF9S
RVNVTFRfQ09ORklSTSBpcyBkZXByZWNhdGVkIGFuZCBNVVNUIE5PVCBiZSByZXR1cm5lZCBieSBh
bg0KPiAgICAgICBORlN2NC4xIHNlcnZlci4NCg0KSSBrbm93IHdoYXQgdGhlIHNwZWMgc2F5cy4g
VGhlIHBvaW50IGlzIHRoYXQgdGhlIGNsaWVudCB3aWxsIGxlYWsgbWVtb3J5LCBhbmQgZmFpbCB0
byBoYW5kbGUgdGhlIHNpdHVhdGlvbiBjb3JyZWN0bHkgd2hlbiB0aGUgc2VydmVyIHJldHVybnMg
T1BFTjRfUkVTVUxUX0NPTkZJUk0gd2l0aCBvciB3aXRoIHRoZSBwYXRjaCB0aGF0IHlvdSBhcmUg
cHJvcG9zaW5nLg0KDQpUaGUgcmlnaHQgdGhpbmcgdG8gZG8gaGVyZSB3b3VsZCByYXRoZXIgYmUg
dG8gcHJpbnQgb3V0IGEgYmlnIGZhdCB3YXJuaW5nIHRvIHRoZSB1c2VyLCBhbmQgdGhlbiBwb3Nz
aWJseSBhbHNvIHRvIGtpbGwgdGhlIG1vdW50Lg==

