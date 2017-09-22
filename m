Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:55386 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752115AbdIVVS5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Sep 2017 17:18:57 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "smayhew@redhat.com" <smayhew@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: override uid and gid for exclusive creates in
 nfs3_proc_create
Date: Fri, 22 Sep 2017 21:18:53 +0000
Message-ID: <1506115132.2557.3.camel@primarydata.com>
References: <20170922201551.15222-1-smayhew@redhat.com>
In-Reply-To: <20170922201551.15222-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE3LTA5LTIyIGF0IDE2OjE1IC0wNDAwLCBTY290dCBNYXloZXcgd3JvdGU6DQo+
IFJGQyAxODEzIHNlY3Rpb24gMy4zLjggc3RhdGVzDQo+IA0KPiAgICAgICBPbmNlIHRoZSBjbGll
bnQgaGFzIHBlcmZvcm1lZCBhIHN1Y2Nlc3NmdWwgZXhjbHVzaXZlDQo+ICAgICAgIGNyZWF0ZSwg
aXQgbXVzdCBpc3N1ZSBhIFNFVEFUVFIgdG8gc2V0IHRoZSBjb3JyZWN0IGZpbGUNCj4gICAgICAg
YXR0cmlidXRlcy4gIFVudGlsIGl0IGRvZXMgc28sIGl0IHNob3VsZCBub3QgcmVseSB1cG9uIGFu
eQ0KPiAgICAgICBvZiB0aGUgZmlsZSBhdHRyaWJ1dGVzLCBzaW5jZSB0aGUgc2VydmVyIGltcGxl
bWVudGF0aW9uDQo+ICAgICAgIG1heSBuZWVkIHRvIG92ZXJsb2FkIGZpbGUgbWV0YWRhdGEgdG8g
c3RvcmUgdGhlIHZlcmlmaWVyLg0KPiANCj4gSFAtVVggZXhwZWN0cyB0aGUgY2xpZW50IHRvIHNl
bmQgdGhlIHVpZCBhbmQgZ2lkIGluIHRoZSBwb3N0LWNyZWF0ZQ0KPiBzZXRhdHRyIGZvciBleGNs
dXNpdmUgY3JlYXRlcy4gIEN1c3RvbWVycyBhcmUgc29tZXRpbWVzIHNlZWluZyBib2d1cw0KPiB2
YWx1ZXMgYmVjYXVzZSB0aGUgTGludXggTkZTIGNsaWVudCBpcyBvbmx5IHVwZGF0aW5nIHRoZSBh
dGltZSBhbmQNCj4gbXRpbWUuDQoNCkknbSBzb3JyeSwgYnV0IHRoYXQgaXMganVzdCBpbnNhbmVs
eSBzdHVwaWQgc2VydmVyIGJlaGF2aW91ci4gSG93IGRvDQp5b3UgZ3VhcmFudGVlIHRoYXQgYSBz
ZWNvbmQgY2xpZW50IHdvbid0IGhpamFjayB0aGUgZmlsZSBieSBzZW5kaW5nDQp0aGVpciBvd24g
U0VUQVRUUiBjYWxsIGJlZm9yZSB5b3VyIGNsaWVudCBoYXMgYW4gb3Bwb3J0dW5pdHkgdG8gc2V0
IHRoZQ0Kb3duZXI/DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1h
aW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

