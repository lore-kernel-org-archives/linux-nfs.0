Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:1872 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932676Ab3GVT2A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 15:28:00 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 09/19] NFS: Add a "struct nfs_server *" argument to
 nfs4_sequence_done()
Date: Mon, 22 Jul 2013 19:27:58 +0000
Message-ID: <1374521276.7972.31.camel@leira.trondhjem.org>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
	 <20130712163245.1444.48096.stgit@seurat.1015granger.net>
In-Reply-To: <20130712163245.1444.48096.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEzLTA3LTEyIGF0IDEyOjMyIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
Rm9yIE5GU3Y0LjEsIGEgc2Vzc2lvbiBzbG90IHRhYmxlIHJlZmVyZW5jZSBpcyBwYXNzZWQgdG8N
Cj4gbmZzNF9zZXF1ZW5jZV9kb25lKCkuDQo+IA0KPiBGb3IgTkZTdjQuMCwgdHJhbnNwb3J0IHN0
YXRlIGlzIG1hbmFnZWQgaW4gdGhlIG5mc19jbGllbnQgdGhhdCBvd25zDQo+IHRoaXMgbmZzX3Nl
cnZlci4gIFRoZSBuZnNfc2VydmVyIHN0cnVjdCBtdXN0IGJlIHBhc3NlZCB0bw0KPiBuZnM0X3Nl
cXVlbmNlX2RvbmUoKSB0byBtYWtlIGl0IGF2YWlsYWJsZSB0byB0aGUgZnVuY3Rpb25zIGRlYWxp
bmcNCj4gd2l0aCB0cmFuc3BvcnQgYmxvY2tpbmcuDQoNCldoeT8gQ2FuJ3QgNC4wIGp1c3QgcmV1
c2UgdGhlIGV4aXN0aW5nIHY0LjEgc2Vzc2lvbiBzbG90IHRhYmxlIGZvciB0aGlzPw0KDQotLSAN
ClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0K
VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQo=
