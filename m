Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:3404 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752101Ab2DPTdW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Apr 2012 15:33:22 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pstaubach@exagrid.com" <pstaubach@exagrid.com>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Date: Mon, 16 Apr 2012 19:33:05 +0000
Message-ID: <1334604785.2879.23.camel@lade.trondhjem.org>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	 <20120413150518.GA1987@us.ibm.com>
	 <20120413114236.0e557e01@tlielax.poochiereds.net>
	 <4F8B1B7B.3040304@itwm.fraunhofer.de>
	 <20120416073655.7cdb90cf@corrin.poochiereds.net>
	 <4F8C3036.2030702@itwm.fraunhofer.de>
	 <20120416134642.1754cd3e@corrin.poochiereds.net>
In-Reply-To: <20120416134642.1754cd3e@corrin.poochiereds.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA0LTE2IGF0IDEzOjQ2IC0wNDAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
VGhlIHF1ZXN0aW9uIGFib3V0IGxvb3BpbmcgaW5kZWZpbml0ZWx5IHJlYWxseSBjb21lcyBkb3du
IHRvOg0KPiANCj4gMSkgaXMgYSBwZXJzaXN0ZW50IEVTVEFMRSBpbiBjb25qdW5jdGlvbiB3aXRo
IGEgc3VjY2Vzc2Z1bCBsb29rdXAgYQ0KPiBzaXR1YXRpb24gdGhhdCB3ZSBleHBlY3QgdG8gYmUg
dGVtcG9yYXJ5LiBpLmUuIHdpbGwgdGhlIGFkbWluIGF0IHNvbWUNCj4gcG9pbnQgYmUgYWJsZSB0
byBkbyBzb21ldGhpbmcgYWJvdXQgaXQ/IElmIG5vdCwgdGhlbiB0aGVyZSdzIG5vIHBvaW50DQo+
IGluIGNvbnRpbnVpbmcgdG8gcmV0cnkuIEFnYWluLCB0aGlzIGlzIGEgc2l0dWF0aW9uIHRoYXQg
KnJlYWxseSogc2hvdWxkDQo+IG5vdCBoYXBwZW4gaWYgdGhlIGZpbGVzeXN0ZW0gaXMgZG9pbmcg
dGhlIHJpZ2h0IHRoaW5nLg0KPiANCj4gMikgSWYgdGhlIGFkbWluIGNhbid0IGRvIGFueXRoaW5n
IGFib3V0IGl0LCBpcyBpdCByZWFzb25hYmxlIHRvIGV4cGVjdA0KPiB0aGF0IHVzZXJzIGNhbiBz
ZW5kIGEgZmF0YWwgc2lnbmFsIHRvIGh1bmcgYXBwbGljYXRpb25zIGlmIHRoaXMNCj4gc2l0dWF0
aW9uIG9jY3Vycy4NCj4gDQo+IFdlIGV4cGVjdCB0aGF0IHRoYXQncyBvayBpbiBvdGhlciBzaXR1
YXRpb25zIHRvIHJlc29sdmUgaHVuZw0KPiBhcHBsaWNhdGlvbnMsIHNvIEknbSBub3Qgc3VyZSBJ
IHVuZGVyc3RhbmQgd2h5IGl0IHdvdWxkbid0IGJlDQo+IGFjY2VwdGFibGUgaGVyZS4uLg0KDQpU
aGVyZSBhcmUgZGVmaW5pdGVseSBwb3RlbnRpYWxseSBwZXJzaXN0ZW50IHBhdGhvbG9naWNhbCBz
aXR1YXRpb25zIHRoYXQNCnRoZSBmaWxlc3lzdGVtIGNhbid0IGRvIGFueXRoaW5nIGFib3V0LiBJ
ZiB0aGUgcG9pbnQgb2Ygb3JpZ2luIGZvciB5b3VyDQpwYXRobmFtZSAoZm9yIGluc3RhbmNlIHlv
dXIgY3VycmVudCBkaXJlY3RvcnkgaW4gdGhlIGNhc2Ugb2YgYSByZWxhdGl2ZQ0KcGF0aG5hbWUp
IGlzIHN0YWxlLCB0aGVuIG5vIGFtb3VudCBvZiBsb29waW5nIGlzIGdvaW5nIHRvIGhlbHAgeW91
IHRvDQpyZWNvdmVyLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBt
YWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRh
cHAuY29tDQoNCg==
