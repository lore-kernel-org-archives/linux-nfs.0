Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:57990 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752726AbdEMQK1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 13 May 2017 12:10:27 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: hch <hch@lst.de>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: remove function pointer casts and constify function tables
Date: Sat, 13 May 2017 16:10:21 +0000
Message-ID: <1494691819.31377.1.camel@primarydata.com>
References: <20170512161701.22468-1-hch@lst.de>
         <1494620040.19467.1.camel@primarydata.com> <20170513072557.GA14602@lst.de>
In-Reply-To: <20170513072557.GA14602@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU2F0LCAyMDE3LTA1LTEzIGF0IDA5OjI1ICswMjAwLCBoY2ggd3JvdGU6DQo+IE9uIEZyaSwg
TWF5IDEyLCAyMDE3IGF0IDA4OjE0OjAzUE0gKzAwMDAsIFRyb25kIE15a2xlYnVzdCB3cm90ZToN
Cj4gPiBIb3cgc2hvdWxkIHdlIHByb2NlZWQgdG8gbWVyZ2UgdGhpcyBzZXJpZXM/IEdpdmVuIHRo
YXQgaXQgaXMNCj4gPiBjaGFuZ2luZyBhDQo+ID4gbG90IG9mIGZ1bmN0aW9uIGhlYWRlcnMsIGJ1
dCBub3QgYWN0dWFsbHkgY2hhbmdpbmcgZnVuY3Rpb25hbGl0eSwNCj4gPiBtaWdodA0KPiA+IGl0
IGJlIHBvc3NpYmxlIHRvIG1lcmdlIGl0IG91dC1vZi1iYW5kIHdpdGggdGhlIG1lcmdlIHdpbmRv
dyAoZS5nLg0KPiA+IG5leHQNCj4gPiB3ZWVrKSBpbiBvcmRlciB0byBtaW5pbWlzZSB0aGUgYW1v
dW50IG9mIHdvcmsgbmVlZGVkIHRvIGZpeCB1cA0KPiA+IGZ1dHVyZQ0KPiA+IHBhdGNoZXM/DQo+
IA0KPiBJJ2QgYmUgb2sgd2l0aCB0aGF0LCBidXQgc29tZW9uZSB3b3VsZCBoYXZlIHRvIHNpZ24g
dXAgdG8gdGFrZSB0aGUNCj4gaGVhdCB3aGVuIExpbnVzIGRvZXNuJ3QgbGlrZSBpdCwgYW5kIGl0
IHdvbid0IGJlIG1lIDopDQoNCk1laC4uLiBMaW51cyBoYXRlcyB1cyBhbGwgYW55d2F5LCBzbyBJ
J20gZmluZSB3aXRoIHRha2luZyB0aGUgaGVhdCBvbg0KdGhhdC4NCg0KPiBPdGhlcndpYXNlIGEg
c2hhcmVkIHN0YWJsZSBicmFuY2ggc291bmRzIGZpbmUuwqDCoEkgY2FuIHByb3ZpZGUgb25lDQo+
IGZvciB5b3Ugb24gaW5mcmFkZWFkIG9yIG9uZSBvZiB5b3UgY291bGQgc2lnbiB1cCBmb3IgaXQu
DQo+IA0KDQpSaWdodCwgc28gdGhlIGFsdGVybmF0aXZlIGlzIHRoYXQgZWl0aGVyIEJydWNlIG9y
IEFubmEgbWVyZ2VzIHRoZSBmdWxsDQpzZXQsIGFuZCB0aGVuIGJvdGggcHVsbCB0aGF0IGNvbW1v
biBiYXNlIGludG8gdGhlaXIgbGludXgtbmV4dCBicmFuY2hlcw0Kb24gbGludXgtbmZzLm9yZywg
YW5kIHdlIHRoZW4gYXNrIGV2ZXJ5b25lIHRvIGRldmVsb3AgdGhlaXIgNC4xMw0KcGF0Y2hlcyBh
Z2FpbnN0IHRob3NlIGJyYW5jaGVzLiBUaGF0IHdvdWxkIHdvcmsgdG9vLi4uDQoNCi0tIA0KVHJv
bmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQp0
cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

