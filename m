Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7976 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754706Ab2DZSLo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 14:11:44 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 2/3] SUNRPC: traverse clients tree on PipeFS event
Date: Thu, 26 Apr 2012 18:11:42 +0000
Message-ID: <1335463902.9701.35.camel@lade.trondhjem.org>
References: <20120420141419.10848.84280.stgit@localhost6.localdomain6>
	 <20120420141925.10848.90395.stgit@localhost6.localdomain6>
In-Reply-To: <20120420141925.10848.90395.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTA0LTIwIGF0IDE4OjE5ICswNDAwLCBTdGFuaXNsYXYgS2luc2J1cnNreSB3
cm90ZToNCg0KPiArc3RhdGljIGludCBfX3JwY19waXBlZnNfZXZlbnQoc3RydWN0IHJwY19jbG50
ICpjbG50LCB1bnNpZ25lZCBsb25nIGV2ZW50LA0KPiArCQkJCXN0cnVjdCBzdXBlcl9ibG9jayAq
c2IpDQo+ICt7DQo+ICsJaW50IGVycm9yOw0KPiArDQo+ICsJaWYgKCFycGNfY2xudF9za2lwX2V2
ZW50KGNsbnQsIGV2ZW50KSkgew0KPiArCQllcnJvciA9IF9fcnBjX2NsbnRfaGFuZGxlX2V2ZW50
KGNsbnQsIGV2ZW50LCBzYik7DQo+ICsJCWlmIChlcnJvcikNCj4gKwkJCXJldHVybiBlcnJvcjsN
Cj4gKwl9DQo+ICsJaWYgKGNsbnQgIT0gY2xudC0+Y2xfcGFyZW50KQ0KPiArCQlyZXR1cm4gX19y
cGNfcGlwZWZzX2V2ZW50KGNsbnQtPmNsX3BhcmVudCwgZXZlbnQsIHNiKTsNCj4gKwlyZXR1cm4g
MDsNCj4gK30NCg0KSGkgU3RhbmlzbGF2LA0KDQpSZWN1cnNpb24gaW4gdGhlIGtlcm5lbCBpcyBn
ZW5lcmFsbHkgZnJvd25lZCB1cG9uIGR1ZSB0byB0aGUgc3RhY2sgc2l6ZQ0KbGltaXRzLiBDb3Vs
ZCB5b3UgcGxlYXNlIHJld3JpdGUgdGhlIGFib3ZlIGludG8gYSBzaW1wbGUgbG9vcC4gU29tZXRo
aW5nDQphbG9uZyB0aGUgbGluZXMgb2Y6DQoNCglmb3IoOzspIHsNCgkJLi4uDQoNCgkJaWYgKGNs
bnQgPT0gY2xudC0+Y2xfcGFyZW50KQ0KCQkJYnJlYWs7DQoJCWNsbnQgPSBjbG50LT5jbF9wYXJl
bnQ7DQoJfQ0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFp
bmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29t
DQoNCg==
