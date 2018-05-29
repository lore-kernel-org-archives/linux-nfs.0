Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-sn1nam02on0125.outbound.protection.outlook.com ([104.47.36.125]:62784
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934099AbeE2NwS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 May 2018 09:52:18 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>
Subject: Re: [PATCH 4/5] NFS: Pass "privileged" value to nfs4_call_sync()
Date: Tue, 29 May 2018 13:52:15 +0000
Message-ID: <a0d97b8d85ccba258a7219757035c8ef45636a1c.camel@hammerspace.com>
References: <20180504202252.5862-1-Anna.Schumaker@Netapp.com>
         <20180504202252.5862-5-Anna.Schumaker@Netapp.com>
In-Reply-To: <20180504202252.5862-5-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE4LTA1LTA0IGF0IDE2OjIyIC0wNDAwLCBzY2h1bWFrZXIuYW5uYUBnbWFpbC5j
b20gd3JvdGU6DQo+IEZyb206IEFubmEgU2NodW1ha2VyIDxBbm5hLlNjaHVtYWtlckBOZXRhcHAu
Y29tPg0KPiANCj4gVGhpcyBsZXRzIHVzIGNvbnZlcnQgYSBmZXcgb3RoZXIgdXNlcnMgb2Ygc3lu
Y2hyb25vdXMgUlBDIGNhbGxzIHRvDQo+IHRoZQ0KPiBuZnM0X2NhbGxfc3luYygpIGZ1bmN0aW9u
Lg0KPiANCj4gU2lnbmVkLW9mZi1ieTogQW5uYSBTY2h1bWFrZXIgPEFubmEuU2NodW1ha2VyQE5l
dGFwcC5jb20+DQo+IC0tLQ0KPiAgZnMvbmZzL25mczQycHJvYy5jIHwgIDggKystLS0NCj4gIGZz
L25mcy9uZnM0X2ZzLmggICB8ICAyICstDQo+ICBmcy9uZnMvbmZzNHByb2MuYyAgfCA3OCArKysr
KysrKysrKysrKysrKysrKysrLS0tLS0tLS0tLS0tLS0tLS0tLS0NCj4gLS0tLQ0KPiAgMyBmaWxl
cyBjaGFuZ2VkLCA0MiBpbnNlcnRpb25zKCspLCA0NiBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYg
LS1naXQgYS9mcy9uZnMvbmZzNDJwcm9jLmMgYi9mcy9uZnMvbmZzNDJwcm9jLmMNCj4gaW5kZXgg
NGQ0YTNkZjI4Nzc5Li43ZTlhMjA4OTQwZTIgMTAwNjQ0DQo+IC0tLSBhL2ZzL25mcy9uZnM0MnBy
b2MuYw0KPiArKysgYi9mcy9uZnMvbmZzNDJwcm9jLmMNCj4gQEAgLTQ3LDcgKzQ3LDcgQEAgc3Rh
dGljIGludCBfbmZzNDJfcHJvY19mYWxsb2NhdGUoc3RydWN0IHJwY19tZXNzYWdlDQo+ICptc2cs
IHN0cnVjdCBmaWxlICpmaWxlcCwNCj4gIAkJcmV0dXJuIC1FTk9NRU07DQo+ICANCj4gIAlzdGF0
dXMgPSBuZnM0X2NhbGxfc3luYyhzZXJ2ZXItPmNsaWVudCwgc2VydmVyLCBtc2csDQo+IC0JCQkJ
JmFyZ3Muc2VxX2FyZ3MsICZyZXMuc2VxX3JlcywgMCk7DQo+ICsJCQkJJmFyZ3Muc2VxX2FyZ3Ms
ICZyZXMuc2VxX3JlcywgMCwgMCk7DQoNClRoaXMgaXMgZ2V0dGluZyBvdmVybHkgY29tcGxpY2F0
ZWQuIE5vdGUgdGhhdCB0aGUgY29tbW9uIGNhc2UgdXNlcnMgYXJlDQphbGwgc2V0dGluZyB0aGUg
bmV3IGFyZ3VtZW50IHRvICcwJy4NCg0KSSdtIGhhcHBpZXIgaWYgd2UgbGV0IHRoZSBwcml2aWxl
Z2VkIGNhbGxzIHN0YW5kIG91dCwgc28gdGhhdCB3ZSBjYW4NCmRpc3Rpbmd1aXNoIHRoZW0gZnJv
bSB0aGUgY3Jvd2QuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpDVE8sIEhhbW1lcnNwYWNlIElu
Yw0KNDMwMCBFbCBDYW1pbm8gUmVhbCwgU3VpdGUgMTA1DQpMb3MgQWx0b3MsIENBIDk0MDIyDQp3
d3cuaGFtbWVyLnNwYWNlIGlkPSIteC1ldm8tc2VsZWN0aW9uLWVuZC1tYXJrZXIiPg==
