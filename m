Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60927 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933237Ab2CZTBP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Mar 2012 15:01:15 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
CC: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>
Subject: Re: unlink within an open directory stream
Date: Mon, 26 Mar 2012 19:01:09 +0000
Message-ID: <1332788474.20469.9.camel@lade.trondhjem.org>
References: <1974178651.72.1332788099966.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1974178651.72.1332788099966.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTAzLTI2IGF0IDE0OjU1IC0wNDAwLCBNYXR0IFcuIEJlbmphbWluIHdyb3Rl
Og0KPiBIaSwNCj4gDQo+IEJvYXo6ICB3ZSBkbyBub3QgYW55IGxvbmdlciBzZW5kIGEgcmVhZGRp
ciBpbmRleC4gIFdlIGRvIHNlbmQgYSBjb29raWV2ZXJmLg0KDQpVaGguLi4gVGhhdCB3b3VsZCBi
ZSBzbyBicm9rZW4sIHRoYXQgSSBjYW4ndCBpbWFnaW5lIHRoYXQgaXMgdHJ1ZS4uLg0KDQo+IEZp
c3Qgb2YgYWxsLCBJIGhhdmVuJ3QgZXN0YWJsaXNoZWQgdGhhdCB0aGUgaXNzdWUgd2UncmUgYWN0
dWFsbHkgb2JzZXJ2aW5nIGlzIGNhdXNlZA0KPiBieSB0aGUgTGludXggY2xpZW50IHNlbmRpbmcg
b2xkIGNvb2tpZXMgdG8gcmVhZGRpcihzb21ldGhpbmcpLiAgSG93ZXZlciwgaWYgaXQgaXMsDQo+
IGl0J3MgaW4gbm8gd2F5IGJldHRlciB0byB0cnkgdG8gbWFrZSBjb29raWVzICJtb3JlIHBlcnNp
c3RlbnQuIiAgTm9yIHNob3VsZCB0aGUgTGludXgNCj4gY2xpZW50IGJlIGV4cGVjdGluZyBpdC4g
IFRoZSBhc3N1bXB0aW9uIGlzIHNpbXBseSBmbGF3ZWQuICBUaGUgcHJvdG9jb2wgaW50cm9kdWNl
ZA0KPiBjb29raWUgdmVyaWZpZXIgKGEgTE9ORyB0aW1lIGFnbykgZm9yIGEgcmVhc29uLg0KDQpC
dWxsc2hpdC4uLiBUaGUgY29va2llIHZlcmlmaWVyIGlzIHVuaW1wbGVtZW50YWJsZS4gRmVlbCBm
cmVlIHRvIHRyeSBvcg0KdG8gc2hvdyBtZSBhbiBpbXBsZW1lbnRhdGlvbiB0aGF0IHdvcmtzLiBI
b3dldmVyIEkgcmVmdXNlIHRvIHdhc3RlIGFueQ0KbW9yZSBvZiBteSB0aW1lIHRyeWluZyB0byBt
YWtlIHRoYXQgY3JhcCB3b3JrLCBoYXZpbmcgYWxyZWFkeSB3YXN0ZWQNCnNldmVyYWwgbW9udGhz
IG9mIG15IGxpZmUgZG9pbmcganVzdCB0aGF0Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGlu
dXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFw
cC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
