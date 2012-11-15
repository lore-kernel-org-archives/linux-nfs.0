Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1770 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767735Ab2KONeW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Nov 2012 08:34:22 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v3] SUNRPC: set desired file system root before
 connecting local transports
Date: Thu, 15 Nov 2012 13:34:16 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9092E2984@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121106124035.GA20522@infradead.org>
	 <20121106130705.GC6718@fieldses.org> <20121106131018.GA12211@infradead.org>
	 <20121106133605.GD6718@fieldses.org> <20121107183355.GA7421@fieldses.org>
	 <50A0B562.2090807@parallels.com> <20121114210112.GA539@fieldses.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9092E0A40@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121114214236.GB539@fieldses.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9092E0AE9@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121114215426.GC539@fieldses.org> <87obize6jp.fsf@xmission.com>
In-Reply-To: <87obize6jp.fsf@xmission.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTExLTE0IGF0IDIyOjE0IC0wODAwLCBFcmljIFcuIEJpZWRlcm1hbiB3cm90
ZToNCj4gIkouIEJydWNlIEZpZWxkcyIgPGJmaWVsZHNAZmllbGRzZXMub3JnPiB3cml0ZXM6DQo+
IA0KPiA+IE9uIFdlZCwgTm92IDE0LCAyMDEyIGF0IDA5OjUxOjMzUE0gKzAwMDAsIE15a2xlYnVz
dCwgVHJvbmQgd3JvdGU6DQo+ID4+IE9uIFdlZCwgMjAxMi0xMS0xNCBhdCAxNjo0MiAtMDUwMCwg
Si4gQnJ1Y2UgRmllbGRzIHdyb3RlOg0KPiA+PiA+IFNpbW8ncyBwYXRjaGVzIHVzZSB0aGVtIGZv
ciB1cGNhbGxzIHRvIHN2Y2dzc2QuICBUaG9zZSB3aWxsIGFsd2F5cyBiZQ0KPiA+PiA+IGRvbmUg
ZnJvbSBzZXJ2ZXIgdGhyZWFkcy4NCj4gPj4gDQo+ID4+IEFueSByZWFzb24gd2h5IHlvdSBjYW4n
dCBzZXQgdGhhdCB1cCB3aGVuIHlvdSBzdGFydCBuZnNkPw0KPiA+DQo+ID4gT2gsIHJpZ2h0LCBJ
IHdhcyB0aGlua2luZyBvZiB0aGUgdXBjYWxscyB0aGVtc2VsdmVzLS1yaWdodCwgdGhlIGNvbm5l
Y3QNCj4gPiB3ZSBzaG91bGQgYmUgYWJsZSB0byBkbyBvbiBzZXJ2ZXIgc3RhcnQsIEkgYWdyZWUu
DQo+ID4NCj4gPj4gDQo+ID4+ID4gPiBJZiBub3QsIHRoZW4gbGV0J3MganVzdCBtb3ZlDQo+ID4+
ID4gPiB0aGUgQUZfTE9DQUwgY29ubmVjdGlvbiBiYWNrIGludG8gdGhlIHByb2Nlc3MgY29udGV4
dCBhbmQgb3V0IG9mIHJwY2lvZC4NCj4gPj4gPiANCj4gPj4gPiBSZW1pbmQgbWUgaG93IHRoaXMg
aGVscHM/DQo+ID4+IA0KPiA+PiBycGNpb2Qgc2hhcmVzIHRoZSAnaW5pdCcgcHJvY2VzcyBuZXQg
bmFtZXNwYWNlIGFuZCBjaHJvb3QgcHJvcGVydGllcy4NCj4gPj4gSWYsIGhvd2V2ZXIgeW91IGNh
bGwgYmluZCgpIGZyb20gdGhlIChjb250YWluZXJpc2VkKSBwcm9jZXNzIHRoYXQgd2FzDQo+ID4+
IHVzZWQgdG8gc3RhcnQgbmZzZCwgdGhlbiB5b3Ugd2lsbCBiZSB1c2luZyBmaWxlc3lzdGVtIHJv
b3QgKGFuZCBuZXQNCj4gPj4gbmFtZXNwYWNlKSBvZiB0aGF0IGNvbnRhaW5lci4NCj4gPg0KPiA+
IEdvdCBpdC4NCj4gDQo+IElmIHlvdSBjYW4gbW92ZSB0aGUgY29ubmVjdCBhbmQgYmluZCBpbnRv
IHRoZSBzZXJ2ZXIgc3RhcnQgdGhhdCBkb2VzDQo+IHNvdW5kIGxpa2UgYSB2ZXJ5IGdvb2QgYW5k
IG1haW50YWluYWJsZSBzb2x1dGlvbi4gIEkgc3VzcGVjdCBpdCBtaWdodA0KPiBldmVuIGJlIGEg
c21pZGdlIGJldHRlciBmb3IgZXJyb3IgaGFuZGxpbmcuDQo+IA0KPiBJcyB0aGVyZSBldmVyIGEg
cmVhc29uIHRvIHJlY29ubmVjdCBvbmUgb2YgdGhlc2Ugc29ja2V0cz8NCg0KTm90IGZvciB0aGUg
cnBjYmluZCBjYXNlLCBob3dldmVyIHlvdSBjYW4gZWFzaWx5IGdldCBpbnRvIGEgc2l0dWF0aW9u
DQp3aGVyZSB0aGUgdXNlciByZXN0YXJ0cyB0aGUgZ3NzIGRhZW1vbi4gVGhlIGdvb2QgbmV3cyBp
cyB0aGF0IHRoZSBnc3MNCnVwY2FsbCBjb2RlIHRoYXQgdXNlcyBBRl9MT0NBTCBoYXNuJ3QgYmVl
biBtZXJnZWQgdXBzdHJlYW0geWV0LCBzbyB0aGF0DQpwYXJ0aWN1bGFyIGludGVyZmFjZSBpcyBu
b3QgeWV0IGxvY2tlZCBpbiBzdG9uZS4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5G
UyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29t
DQp3d3cubmV0YXBwLmNvbQ0K
