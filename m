Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:51109 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753988AbdCKPqY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Mar 2017 10:46:24 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "kolga@netapp.com" <kolga@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] PNFS dont retry some error when MDS=DS
Date: Sat, 11 Mar 2017 15:46:17 +0000
Message-ID: <1489247175.3260.5.camel@primarydata.com>
References: <CAN-5tyEe9txY5CmcZLOE4du=modRSaxKm8uLLT44YtKmSgAOgg@mail.gmail.com>
         <20170310213715.38258-1-kolga@netapp.com>
In-Reply-To: <20170310213715.38258-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE3LTAzLTEwIGF0IDE2OjM3IC0wNTAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gSWYgd2Ugc2VudCBhbiBvcGVyYXRpb24gdG8gdGhlICJEUyIgYW5kIGdvdCBhbiBlcnJv
ciwgdGhlIGNvZGUNCj4gcmVzZW5kcw0KPiB0byAiTURTIiBidXQgd2hlbiB0aGV5IGFyZSB0aGUg
c2FtZSwgaXQgZ2V0cyB0aGUgc2FtZSBlcnJvciBhbmQgZ29lcw0KPiBpbnRvIHRoZSBpbmZpbml0
ZSBsb29wLiBFeGFtcGxlIHdhcyBDT01NSVQgZ2V0dGluZyBFQUNDRVMuDQo+IA0KDQpUaGUgY29y
cmVjdCBiZWhhdmlvdXIgd2hlbiBnZXR0aW5nIEVBQ0NFUyBmcm9tIGEgQ09NTUlUIHRvIHRoZSBN
RFMNCndvdWxkIGJlIHRvIHJldHJ5IHRoZSBlbnRpcmUgc2VyaWVzIG9mIFdSSVRFIGNhbGxzIHdp
dGggc3RhYmxlIHdyaXRlcy4NCklmIHRoZSBzZXJ2ZXIgdGhlbiByZXR1cm5zIHdpdGggYW55dGhp
bmcgb3RoZXIgdGhhbiBGSUxFX1NZTkMsIHRoZW4NCkVJTy4NCg0KV2h5IGlzIHRoZSBzZXJ2ZXIg
ZmFpbGluZyB0aGUgQ09NTUlUIGhlcmUgaWYgdGhlIGNsaWVudCB0aGlua3MgaXQgc2VudA0KdW5z
dGFibGUgd3JpdGVzPw0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBt
YWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K

