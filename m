Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: "bcodding@redhat.com" <bcodding@redhat.com>,
        "Anna.Schumaker@Netapp.com"
	<Anna.Schumaker@Netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "green@linuxhacker.ru" <green@linuxhacker.ru>
Subject: Re: [PATCH v7 13/31] NFSv4.1: Ensure we always run TEST/FREE_STATEID
 on locks
Date: Thu, 10 Nov 2016 16:51:52 +0000
Message-ID: <1478796708.3239.3.camel@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
	 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
	 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
	 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
	 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
	 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
	 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
	 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
	 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
	 <599EE56B-46DD-411B-805D-11C2FB5E30A4@redhat.com>
	 <34B1D68A-1A1C-4B59-A19E-467D48F7A9D0@redhat.com>
	 <F1712484-1131-418A-98F0-272A4A1BAE59@redhat.com>
	 <AB669741-1EC9-4C08-86A8-479755398679@redhat.com>
	 <6ABCDB9B-997E-49C1-9363-D59AF9BEC0E9@primarydata.com>
	 <B41EEA6E-B168-4DE3-AC73-F4270287EF0D@redhat.com>
	 <806bf204-eb35-5a3a-30fa-612bf22fb09a@Netapp.com>
	 <D4F8C627-7DDD-45FF-900E-253F4FB3F47B@redhat.com>
In-Reply-To: <D4F8C627-7DDD-45FF-900E-253F4FB3F47B@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE2LTExLTEwIGF0IDEwOjU4IC0wNTAwLCBCZW5qYW1pbiBDb2RkaW5ndG9uIHdy
b3RlOg0KPiBIaSBBbm5hLA0KPiANCj4gT24gMTAgTm92IDIwMTYsIGF0IDEwOjAxLCBBbm5hIFNj
aHVtYWtlciB3cm90ZToNCj4gPiANCj4gPiBEbyB5b3UgaGF2ZSBhbiBlc3RpbWF0ZSBmb3Igd2hl
biB0aGlzIHBhdGNoIHdpbGwgYmUgcmVhZHk/wqDCoEkgd2FudA0KPiA+IHRvwqANCj4gPiBpbmNs
dWRlIGl0IGluIG15IG5leHQgYnVnZml4IHB1bGwgcmVxdWVzdCBmb3IgNC45Lg0KPiANCj4gSSBo
YXZlbid0IHBvc3RlZCBiZWNhdXNlIEkgYW0gc3RpbGwgdHJ5aW5nIHRvIGdldCB0byB0aGUgYm90
dG9tIG9mwqANCj4gYW5vdGhlcg0KPiBwcm9ibGVtIHdoZXJlIHRoZSBjbGllbnQgZ2V0cyBzdHVj
ayBpbiBhIGxvb3Agc2VuZGluZyB0aGUgc2FtZQ0KPiBzdGF0ZWlkwqANCj4gb3Zlcg0KPiBhbmQg
b3ZlciBvbiBORlM0RVJSX09MRF9TVEFURUlELsKgwqBJIHdhbnQgdG8gbWFrZSBzdXJlIHRoaXMg
cHJvYmxlbQ0KPiBpc24ndA0KPiBjYXVzZWQgYnkgdGhpcyBmaXggLS0gd2hpY2ggSSBkb24ndCB0
aGluayBpdCBpcywgYnV0IEknZCByYXRoZXIgbWFrZcKgDQo+IHN1cmUuDQo+IElmIEkgZG9uJ3Qg
bWFrZSBhbnkgcHJvZ3Jlc3Mgb24gdGhpcyBwcm9ibGVtIGJ5IHRoZSBlbmQgb2YgdG9kYXksDQo+
IEknbGzCoA0KPiBwb3N0DQo+IHdoYXQgSSBoYXZlLg0KPiANCj4gUmVhZCBvbiBpZiBpbnRlcmVz
dGVkIGluIHRoaXMgbmV3IHByb2JsZW06DQo+IA0KPiBJdCBsb29rcyBsaWtlIHJhY2luZyBvcGVu
cyB3aXRoIHRoZSBzYW1lIG9wZW5vd25lciBjYW4gYmUgcmV0dXJuZWQNCj4gb3V0wqANCj4gb2YN
Cj4gb3JkZXIgYnkgdGhlIHNlcnZlciwgc28gdGhlIGNsaWVudCBzZWVzIHN0YXRlaWQgc2VxaWQg
b2YgMiBiZWZvcmUNCj4gMS7CoMKgDQo+IFRoZW4gYQ0KPiBMT0NLIHNlbnQgd2l0aCBzZXFpZCAx
IGlzIGVuZGxlc3NseSByZXRyaWVkIGlmIHNlbnQgd2hpbGUgZG9pbmfCoA0KPiByZWNvdmVyeS4N
Cj7CoA0KDQpXaHkgaXMgaXQgZG9pbmcgdGhhdD/CoG5mczRfbG9ja19wcmVwYXJlKCkgc2hvdWxk
IGJlIGNvcHlpbmcgdGhlIHN0YXRlaWQNCmZyb20gdGhlIG5mczRfc3RhdGUgc3RydWN0dXJlIG9u
IGVhY2ggaXRlcmF0aW9uLg0KDQpDaGVlcnMNCsKgIFRyb25k
