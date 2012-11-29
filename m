Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33940 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755163Ab2K2VJ4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2012 16:09:56 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: simo <idra@samba.org>
CC: Stef Bon <stefbon@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>
Subject: Re: Possible to make nfs aware of a inotify watch has been set.
Date: Thu, 29 Nov 2012 21:09:54 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA90B32D9D4@SACEXCMBX04-PRD.hq.netapp.com>
References: <CANXojcy9thLBwrENTkOTSSE17L3N17A8XsTmyNqq3oNdhW_Q_w@mail.gmail.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA90B329CFD@SACEXCMBX04-PRD.hq.netapp.com>
	 <CANXojcxR9673fRObMLPSScogAN05RSVhPFoni=ENc6YDWq9T7w@mail.gmail.com>
	 <1354202525.4064.1.camel@pico.ipa.ssimo.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA90B32AEB7@SACEXCMBX04-PRD.hq.netapp.com>
	 <CANXojcys4wR8N-R3oSjWRWJLsObn0Qf+i41vBUaNnJctdcrKVw@mail.gmail.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA90B32B2A0@SACEXCMBX04-PRD.hq.netapp.com>
	 <1354219557.4064.7.camel@pico.ipa.ssimo.org>
In-Reply-To: <1354219557.4064.7.camel@pico.ipa.ssimo.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTExLTI5IGF0IDE1OjA1IC0wNTAwLCBzaW1vIHdyb3RlOg0KPiBPbiBUaHUs
IDIwMTItMTEtMjkgYXQgMTc6MTEgKzAwMDAsIE15a2xlYnVzdCwgVHJvbmQgd3JvdGU6DQo+ID4g
VGhlIGlkZWEgdGhhdCAiaWYgd2UgYnVpbGQgYSBicmlkZ2UsIHRoZXkgd2lsbCBjb21lIHRvIHVz
IiBpcyB3aGF0DQo+ID4gZ2F2ZQ0KPiA+IHJpc2UgdG8gZG5vdGlmeSwgdGhlbiBpbm90aWZ5IChu
b2JvZHkgY2FtZSwgc28gbGV0J3MgYnVpbGQgYSBiaWdnZXINCj4gPiBicmlkZ2UpIGFuZCBmc25v
dGlmeSAobWFrZSBpdCBhIHRvbGwgYnJpZGdlKS4gTm9ib2R5IGlzIHVzaW5nIHRob3NlDQo+ID4g
aW50ZXJmYWNlcyBtdWNoIG9uIGxvY2FsIGZpbGVzeXN0ZW1zLCBzbyB3aHkgaXMgYWRkaW5nIGl0
IHRvIE5GUyBhbmQNCj4gPiBDSUZTIGdvaW5nIHRvIGJlIHN1Y2ggYSBnYW1lIGNoYW5nZXI/DQo+
IA0KPiBTb3JyeSBUcm9uZCwNCj4gYnV0IHRoaXMgaXMgc2ltcGx5IG5vdCB0cnVlLg0KPiANCj4g
aW5vdGlmeSBpcyBhIGtleSBmZWF0dXJlIGF0IGxlYXN0IGluIHNvbWUgcGFja2FnZXMgSSBrbm93
LCBhbmQgbWFrZXMNCj4gc29tZSB0aGluZ3MgKmEgbG90KiBlYXNpZXIuDQo+IA0KPiBPZiBjb3Vy
c2UgdGhpcyBhcmUgbGVzcyB2aXNpYmxlIGZlYXR1cmVzLCB0aGF0IGFyZSBlYXN5IHRvIG92ZXJs
b29rLCBidXQNCj4gdGhleSBhcmUgbm90IHVudXNlZCBmb3Igc3VyZS4NCg0KU28gd2h5IGlzIGl0
IHNvIGRpZmZpY3VsdCBmb3IgYW55b25lIGluIHRoaXMgdGhyZWFkIHRvIG5hbWUgdGhlc2Uga2ls
bGVyDQphcHBsaWNhdGlvbnMgdGhhdCB3b3VsZCBiZW5lZml0IGZyb20gTkZTK0NJRlMgc3VwcG9y
dD8gSSBrZWVwIGFza2luZywNCmFuZCBhbGwgSSBnZXQgaXMgd2lzaHktd2FzaHkgYW5kIGhhbmQt
d2F2eSBhbnN3ZXJzLg0KDQpXaXRob3V0IHVzZSBjYXNlcywgdGhlcmUgaXMgbm90aGluZyB0byBk
aXNjdXNzIG9uIHRoZSBpbXBsZW1lbnRhdGlvbg0KZnJvbnQuDQoNCi0tIA0KVHJvbmQgTXlrbGVi
dXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1
c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
