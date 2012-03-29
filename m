Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:6284 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759080Ab2C2Qyy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Mar 2012 12:54:54 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Orion Poplawski <orion@cora.nwra.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] open(O_CREAT) returns EEXISTS on symbolic link created
 on another system until stat()ed
Date: Thu, 29 Mar 2012 16:54:46 +0000
Message-ID: <1333040091.5547.32.camel@lade.trondhjem.org>
References: <loom.20120329T182500-467@post.gmane.org>
In-Reply-To: <loom.20120329T182500-467@post.gmane.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTAzLTI5IGF0IDE2OjI4ICswMDAwLCBPcmlvbiBQb3BsYXdza2kgd3JvdGU6
DQo+IEkgZmlsZWQgYSBidWcgaGVyZTogaHR0cHM6Ly9idWd6aWxsYS5yZWRoYXQuY29tL3Nob3df
YnVnLmNnaT9pZD04MDgxMTINCj4gDQo+IERlc2NyaXB0aW9uIG9mIHByb2JsZW06DQo+IA0KPiBj
bGllbnQgQToNCj4gdG91Y2ggYmxhaA0KPiBsbiAtcyBibGFoIGJsYWhsaW5rDQo+IA0KPiBjbGll
bnQgQjoNCj4gb3BlbigiYmxhaGxpbmsiLCBPX1JET05MWXxPX0NSRUFULCAwNjY2KSA9IC0xIEVF
WElTVCAoRmlsZSBleGlzdHMpDQoNClRoYXQgc291bmRzIG1vcmUgbGlrZSBhIHNlcnZlciBidWcu
IEl0IHNob3VsZG4ndCBiZSByZXBseWluZw0KTkZTNEVSUl9FWElTVCBoZXJlLCBzaW5jZSB0aGlz
IGlzbid0IGFuIGV4Y2x1c2l2ZSBjcmVhdGU7IGl0IHNob3VsZA0KcmF0aGVyIGJlIHJlcGx5aW5n
IHdpdGggTkZTNEVSUl9TWU1MSU5LLg0KDQpXaGljaCBzZXJ2ZXIgYXJlIHlvdSB0ZXN0aW5nIGFn
YWluc3QsIGFuZCB3aGF0IGRvZXMgdGhlIHdpcmVzaGFyayB0cmFjZQ0Kc2hvdz8NCg0KLS0gDQpU
cm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRy
b25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
