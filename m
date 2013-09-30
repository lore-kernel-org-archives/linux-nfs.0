Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:34145 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755224Ab3I3SCO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Sep 2013 14:02:14 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
CC: Miklos Szeredi <miklos@szeredi.hu>, Ric Wheeler <rwheeler@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Zach Brown <zab@redhat.com>,
        "Anna Schumaker" <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
Date: Mon, 30 Sep 2013 18:02:08 +0000
Message-ID: <1380564126.6501.23.camel@leira.trondhjem.org>
References: <20130930143432.GG16579@fieldses.org>
		 <CAJfpeguMCzv-UhrXrG7e9Q7F_0aEe3_ZMumFwLu3hxcewA_7gA@mail.gmail.com>
		 <52499026.3090802@redhat.com>
		 <CAJfpegtpXuh9070ALGy16Y8kdgioBqSf4JQqBBCF4FHvFJWAWQ@mail.gmail.com>
		 <52498AA8.2090204@redhat.com>
		 <CAJfpegv_C6cLOuA-mNtgtf2QbmmmcHwjQVo8mAnhf_wbJ8iRhg@mail.gmail.com>
		 <52498DB6.7060901@redhat.com>
		 <CAJfpegsvrr7x3MbdpvxUmzq0ZfDHfZkzAar6Od2G7wg8DgPLYQ@mail.gmail.com>
		 <52498F68.8050200@redhat.com>
		 <CAJfpegvvN_5c5oMv8UoODXQHc-DQnijhOtPDXmNamVpQLDoWMQ@mail.gmail.com>
		 <20130930163159.GA14242@tucsk.piliscsaba.szeredi.hu>
		 <5249B21E.70603@itwm.fraunhofer.de>
	 <1380563050.6501.15.camel@leira.trondhjem.org>
	 <5249B987.8020807@itwm.fraunhofer.de>
In-Reply-To: <5249B987.8020807@itwm.fraunhofer.de>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEzLTA5LTMwIGF0IDE5OjQ4ICswMjAwLCBCZXJuZCBTY2h1YmVydCB3cm90ZToN
Cj4gT24gMDkvMzAvMjAxMyAwNzo0NCBQTSwgTXlrbGVidXN0LCBUcm9uZCB3cm90ZToNCj4gPiBP
biBNb24sIDIwMTMtMDktMzAgYXQgMTk6MTcgKzAyMDAsIEJlcm5kIFNjaHViZXJ0IHdyb3RlOg0K
PiA+PiBJdCB3b3VsZCBiZSBuaWNlIGlmIHRoZXJlIHdvdWxkIGJlIHdheSBpZiB0aGUgZmlsZSBz
eXN0ZW0gd291bGQgZ2V0IGENCj4gPj4gaGludCB0aGF0IHRoZSB0YXJnZXQgZmlsZSBpcyBzdXBw
b3NlZCB0byBiZSBjb3B5IG9mIGFub3RoZXIgZmlsZS4gVGhhdA0KPiA+PiB3YXkgZGlzdHJpYnV0
ZWQgZmlsZSBzeXN0ZW1zIGNvdWxkIGFsc28gY3JlYXRlIHRoZSB0YXJnZXQtZmlsZSB3aXRoIHRo
ZQ0KPiA+PiBjb3JyZWN0IG1ldGEtaW5mb3JtYXRpb24gKHNhbWUgc3RvcmFnZSB0YXJnZXRzIGFz
IGluLWZpbGUgaGFzKS4NCj4gPj4gV2VsbCwgaWYgd2UgY2Fubm90IGFncmVlIG9uIHRoYXQsIGZp
bGUgc3lzdGVtIHdpdGggYSBjdXN0b20gcHJvdG9jb2wgYXQNCj4gPj4gbGVhc3QgY2FuIGRldGVj
dCBmcm9tIDAgdG8gU1NJWkVfTUFYIGFuZCB0aGVuIHJlc2V0IG1ldGFkYXRhLiBJJ20gbm90DQo+
ID4+IHN1cmUgaWYgdGhpcyB3b3VsZCB3b3JrIGZvciBwTkZTLCB0aG91Z2guDQo+ID4NCj4gPiBz
cGxpY2UoKSBkb2VzIG5vdCBjcmVhdGUgbmV3IGZpbGVzLiBXaGF0IHlvdSBhcHBlYXIgdG8gYmUg
YXNraW5nIGZvcg0KPiA+IGxpZXMgd2F5IG91dHNpZGUgdGhlIHNjb3BlIG9mIHRoYXQgc3lzdGVt
IGNhbGwgaW50ZXJmYWNlLg0KPiA+DQo+IA0KPiBTb3JyeSBJIGtub3csIGRlZmluaXRlbHkgb3V0
c2lkZSB0aGUgc2NvcGUgb2Ygc3BsaWNlLCBidXQgaW4gdGhlIGNvbnRleHQgDQo+IG9mIG9mZmxv
YWRlZCBmaWxlIGNvcGllcy4gU28gdGhlIHF1ZXN0aW9uIGlzLCB3aGF0IGlzIHRoZSBiZXN0IHdh
eSB0byANCj4gYWRkcmVzcy9kaXNjdXNzIHRoYXQ/DQoNCldoeSBkb2VzIGl0IG5lZWQgdG8gYmUg
YWRkcmVzc2VkIGluIHRoZSBmaXJzdCBwbGFjZT8NCg0KV2hhdCBpcyBwcmV2ZW50aW5nIGFuIGFw
cGxpY2F0aW9uIGZyb20gcmV0cmlldmluZyBhbmQgc2V0dGluZyB0aGlzDQppbmZvcm1hdGlvbiB1
c2luZyBzdGFuZGFyZCBsaWJjIGZ1bmN0aW9ucyBzdWNoIGFzIGZzdGF0KCkrb3BlbigpLCBhbmQN
CnN1cHBsZW1lbnRlZCB3aXRoIGxpYmF0dHIgYXR0cl9zZXRmL2dldGYoKSwgYW5kIGxpYmFjbCBh
Y2xfZ2V0X2ZkL3NldF9mZA0Kd2hlcmUgYXBwcm9wcmlhdGU/DQoNCi0tIA0KVHJvbmQgTXlrbGVi
dXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1
c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
