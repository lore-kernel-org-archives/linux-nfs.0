Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45654 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012Ab2I0QQ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Sep 2012 12:16:29 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Joerg Roedel <joro@8bytes.org>
CC: Joerg Roedel <joerg.roedel@amd.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
Date: Thu, 27 Sep 2012 16:16:25 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF7A3@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120807134156.GP1996@amd.com>
	 <20120927145217.GA18962@8bytes.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF572@SACEXCMBX04-PRD.hq.netapp.com>
	 <20120927153928.GB18962@8bytes.org>
In-Reply-To: <20120927153928.GB18962@8bytes.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTA5LTI3IGF0IDE3OjM5ICswMjAwLCBKb2VyZyBSb2VkZWwgd3JvdGU6DQo+
IE9uIFRodSwgU2VwIDI3LCAyMDEyIGF0IDAzOjMyOjAyUE0gKzAwMDAsIE15a2xlYnVzdCwgVHJv
bmQgd3JvdGU6DQo+IA0KPiA+IERvZXMgeW91ciBjaGVja2VkIG91dCBjb3B5IG9mIDMuNi1yYzcg
Y29udGFpbiBjb21taXQgYzUwNjY5IChORlM6DQo+ID4gQ2xlYXIga2V5IGNvbnN0cnVjdGlvbiBk
YXRhIGlmIHRoZSBpZG1hcCB1cGNhbGwgZmFpbHMpPyBUaGUgbGF0dGVyIHdhcw0KPiA+IG1lcmdl
ZCBpbjMuNi1yYzMsIGFuZCBpcyByZXBvcnRlZCB0byBmaXggdGhlIHByb2JsZW0gZm9yIHRoZSBv
dGhlcg0KPiA+IHRlc3RlcnMuDQo+IA0KPiBZZXMsIGl0IGNvbnRhaW5zIHRoYXQgY29tbWl0LiBJ
IHdhcyBhYm91dCB0byB0ZXN0IHBsYWluIHYzLjYtcmM3IHdpdGhvdXQNCj4gbXkgcGF0Y2hlcyAo
bm90IG5mcyByZWxhdGVkLCBvZiBjb3VyY2UpIG9uLXRvcCwgYnV0IHVuZm9ydHVuYXRseSB0aGUN
Cj4gZGlzayB3aXRoIHRoZSByb290LWZzIGRpZWQgOi0vDQo+IEkgYW0gYWJvdXQgdG8gc2V0IHVw
IHRoZSBib3ggYWdhaW4gYW5kIHRlc3QgcGxhaW4gLXJjNy4NCg0KUGxlYXNlIGRvLg0KDQpJIGNh
bm5vdCBzZWUgaG93IHRoYXQgQlVHX09OIGNhbiBiZSB0cmlnZ2VyZWQgaW4gdGhlIGN1cnJlbnQg
Y29kZSwgZ2l2ZW4NCnRoYXQgdGhlIG9ubHkgcGxhY2Ugd2hlcmUgaWRtYXAtPmlkbWFwX2tleV9j
b25zIGlzIHNldCB0byBhIG5vbi1OVUxMDQp2YWx1ZSBpcyBjb3ZlcmVkIGJ5IGEgbXV0ZXgsIGFu
ZCB0aGF0IGl0IGlzIGFsd2F5cyBjbGVhcmVkIGJlZm9yZSB3ZQ0KcmVsZWFzZSBzYWlkIG11dGV4
Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoN
Ck5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQo=
