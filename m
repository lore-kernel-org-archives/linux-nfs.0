Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:24888 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423552Ab2KOSXS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Nov 2012 13:23:18 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>
CC: DENIEL Philippe <philippe.deniel@cea.fr>,
        "Matt W. Benjamin" <matt@linuxbox.com>,
        Tomasz Chmielewski <mangoo@wpkg.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: xattr support in NFS?
Date: Thu, 15 Nov 2012 18:23:15 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9092E3391@SACEXCMBX04-PRD.hq.netapp.com>
References: <939474821.100.1352749795732.JavaMail.root@thunderbeast.private.linuxbox.com>
	 <50A1FCB2.9090502@cea.fr>
	 <CAGue13o69+M4zDrHj3Cs5dSJz_bT49UPoBO=QKr+JCnXwYgcqg@mail.gmail.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9092DFB2C@SACEXCMBX04-PRD.hq.netapp.com>
	 <CAGue13puoByUyEn6WAP4z+Csom7chv3VUsSAmb-ZP0gN7DaKTA@mail.gmail.com>
In-Reply-To: <CAGue13puoByUyEn6WAP4z+Csom7chv3VUsSAmb-ZP0gN7DaKTA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTExLTE1IGF0IDE4OjUxICswMTAwLCBUaWdyYW4gTWtydGNoeWFuIHdyb3Rl
Og0KPiANCj4gT24gV2VkLCBOb3YgMTQsIDIwMTIgYXQgNDowMyBQTSwgTXlrbGVidXN0LCBUcm9u
ZA0KPiA8VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20+IHdyb3RlOg0KPiAgICAgICAgIE9uIFdl
ZCwgMjAxMi0xMS0xNCBhdCAxMTo0NyArMDEwMCwgVGlncmFuIE1rcnRjaHlhbiB3cm90ZToNCj4g
ICAgICAgICA+IFRoYXQncyBiYWQgbmV3cy4uLi4gQ3VycmVudGx5IHdlIHVzZSAnbWFnaWMgZmls
ZXMnIHRvDQo+ICAgICAgICAgc2V0L2dldCB1c2VyDQo+ICAgICAgICAgPiBzcGVjaWZpYyBtZXRh
ZGF0YSBsaWtlIG51bWJlciBvZiBldmVudHMsIHNwYWNlIHJlc2VydmF0aW9uDQo+ICAgICAgICAg
ICAgYW5kDQo+ICAgICAgICAgPiBkaWZmZXJlbnQgZmlsZSByZXRlbnRpb24gcG9saWNpZXMuIFRo
ZSBob3BlIHdhcyB0aGF0IGFsbA0KPiAgICAgICAgIGNvdWxkIGJlIGRvbmUNCj4gICAgICAgICA+
IHdpdGggbmFtZWQgYXR0cmlidXRlcy4NCj4gICAgICAgICA+DQo+ICAgICAgICAgPiAgVGlncmFu
Lg0KPiAgICAgICAgID4NCj4gICAgICAgICANCj4gICAgICAgICANCj4gICAgICAgICBUaGUgc2V0
dGluZyBhbmQgcXVlcnlpbmcgb2YgcmV0ZW50aW9uIHBvbGljaWVzIGlzIGFscmVhZHkNCj4gICAg
ICAgICBjb3ZlcmVkIGluIHRoZQ0KPiAgICAgICAgIE5GU3Y0LjEgcHJvdG9jb2wgd2l0aG91dCBh
bnkgbmVlZCBmb3IgYW55IGFkZGl0aW9ucy4gU3BhY2UNCj4gICAgICAgICByZXNlcnZhdGlvbg0K
PiAgICAgICAgIGlzIGFscmVhZHkgY292ZXJlZCBpbiBORlN2NC4yIChhcyBhcmUgc2VjdXJpdHkg
bGFiZWxzIC0NCj4gICAgICAgICBhbm90aGVyIGNvbW1vbg0KPiAgICAgICAgIGhvYmJ5LWhvcnNl
IGZvciB4YXR0ciBhZHZvY2F0ZXMpLiBXaHkgZG9uJ3QgeW91IGltcGxlbWVudA0KPiAgICAgICAg
IHRob3NlIGluc3RlYWQNCj4gICAgICAgICBvZiB3aXNoaW5nIGZvciBhIGNvbXBsZXRlbHkgZGlm
ZmVyZW50IHdheSBvZiBkb2luZyB0aGUgc2FtZQ0KPiAgICAgICAgIHRoaW5nPw0KPiAgICAgICAg
IA0KPiANCj4gDQo+IEJlIGNhdXNlIHRoZSBvbmx5IHRvb2wgd2hpY2ggSSBoYXZlIG9uIHRoZSBj
bGllbnQgc2lkZSBpcyBzZXQvZ2V0DQo+IHhhdHRyLg0KDQpZb3UncmUgbm90IHdyaXRpbmcgYSBj
bGllbnQ7IHlvdSdyZSB3cml0aW5nIGEgc2VydmVyLg0KDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0
DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RA
bmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
