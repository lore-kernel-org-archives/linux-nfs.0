Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:28832 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755468AbdIGPMK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Sep 2017 11:12:10 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "tarangg@amazon.com" <tarangg@amazon.com>
CC: "jsstraus@amazon.com" <jsstraus@amazon.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFS: Sync the correct byte range during synchronous
 writes
Date: Thu, 7 Sep 2017 15:12:05 +0000
Message-ID: <1504797123.7816.0.camel@primarydata.com>
References: <20170907132923.49969-1-tarangg@amazon.com>
In-Reply-To: <20170907132923.49969-1-tarangg@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE3LTA5LTA3IGF0IDA5OjI5IC0wNDAwLCB0YXJhbmdnQGFtYXpvbi5jb20gd3Jv
dGU6DQo+IFNpbmNlIGNvbW1pdCAxODI5MDY1MGIxYzggKCJORlM6IE1vdmUgYnVmZmVyZWQgSS9P
IGxvY2tpbmcgaW50bw0KPiBuZnNfZmlsZV93cml0ZSgpIikgbmZzX2ZpbGVfd3JpdGUoKSBoYXMg
bm90IGZsdXNoZWQgdGhlIGNvcnJlY3QgYnl0ZQ0KPiByYW5nZSBkdXJpbmcgc3luY2hyb25vdXMg
d3JpdGVzLiAgZ2VuZXJpY193cml0ZV9zeW5jKCkgZXhwZWN0cyB0aGF0DQo+IGlvY2ItPmtpX3Bv
cyBwb2ludHMgdG8gdGhlIHJpZ2h0IGVkZ2Ugb2YgdGhlIHJhbmdlIHJhdGhlciB0aGFuIHRoZQ0K
PiBsZWZ0IGVkZ2UuDQo+IA0KPiBUbyByZXBsaWNhdGUgdGhlIHByb2JsZW0sIG9wZW4gYSBmaWxl
IHdpdGggT19EU1lOQywgaGF2ZSB0aGUgY2xpZW50DQo+IHdyaXRlIGF0IGluY3JlYXNpbmcgb2Zm
c2V0cywgYW5kIHRoZW4gcHJpbnQgdGhlIHN1Y2Nlc3NmdWwgb2Zmc2V0cy4NCj4gQmxvY2sgcG9y
dCAyMDQ5IHBhcnR3YXkgdGhyb3VnaCB0aGF0IHNlcXVlbmNlLCBhbmQgb2JzZXJ2ZSB0aGF0IHRo
ZQ0KPiBjbGllbnQgYXBwbGljYXRpb24gaW5kaWNhdGVzIHN1Y2Nlc3NmdWwgd3JpdGVzIGluIGFk
dmFuY2Ugb2Ygd2hhdCB0aGUNCj4gc2VydmVyIHJlY2VpdmVkLg0KPiANCj4gRml4ZXM6IDE4Mjkw
NjUwYjFjOCAoIk5GUzogTW92ZSBidWZmZXJlZCBJL08gbG9ja2luZyBpbnRvDQo+IG5mc19maWxl
X3dyaXRlKCkiKQ0KPiBTaWduZWQtb2ZmLWJ5OiBKYWNvYiBTdHJhdXNzIDxqc3N0cmF1c0BhbWF6
b24uY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBUYXJhbmcgR3VwdGEgPHRhcmFuZ2dAYW1hem9uLmNv
bT4NCj4gVGVzdGVkLWJ5OiBUYXJhbmcgR3VwdGEgPHRhcmFuZ2dAYW1hem9uLmNvbT4NCg0KVGhh
bmtzISBOaWNlIGNhdGNoIQ0KDQpQYXRjaCBpcyBhcHBsaWVkIGFuZCB3aWxsIGJlIHF1ZXVlZCBm
b3Igc3RhYmxlIDQuOCsuLi4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGll
bnQgbWFpbnRhaW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5j
b20NCg==

