Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38666 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753451Ab2HNAtT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Aug 2012 20:49:19 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Peng Tao <bergwolf@gmail.com>, Benny Halevy <bhalevy@tonian.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "Welch, Brent" <welch@panasas.com>,
        Garth Gibson <garth.gibson@panasas.com>
Subject: Re: [PATCH] NFSv4.1: Remove a bogus BUG_ON() in
 nfs4_layoutreturn_done
Date: Tue, 14 Aug 2012 00:49:01 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA93A08A8@SACEXCMBX04-PRD.hq.netapp.com>
References: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>
	    <CA+a=Yy7SX+cPLFiNy552bU9ZMS_rSwvaSpV732_mDwpcPAH5Wg@mail.gmail.com>
	    <1344522979.23523.2.camel@lade.trondhjem.org>
	    <CA+a=Yy7tDi0kQGvjPeb=O_9XMnZDm-_31VTkNF7wEW7Pb0BZow@mail.gmail.com>
	   <1344526780.25447.6.camel@lade.trondhjem.org>
	   <5027E98B.7050603@panasas.com>
	  <4FA345DA4F4AE44899BD2B03EEEC2FA939C3E7@SACEXCMBX04-PRD.hq.netapp.com>
	  <50299041.2040302@panasas.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA93A064E@SACEXCMBX04-PRD.hq.netapp.com>
	 <50299BAA.40909@panasas.com>
In-Reply-To: <50299BAA.40909@panasas.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA4LTE0IGF0IDAzOjI4ICswMzAwLCBCb2F6IEhhcnJvc2ggd3JvdGU6DQo+
IE9uIDA4LzE0LzIwMTIgMDM6MTYgQU0sIE15a2xlYnVzdCwgVHJvbmQgd3JvdGU6DQo+IA0KPiA+
IA0KPiA+IFRoZSBjbGllbnQgY2FuJ3QgZ3VhcmFudGVlIHRoYXQuIFRoZSBwcm90b2NvbCBvZmZl
cnMgbm8gd2F5IGZvciBpdCB0byBkbw0KPiA+IHNvLCBubyBtYXR0ZXIgd2hhdCB0aGUgcE5GUyB0
ZXh0IG1heSBjaG9vc2UgdG8gc2F5Lg0KPiA+IA0KPiANCj4gDQo+IFdoYXQ/IHdoeSBub3Q/IGFs
bCB0aGUgY2xpZW50IG5lZWRzIHRvIGRvIGlzIHN0b3Agc2VuZGluZyBieXRlcy4NCj4gV2hhdCBp
cyBub3QgZ3VhcmFudGllZD8gSSBjb21wbGV0ZWx5IGRvIG5vdCB1bmRlcnN0YW5kIHdoYXQgeW91
DQo+IHNheS4gSG93IHN0b3BwaW5nIGFueSBzZW5kcyBkb2VzIG5vdCBndWFyYW50eSB0aGF0Pw0K
DQpJZiB0aGUgY2xpZW50IGhhcyBsb3N0IGNvbnRyb2wgb2YgdGhlIHRyYW5zcG9ydCwgdGhlbiBp
dCBoYXMgbm8gY29udHJvbA0Kb3ZlciB3aGF0IHRoZSBkYXRhIHNlcnZlciBzZWVzIGFuZCB3aGVu
LiBJdCBjYW4gcHJvY2VzcyB0aGUgY2xpZW50J3MNCndyaXRlIFJQQyA1IG1pbnV0ZXMgZnJvbSBu
b3csIGFuZCBpdCB3aWxsIG5ldmVyIGtub3cuDQoNClRIQVQgaXMgd2hhdCBpcyBhYnN1cmQgYWJv
dXQgdGhlIHdob2xlICJ0aGUgY2xpZW50IE1VU1QgTk9UIHNlbmQuLi4iDQpzaGViYW5nLg0KVEhB
VCBpcyB3aHkgdGhlcmUgaXMgbm8gZ3VhcmFudGVlLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0K
TGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5l
dGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
