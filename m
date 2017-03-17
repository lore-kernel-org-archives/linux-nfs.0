Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:29227 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751018AbdCQMxl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Mar 2017 08:53:41 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "elena.reshetova@intel.com" <elena.reshetova@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "ralf@linux-mips.org" <ralf@linux-mips.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "ishkamiel@gmail.com" <ishkamiel@gmail.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
        "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jreuter@yaina.de" <jreuter@yaina.de>,
        "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>,
        "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "dwindsor@gmail.com" <dwindsor@gmail.com>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "zyan@redhat.com" <zyan@redhat.com>,
        "sage@redhat.com" <sage@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "vyasevich@gmail.com" <vyasevich@gmail.com>,
        "linux-x25@vger.kernel.org" <linux-x25@vger.kernel.org>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>
Subject: Re: [PATCH 01/23] net, sunrpc: convert rpc_cred.cr_count from
 atomic_t to refcount_t
Date: Fri, 17 Mar 2017 12:50:12 +0000
Message-ID: <1489755011.6453.1.camel@primarydata.com>
References: <1489752646-8749-1-git-send-email-elena.reshetova@intel.com>
         <1489752646-8749-2-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1489752646-8749-2-git-send-email-elena.reshetova@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE3LTAzLTE3IGF0IDE0OjEwICswMjAwLCBFbGVuYSBSZXNoZXRvdmEgd3JvdGU6
DQo+IHJlZmNvdW50X3QgdHlwZSBhbmQgY29ycmVzcG9uZGluZyBBUEkgc2hvdWxkIGJlDQo+IHVz
ZWQgaW5zdGVhZCBvZiBhdG9taWNfdCB3aGVuIHRoZSB2YXJpYWJsZSBpcyB1c2VkIGFzDQo+IGEg
cmVmZXJlbmNlIGNvdW50ZXIuIFRoaXMgYWxsb3dzIHRvIGF2b2lkIGFjY2lkZW50YWwNCj4gcmVm
Y291bnRlciBvdmVyZmxvd3MgdGhhdCBtaWdodCBsZWFkIHRvIHVzZS1hZnRlci1mcmVlDQo+IHNp
dHVhdGlvbnMuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBFbGVuYSBSZXNoZXRvdmEgPGVsZW5hLnJl
c2hldG92YUBpbnRlbC5jb20+DQo+IFNpZ25lZC1vZmYtYnk6IEhhbnMgTGlsamVzdHJhbmQgPGlz
aGthbWllbEBnbWFpbC5jb20+DQo+IFNpZ25lZC1vZmYtYnk6IEtlZXMgQ29vayA8a2Vlc2Nvb2tA
Y2hyb21pdW0ub3JnPg0KPiBTaWduZWQtb2ZmLWJ5OiBEYXZpZCBXaW5kc29yIDxkd2luZHNvckBn
bWFpbC5jb20+DQo+IC0tLQ0KPiDCoGluY2x1ZGUvbGludXgvc3VucnBjL2F1dGguaCB8wqDCoDgg
KysrKy0tLS0NCj4gwqBuZXQvc3VucnBjL2F1dGguY8KgwqDCoMKgwqDCoMKgwqDCoMKgwqB8IDEy
ICsrKysrKy0tLS0tLQ0KPiDCoDIgZmlsZXMgY2hhbmdlZCwgMTAgaW5zZXJ0aW9ucygrKSwgMTAg
ZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9zdW5ycGMvYXV0
aC5oDQo+IGIvaW5jbHVkZS9saW51eC9zdW5ycGMvYXV0aC5oDQo+IGluZGV4IGIxYmM2MmIuLmJk
MzZlMGIgMTAwNjQ0DQo+IC0tLSBhL2luY2x1ZGUvbGludXgvc3VucnBjL2F1dGguaA0KPiArKysg
Yi9pbmNsdWRlL2xpbnV4L3N1bnJwYy9hdXRoLmgNCj4gQEAgLTE1LDcgKzE1LDcgQEANCj4gwqAj
aW5jbHVkZSA8bGludXgvc3VucnBjL21zZ19wcm90Lmg+DQo+IMKgI2luY2x1ZGUgPGxpbnV4L3N1
bnJwYy94ZHIuaD4NCj4gwqANCj4gLSNpbmNsdWRlIDxsaW51eC9hdG9taWMuaD4NCj4gKyNpbmNs
dWRlIDxsaW51eC9yZWZjb3VudC5oPg0KPiDCoCNpbmNsdWRlIDxsaW51eC9yY3VwZGF0ZS5oPg0K
PiDCoCNpbmNsdWRlIDxsaW51eC91aWRnaWQuaD4NCj4gwqAjaW5jbHVkZSA8bGludXgvdXRzbmFt
ZS5oPg0KPiBAQCAtNjgsNyArNjgsNyBAQCBzdHJ1Y3QgcnBjX2NyZWQgew0KPiDCoCNlbmRpZg0K
PiDCoAl1bnNpZ25lZCBsb25nCQljcl9leHBpcmU7CS8qIHdoZW4gdG8gZ2MNCj4gKi8NCj4gwqAJ
dW5zaWduZWQgbG9uZwkJY3JfZmxhZ3M7CS8qIHZhcmlvdXMNCj4gZmxhZ3MgKi8NCj4gLQlhdG9t
aWNfdAkJY3JfY291bnQ7CS8qIHJlZiBjb3VudCAqLw0KPiArCXJlZmNvdW50X3QJCWNyX2NvdW50
OwkvKiByZWYgY291bnQgKi8NCj4gDQoNCk5BQ0suIFRoYXQncyBnb2luZyB0byBiZSBoaXR0aW5n
IFdBUk5fT05DRSghcmVmY291bnRfaW5jX25vdF96ZXJvKHIpLA0KInJlZmNvdW50X3Q6IGluY3Jl
bWVudCBvbiAwOyB1c2UtYWZ0ZXItZnJlZS5cbiIpIGxpa2UgdGhlcmUncyBubw0KdG9tb3Jyb3cu
Li4NCg0KUGxlYXNlIHN0b3Agd2l0aCB0aGVzZSBhdXRvbWF0ZWQgY29udmVyc2lvbnMuIFRoZXkg
YXJlIGdvaW5nIHRvIGNhdXNlIGENCmxvdCBtb3JlIGJ1Z3MgdGhhbiB0aGV5IGZpeC4NCg0KLS0g
DQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgUHJpbWFyeURh
dGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

