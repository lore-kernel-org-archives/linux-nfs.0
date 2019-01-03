Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D838C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 23:41:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 150B9217F5
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 23:41:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Uaq42zdC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728861AbfACXlF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 18:41:05 -0500
Received: from mail-eopbgr760107.outbound.protection.outlook.com ([40.107.76.107]:12120
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728829AbfACXlF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 18:41:05 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=i9VSC9KMpe9x0PNi/eU7iRFo54Kl1hMPSts5Ay65+O4=;
 b=Uaq42zdCWLNUzmJuDiC8cfXe5y1CES2xUnrp5kw6VxpsVgNpEZ6dhHfAP9WRYPNxznjTH9fCHEeF2+iRorJ/itIeAETc3/Nltn3uEcSrA6E5o9f3SPD5IypqmEMWFcjWAQtoDEOh/o6Y6G1iZ/yF5D5D/+5rbzGKxiCPT1N+Q+c=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2366.namprd13.prod.outlook.com (52.135.94.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.5; Thu, 3 Jan 2019 23:40:21 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Thu, 3 Jan 2019
 23:40:21 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Thread-Topic: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Thread-Index: AQHUo28wQYHfdyrJOkiXFnTxUjWqjaWeJS6AgAAPUoA=
Date:   Thu, 3 Jan 2019 23:40:21 +0000
Message-ID: <a0493a5f022a666779d19fde5cdfbfdf9c7316c4.camel@hammerspace.com>
References: <20190103141712.24381-1-trond.myklebust@hammerspace.com>
         <20190103224529.GA6907@fieldses.org>
In-Reply-To: <20190103224529.GA6907@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2366;6:v5eUPTijTObKBxY+BmzdSgfU8UlZL4gbjm0Ct6WRJlgW8bnrTIffg4fzB3VCOfE5RW0nrpSLceiwSTj1lzu/dTwisuvgeci2bRWEMiZOrVWsu4c/BCoqREGhtdgUviixIy3BTl8HuYaO9B7BUQO6cZl1WXHUMiZEQeQGxY5G678enoYrdq1LciwA2QpAUsVGsEc/JVmc+Pw456ovlj+8tajQ9FVdZ4VDqXyLcReKTxS4MFWSCIb/vLP4FblTA+dE2zFvaozCErgh/FqPBiH8pdIswl98EDaS1tneVzAGmBGc7BTlkwyoppMjpcFYTTCp3vm1VW75ITCbkVW139jtz1G9+heTwO3Z+PitsMUj7fl7JE9RDNhhtS4Im+pTNO5SGvh9zA+7ugD32WvQtNTWEWsu4QVKZ+MrZXA5qEil9Wn9hN6N/dp8lG9LG0yvH5X1zeurWy4+nXiIkN5AoJ8jeg==;5:gl8szXIlOWXpx83GfD7t3K09RfhZSaFQSxZdoSqFXYexzooZeAETotNY9ZM3eDEeYQlBxH3k2uMzGwUP4OdhsvTcHZ1XszbVAG/CGdZMaK45SbNBkoYgkVeQiaIOIGnTpSAYhLVPv7FKXA7ZPi4dBHp0kT1M/3ERWbfl4SDwKgx7aOS00MWePIN+63Phk6liYVVXoEkGD0DDM/i9clbEDg==;7:MOrYWqImdsr3GwZCY0cN4Q1/W5cz+vxAiEjZ4BUBfVMx3lMpzj1w0123wWMeThlfllGUSo9Ce6W02ThvyqGDSiqWcltH0f8MuRQgI1U5NJ63L0m398Y7r5FpRyQwQy6QRIzF5KC8GsYVPSjWxEd4IA==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: f181fcb6-ac58-4ada-21d3-08d671d4d360
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2366;
x-ms-traffictypediagnostic: SN6PR13MB2366:
x-microsoft-antispam-prvs: <SN6PR13MB23667E3C4C3687CC3B581B49B88D0@SN6PR13MB2366.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220060)(2401047)(8121501046)(3231475)(944501520)(52105112)(93006095)(93001095)(10201501046)(3002001)(6041310)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123562045)(20161123558120)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2366;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2366;
x-forefront-prvs: 0906E83A25
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(346002)(366004)(396003)(39830400003)(136003)(189003)(199004)(4326008)(305945005)(256004)(25786009)(7736002)(3846002)(6116002)(53936002)(6512007)(8676002)(6916009)(6246003)(105586002)(71190400001)(118296001)(8936002)(86362001)(2351001)(81156014)(68736007)(1730700003)(2906002)(71200400001)(486006)(5640700003)(106356001)(316002)(14444005)(6436002)(97736004)(81166006)(6506007)(2501003)(76176011)(229853002)(6486002)(14454004)(478600001)(36756003)(5660300001)(99286004)(26005)(102836004)(6346003)(186003)(11346002)(446003)(2616005)(476003)(66066001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2366;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: CGef9rUAE+3fpRDq399d1UROXFuNQU7Mfh9f5X4NtQt3KOvOXZCyz7Qw93I8B55G6lmjO6JTdZza7bu+jZjm7jJ3RgDyPnuyyx81IU4dHEOvG421MOVXxZjiSn+WjGtDOJAiIkKg659ZAYm2d3YbgwHrdkWXwHYIo6uO9Yv6WOIoxcDv428IYQg/Q9gtg6cJZmNToeIgkz7LzRJ69g8knREKylR996R+b9kNRZX34dimynP/Qp56zKVWhoETyJ71rKOpAlDaStt0heUb5qSo2yIrlT8MeVQ2wc4omDkd0egG4s6GUUKeVZw60LDHJ/au
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <26FFD60ED41016409A4F89709DC5213B@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f181fcb6-ac58-4ada-21d3-08d671d4d360
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jan 2019 23:40:21.2020
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2366
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAxLTAzIGF0IDE3OjQ1IC0wNTAwLCBKIEJydWNlIEZpZWxkcyB3cm90ZToN
Cj4gT24gVGh1LCBKYW4gMDMsIDIwMTkgYXQgMDk6MTc6MTJBTSAtMDUwMCwgVHJvbmQgTXlrbGVi
dXN0IHdyb3RlOg0KPiA+IFVzZSBSRUFEX09OQ0UoKSB0byB0ZWxsIHRoZSBjb21waWxlciB0byBu
b3Qgb3B0aW1zZSBhd2F5IHRoZSByZWFkDQo+ID4gb2YNCj4gPiB4cHJ0LT54cHRfZmxhZ3MgaW4g
c3ZjX3hwcnRfcmVsZWFzZV9zbG90KCkuDQo+IA0KPiBXaGF0IGV4YWN0bHkgaXMgdGhlIHBvc3Np
YmxlIHJhY2UgaGVyZT8gIEFuZCB3aHkgaXMgYSBSRUFEX09OQ0UoKQ0KPiBzdWZmaWNpZW50LCBh
cyBvcHBvc2VkIHRvIHNvbWUgbWVtb3J5IGJhcnJpZXJzPw0KPiANCj4gSSBtYXkgbmVlZCB0byBz
aHV0IG15c2VsZiBpbiBhIHJvb20gd2l0aCBtZW1vcnktYmFycmllcnMudHh0LCBJJ20NCj4gcHJl
dHR5DQo+IGhhenkgb24gdGhlc2UgdGhpbmdzLg0KPiANCg0KSXQncyBub3QgYWJvdXQgZml4aW5n
IGFueSByYWNlcy4gSXQgaXMgYWJvdXQgZW5zdXJpbmcgdGhhdCB0aGUgY29tcGlsZXINCmRvZXMg
bm90IG9wdGltaXNlIGF3YXkgdGhlIHJlYWQgaWYgdGhlIGZ1bmN0aW9uIGlzIGV2ZXIgY2FsbGVk
IGZyb20NCmluc2lkZSBhIGxvb3AuIE5vdCBhbiBpbXBvcnRhbnQgZml4LCBzaW5jZSBJJ20gbm90
IGF3YXJlIG9mIGFueSBjYXNlcw0Kd2hlcmUgdGhpcyBoYXMgaGFwcGVuZWQuIEhvd2V2ZXIgc3Ry
aWN0bHkgc3BlYWtpbmcsIHdlIHNob3VsZCB1c2UNClJFQURfT05DRSgpIGhlcmUgYmVjYXVzZSB0
aGF0IHZhcmlhYmxlIGlzIHZvbGF0aWxlOyBpdCBjYW4gYmUgY2hhbmdlZA0KYnkgYSBiYWNrZ3Jv
dW5kIGFjdGlvbi4NCg0KPiAtLWIuDQo+IA0KPiA+IFNpZ25lZC1vZmYtYnk6IFRyb25kIE15a2xl
YnVzdCA8dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCj4gPiAtLS0NCj4gPiAgbmV0
L3N1bnJwYy9zdmNfeHBydC5jIHwgNiArKysrLS0NCj4gPiAgMSBmaWxlIGNoYW5nZWQsIDQgaW5z
ZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCj4gPiANCj4gPiBkaWZmIC0tZ2l0IGEvbmV0L3N1
bnJwYy9zdmNfeHBydC5jIGIvbmV0L3N1bnJwYy9zdmNfeHBydC5jDQo+ID4gaW5kZXggNTFkMzYy
MzBiNmUzLi45NGQzNDQzMjVlMjIgMTAwNjQ0DQo+ID4gLS0tIGEvbmV0L3N1bnJwYy9zdmNfeHBy
dC5jDQo+ID4gKysrIGIvbmV0L3N1bnJwYy9zdmNfeHBydC5jDQo+ID4gQEAgLTM2Myw5ICszNjMs
MTEgQEAgc3RhdGljIHZvaWQgc3ZjX3hwcnRfcmVsZWFzZV9zbG90KHN0cnVjdA0KPiA+IHN2Y19y
cXN0ICpycXN0cCkNCj4gPiAgDQo+ID4gIHN0YXRpYyBib29sIHN2Y194cHJ0X2hhc19zb21ldGhp
bmdfdG9fZG8oc3RydWN0IHN2Y194cHJ0ICp4cHJ0KQ0KPiA+ICB7DQo+ID4gLQlpZiAoeHBydC0+
eHB0X2ZsYWdzICYgKCgxPDxYUFRfQ09OTil8KDE8PFhQVF9DTE9TRSkpKQ0KPiA+ICsJdW5zaWdu
ZWQgbG9uZyB4cHRfZmxhZ3MgPSBSRUFEX09OQ0UoeHBydC0+eHB0X2ZsYWdzKTsNCj4gPiArDQo+
ID4gKwlpZiAoeHB0X2ZsYWdzICYgKEJJVChYUFRfQ09OTikgfCBCSVQoWFBUX0NMT1NFKSkpDQo+
ID4gIAkJcmV0dXJuIHRydWU7DQo+ID4gLQlpZiAoeHBydC0+eHB0X2ZsYWdzICYgKCgxPDxYUFRf
REFUQSl8KDE8PFhQVF9ERUZFUlJFRCkpKSB7DQo+ID4gKwlpZiAoeHB0X2ZsYWdzICYgKEJJVChY
UFRfREFUQSkgfCBCSVQoWFBUX0RFRkVSUkVEKSkpIHsNCj4gPiAgCQlpZiAoeHBydC0+eHB0X29w
cy0+eHBvX2hhc193c3BhY2UoeHBydCkgJiYNCj4gPiAgCQkgICAgc3ZjX3hwcnRfc2xvdHNfaW5f
cmFuZ2UoeHBydCkpDQo+ID4gIAkJCXJldHVybiB0cnVlOw0KPiA+IC0tIA0KPiA+IDIuMjAuMQ0K
LS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVy
c3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
