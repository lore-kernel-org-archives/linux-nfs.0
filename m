Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57230 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752991Ab1JGBtX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Oct 2011 21:49:23 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Subject: RE: [nfsv4] back channel flags, CREATE_SESSION, BIND_CONN_TO_SESSION
Date: Thu, 6 Oct 2011 18:49:21 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B8303F4@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <1579920738.2729006.1317951743769.JavaMail.root@erie.cs.uoguelph.ca>
References: <1317871693.14305.5.camel@lade.trondhjem.org> <1579920738.2729006.1317951743769.JavaMail.root@erie.cs.uoguelph.ca>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Rick Macklem" <rmacklem@uoguelph.ca>
Cc: "linux-nfs" <linux-nfs@vger.kernel.org>,
        "nfs-ganesha-devel" <nfs-ganesha-devel@lists.sourceforge.net>,
        "nfsv4" <nfsv4@ietf.org>, "Matt W. Benjamin" <matt@linuxbox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBSaWNrIE1hY2tsZW0gW21haWx0
bzpybWFja2xlbUB1b2d1ZWxwaC5jYV0NCj4gU2VudDogVGh1cnNkYXksIE9jdG9iZXIgMDYsIDIw
MTEgOTo0MiBQTQ0KPiBUbzogTXlrbGVidXN0LCBUcm9uZA0KPiBDYzogbGludXgtbmZzOyBuZnMt
Z2FuZXNoYS1kZXZlbDsgbmZzdjQ7IE1hdHQgVy4gQmVuamFtaW4NCj4gU3ViamVjdDogUmU6IFtu
ZnN2NF0gYmFjayBjaGFubmVsIGZsYWdzLCBDUkVBVEVfU0VTU0lPTiwNCj4gQklORF9DT05OX1RP
X1NFU1NJT04NCj4gDQo+IFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4gPiBPbiBXZWQsIDIwMTEt
MTAtMDUgYXQgMTk6MjEgLTA0MDAsIE1hdHQgVy4gQmVuamFtaW4gd3JvdGU6DQo+IEp1c3QgZnlp
LCB3aGF0IEkgaGF2ZSBpbXBsZW1lbnRlZCAoYW5kIEkgZG9uJ3QgaW50ZW5kIHRvIGNoYW5nZSBp
dCkgaXMgd2hhdA0KPiBUcm9uZCBjdXJyZW50bHkgaGFzIGRvbmUuIEZvciB0aGUgRnJlZUJTRCA0
LjEgY2xpZW50LCBpdCB3aWxsIHNldA0KPiBDUkVBVEVfU0VTU0lPTjRfRkxBR19DT05OX0JBQ0tf
Q0hBTiBpbiBjc2FfZmxhZ3MsIGJ1dCBpZiB0aGUgc2VydmVyDQo+IGRvZXNuYHQgc2V0IGl0IGlu
IGNzcl9mbGFncywgSSBzaW1wbHkgYXNzdW1lIGBubyBiYWNrY2hhbm5lbGAuIEkgZG9uYHQgcGxh
biBvbg0KPiBpbXBsZW1lbnRpbmcgYSBkZWRpY2F0ZWQgYmFjayBjaGFubmVsLiAoSSBzdXBwb3Nl
IHRoYXQgY291bGQgY2hhbmdlIGlmDQo+IHRoZXJlIHdlcmUgc3Ryb25nIGV2aWRlbmNlIHRoYXQg
YSBkZWRpY2F0ZWQgYmFjayBjaGFubmVsIGRpZCBpbXByb3ZlDQo+IHBlcmZvcm1hbmNlIHNpZ25p
ZmljYW50bHkuKQ0KPiANCj4gSSB0aG91Z2h0IElgZCBwb3N0IHRoaXMgbWFpbmx5IHRvIHNob3cg
dGhhdCB0aGVyZSBhcmUgYWN0dWFsbHkgdGltZXMgd2hlbiBJDQo+IGFncmVlIHdpdGggVHJvbmQ7
LSkgcmljaw0KDQpIZXkuLi4gRG9uJ3QgeW91IGFsd2F5cz8gOy0pDQoNCiAgICAgVHJvbmQNCg==
