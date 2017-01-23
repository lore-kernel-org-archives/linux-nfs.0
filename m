Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:56145 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751194AbdAWRma (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2017 12:42:30 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: hch <hch@lst.de>
CC: "bfields@redhat.com" <bfields@redhat.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: special case truncates some more
Date: Mon, 23 Jan 2017 17:42:16 +0000
Message-ID: <1485193333.34422.5.camel@primarydata.com>
References: <1485104060-15209-1-git-send-email-hch@lst.de>
         <1485104060-15209-2-git-send-email-hch@lst.de>
         <1485174116.2786.7.camel@poochiereds.net> <20170123123348.GA28102@lst.de>
         <20170123153615.GA32201@lst.de> <1485186729.2786.11.camel@poochiereds.net>
         <20170123160559.GA786@lst.de> <1485188442.41392.1.camel@primarydata.com>
         <20170123162607.GA21199@lst.de> <1485192333.34422.1.camel@primarydata.com>
         <20170123173817.GA22777@lst.de>
In-Reply-To: <20170123173817.GA22777@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDE3LTAxLTIzIGF0IDE4OjM4ICswMTAwLCBoY2ggd3JvdGU6DQo+IE9uIE1vbiwg
SmFuIDIzLCAyMDE3IGF0IDA1OjI1OjM0UE0gKzAwMDAsIFRyb25kIE15a2xlYnVzdCB3cm90ZToN
Cj4gPiBJbiB0aGF0IGNhc2UgdGhlIGNsaWVudCB3aWxsIGJlIHJlcXVpcmVkIHRvIGNvbnRpbnVl
IHRvIG5lZWQgdG8NCj4gPiBzZW5kDQo+ID4gbXRpbWUvY3RpbWUgaW4gb3JkZXIgdG8gZW5zdXJl
IHRoYXQgd2UgZ2V0IHRoZSBzYW1lIGhpc3RvcmljYWwNCj4gPiBzZW1hbnRpY3Mgdy5yLnQuIGZ0
cnVuY2F0ZSgpIHZzIHRydW5jYXRlKCkuDQo+ID4gDQo+ID4gSU9XOiBJdCdzIG5vdCBhIHF1ZXN0
aW9uIG9mIHRoZSBjbGllbnQgYmVpbmcgbGF6eSBhYm91dCBjbGVhcmluZw0KPiA+IHRoZQ0KPiA+
IGZsYWdzLiBJdCdzIGEgcXVlc3Rpb24gb2YgZW5mb3JjaW5nIHRoZSBjb3JyZWN0IHNlbWFudGlj
cy4NCj4gDQo+IE5vLCB0aGUgTkZTIHNwZWMgcmVxdWlyZXMgdGhlIHNlcnZlciB0byBhZGQgYW4g
aW1wbGljaXQgbXRpbWUNCj4gd2hlbiB0aGUgc2l6ZSBhY3R1YWxseSBjaGFuZ2VzLsKgwqBJbiBm
YWN0IHRoZSBjdXJyZW50IGNvZGUgaGFzIGENCj4gY29tbWVudA0KPiBwb2ludGluZyB0byB0aGUg
c2VjdGlvbjoNCj4gDQo+IMKgKiBSRkM1NjYxLCBTZWN0aW9uIDE4LjMwLjQ6DQo+IMKgKsKgwqDC
oENoYW5naW5nIHRoZSBzaXplIG9mIGEgZmlsZSB3aXRoIFNFVEFUVFIgaW5kaXJlY3RseQ0KPiDC
oCrCoMKgwqBjaGFuZ2VzIHRoZSB0aW1lX21vZGlmeSBhbmQgY2hhbmdlIGF0dHJpYnV0ZXMuDQo+
IMKgKg0KPiDCoCogKGFuZCBzaW1pbGFyIGZvciB0aGUgb2xkZXIgUkZDcykNCj4gDQo+IEFuZCB5
ZXMsIEkndmUgZG91YmxlIGNoZWNrZWQgdGhhdCBpbiB0aGUgUkZDLg0KDQpTdXJlLCBidXQgdHJ1
bmNhdGUoKSBvbiBQT1NJWCBhZGRzIHRoZSByZXF1aXJlbWVudCB0aGF0IHRoZSBtdGltZS9jdGlt
ZQ0Kc2hvdWxkIGNoYW5nZSBldmVuIHdoZW4gdGhlIGZpbGUgc2l6ZSBpcyBub3QgY2hhbmdlZC4N
Cg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgUHJp
bWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

