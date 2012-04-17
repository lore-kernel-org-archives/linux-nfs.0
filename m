Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8597 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755605Ab2DQOEg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 10:04:36 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Miklos Szeredi <miklos@szeredi.hu>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pstaubach@exagrid.com" <pstaubach@exagrid.com>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Date: Tue, 17 Apr 2012 14:04:34 +0000
Message-ID: <1334671473.2963.27.camel@lade.trondhjem.org.localdomain>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	 <20120413150518.GA1987@us.ibm.com>
	 <20120413114236.0e557e01@tlielax.poochiereds.net>
	 <4F8B1B7B.3040304@itwm.fraunhofer.de>
	 <20120416073655.7cdb90cf@corrin.poochiereds.net>
	 <4F8C3036.2030702@itwm.fraunhofer.de>
	 <20120416134642.1754cd3e@corrin.poochiereds.net>
	 <1334604785.2879.23.camel@lade.trondhjem.org>
	 <20120416154322.0d95e435@corrin.poochiereds.net>
	 <1334607906.2879.36.camel@lade.trondhjem.org>
	 <20120416190548.2463d1d0@corrin.poochiereds.net>
	 <87sjg2o62z.fsf@tucsk.pomaz.szeredi.hu>
	 <20120417093222.2ff5e1bd@corrin.poochiereds.net>
In-Reply-To: <20120417093222.2ff5e1bd@corrin.poochiereds.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA0LTE3IGF0IDA5OjMyIC0wNDAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
T24gVHVlLCAxNyBBcHIgMjAxMiAxNToxMjoyMCArMDIwMA0KPiBNaWtsb3MgU3plcmVkaSA8bWlr
bG9zQHN6ZXJlZGkuaHU+IHdyb3RlOg0KDQo+IFRvIGRvIHRoYXQgd291bGQgcmVxdWlyZSBwcm90
b2NvbCBzdXBwb3J0IHRoYXQgd2Ugc2ltcGx5IGRvbid0IGhhdmUuIFdlDQo+IGRvbid0IGhhdmUg
YSB3YXkgdG8gKGZvciBpbnN0YW5jZSkgc2F5IHZpYSBORlMgImdpdmUgbWUgdGhlIGF0dHJpYnV0
ZXMNCj4gZm9yIHRoaXMgZmlsZW5hbWUiLiBXZWxsLCBhdCBsZWFzdCBub3QgZm9yIE5GU3YzLi4u
DQoNCldoYXQncyB3cm9uZyB3aXRoIExPT0tVUD8NCg0KPiBXaXRoIHY0IHlvdSBjb3VsZCB0aGVv
cmV0aWNhbGx5IGNvbnN0cnVjdCBhIGNvbXBvdW5kIHRoYXQgZG9lcyB0aGF0LA0KPiBidXQgeW91
J2QgaGF2ZSB0byBhc3N1bWUgdGhhdCB0aGUgc2VydmVyIHdvbid0IHJlbGVhc2UgdGhlIHJlZmVy
ZW5jZSB0bw0KPiB0aGUgaW5vZGUgbWlkd2F5IHRocm91Z2ggdGhlIGNvbXBvdW5kLiBUaGF0J3Mg
YSByZWFzb25hYmx5IHNhZmUNCj4gYXNzdW1wdGlvbi4NCg0KQWN0dWFsbHksIE5GU3Y0IGlzIHRo
ZSBvbmUgdGhhdCBoYXMgdGhlIHByb2JsZW06IHRoZXJlIGFyZSBubyBhdG9taWNpdHkNCmd1YXJh
bnRlZXMgd2l0aGluIGNvbXBvdW5kcywgc28geW91IGNvdWxkIHRoZW9yZXRpY2FsbHkgZ2V0IGFu
IEVTVEFMRSBpbg0KdGhlIEdFVEFUVFIgcGFydCBvZiBvdXIgbG9va3VwIGNvbXBvdW5kLg0KDQot
LSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFw
cA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
