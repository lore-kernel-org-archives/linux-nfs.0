Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:2108 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753638Ab3I3Ro0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Sep 2013 13:44:26 -0400
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
Date: Mon, 30 Sep 2013 17:44:12 +0000
Message-ID: <1380563050.6501.15.camel@leira.trondhjem.org>
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
In-Reply-To: <5249B21E.70603@itwm.fraunhofer.de>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEzLTA5LTMwIGF0IDE5OjE3ICswMjAwLCBCZXJuZCBTY2h1YmVydCB3cm90ZToN
Cj4gSXQgd291bGQgYmUgbmljZSBpZiB0aGVyZSB3b3VsZCBiZSB3YXkgaWYgdGhlIGZpbGUgc3lz
dGVtIHdvdWxkIGdldCBhIA0KPiBoaW50IHRoYXQgdGhlIHRhcmdldCBmaWxlIGlzIHN1cHBvc2Vk
IHRvIGJlIGNvcHkgb2YgYW5vdGhlciBmaWxlLiBUaGF0IA0KPiB3YXkgZGlzdHJpYnV0ZWQgZmls
ZSBzeXN0ZW1zIGNvdWxkIGFsc28gY3JlYXRlIHRoZSB0YXJnZXQtZmlsZSB3aXRoIHRoZSANCj4g
Y29ycmVjdCBtZXRhLWluZm9ybWF0aW9uIChzYW1lIHN0b3JhZ2UgdGFyZ2V0cyBhcyBpbi1maWxl
IGhhcykuDQo+IFdlbGwsIGlmIHdlIGNhbm5vdCBhZ3JlZSBvbiB0aGF0LCBmaWxlIHN5c3RlbSB3
aXRoIGEgY3VzdG9tIHByb3RvY29sIGF0IA0KPiBsZWFzdCBjYW4gZGV0ZWN0IGZyb20gMCB0byBT
U0laRV9NQVggYW5kIHRoZW4gcmVzZXQgbWV0YWRhdGEuIEknbSBub3QgDQo+IHN1cmUgaWYgdGhp
cyB3b3VsZCB3b3JrIGZvciBwTkZTLCB0aG91Z2guDQoNCnNwbGljZSgpIGRvZXMgbm90IGNyZWF0
ZSBuZXcgZmlsZXMuIFdoYXQgeW91IGFwcGVhciB0byBiZSBhc2tpbmcgZm9yDQpsaWVzIHdheSBv
dXRzaWRlIHRoZSBzY29wZSBvZiB0aGF0IHN5c3RlbSBjYWxsIGludGVyZmFjZS4NCg0KLS0gDQpU
cm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRy
b25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
