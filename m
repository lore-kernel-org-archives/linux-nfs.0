Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:3915 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756180Ab3I3Te3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Sep 2013 15:34:29 -0400
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
Date: Mon, 30 Sep 2013 19:34:26 +0000
Message-ID: <1380569663.6501.63.camel@leira.trondhjem.org>
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
	 <1380564126.6501.23.camel@leira.trondhjem.org>
	 <5249C7C7.7020207@itwm.fraunhofer.de>
In-Reply-To: <5249C7C7.7020207@itwm.fraunhofer.de>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEzLTA5LTMwIGF0IDIwOjQ5ICswMjAwLCBCZXJuZCBTY2h1YmVydCB3cm90ZToN
Cj4gT24gMDkvMzAvMjAxMyAwODowMiBQTSwgTXlrbGVidXN0LCBUcm9uZCB3cm90ZToNCj4gPiBP
biBNb24sIDIwMTMtMDktMzAgYXQgMTk6NDggKzAyMDAsIEJlcm5kIFNjaHViZXJ0IHdyb3RlOg0K
PiA+PiBPbiAwOS8zMC8yMDEzIDA3OjQ0IFBNLCBNeWtsZWJ1c3QsIFRyb25kIHdyb3RlOg0KPiA+
Pj4gT24gTW9uLCAyMDEzLTA5LTMwIGF0IDE5OjE3ICswMjAwLCBCZXJuZCBTY2h1YmVydCB3cm90
ZToNCj4gPj4+PiBJdCB3b3VsZCBiZSBuaWNlIGlmIHRoZXJlIHdvdWxkIGJlIHdheSBpZiB0aGUg
ZmlsZSBzeXN0ZW0gd291bGQgZ2V0IGENCj4gPj4+PiBoaW50IHRoYXQgdGhlIHRhcmdldCBmaWxl
IGlzIHN1cHBvc2VkIHRvIGJlIGNvcHkgb2YgYW5vdGhlciBmaWxlLiBUaGF0DQo+ID4+Pj4gd2F5
IGRpc3RyaWJ1dGVkIGZpbGUgc3lzdGVtcyBjb3VsZCBhbHNvIGNyZWF0ZSB0aGUgdGFyZ2V0LWZp
bGUgd2l0aCB0aGUNCj4gPj4+PiBjb3JyZWN0IG1ldGEtaW5mb3JtYXRpb24gKHNhbWUgc3RvcmFn
ZSB0YXJnZXRzIGFzIGluLWZpbGUgaGFzKS4NCj4gPj4+PiBXZWxsLCBpZiB3ZSBjYW5ub3QgYWdy
ZWUgb24gdGhhdCwgZmlsZSBzeXN0ZW0gd2l0aCBhIGN1c3RvbSBwcm90b2NvbCBhdA0KPiA+Pj4+
IGxlYXN0IGNhbiBkZXRlY3QgZnJvbSAwIHRvIFNTSVpFX01BWCBhbmQgdGhlbiByZXNldCBtZXRh
ZGF0YS4gSSdtIG5vdA0KPiA+Pj4+IHN1cmUgaWYgdGhpcyB3b3VsZCB3b3JrIGZvciBwTkZTLCB0
aG91Z2guDQo+ID4+Pg0KPiA+Pj4gc3BsaWNlKCkgZG9lcyBub3QgY3JlYXRlIG5ldyBmaWxlcy4g
V2hhdCB5b3UgYXBwZWFyIHRvIGJlIGFza2luZyBmb3INCj4gPj4+IGxpZXMgd2F5IG91dHNpZGUg
dGhlIHNjb3BlIG9mIHRoYXQgc3lzdGVtIGNhbGwgaW50ZXJmYWNlLg0KPiA+Pj4NCj4gPj4NCj4g
Pj4gU29ycnkgSSBrbm93LCBkZWZpbml0ZWx5IG91dHNpZGUgdGhlIHNjb3BlIG9mIHNwbGljZSwg
YnV0IGluIHRoZSBjb250ZXh0DQo+ID4+IG9mIG9mZmxvYWRlZCBmaWxlIGNvcGllcy4gU28gdGhl
IHF1ZXN0aW9uIGlzLCB3aGF0IGlzIHRoZSBiZXN0IHdheSB0bw0KPiA+PiBhZGRyZXNzL2Rpc2N1
c3MgdGhhdD8NCj4gPg0KPiA+IFdoeSBkb2VzIGl0IG5lZWQgdG8gYmUgYWRkcmVzc2VkIGluIHRo
ZSBmaXJzdCBwbGFjZT8NCj4gDQo+IEFuIG9mZmxvYWRlZCBjb3B5IGlzIHN0aWxsIG5vdCBlZmZp
Y2llbnQgaWYgZGlmZmVyZW50IHN0b3JhZ2UgDQo+IHNlcnZlcnMvdGFyZ2V0cyB1c2VkIGJ5IGZy
b20tZmlsZSBhbmQgdG8tZmlsZS4NCg0KU28/IA0KDQo+ID4NCj4gPiBXaGF0IGlzIHByZXZlbnRp
bmcgYW4gYXBwbGljYXRpb24gZnJvbSByZXRyaWV2aW5nIGFuZCBzZXR0aW5nIHRoaXMNCj4gPiBp
bmZvcm1hdGlvbiB1c2luZyBzdGFuZGFyZCBsaWJjIGZ1bmN0aW9ucyBzdWNoIGFzIGZzdGF0KCkr
b3BlbigpLCBhbmQNCj4gPiBzdXBwbGVtZW50ZWQgd2l0aCBsaWJhdHRyIGF0dHJfc2V0Zi9nZXRm
KCksIGFuZCBsaWJhY2wgYWNsX2dldF9mZC9zZXRfZmQNCj4gPiB3aGVyZSBhcHByb3ByaWF0ZT8N
Cj4gPg0KPiANCj4gQXQgYSBtaW5pbXVtIHRoaXMgcmVxdWlyZXMgbmV0d29yayBhbmQgbWV0YWRh
dGEgb3ZlcmhlYWQuIEFuZCB3aGlsZSBJJ20gDQo+IHdvcmtpbmcgb24gRmhHRlMgbm93LCBJIHN0
aWxsIHdvbmRlciB3aGF0IG90aGVyIGZpbGUgc3lzdGVtIG5lZWQgdG8gZG8gLSANCj4gZm9yIGV4
YW1wbGUgTHVzdHJlIHByZS1hbGxvY2F0ZXMgc3RvcmFnZS10YXJnZXQgZmlsZXMgb24gY3JlYXRp
bmcgYSANCj4gZmlsZSwgc28gZmlsZSBsYXlvdXQgY2hhbmdlcyBtZWFuIGV2ZW4gbW9yZSBvdmVy
aGVhZCB0aGVyZS4NCg0KVGhlIHByb2JsZW0geW91IGFyZSBkZXNjcmliaW5nIGlzIGxpbWl0ZWQg
dG8gYSBuYXJyb3cgc2V0IG9mIHN0b3JhZ2UNCmFyY2hpdGVjdHVyZXMuIElmIGNvcHkgb2ZmbG9h
ZCB1c2luZyBzcGxpY2UoKSBkb2Vzbid0IG1ha2Ugc2Vuc2UgZm9yDQp0aG9zZSBhcmNoaXRlY3R1
cmVzLCB0aGVuIGRvbid0IGltcGxlbWVudCBpdCBmb3IgdGhlbS4NCllvdSBtaWdodCBiZSBhYmxl
IHRvIHByb3ZpZGUgaW9jdGxzKCkgdG8gZG8gdGhlc2Ugc3BlY2lhbCBoaW50ZWQgZmlsZQ0KY3Jl
YXRpb25zIGZvciB0aG9zZSBmaWxlc3lzdGVtcyB0aGF0IG5lZWQgaXQsIGJ1dCB0aGUgdmFzdCBt
YWpvcml0eQ0KZG9uJ3QsIGFuZCB5b3Ugc2hvdWxkbid0IGVuZm9yY2UgaXQgb24gdGhlbS4NCg0K
PiBBbnl3YXksIGlmIHdlIGNvdWxkIGFncmVlIG9uIHRvIHVzZSBsaWJhdHRyIG9yIGxpYmFjbCB0
byB0ZWFjaCB0aGUgZmlsZSANCj4gc3lzdGVtIGFib3V0IHRoZSB1cGNvbWluZyBzcGxpY2UgY2Fs
bCBJIHdvdWxkIGJlIGZpbmUuDQoNCmxpYmF0dHIgYW5kIGxpYmFjbCBhcmUgZ2VuZXJpYyBsaWJy
YXJpZXMgdGhhdCBleGlzdCB0byBtYW5pcHVsYXRlIHhhdHRycw0KYW5kIGFjbHMuIFRoZXkgZG8g
bm90IG5lZWQgdG8gY29udGFpbiBMdXN0cmUtc3BlY2lmaWMgY29kZS4NCg0KLS0gDQpUcm9uZCBN
eWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15
a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
