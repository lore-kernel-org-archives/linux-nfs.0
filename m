Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx01.eckelmann.de ([217.19.183.92]:56442 "EHLO
        mx01.eckelmann.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751092AbeFTFzB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jun 2018 01:55:01 -0400
From: "Schenk, Gavin" <G.Schenk@eckelmann.de>
To: "tglx@linutronix.de" <tglx@linutronix.de>,
        "longman@redhat.com" <longman@redhat.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "mingo@redhat.com" <mingo@redhat.com>
CC: "dan.j.williams@intel.com" <dan.j.williams@intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "arnd@arndb.de" <arnd@arndb.de>,
        "dave@stgolabs.net" <dave@stgolabs.net>
Subject: Re: [Customers.Eckelmann] [PATCH] locking/rwsem: Fix
 up_read_non_owner() warning with DEBUG_RWSEMS
Date: Wed, 20 Jun 2018 05:49:30 +0000
Message-ID: <052d9796f814fc5d6625ac7fcd00dc37b0f11da1.camel@eckelmann.de>
References: <1527168398-4291-1-git-send-email-longman@redhat.com>
         <ba5a8266-b475-0f80-50eb-1ed39ffa6d2a@redhat.com>
In-Reply-To: <ba5a8266-b475-0f80-50eb-1ed39ffa6d2a@redhat.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SGksDQoNCk9uIFdlZCwgMjAxOC0wNi0yMCBhdCAwNzowOSArMDgwMCwgV2FpbWFuIExvbmcgd3Jv
dGU6DQo+IE9uIDA1LzI0LzIwMTggMDk6MjYgUE0sIFdhaW1hbiBMb25nIHdyb3RlOg0KPiA+IEl0
IHdhcyBmb3VuZCB0aGF0IHRoZSB1c2Ugb2YgdXBfcmVhZF9ub25fb3duZXIoKSBpbiBORlMgd2Fz
IGNhdXNpbmcNCj4gPiB0aGUgZm9sbG93aW5nIHdhcm5pbmcgd2hlbiBERUJVR19SV1NFTVMgd2Fz
IGNvbmZpZ3VyZWQuDQo+ID4gDQo+ID4gICBERUJVR19MT0NLU19XQVJOX09OKHNlbS0+b3duZXIg
IT0gKChzdHJ1Y3QgdGFza19zdHJ1Y3QgKikoMVVMIDw8IDApKSkNCj4gPiANCj4gPiBMb29raW5n
IGludG8gdGhlIHJ3c2VtLmMgZmlsZSwgaXQgd2FzIGRpc2NvdmVyZWQgdGhhdCB0aGUgY29ycmVz
cG9uZGluZw0KPiA+IGRvd25fcmVhZF9ub25fb3duZXIoKSBmdW5jdGlvbiB3YXMgbm90IHNldHRp
bmcgdGhlIG93bmVyIGZpZWxkIHByb3Blcmx5Lg0KPiA+IFRoaXMgaXMgZml4ZWQgbm93LCBhbmQg
dGhlIHdhcm5pbmcgc2hvdWxkIGJlIGdvbmUuDQo+ID4gDQo+ID4gU2lnbmVkLW9mZi1ieTogV2Fp
bWFuIExvbmcgPGxvbmdtYW5AcmVkaGF0LmNvbT4NClRlc3RlZC1ieTogR2F2aW4gU2NoZW5rIDxn
LnNjaGVua0BlY2tlbG1hbm4uZGU+DQoNClRoaXMgZml4ZXMgbXkgcmVwcm9kdWNpYmxlIGxvY2tp
bmcgc3BsYXQgd2hlbiBib290aW5nIHdpdGggbmZzcm9vdCBhbmQgY2hhbmdpbmcgcGFzc3dvcmQu
IFRoYW5rIHlvdSENCg0KUmVnYXJkcw0KR2F2aW4gU2NoZW5rDQo=
