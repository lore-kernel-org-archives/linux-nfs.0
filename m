Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50793 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752588Ab2A3UuN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jan 2012 15:50:13 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
CC: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "rdunlap@xenotime.net" <rdunlap@xenotime.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "xemul@parallels.com" <xemul@parallels.com>,
        "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jbottomley@parallels.com" <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 1/2] SUNRPC: register RPC stats /proc entries in passed
 network namespace context
Date: Mon, 30 Jan 2012 20:49:49 +0000
Message-ID: <1327956588.4090.26.camel@lade.trondhjem.org>
References: <20111206123748.15702.93290.stgit@localhost6.localdomain6>
	 <20111206124240.15702.61866.stgit@localhost6.localdomain6>
	 <CAP=VYLoTsFvqez72mLEctmrcHbf0VcfREbHF32zsnh35=RUsHQ@mail.gmail.com>
In-Reply-To: <CAP=VYLoTsFvqez72mLEctmrcHbf0VcfREbHF32zsnh35=RUsHQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTAxLTMwIGF0IDEzOjI5IC0wNTAwLCBQYXVsIEdvcnRtYWtlciB3cm90ZToN
Cj4gT24gVHVlLCBEZWMgNiwgMjAxMSBhdCA4OjQyIEFNLCBTdGFuaXNsYXYgS2luc2J1cnNreQ0K
PiA8c2tpbnNidXJza3lAcGFyYWxsZWxzLmNvbT4gd3JvdGU6DQo+ID4gVGhpcyBwYXRjaCBtYWtl
cyBpdCBwb3NzaWJsZSB0byBjcmVhdGUgTkZTIHByb2dyYW0gZW50cnkgKCIvcHJvYy9uZXQvcnBj
L25mcyIpDQo+ID4gaW4gcGFzc2VkIG5ldHdvcmsgbmFtZXNwYWNlIGNvbnRleHQgaW5zdGVhZCBv
ZiBoYXJkLWNvZGVkICJpbml0X25ldCIuDQo+IA0KPiBIaSBUcm9uZCwNCj4gDQo+IElzIHRoaXMg
cGF0Y2ggZ29pbmcgdG8gYmUgZHJvcHBlZCBhbmQgcmUtc3VibWl0dGVkPyAgIEl0IGhhcyBvYnZp
b3VzDQo+IHR5cG9zIHRoYXQgaGF2ZSBiZWVuIGNhdXNpbmcgcmVwb3J0ZWQgYnVpbGQgZmFpbHVy
ZXNbMV0gaW4gbGludXgtbmV4dA0KPiBmb3IgYSB3ZWVrIG5vdy4gICBJbiBhZGRpdGlvbiB0byB0
aGF0LCBpdCBoYXMgc2V2ZXJhbCB3aGl0ZXNwYWNlIGVycm9ycw0KPiAobG9uZyBsaW5lcywgbm8g
c3BhY2UgYWZ0ZXIgY29tbWEsIGV0Yy4pIHRoYXQgSSBiZXQgY2hlY2twYXRjaC5wbA0KPiB3b3Vs
ZCBoYXZlIGZvdW5kLCBpZiBpdCB3YXMgdXNlZC4NCj4gDQo+IENvbW1pdCA0NDk0Yzc1MDI0MGJh
YjFiYjgzYmQ4ZjRkNWEyNjg2NjNjMzdjOWIzIGluIG5leHQtMjAxMjAxMzAuDQoNCkkndmUgYXBw
bGllZCBSYW5keSdzIGZpeCB0byBteSB0cmVlLiBTb3JyeSBpdCB0b29rIHNvIGxvbmcsIGJ1dCBJ
IHdhcw0KdHJhdmVsbGluZyBsYXN0IHdlZWsuLi4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxp
bnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRh
cHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
