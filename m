Return-Path: <SRS0=jPLZ=PP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A04EEC43387
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 22:21:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5D4892087F
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 22:21:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netapp.onmicrosoft.com header.i=@netapp.onmicrosoft.com header.b="RrEOL/xk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726821AbfAGWVw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 7 Jan 2019 17:21:52 -0500
Received: from mail-eopbgr750041.outbound.protection.outlook.com ([40.107.75.41]:63251
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726773AbfAGWVw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 Jan 2019 17:21:52 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=netapp.onmicrosoft.com; s=selector1-netapp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2Do7Ejz3UETQ9O4GhXc4mgpcdbTM/1iq4ORplCymFsA=;
 b=RrEOL/xktesM76p3p6D9Z58tPPs5s1stplnvaapghvm0980isvES5AebiJFBPK+VjhFm1aBljPlQH4mB77WAv6rsYTamRfjhLiiXmo20DKUUw/ulZlFiqR102vJmJhFCL3YuI3rN8X+Hin4M1Pxe/RGxYsfIF3WS1CGfH8PJUf0=
Received: from DM5PR06MB3161.namprd06.prod.outlook.com (10.174.240.148) by
 DM5PR06MB2697.namprd06.prod.outlook.com (10.168.199.22) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.6; Mon, 7 Jan 2019 22:21:48 +0000
Received: from DM5PR06MB3161.namprd06.prod.outlook.com
 ([fe80::e942:888d:b5bb:44fb]) by DM5PR06MB3161.namprd06.prod.outlook.com
 ([fe80::e942:888d:b5bb:44fb%5]) with mapi id 15.20.1495.011; Mon, 7 Jan 2019
 22:21:48 +0000
From:   "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
        "trond.myklebust@hammerspace.com" <trond.myklebust@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
Subject: Re: [PATCH 2/2] xprtrdma: Double free in rpcrdma_sendctxs_create()
Thread-Topic: [PATCH 2/2] xprtrdma: Double free in rpcrdma_sendctxs_create()
Thread-Index: AQHUpPeQs3tnMa3GyEeaXbfEZpS//aWg3GeAgAM06ICAAFOBAA==
Date:   Mon, 7 Jan 2019 22:21:47 +0000
Message-ID: <d3c36bfdf67dd7f6774f3ff7849a8392e14793d1.camel@netapp.com>
References: <20190105130648.GC3288@kadam>
         <0CEEB35A-2083-4888-9035-8A9ADF22E8E3@oracle.com>
         <20190107172253.GA7196@fieldses.org>
In-Reply-To: <20190107172253.GA7196@fieldses.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Evolution 3.30.4 
x-originating-ip: [23.28.75.121]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;DM5PR06MB2697;6:6N8mUgb4a/N/cCc6gID8oQPx59W2WSGITPiIgE0kdlg8gr1jovT4CAIrkK/UWkgVAlB5MzMX3+rDJdcs04eN4nb/uK9KYR/3UANXN1j/EqCXhVJpMERVAdyfCYKpJ+E/iFvvcL3VE5QYchAiPfpCaJxVKeGnvdSdDKXkDHg6preaGfCXBRHN+MkqzWY74UmvRAUfqA9J8kLQFGlX/BvGaUh+PtTST8ABaP/womUMY4yUGae8kck/mfBaNJt46wNaUG4qaMW6fMFdGg5gb1YgBUz6XzjiDldeGUuN5LJ4DdjJYfA2N6oEJTnZdjagLUPhmc4D4E56Ex/QNz/goeAgHlwxJiiqK58ysZ5C0gWTJy/zpiKa9cEMTyXLFHNz0+AbrEuIBpRtwvcsWsF0Gjh/Hk1L0zKxE2NOd/RyPI99UHQpW2VVhkYn4kW33UXxhgMBsEKPqD0Uxyh/tS7KYlCZLg==;5:Ilj+eEeUtF3w+qrcVfP1aMQ/8xnqb3eUkUwcoYIvip95gruu/CTIqzKs/YZHK+v4YJAZf8ZNsEUjR6A21TUb1j0M/N1XOOZUPQMJH3TzQPQHGUJjpY0JmPmaVn3ZN36YZ62lgVGDugd271/p7K9KnY64hNMUy0J8TtTfDfX2C+5B37blFFqd6TjiOTVDyfDfCQjHEO5DwHmz16Ydjt6kew==;7:Xn734t/2vBNVvHaeuQItfzKftET5NasU/56A7z5Yf3X4VHUl1pbE8ovm9J6v+eBkP1tBW0er91ODcy8i+QeDhZcbaxskNq6QH4/TLfx9UD4CfgVg0b24/jYMNBuD7EsxVlw3MrGlRSRAC2xDF/+haw==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: f4a042b2-bed5-4776-e736-08d674ee83e8
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7193020);SRVR:DM5PR06MB2697;
x-ms-traffictypediagnostic: DM5PR06MB2697:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Anna.Schumaker@netapp.com; 
x-microsoft-antispam-prvs: <DM5PR06MB2697B1D871845D547A779976F8890@DM5PR06MB2697.namprd06.prod.outlook.com>
x-forefront-prvs: 0910AAF391
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(376002)(346002)(396003)(136003)(366004)(39860400002)(199004)(189003)(476003)(186003)(26005)(305945005)(486006)(8936002)(7736002)(6512007)(6246003)(2906002)(99286004)(446003)(2616005)(11346002)(86362001)(6116002)(3846002)(102836004)(36756003)(53936002)(81166006)(6436002)(6486002)(8676002)(256004)(4326008)(229853002)(118296001)(81156014)(68736007)(25786009)(14454004)(106356001)(71190400001)(105586002)(71200400001)(5660300001)(478600001)(316002)(53546011)(58126008)(54906003)(2501003)(72206003)(66066001)(6506007)(110136005)(97736004)(76176011);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR06MB2697;H:DM5PR06MB3161.namprd06.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: netapp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: O4V3glchk2Ddiy6cnku1Yp07L4YZr+FKTEvpUiaLvkY6HtT9qGkPm+Vc+Er3hya89j2D37uck0Tcf3hc5ueKK1QyC1C99SPKZl//0faAHd4ENsZbk6SDKauL0+HwKFACjDMyQ1iTFxY4qO/A16iW19tTrTm/ZIzNYCNzvdeA2x/qX7i/SmWgBbocLwzbFCOMdFZSltfWAMQuLfoG0AjxrDJ4iRJoDpHbOSJtuuZtx6wzI6/y0sPAvLAUkYRHRiyxDCH5DKbyAdQOsML4qkZYAUwOw/L1mwXX/1CZQb7hSRp6kWU1/LqJM6wFZ9HIK6Es
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <3ED363C32DA49F4EB34FF44218C4E8F7@namprd06.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f4a042b2-bed5-4776-e736-08d674ee83e8
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Jan 2019 22:21:48.2230
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR06MB2697
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

