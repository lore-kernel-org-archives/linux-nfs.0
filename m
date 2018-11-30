Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D462C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:08:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ACE8820660
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:08:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="aP5kuvxx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACE8820660
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726103AbeLAITG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 03:19:06 -0500
Received: from mail-eopbgr750107.outbound.protection.outlook.com ([40.107.75.107]:57536
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725867AbeLAITG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 1 Dec 2018 03:19:06 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=7om8QthGLtvMNCcwLnKIoNSHhfnp6n4mX6asyXsKXg0=;
 b=aP5kuvxx1VtAtZSQgDzJP2rxK/boTVp0fXcYkpeDZtqIroGF/5Bv7ASvQgAphjL0bMgd1UNEP000Jw2ElpYBYnbUrw8oDEpXysD3SQzI0705mu97Wc4XNgWYtTjfrwsZgvK6iD/mL8GrQzpExpWAGeAuG+C+3xEfAkFpWyY1Xd4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2542.namprd13.prod.outlook.com (52.135.95.160) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1382.14; Fri, 30 Nov 2018 21:08:27 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.011; Fri, 30 Nov 2018
 21:08:27 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Fix leak of krb5p encode pages
Thread-Topic: [PATCH] SUNRPC: Fix leak of krb5p encode pages
Thread-Index: AQHUiOzeqWrG5HWjNkydYaOAyUNIY6Voz9CA
Date:   Fri, 30 Nov 2018 21:08:27 +0000
Message-ID: <b9546c7b283c426d3e1598c233862c38c9a763cf.camel@primarydata.com>
References: <20181130203957.2378.23724.stgit@manet.1015granger.net>
In-Reply-To: <20181130203957.2378.23724.stgit@manet.1015granger.net>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2542;6:yOajKXofKo59tKvoA5U0E+VyL6NwlF5WDucggr08TdgFfhTnJq4wE0Rq1fpA0hnMc8qW7xRSqPowrGSJootO/Owhz6La6/vYBi8/ymkXEoCAEe0prwVbLXE6Fqs3VRPQ9pnCb6pQZwhBISbKVnXncjMV5HQ0cNM0e5CYmm6ZeVr9iisHZJrouRThslngXoj0kxaHSklLR6W96zRdqC9P/vxSyLlUr5mcxKB9b2Kjc4AWOyhEJwSbhnb+iI0D9SgzI76dLlpBr1D+NTeijSl9TynkuZGGdZN4Zj0gX9fKEy2MmuCm2qyrS7I+oPcocZzeBxFymKICwPk8mO0AfPai9qPZoknNFMdyxYqSZ4jOwUp2Usr8W7mlSNrA7xg7/FqZ3ZpXs0UDqwo6aOAqum7CsvwJJh2eHgNw0JtE9xSAl+scJoMy+5n0pshcimknU+Lr5oeo34DxiZQXhIfx4K3ANA==;5:DtUBqaAr9Hblh9u2Wo/0OZncUg64KtikjtTxr4W2MiApX7ncnuc3dhLr8KRcp0bK71FV7nUYiVlN+D4wqlPj6uanUuZ5izQILiQbWbO+KbX+L0h8TL7fLSqy6rOeDVLvzz6fmUW2sJCE2CTZy2v1IUbaJhiuYyizup/l3ZBdiV8=;7:GaH2cT+b1xdHKAMTu7rkRz09NsulnuuRJ8zPb2eIpZIjvQgb2PGFIQrVtQGO9GJxOIfclTc2Lobzvh/90RSAj78B88zI/MB3bfzL7MOOxZ11e91shYrsyrv9DrLjwdgHPrc4sHhaExFLK8NJNHeRqg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 7d9e92dd-8332-4c5d-e33b-08d65707f94c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2542;
x-ms-traffictypediagnostic: SN6PR13MB2542:
x-microsoft-antispam-prvs: <SN6PR13MB25427BBF2DA0DDF9189ABF13B8D30@SN6PR13MB2542.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(10201501046)(3231453)(999002)(944501410)(52105112)(3002001)(148016)(149066)(150057)(6041310)(20161123562045)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123558120)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2542;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2542;
x-forefront-prvs: 087223B4DA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39830400003)(366004)(396003)(346002)(376002)(199004)(189003)(305945005)(11346002)(6486002)(86362001)(2351001)(7736002)(81166006)(186003)(81156014)(2501003)(8936002)(446003)(25786009)(105586002)(4326008)(8676002)(36756003)(6506007)(6436002)(6916009)(5660300001)(14454004)(4001150100001)(486006)(97736004)(229853002)(71190400001)(71200400001)(476003)(6116002)(3846002)(26005)(2906002)(14444005)(256004)(9686003)(6512007)(5640700003)(6246003)(118296001)(99286004)(478600001)(102836004)(66066001)(53936002)(33896004)(68736007)(106356001)(76176011)(316002)(42413003)(32563001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2542;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: zzw5aNxsALTYE/H6YANTPQOkDpKlIFoGtyfH24miOAo/Gfn/uXmKu8Rjqh618VSUc80gnhskFJAzDv4dRPo6WWLPJ8UwUCWl+UolM668/BqyGlH8IBtbTSjX/WAsWH5HtL6L0NfxMEHfkEpY8JQIvEwX7GGAPz9ZbpvTwbXod6k94LBJr5Zo3yuMz1F92Ghg6tdH5McLj7pOa8d3cLfBubfgtdt7FO9ZLVPZj0liMutWaNZc/bGo7KHapMwDtxWD30D1nXRuYP6g20KXlaifyH/1LcwSi2yVvAwZ/Bl1+8HvJm+Jsqj94gIcKJ7LKPKjbqdVZ9idML3GfOyLIqyg3K/5zF6kTHpTztWK77uMq78=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <3FF44CB80D5C0D498548A1CB1FA9C1C3@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7d9e92dd-8332-4c5d-e33b-08d65707f94c
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Nov 2018 21:08:27.7236
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2542
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTExLTMwIGF0IDE1OjM5IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
Y2FsbF9lbmNvZGUgY2FuIGJlIGludm9rZWQgbW9yZSB0aGFuIG9uY2UgcGVyIFJQQyBjYWxsLiBF
bnN1cmUgdGhhdA0KPiBlYWNoIGNhbGwgdG8gZ3NzX3dyYXBfcmVxX3ByaXYgZG9lcyBub3Qgb3Zl
cndyaXRlIHBvaW50ZXJzIHRvDQo+IHByZXZpb3VzbHkgYWxsb2NhdGVkIG1lbW9yeS4NCj4gDQo+
IFNpZ25lZC1vZmYtYnk6IENodWNrIExldmVyIDxjaHVjay5sZXZlckBvcmFjbGUuY29tPg0KPiBD
Yzogc3RhYmxlQGtlcm5lbC5vcmcNCj4gLS0tDQo+ICBuZXQvc3VucnBjL2F1dGhfZ3NzL2F1dGhf
Z3NzLmMgfCAgICA0ICsrKysNCj4gIDEgZmlsZSBjaGFuZ2VkLCA0IGluc2VydGlvbnMoKykNCj4g
DQo+IGRpZmYgLS1naXQgYS9uZXQvc3VucnBjL2F1dGhfZ3NzL2F1dGhfZ3NzLmMNCj4gYi9uZXQv
c3VucnBjL2F1dGhfZ3NzL2F1dGhfZ3NzLmMNCj4gaW5kZXggNWQzZjI1Mi4uYmE3NjU0NyAxMDA2
NDQNCj4gLS0tIGEvbmV0L3N1bnJwYy9hdXRoX2dzcy9hdXRoX2dzcy5jDQo+ICsrKyBiL25ldC9z
dW5ycGMvYXV0aF9nc3MvYXV0aF9nc3MuYw0KPiBAQCAtMTc5MSw2ICsxNzkxLDcgQEAgc3RhdGlj
IHZvaWQgZ3NzX3dyYXBfcmVxX2VuY29kZShreGRyZXByb2NfdA0KPiBlbmNvZGUsIHN0cnVjdCBy
cGNfcnFzdCAqcnFzdHAsDQo+ICAJZm9yIChpPTA7IGkgPCBycXN0cC0+cnFfZW5jX3BhZ2VzX251
bTsgaSsrKQ0KPiAgCQlfX2ZyZWVfcGFnZShycXN0cC0+cnFfZW5jX3BhZ2VzW2ldKTsNCj4gIAlr
ZnJlZShycXN0cC0+cnFfZW5jX3BhZ2VzKTsNCj4gKwlycXN0cC0+cnFfcmVsZWFzZV9zbmRfYnVm
ID0gTlVMTDsNCj4gIH0NCj4gIA0KPiAgc3RhdGljIGludA0KPiBAQCAtMTc5OSw2ICsxODAwLDkg
QEAgc3RhdGljIHZvaWQgZ3NzX3dyYXBfcmVxX2VuY29kZShreGRyZXByb2NfdA0KPiBlbmNvZGUs
IHN0cnVjdCBycGNfcnFzdCAqcnFzdHAsDQo+ICAJc3RydWN0IHhkcl9idWYgKnNuZF9idWYgPSAm
cnFzdHAtPnJxX3NuZF9idWY7DQo+ICAJaW50IGZpcnN0LCBsYXN0LCBpOw0KPiAgDQo+ICsJaWYg
KHJxc3RwLT5ycV9yZWxlYXNlX3NuZF9idWYpDQo+ICsJCXJxc3RwLT5ycV9yZWxlYXNlX3NuZF9i
dWYocnFzdHApOw0KPiArDQo+ICAJaWYgKHNuZF9idWYtPnBhZ2VfbGVuID09IDApIHsNCj4gIAkJ
cnFzdHAtPnJxX2VuY19wYWdlc19udW0gPSAwOw0KPiAgCQlyZXR1cm4gMDsNCj4gDQoNCk91Y2gu
Li4gT0ssIEkgdGhpbmsgSSBzZWUgd2hlcmUgdGhlIGJpb192ZWMgcHJvYmxlbSBpcyBoYXBwZW5p
bmcuDQoNCklmIGdzc193cmFwX3JlcV9wcml2KCkgaXMgcmVwbGFjaW5nIHNuZF9idWYtPnBhZ2Vz
IGluc3RlYWQgb2YgcmV1c2luZw0KdGhlIHJxX2VuY19wYWdlcywgdGhlbiB3ZSBuZWVkIHRvIGNh
bGwgeGRyX2ZyZWVfYnZlYygpIGFzIHBhcnQgb2YNCnhzX3N0cmVhbV9wcmVwYXJlX3JlcXVlc3Qo
KSBpbiBvcmRlciB0byBlbnN1cmUgdGhhdCB3ZSByZWZyZXNoIHRoZQ0KY29udGVudHMgb2YgdGhl
IGJ2ZWMuLi4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRh
aW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
