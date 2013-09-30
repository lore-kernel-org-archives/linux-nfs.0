Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:54057 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756318Ab3I3U1c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Sep 2013 16:27:32 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Ric Wheeler <rwheeler@redhat.com>
CC: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Miklos Szeredi <miklos@szeredi.hu>,
        "J. Bruce Fields" <bfields@fieldses.org>, Zach Brown <zab@redhat.com>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        "Kernel Mailing List" <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
Date: Mon, 30 Sep 2013 20:27:30 +0000
Message-ID: <1380572847.6501.81.camel@leira.trondhjem.org>
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
	 <1380569663.6501.63.camel@leira.trondhjem.org>
	 <5249D86A.7080603@itwm.fraunhofer.de> <5249DA50.5060105@redhat.com>
In-Reply-To: <5249DA50.5060105@redhat.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEzLTA5LTMwIGF0IDE2OjA4IC0wNDAwLCBSaWMgV2hlZWxlciB3cm90ZToNCj4g
T24gMDkvMzAvMjAxMyAwNDowMCBQTSwgQmVybmQgU2NodWJlcnQgd3JvdGU6DQo+ID4gcE5GUywg
RmhHRlMsIEx1c3RyZSwgQ2VwaCwgZXRjLiwgYWxsIG9mIHRoZW0gc2hhbGwgaW1wbGVtZW50IHRo
ZWlyIG93biANCj4gPiBpbnRlcmZhY2U/IEFuZCB1c2Vyc3BhY2UgbmVlZHMgdG8gYWRkcmVzcyBh
bGwgb2YgdGhlbSBkaWZmZXJlbnRseT8gDQo+IA0KPiBUaGUgTkZTIGFuZCBTQ1NJIGdyb3VwcyBo
YXZlIGVhY2ggZGVmaW5lZCBhIHN0YW5kYXJkIHdoaWNoIFphY2gncyBwcm9wb3NhbCANCj4gYWJz
dHJhY3RzIGludG8gYSBjb21tb24gdXNlciBBUEkuDQo+IA0KPiBEaXN0cmlidXRlZCBmaWxlIHN5
c3RlbXMgdGVuZCB0byBiZSByYXRoZXIgdW5pcXVlIGFuZCBkbyBub3QgaGF2ZSBzaW1pbGFyIA0K
PiBzdGFuZGFyZCBib2RpZXMsIGJ1dCBhIGxvdCBvZiB0aGVtIGNvdWxkIGhpZGUgc2VydmVyIHNw
ZWNpZmljIGltcGxlbWVudGF0aW9ucyANCj4gdW5kZXIgdGhlIGN1cnJlbnQgcHJvcG9zZWQgaW50
ZXJmYWNlcy4NCj4gDQo+IFdoYXQgaXMgbm90IGEgZ29vZCBpZGVhIGlzIHRvIGRyYWcgb3V0IHRo
ZSBjb3JlLCBzaW1wbGUgY29weSBvZmZsb2FkIGRpc2N1c3Npb24gDQo+IGZvciBhbm90aGVyIDUg
eWVhcnMgdG8gcHVsbCBpbiBldmVyeSBvZGQgdXNlIGNhc2UgOikNCg0KQWdyZWVkLiBUaGUgd2hv
bGUgaWRlYSBvZiBhIGNvbW1vbiBzeXN0ZW0gY2FsbCBpbnRlcmZhY2Ugc2hvdWxkIGJlIHRvDQph
bGxvdyB1cyB0byBhYnN0cmFjdCBhd2F5IHRoZSB1bmRlcmx5aW5nIHN0b3JhZ2UgYW5kIGZpbGVz
eXN0ZW0NCmFyY2hpdGVjdHVyZXMuIElmIGZpbGVzeXN0ZW0gZGV2ZWxvcGVycyBhbHNvIHdhbnQg
YSB3YXkgdG8gZXhwb3NlIHRoYXQNCnVuZGVybHlpbmcgYXJjaGl0ZWN0dXJlIHRvIGFwcGxpY2F0
aW9ucyBpbiBvcmRlciB0byBlbmFibGUgZnVydGhlcg0Kb3B0aW1pc2F0aW9ucywgdGhlbiB0aGF0
IGJlbG9uZ3MgaW4gYSBzZXBhcmF0ZSBkaXNjdXNzaW9uLg0KDQotLSANClRyb25kIE15a2xlYnVz
dA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0
QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQo=
