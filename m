Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52265 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754958Ab2CWPUl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Mar 2012 11:20:41 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v10 3/8] sunrpc: create nfsd dir in rpc_pipefs
Date: Fri, 23 Mar 2012 15:20:21 +0000
Message-ID: <1332516024.3087.1.camel@lade.trondhjem.org>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
	 <1332337929-18580-4-git-send-email-jlayton@redhat.com>
	 <20120323121208.GA3219@fieldses.org> <20120323133111.GA2991@fieldses.org>
In-Reply-To: <20120323133111.GA2991@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTAzLTIzIGF0IDA5OjMxIC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIEZyaSwgTWFyIDIzLCAyMDEyIGF0IDA4OjEyOjA4QU0gLTA0MDAsIEouIEJydWNlIEZp
ZWxkcyB3cm90ZToNCj4gPiBPbiBXZWQsIE1hciAyMSwgMjAxMiBhdCAwOTo1MjowNEFNIC0wNDAw
LCBKZWZmIExheXRvbiB3cm90ZToNCj4gPiA+IEFkZCBhIG5ldyB0b3AtbGV2ZWwgZGlyIGluIHJw
Y19waXBlZnMgdG8gaG9sZCB0aGUgcGlwZSBmb3IgdGhlIGNsaWVudGlkDQo+ID4gPiB1cGNhbGwu
DQo+ID4gDQo+ID4gQWZ0ZXIgYXBwbHlpbmcgdGhpcyBwYXRjaCwgbXkgdGVzdHMgY29uc2lzdGVu
dGx5IGhhbmcuICBUaGUgaGFuZyBoYXBwZW5zDQo+ID4gaW4gZXhjbHRlc3QgKG9mIHRoZSBzcGVj
aWFsIGNvbm5lY3RhdG9uIHRlc3RzKSwgb3ZlciBuZnM0LjEgYW5kIGtyYjUuDQo+ID4gTG9va2lu
ZyBhdCB0aGUgd2lyZSB0cmFmZmljLCBJJ20gc2VlaW5nIERFTEFZIHJldHVybmVkIGZyb20gYSBz
ZXRhdHRyDQo+ID4gZm9yIG1vZGUgb24gYSBuZXdseS1jcmVhdGVkICh3aXRoIEVYQ0xVU0lWRTRf
MSkgZmlsZS4gIFRoYXQgb3BlbiBnb3QgYQ0KPiA+IGRlbGVnYXRpb24sIHNvIHByZXN1bWFibHkg
dGhhdCdzIHdoYXQncyBjYXVzaW5nIHRoZSBERUxBWSwgdGhvdWdoIEknbQ0KPiA+IG5vdCBzZWVp
bmcgdGhlIHNlcnZlciBzZW5kIGEgcmVjYWxsLiAgVGhhdCBjb3VsZCBiZSBhIGtyYjUgYnVnLg0K
PiA+IA0KPiA+IFdoYXRldmVyIGJ1ZyB0aGVyZSBpcyBoZXJlLCBpdCdzIGhhcmQgdG8gdGVsbCB3
aHkgdGhpcyBwYXRjaCBpbg0KPiA+IHBhcnRpY3VsYXIgd291bGQgbWFrZSBpdCBtb3JlIGxpa2Vs
eS4NCj4gPiANCj4gPiBTbywgc3RpbGwgaW52ZXN0aWdhdGluZyENCj4gDQo+IFJlcHJvZHVjZWFi
bGUgYnk6DQo+IA0KPiAJbW91bnQgLW9zZWM9a3JiNSxtaW5vcnZlcnNpb249MSBzZXJ2ZXI6L2V4
cG9ydC8gL21udC8NCj4gCWNwIGN0aG9uMDQvc3BlY2lhbC9leGNsdGVzdCAvbW50Lw0KPiAJY2Qg
L21udA0KPiAJLi9leGNsdGVzdA0KDQpVbW0uLi4gV2hlbiB3b3VsZCB5b3UgZXZlciBnZXQgYSBE
RUxBWSBpbiB0aGUgYWJvdmUgc2NlbmFyaW8/IEkgY2FuIHNlZQ0KZ2V0dGluZyBhbiBORlM0RVJS
X09QRU5NT0RFLCBidXQgbm90IERFTEFZLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5j
b20NCnd3dy5uZXRhcHAuY29tDQoNCg==
