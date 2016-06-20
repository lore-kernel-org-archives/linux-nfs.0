Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:49648 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755350AbcFTPuZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 11:50:25 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Schumaker Anna <Anna.Schumaker@netapp.com>
CC: Viro Alexander <viro@ZenIV.linux.org.uk>,
        Oleg Drokin <green@linuxhacker.ru>, Fields Bruce <bfields@redhat.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Subject: Re: NFS/d_splice_alias breakage
Date: Mon, 20 Jun 2016 15:47:14 +0000
Message-ID: <3DBA217E-C08E-4145-8C25-326A57455991@primarydata.com>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru>
 <20160603033750.GL14480@ZenIV.linux.org.uk>
 <0C971585-6BFC-4665-832B-9B262F733BFC@linuxhacker.ru>
 <20160603042648.GN14480@ZenIV.linux.org.uk>
 <51139F5D-8CC8-4448-B3AB-5EF1B67E2D6C@linuxhacker.ru>
 <20160603055655.GQ14480@ZenIV.linux.org.uk>
 <D500FB60-CE33-4655-9995-70332B5945D2@linuxhacker.ru>
 <20160620140858.GJ14480@ZenIV.linux.org.uk>
 <d56d898b-0d6b-2d1a-9395-f95930325a32@Netapp.com>
In-Reply-To: <d56d898b-0d6b-2d1a-9395-f95930325a32@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIEp1biAyMCwgMjAxNiwgYXQgMTE6NDMsIEFubmEgU2NodW1ha2VyIDxBbm5hLlNjaHVt
YWtlckBuZXRhcHAuY29tPiB3cm90ZToNCj4gDQo+IEhpLA0KPiANCj4gT24gMDYvMjAvMjAxNiAx
MDowOCBBTSwgQWwgVmlybyB3cm90ZToNCj4+IE9uIE1vbiwgSnVuIDIwLCAyMDE2IGF0IDA5OjI1
OjEyQU0gLTA0MDAsIE9sZWcgRHJva2luIHdyb3RlOg0KPj4+IEl0IGxvb2tzIGxpa2UgdGhpcyBw
YXRjaCB3YXMgdG90YWxseSBmb3Jnb3R0ZW4/DQo+Pj4gSSBkb24ndCBzZWUgaXQgaW4gbmVpdGhl
ciB2ZnMgbm9yIG5mcyB0cmVlcyBhbmQgeWV0IGl0IGZpeGVzIGEgdmVyeSBlYXN5IHRvIGNhdXNl
DQo+Pj4gY3Jhc2ggaW4gbmZzIGNvZGUuIEFuZCBJIHRoaW5rIGl0J3MgdW5yZWxhdGVkIHRvIHRo
ZSBvdGhlciBwYXJhbGxlbCBjYXNlIHRvby4NCj4+IA0KPj4gSSBhc3N1bWVkIGl0IHdvdWxkIGdv
IHRocm91Z2ggTkZTIHRyZWUsIHNlZWluZyB0aGF0IGl0J3MgTkZTLXNwZWNpZmljIGFuZA0KPj4g
aGFzIG5vdGhpbmcgdG8gZG8gd2l0aCBhbnkgb2YgdGhlIHJlY2VudCBWRlMgY2hhbmdlcyAob29w
cyBpcyB0cmlnZ2VyYWJsZQ0KPj4gc3RhcnRpbmcgZnJvbSAzLjExKTsgSSBjYW4gY2VydGFpbmx5
IHB1dCBpdCB0aHJvdWdoIHZmcy5naXQsIGFuZCB0aGVyZQ0KPj4gd2lsbCBiZSBjaGFuZ2VzIG5l
YXJieSwgYnV0IHRoaXMgb25lIHNob3VsZCBnbyBpbnRvIC1zdGFibGUgYXMgYSBzZXBhcmF0ZQ0K
Pj4gcGF0Y2guDQo+IA0KPiBJIHdhcyBnb2luZyB0byBwdXQgdG9nZXRoZXIgYW4gbmZzIGJ1Z2Zp
eGVzIHB1bGwgcmVxdWVzdCBmb3IgNC43IHRoaXMgd2Vlaywgc28gSSBjYW4gaW5jbHVkZSB0aGUg
cGF0Y2ggdGhlcmUgaWYgdGhpcyBpcyBlYXN5IHRvIGhpdC4NCj4gDQoNCkhpIEFubmEsDQoNClBs
ZWFzZSBkbywgYW5kIHBsZWFzZSBrZWVwIHRoZSBDYzogc3RhYmxl4oCmDQoNClRoYW5rcw0KIFRy
b25kDQoNCg==

