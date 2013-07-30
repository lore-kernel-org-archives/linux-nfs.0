Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:62653 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757044Ab3G3VUn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Jul 2013 17:20:43 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>,
        =?utf-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>,
        "Serge E. Hallyn" <serge@hallyn.com>, Andrey Vagin <avagin@openvz.org>,
        "Al Viro" <viro@zeniv.linux.org.uk>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: fuzz tested user mode linux core dumps in
 fs/lockd/clntproc.c:131 (nfs in a netns utsns problems?)
Date: Tue, 30 Jul 2013 21:20:32 +0000
Message-ID: <1375219230.2468.7.camel@leira.trondhjem.org>
References: <51F39AE8.3090401@gmx.de> <20130727170051.GA31447@redhat.com>
	 <87iozujkdy.fsf@xmission.com> <87r4eii4td.fsf@xmission.com>
	 <20130729141758.GA8505@redhat.com> <871u6h45zy.fsf_-_@xmission.com>
	 <20130730211202.GH1443@fieldses.org>
In-Reply-To: <20130730211202.GH1443@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEzLTA3LTMwIGF0IDE3OjEyIC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIE1vbiwgSnVsIDI5LCAyMDEzIGF0IDEwOjQyOjU3QU0gLTA3MDAsIEVyaWMgVy4gQmll
ZGVybWFuIHdyb3RlOg0KPiA+IA0KPiA+IEFkZGluZyBzb21lIHBlb3BsZSB3aG8gcGF5IG1vcmUg
YXR0ZW50aW9uIHRvIG5mcyBpbiBuZXR3b3JrIG5hbWVzcGFjZXMNCj4gPiB0aGFuIEkgdXN1YWxs
eSBkby4NCj4gPiANCj4gPiBPbGVnIE5lc3Rlcm92IDxvbGVnQHJlZGhhdC5jb20+IHdyaXRlczoN
Cj4gPiANCj4gPiA+IE9uIDA3LzI4LCBFcmljIFcuIEJpZWRlcm1hbiB3cm90ZToNCj4gPiA+Pg0K
PiA+ID4+ID4gVGhpcyB1bnRlc3RlZCBwYXRjaCBzaG91bGQgZml4IGl0IHdpdGhvdXQgYW55IG5l
ZWQgdG8gd29ycnkgYWJvdXQNCj4gPiA+PiA+IGR5bmFtaWMgYmVoYXZpb3IuDQo+ID4gPg0KPiA+
ID4gWWVlZXMgOykgSSB3YXMgdGhpbmtpbmcgYWJvdXQgdGhpcyBjaGFuZ2UgdG9vLCBidXQgSSBo
YXZlIG5vIGlkZWENCj4gPiA+IHdoYXQgdGhpcyAtPm5vZGVuYW1lIGFjdHVhbGx5IG1lYW5zIGZv
ciBuZnMuDQo+ID4gPg0KPiA+ID4gSWYgeW91IGFyZSBnb2luZyB0byBzZW5kIHRoaXMgcGF0Y2gg
LSBncmVhdCENCj4gPiANCj4gPiBKdXN0IGJhdHRpbmcgaXQgYXJvdW5kIGZvciBub3csIGFuZCBo
b3Bpbmcgd2UgaGF2ZSB0aGUgcmlnaHQgY29tYmluYXRpb24NCj4gPiBvZiBleWViYWxscyBsb29r
IGF0IGl0LiAgVGhlcmUgYXJlIG1vcmUgcGxhY2VzIGluIG5mcyB0aGF0IGhhdmUNCj4gPiBxdWVz
dGlvbmFibGUgdXNlcyBvZiB1dHNuYW1lKCkgaW5zdGVhZCBvZiBpbml0X3V0c25hbWUoKS4gIFNv
IEkgdGhpbmsgd2UNCj4gPiBwcm9iYWJseSBuZWVkIGEgbW9yZSBjb21wcmVoZW5zaXZlIHBhdGNo
IGF0IHRoZSB2ZXJ5IGxlYXN0Lg0KPiA+IA0KPiA+IG5mc2NsbnRfcmVjbGFpbSBpcyBuZXZlciBj
YWxsZWQgZnJvbSB1c2Vyc3BhY2UuDQo+IA0KPiBTbywgbG9va2luZyBqdXN0IGF0IHRoaXMgb25l
Li4uLg0KPiANCj4gTm90ZSBJIHRoaW5rIHlvdSBtZWFuIG5sbWNsbnRfcmVjbGFpbS4NCj4gDQo+
IFRoYXQncyBwYXJ0IG9mIHRoZSBjbGllbnQncyBoYW5kbGluZyBvZiBzZXJ2ZXIgcmVib290cy4g
IFRoZSBjbGllbnQNCj4ga25vd3MgdGhhdCBpdCBzaG91bGQgaG9sZCBzb21lIGZpbGUgbG9jaywg
YnV0IGtub3dzIHRoYXQgdGhlIHNlcnZlciBoYXMNCj4gbm93IGZvcmdvdHRlbiB0aGF0IGZhY3Qs
IGFuZCBuZWVkcyB0byBzZW5kIGEgInJlY2xhaW0iIHRvIGdldCB0aGUgbG9jaw0KPiBiYWNrLg0K
PiANCj4gVGhhdCByZWNsYWltIHdpbGwgZ2V0IGtpY2tlZCBvZmYgd2hlbiB0aGUgY2xpZW50J3Mg
bm90aWZpZWQgdGhhdCB0aGUNCj4gc2VydmVyIHJlYm9vdGVkLg0KPiANCj4gU28gd2UncmUgbm90
IGluIHRoZSBjb250ZXh0IG9mIHdob2V2ZXIgb3JpZ2luYWxseSBkaWQgdGhlDQo+IGZjbnRsKC4s
Rl9TRVRMSywuKSwgYW5kIHRyeWluZyB0byBnZXQgdGhlIG5hbWVzcGFjZSBvdXQgb2YgY3VycmVu
dCBpcw0KPiBjbGVhcmx5IHdyb25nLg0KPiANCj4gbmxtX2hvc3QgY3VycmVudGx5IGhhcyBhICJz
dHJ1Y3QgbmV0ICpuZXQiIGZpZWxkLiAgTWF5YmUgd2UgYWxzbyBuZWVkIHRvDQo+IHN0YXNoIGEg
InN0cnVjdCB1dHNfbmFtZXNwYWNlICoiLCBvciBqdXN0IGEgY29weSBvZiB0aGUgbm9kZW5hbWU/
DQoNClRoZSBzdHJ1Y3QgcnBjX2NsbnQgYWxyZWFkeSBoYXMgdGhhdCBpbmZvcm1hdGlvbiBpbiB0
aGUgY2xfbm9kZW5hbWUNCmZpZWxkLg0KDQpDaGVlcnMNCiAgVHJvbmQNCg0KLS0gDQpUcm9uZCBN
eWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15
a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