DQpPbiBNb24sIDIwMTktMDEtMDcgYXQgMTI6MjIgLTA1MDAsIEJydWNlIEZpZWxkcyB3cm90ZToN
Cj4gT24gU2F0LCBKYW4gMDUsIDIwMTkgYXQgMTE6MjQ6NDVBTSAtMDUwMCwgQ2h1Y2sgTGV2ZXIg
d3JvdGU6DQo+ID4gPiBPbiBKYW4gNSwgMjAxOSwgYXQgODowNiBBTSwgRGFuIENhcnBlbnRlciA8
ZGFuLmNhcnBlbnRlckBvcmFjbGUuY29tPg0KPiA+ID4gd3JvdGU6DQo+ID4gPiANCj4gPiA+IFRo
ZSBjbGVhbiB1cCBpcyBoYW5kbGVkIGJ5IHRoZSBjYWxsZXIsIHJwY3JkbWFfYnVmZmVyX2NyZWF0
ZSgpLCBzbyB0aGlzDQo+ID4gPiBjYWxsIHRvIHJwY3JkbWFfc2VuZGN0eHNfZGVzdHJveSgpIGxl
YWRzIHRvIGEgZG91YmxlIGZyZWUuDQo+ID4gDQo+ID4gVHJ1ZS4gVGhpcyBmaXggaXMgYWRlcXVh
dGUsIGJ1dCBJJ20gd29uZGVyaW5nIGlmIHJwY3JkbWFfc2VuZGN0eHNfZGVzdHJveQ0KPiA+IHNo
b3VsZCBiZSBtYWRlIG1vcmUgY2FyZWZ1bCBhYm91dCBiZWluZyBjYWxsZWQgdHdpY2UuIEhtLg0K
PiA+IA0KPiA+IFJldmlld2VkLWJ5OiBDaHVjayBMZXZlciA8Y2h1Y2subGV2ZXJAb3JhY2xlLmNv
bT4NCj4gDQo+IEknbSBhc3N1bWluZyBUcm9uZCBvciBBbm5hIHdpbGwgcGljayB0aGlzIHVwLi0t
Yi4NCg0KWWVhaCwgSSdsbCB0YWtlIHRoaXMgb25lIGFuZCAxLzIgZm9yIGEgNS4wLXJjLiAgSSBt
aWdodCBzYXZlIHRoZSBhZGRpdGlvbmFsDQpjbGVhbnVwIHBhdGNoIERhbiBzZW50IGZvciA1LjEN
Cg0KQW5uYQ0KDQo+IA0KPiA+IA0KPiA+ID4gRml4ZXM6IGFlNzI5NTBhYmY5OSAoInhwcnRyZG1h
OiBBZGQgZGF0YSBzdHJ1Y3R1cmUgdG8gbWFuYWdlIFJETUEgU2VuZA0KPiA+ID4gYXJndW1lbnRz
IikNCj4gPiA+IFNpZ25lZC1vZmYtYnk6IERhbiBDYXJwZW50ZXIgPGRhbi5jYXJwZW50ZXJAb3Jh
Y2xlLmNvbT4NCj4gPiA+IC0tLQ0KPiA+ID4gbmV0L3N1bnJwYy94cHJ0cmRtYS92ZXJicy5jIHwg
NiArLS0tLS0NCj4gPiA+IDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgNSBkZWxldGlv
bnMoLSkNCj4gPiA+IA0KPiA+ID4gZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMveHBydHJkbWEvdmVy
YnMuYyBiL25ldC9zdW5ycGMveHBydHJkbWEvdmVyYnMuYw0KPiA+ID4gaW5kZXggM2RkZTA1ODky
YzhlLi40OTk0ZTc1OTQ1YjggMTAwNjQ0DQo+ID4gPiAtLS0gYS9uZXQvc3VucnBjL3hwcnRyZG1h
L3ZlcmJzLmMNCj4gPiA+ICsrKyBiL25ldC9zdW5ycGMveHBydHJkbWEvdmVyYnMuYw0KPiA+ID4g
QEAgLTg0NSwxNyArODQ1LDEzIEBAIHN0YXRpYyBpbnQgcnBjcmRtYV9zZW5kY3R4c19jcmVhdGUo
c3RydWN0DQo+ID4gPiBycGNyZG1hX3hwcnQgKnJfeHBydCkNCj4gPiA+IAlmb3IgKGkgPSAwOyBp
IDw9IGJ1Zi0+cmJfc2NfbGFzdDsgaSsrKSB7DQo+ID4gPiAJCXNjID0gcnBjcmRtYV9zZW5kY3R4
X2NyZWF0ZSgmcl94cHJ0LT5yeF9pYSk7DQo+ID4gPiAJCWlmICghc2MpDQo+ID4gPiAtCQkJZ290
byBvdXRfZGVzdHJveTsNCj4gPiA+ICsJCQlyZXR1cm4gLUVOT01FTTsNCj4gPiA+IA0KPiA+ID4g
CQlzYy0+c2NfeHBydCA9IHJfeHBydDsNCj4gPiA+IAkJYnVmLT5yYl9zY19jdHhzW2ldID0gc2M7
DQo+ID4gPiAJfQ0KPiA+ID4gDQo+ID4gPiAJcmV0dXJuIDA7DQo+ID4gPiAtDQo+ID4gPiAtb3V0
X2Rlc3Ryb3k6DQo+ID4gPiAtCXJwY3JkbWFfc2VuZGN0eHNfZGVzdHJveShidWYpOw0KPiA+ID4g
LQlyZXR1cm4gLUVOT01FTTsNCj4gPiA+IH0NCj4gPiA+IA0KPiA+ID4gLyogVGhlIHNlbmRjdHgg
cXVldWUgaXMgbm90IGd1YXJhbnRlZWQgdG8gaGF2ZSBhIHNpemUgdGhhdCBpcyBhDQo+ID4gPiAt
LSANCj4gPiA+IDIuMTcuMQ0KPiA+ID4gDQo+ID4gDQo+ID4gLS0NCj4gPiBDaHVjayBMZXZlcg0K
PiA+IA0KPiA+IA0K
