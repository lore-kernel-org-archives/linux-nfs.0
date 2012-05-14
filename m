Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7318 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757353Ab2ENXJB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 May 2012 19:09:01 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Andreas Dilger <adilger@dilger.ca>
CC: "J. Bruce Fields" <bfields@fieldses.org>, "Theodore Ts'o" <tytso@mit.edu>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Date: Mon, 14 May 2012 23:08:19 +0000
Message-ID: <1337036918.2522.32.camel@lade.trondhjem.org>
References: <20120514140618.GA29902@fieldses.org>
	 <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
In-Reply-To: <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA1LTE0IGF0IDA5OjAyIC0wNjAwLCBBbmRyZWFzIERpbGdlciB3cm90ZToN
Cj4gT24gMjAxMi0wNS0xNCwgYXQgODowNiwgIkouIEJydWNlIEZpZWxkcyIgPGJmaWVsZHNAZmll
bGRzZXMub3JnPiB3cm90ZToNCj4gPiBrbmZzZCBuZWVkcyBpX3ZlcnNpb24gdXBkYXRlcyBvbiwg
YXMgd2lsbCB1c2Vyc3BhY2UgbmZzIHNlcnZlcnMgYW5kDQo+ID4gcHJvYmFibHkgb3RoZXJzLg0K
PiA+IA0KPiA+IFRoZSBvbmx5IGVmZmVjdHMgYXJlIHRoYXQgaW5vZGUtPmlfdmVyc2lvbiBpcyBi
dW1wZWQgKHVuZGVyIHRoZSBpX2xvY2spDQo+ID4gaW4gbW9yZSBwbGFjZXMsIGFuZCB0aGF0IC0+
ZGlydHlfaW5vZGUoSV9ESVJUWV9EQVRBU1lOQykgbWF5IGJlIGNhbGxlZA0KPiA+IG1vcmUgZnJl
cXVlbnRseSB0aGFuIG9uY2UgcGVyIGppZmZ5IG9uIHdyaXRlIChzZWUgZmlsZV91cGRhdGVfdGlt
ZSkuDQo+ID4gSG93ZXZlciB0aGUgbGF0dGVyIGFwcGVhcnMgdG8gYmUgbW9zdGx5IGEgbm8tb3Ag
aW4gdGhhdCBjYXNlLg0KPiANCj4gSSB0aG91Z2h0IHRoaXMgY2FuIGhhdmUgbm90aWNlYWJsZSBw
ZXJmb3JtYW5jZSBpbXBhY3QsIHNpbmNlIGV4dDRfbWFya19pbm9kZV9kaXJ0eSgpIGlzIHF1aXRl
IGhlYXZ5d2VpZ2h0Pw0KPiANCj4gVGhpcyBpcyBvbmUgb2YgdGhlIHJlYXNvbnMgdGhhdCB0aGUg
aV92ZXJzaW9uIHVwZGF0ZSBpcyBjb25kaXRpb25hbC4gSWYgc29tZW9uZSBpcyBleHBvcnRpbmcg
YSBmaWxlc3lzdGVtIGZyb20gdXNlcnNwYWNlIHRoZSBzaG91bGQgYmUgYWJsZSB0byB0dXJuIHRo
aXMgb24gYXMgYSBtb3VudCBvcHRpb24sIGFuZCBrbmZzZCBjb3VsZCBkbyBpdCBmcm9tIGluc2lk
ZSB0aGUga2VybmVsLiBXaHkgYWRkIG92ZXJoZWFkIHdoZW4gaXQgaXMgbm90IG5lZWRlZD8NCg0K
Tm8uIEhhdmluZyBrbmZzZCBkb2luZyBzb21ldGhpbmcgbGlrZSB0aGF0IHVuZGVyIHRoZSBjb3Zl
cnMgaXMgYSBCQUQNCmlkZWEuIEl0IGlzIHdheSB0b28gZWFzeSB0byBnZXQgaW50byBzaXR1YXRp
b25zIHdoZXJlIHNvbWVvbmUgc3RhcnRzDQpjaGFuZ2luZyBmaWxlcyBhZnRlciB0aGUgbW91bnQg
YW5kIGJlZm9yZSBrbmZzZCBpcyBzdGFydGVkLiBBcyBzb29uIGFzDQp5b3UgYWxsb3cgZmlsZXMg
dG8gYmUgY2hhbmdlZCB3aXRob3V0IGlfdmVyc2lvbiBjaGFuZ2luZywgdGhlbiB5b3UgYXJlDQpz
ZXR0aW5nIHlvdXJzZWxmIHVwIGZvciBmdXR1cmUgY29ycnVwdGlvbi4NCg0KSWRlYWxseSwgYW4g
TkZTdjQtZXhwb3J0ZWQgZmlsZXN5c3RlbSBzaG91bGQgYmUgcmVxdWlyZWQgdG8gc2V0IHRoZQ0K
dHVuZTJmcyBtb3VudF9vcHRzIHRvIGluY2x1ZGUgdGhlICdpX3ZlcnNpb24nIGZsYWcgdG8gbWFr
ZSBpdCBoYXJkIHRvDQppbmFkdmVydGVudGx5IG1vdW50IHRoYXQgZmlsZXN5c3RlbSB3aXRob3V0
IGl0Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVy
DQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoN
Cg==
