Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr730119.outbound.protection.outlook.com ([40.107.73.119]:53885
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727603AbeJTAUm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Oct 2018 20:20:42 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "olga.kornievskaia@gmail.com" <olga.kornievskaia@gmail.com>
CC: "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH v1 01/11] fs: Don't copy beyond the end of the file
Date: Fri, 19 Oct 2018 16:13:52 +0000
Message-ID: <4bbd2e38cf388629e50a9c1eb35a458786afa858.camel@hammerspace.com>
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
         <20181019152932.32462-2-olga.kornievskaia@gmail.com>
In-Reply-To: <20181019152932.32462-2-olga.kornievskaia@gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE4LTEwLTE5IGF0IDExOjI5IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gRnJvbTogQW5uYSBTY2h1bWFrZXIgPEFubmEuU2NodW1ha2VyQE5ldGFwcC5jb20+DQo+
IA0KPiBTaWduZWQtb2ZmLWJ5OiBBbm5hIFNjaHVtYWtlciA8QW5uYS5TY2h1bWFrZXJATmV0YXBw
LmNvbT4NCj4gLS0tDQo+ICBmcy9yZWFkX3dyaXRlLmMgfCAzICsrKw0KPiAgMSBmaWxlIGNoYW5n
ZWQsIDMgaW5zZXJ0aW9ucygrKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2ZzL3JlYWRfd3JpdGUuYyBi
L2ZzL3JlYWRfd3JpdGUuYw0KPiBpbmRleCAzOWI0YTIxLi5jNjA3OTBmIDEwMDY0NA0KPiAtLS0g
YS9mcy9yZWFkX3dyaXRlLmMNCj4gKysrIGIvZnMvcmVhZF93cml0ZS5jDQo+IEBAIC0xNTcwLDYg
KzE1NzAsOSBAQCBzc2l6ZV90IHZmc19jb3B5X2ZpbGVfcmFuZ2Uoc3RydWN0IGZpbGUNCj4gKmZp
bGVfaW4sIGxvZmZfdCBwb3NfaW4sDQo+ICAJaWYgKHVubGlrZWx5KHJldCkpDQo+ICAJCXJldHVy
biByZXQ7DQo+ICANCj4gKwlpZiAocG9zX2luID49IGlfc2l6ZV9yZWFkKGlub2RlX2luKSkNCj4g
KwkJcmV0dXJuIC1FSU5WQUw7DQo+ICsNCj4gIAlpZiAoIShmaWxlX2luLT5mX21vZGUgJiBGTU9E
RV9SRUFEKSB8fA0KPiAgCSAgICAhKGZpbGVfb3V0LT5mX21vZGUgJiBGTU9ERV9XUklURSkgfHwN
Cj4gIAkgICAgKGZpbGVfb3V0LT5mX2ZsYWdzICYgT19BUFBFTkQpKQ0KDQpUaGlzIHBhdGNoIHJl
cXVpcmVzIGFuIEFDSyBmcm9tIHRoZSBWRlMgbWFpbnRhaW5lcnMgaWYgSSdtIHRvIHB1c2ggaXQN
CnVwc3RyZWFtLg0KQ2M6IEFsIGFuZCBMaW51eC1mc2RldmVsLg0KDQotLSANClRyb25kIE15a2xl
YnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlr
bGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
