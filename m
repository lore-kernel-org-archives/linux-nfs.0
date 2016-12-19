Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:32719 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752651AbcLSA2j (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Dec 2016 19:28:39 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: NeilBrown <neilb@suse.com>
CC: Olga Kornievskaia <aglo@umich.edu>,
        William Andros Adamson <andros@netapp.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>,
        "Adamson@suse.com" <Adamson@suse.com>,
        William Andros Adamson <William.Adamson@netapp.com>
Subject: Re: [PATCH resend] NFSv4.1: nfs4_fl_prepare_ds must be careful about
 reporting success.
Date: Mon, 19 Dec 2016 00:28:32 +0000
Message-ID: <7AC22ABA-C13B-4987-92F4-5347C82481AA@primarydata.com>
References: <87lgxiwoxi.fsf@notabene.neil.brown.name>
 <8760nlfkkq.fsf@notabene.neil.brown.name>
 <C9C69F9A-F0AD-4F76-B334-11C4E83D4155@primarydata.com>
 <CAN-5tyH+4=9y9a3v0po5-cW+5ABSp5Z1pXN=+eTZSnd0KORk2Q@mail.gmail.com>
 <87wpg0dlnb.fsf@notabene.neil.brown.name>
 <CAN-5tyFfnSxcnFjpcCqT--qQhpHa-37NnVXuX70imE1WiyFFNg@mail.gmail.com>
 <8760mgvkh8.fsf@notabene.neil.brown.name>
In-Reply-To: <8760mgvkh8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIERlYyAxOCwgMjAxNiwgYXQgMTk6MTksIE5laWxCcm93biA8bmVpbGJAc3VzZS5jb20+
IHdyb3RlOg0KPiANCj4gDQo+IFZhcmlvdXMgcGxhY2VzIGFzc3VtZSB0aGF0IGlmIG5mczRfZmxf
cHJlcGFyZV9kcygpIHR1cm5zIGEgbm9uLU5VTEwgJ2RzJywNCj4gdGhlbiBkcy0+ZHNfY2xwIHdp
bGwgYWxzbyBiZSBub24tTlVMTC4NCj4gDQo+IFRoaXMgaXMgbm90IG5lY2Vzc2FzcmlseSB0cnVl
IGluIHRoZSBjYXNlIHdoZW4gdGhlIHByb2Nlc3MgcmVjZWl2ZWQgYSBmYXRhbCBzaWduYWwNCj4g
d2hpbGUgbmZzNF9wbmZzX2RzX2Nvbm5lY3QgaXMgd2FpdGluZyBpbiBuZnM0X3dhaXRfZHNfY29u
bmVjdCgpLg0KPiBJbiB0aGF0IGNhc2UgLT5kc19jbHAgbWF5IG5vdCBiZSBzZXQsIGFuZCB0aGUg
ZGV2aWQgbWF5IG5vdCByZWNlbnRseSBoYXZlIGJlZW4gbWFya2VkDQo+IHVuYXZhaWxhYmxlLg0K
PiANCj4gU28gYWRkIGEgdGVzdCBmb3IgZHNfY2xwID09IE5VTEwgYW5kIHJldHVybiBOVUxMIGlu
IHRoYXQgY2FzZS4NCj4gDQo+IEZpeGVzOiBjMjMyNjZkNTMyYjQgKCJORlM0LjEgRml4IGRhdGEg
c2VydmVyIGNvbm5lY3Rpb24gcmFjZSIpDQo+IFNpZ25lZC1vZmYtYnk6IE5laWxCcm93biA8bmVp
bGJAc3VzZS5jb20+DQo+IEFja2VkLWJ5OiBPbGdhIEtvcm5pZXZza2FpYSA8YWdsb0B1bWljaC5l
ZHU+DQo+IEFja2VkLWJ5OiBBZGFtc29uLCBBbmR5IDxXaWxsaWFtLkFkYW1zb25AbmV0YXBwLmNv
bT4NCj4gLS0tDQo+IA0KPiBIaSBUcm9uZCwNCj4gSSBqdXN0IG5vdGljZWQgdGhhdCB0aGlzIHdh
c24ndCBpbiB5b3VyIDQuMTAgcHVsbCByZXF1ZXN0LiAgU28gSSd2ZQ0KPiBhZGRlZCBBY2tlZC1i
eXMgZnJvbSBBbmR5IGFuZCBPbGdhIGFuZCBhbSByZXNlbmRpbmcuDQo+IA0KDQpTb3JyeSBmb3Ig
aGF2aW5nIG1pc3NlZCB0aGVpciBBY2tlZC1ieXMgZWFybGllcuKApiBJ4oCZbGwgc2VuZCB0aGlz
IHRvZ2V0aGVyIHdpdGggdGhlIG90aGVyIDEwIHBhdGNoZXMgdG9tb3Jyb3cuDQoNCkNoZWVycw0K
ICBUcm9uZA0KDQo=

