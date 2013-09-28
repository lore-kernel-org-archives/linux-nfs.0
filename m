Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:3400 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753682Ab3I1PUU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Sep 2013 11:20:20 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Miklos Szeredi <miklos@szeredi.hu>, Zach Brown <zab@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Ric Wheeler <rwheeler@redhat.com>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        "Kernel Mailing List" <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: RE: [RFC] extending splice for copy offloading
Date: Sat, 28 Sep 2013 15:20:17 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9467EF2D7@SACEXCMBX04-PRD.hq.netapp.com>
References: <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com>
	<20130925183828.GA30372@lenny.home.zabbo.net>
	<CAFX2JfnyF8kyMYzCdqdr2JkoyQCom1bFLpFj89wODjoju54-Ow@mail.gmail.com>
	<20130925190620.GB30372@lenny.home.zabbo.net>
	<20130925195526.GA18971@fieldses.org>
	<20130925210742.GG30372@lenny.home.zabbo.net>
	<CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com>
	<20130926185508.GO30372@lenny.home.zabbo.net>	<5244A68F.906@redhat.com>
	<20130927200550.GA22640@fieldses.org>
	<20130927205013.GZ30372@lenny.home.zabbo.net>
 <CAJfpegtdiQzP7t5hc_OaHjSGTrjdZLfKi6fiKqBQ_+AP2Y0-oQ@mail.gmail.com>
In-Reply-To: <CAJfpegtdiQzP7t5hc_OaHjSGTrjdZLfKi6fiKqBQ_+AP2Y0-oQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBNaWtsb3MgU3plcmVkaSBbbWFp
bHRvOm1pa2xvc0BzemVyZWRpLmh1XQ0KPiBTZW50OiBTYXR1cmRheSwgU2VwdGVtYmVyIDI4LCAy
MDEzIDEyOjUwIEFNDQo+IFRvOiBaYWNoIEJyb3duDQo+IENjOiBKLiBCcnVjZSBGaWVsZHM7IFJp
YyBXaGVlbGVyOyBBbm5hIFNjaHVtYWtlcjsgS2VybmVsIE1haWxpbmcgTGlzdDsgTGludXgtDQo+
IEZzZGV2ZWw7IGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc7IE15a2xlYnVzdCwgVHJvbmQ7IFNj
aHVtYWtlciwgQnJ5YW47DQo+IE1hcnRpbiBLLiBQZXRlcnNlbjsgSmVucyBBeGJvZTsgTWFyayBG
YXNoZWg7IEpvZWwgQmVja2VyOyBFcmljIFdvbmcNCj4gU3ViamVjdDogUmU6IFtSRkNdIGV4dGVu
ZGluZyBzcGxpY2UgZm9yIGNvcHkgb2ZmbG9hZGluZw0KPiANCj4gT24gRnJpLCBTZXAgMjcsIDIw
MTMgYXQgMTA6NTAgUE0sIFphY2ggQnJvd24gPHphYkByZWRoYXQuY29tPiB3cm90ZToNCj4gPj4g
QWxzbywgSSBkb24ndCBnZXQgdGhlIGZpcnN0IG9wdGlvbiBhYm92ZSBhdCBhbGwuICBUaGUgYXJn
dW1lbnQgaXMNCj4gPj4gdGhhdCBpdCdzIHNhZmVyIHRvIGhhdmUgbW9yZSBjb3BpZXM/ICBIb3cg
bXVjaCBzYWZldHkgZG9lcyBhbm90aGVyDQo+ID4+IGNvcHkgb24gdGhlIHNhbWUgZGlzayByZWFs
bHkgZ2l2ZSB5b3U/ICBEbyBzeXN0ZW1zIHRoYXQgZG8gZGVkdXANCj4gPj4gcHJvdmlkZSBpbnRl
cmZhY2VzIHRvIHR1cm4gaXQgb2ZmIHBlci1maWxlPw0KPiANCj4gSSBkb24ndCBzZWUgdGhlIHNh
ZmV0eSBhcmd1bWVudCB2ZXJ5IGNvbXBlbGxpbmcgZWl0aGVyLiAgVGhlcmUgYXJlIHJlYWwNCj4g
c2VtYW50aWMgZGlmZmVyZW5jZXMsIGhvd2V2ZXI6IEVOT1NQQyBvbiBhIHdyaXRlIHRvIGENCj4g
KGFwcGFyZW50bMOteSkgYWxyZWFkeSBhbGxvY2F0ZWQgYmxvY2suICBUaGF0IGNvdWxkIGJlIGEg
Yml0IHVuZXhwZWN0ZWQuICBEbyB3ZQ0KPiBuZWVkIGEgZmFsbG9jYXRlIGV4dGVuc2lvbiB0byBk
ZWFsIHdpdGggc2hhcmVkIGJsb2Nrcz8NCg0KVGhlIGFib3ZlIGhhcyBiZWVuIHRoZSBjYXNlIGZv
ciBhbGwgZW50ZXJwcmlzZSBzdG9yYWdlIGFycmF5cyBldmVyIHNpbmNlIHRoZSBpbnZlbnRpb24g
b2Ygc25hcHNob3RzLiBUaGUgTkZTdjQuMiBzcGVjIGRvZXMgYWxsb3cgeW91IHRvIHNldCBhIHBl
ci1maWxlIGF0dHJpYnV0ZSB0aGF0IGNhdXNlcyB0aGUgc3RvcmFnZSBzZXJ2ZXIgdG8gYWx3YXlz
IHByZWFsbG9jYXRlIGVub3VnaCBidWZmZXJzIHRvIGd1YXJhbnRlZSB0aGF0IHlvdSBjYW4gcmV3
cml0ZSB0aGUgZW50aXJlIGZpbGUsIGhvd2V2ZXIgdGhlIGZhY3QgdGhhdCB3ZSd2ZSBsaXZlZCB3
aXRob3V0IGl0IGZvciBzYWlkIDIwIHllYXJzIGxlYWRzIG1lIHRvIGJlbGlldmUgdGhhdCBkZW1h
bmQgZm9yIGl0IGlzIGdvaW5nIHRvIGJlIGxpbWl0ZWQuIEkgaGF2ZW4ndCBwdXQgaXQgdG9wIG9m
IHRoZSBsaXN0IG9mIGZlYXR1cmVzIHdlIGNhcmUgdG8gaW1wbGVtZW50Li4uDQoNCkNoZWVycywN
CiAgIFRyb25kDQo=
