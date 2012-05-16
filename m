Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48370 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758514Ab2EPRNg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 13:13:36 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Peng Tao <tao.peng@emc.com>
Subject: Re: [PATCH 2/2] NFS: call block plug around direct read
Date: Wed, 16 May 2012 17:12:46 +0000
Message-ID: <1337188394.3008.3.camel@lade.trondhjem.org>
References: <1337096303-2516-1-git-send-email-bergwolf@gmail.com>
	 <1337096303-2516-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1337096303-2516-2-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA1LTE1IGF0IDIzOjM4ICswODAwLCBQZW5nIFRhbyB3cm90ZToNCj4gU2ln
bmVkLW9mZi1ieTogUGVuZyBUYW8gPHRhby5wZW5nQGVtYy5jb20+DQo+IC0tLQ0KPiAgZnMvbmZz
L2RpcmVjdC5jIHwgICAgMyArKysNCj4gIDEgZmlsZXMgY2hhbmdlZCwgMyBpbnNlcnRpb25zKCsp
LCAwIGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2ZzL25mcy9kaXJlY3QuYyBiL2Zz
L25mcy9kaXJlY3QuYw0KPiBpbmRleCBhNDg1NTYwLi4yY2YzYjQ1IDEwMDY0NA0KPiAtLS0gYS9m
cy9uZnMvZGlyZWN0LmMNCj4gKysrIGIvZnMvbmZzL2RpcmVjdC5jDQo+IEBAIC04NjYsNiArODY2
LDcgQEAgc3NpemVfdCBuZnNfZmlsZV9kaXJlY3RfcmVhZChzdHJ1Y3Qga2lvY2IgKmlvY2IsIGNv
bnN0IHN0cnVjdCBpb3ZlYyAqaW92LA0KPiAgCXNzaXplX3QgcmV0dmFsID0gLUVJTlZBTDsNCj4g
IAlzdHJ1Y3QgZmlsZSAqZmlsZSA9IGlvY2ItPmtpX2ZpbHA7DQo+ICAJc3RydWN0IGFkZHJlc3Nf
c3BhY2UgKm1hcHBpbmcgPSBmaWxlLT5mX21hcHBpbmc7DQo+ICsJc3RydWN0IGJsa19wbHVnIHBs
dWc7DQo+ICAJc2l6ZV90IGNvdW50Ow0KPiAgDQo+ICAJY291bnQgPSBpb3ZfbGVuZ3RoKGlvdiwg
bnJfc2Vncyk7DQo+IEBAIC04ODYsNyArODg3LDkgQEAgc3NpemVfdCBuZnNfZmlsZV9kaXJlY3Rf
cmVhZChzdHJ1Y3Qga2lvY2IgKmlvY2IsIGNvbnN0IHN0cnVjdCBpb3ZlYyAqaW92LA0KPiAgDQo+
ICAJdGFza19pb19hY2NvdW50X3JlYWQoY291bnQpOw0KPiAgDQo+ICsJYmxrX3N0YXJ0X3BsdWco
JnBsdWcpOw0KPiAgCXJldHZhbCA9IG5mc19kaXJlY3RfcmVhZChpb2NiLCBpb3YsIG5yX3NlZ3Ms
IHBvcyk7DQo+ICsJYmxrX2ZpbmlzaF9wbHVnKCZwbHVnKTsNCj4gIAlpZiAocmV0dmFsID4gMCkN
Cj4gIAkJaW9jYi0+a2lfcG9zID0gcG9zICsgcmV0dmFsOw0KPiAgDQoNCkRpdHRvLiBUaGlzIGlz
IG5vdCBnZW5lcmljLi4uDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50
IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5l
dGFwcC5jb20NCg0K
