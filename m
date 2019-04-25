Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1312C43218
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 16:40:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0909720693
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 16:40:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="E6Gk1ZL0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726026AbfDYQkY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 12:40:24 -0400
Received: from mail-eopbgr780102.outbound.protection.outlook.com ([40.107.78.102]:19454
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726065AbfDYQkX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 12:40:23 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LSiUVBapy8oInB73yNfxC2fS9qBEHZBeDKNrJzvCTQ4=;
 b=E6Gk1ZL0nac88mtLDehwBFs5hKIUDMlehd1IhHWrBlbZ8FiAJG9bPplO2KCpL3DynK8T9v1T6bNupjWJgp4pjGU9lfSiS34v0txhOMj4BiucQ2tUf+Z+tiyhrfw381ct2q9cmFi6pPKjaRXE8VLFrAzMf5iiTSoBHzybLVGwXnU=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2285.namprd13.prod.outlook.com (52.135.94.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1856.5; Thu, 25 Apr 2019 16:40:19 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::396d:aed6:eeb4:2511]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::396d:aed6:eeb4:2511%7]) with mapi id 15.20.1856.004; Thu, 25 Apr 2019
 16:40:19 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH 6/9] NFSv4: Convert the NFS client idmapper to use the
 container user namespace
Thread-Topic: [PATCH 6/9] NFSv4: Convert the NFS client idmapper to use the
 container user namespace
Thread-Index: AQHU+ueMW9/YXGY8FEO55fCIdOiQ4KZM8a2AgAAHtwCAAAlPgIAAEp6A
Date:   Thu, 25 Apr 2019 16:40:18 +0000
Message-ID: <e3553fd56047430f171a3c285150b56d5fc69ccd.camel@hammerspace.com>
References: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
         <20190424214650.4658-2-trond.myklebust@hammerspace.com>
         <20190424214650.4658-3-trond.myklebust@hammerspace.com>
         <20190424214650.4658-4-trond.myklebust@hammerspace.com>
         <20190424214650.4658-5-trond.myklebust@hammerspace.com>
         <20190424214650.4658-6-trond.myklebust@hammerspace.com>
         <20190424214650.4658-7-trond.myklebust@hammerspace.com>
         <20190425143243.GA8133@fieldses.org>
         <e94c2488d89ae13675f9931d013a3d711459ecad.camel@hammerspace.com>
         <20190425153339.GB8133@fieldses.org>
In-Reply-To: <20190425153339.GB8133@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: db354a76-b5ae-4709-11c8-08d6c99cb408
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2285;
x-ms-traffictypediagnostic: SN6PR13MB2285:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <SN6PR13MB228509040942BD0BBCCE7D49B83D0@SN6PR13MB2285.namprd13.prod.outlook.com>
x-forefront-prvs: 0018A2705B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(39830400003)(346002)(376002)(396003)(136003)(199004)(189003)(8676002)(256004)(186003)(6246003)(14454004)(102836004)(118296001)(6486002)(486006)(446003)(11346002)(6512007)(6506007)(476003)(2616005)(73956011)(76116006)(91956017)(7736002)(36756003)(2501003)(53936002)(66476007)(2351001)(66446008)(66946007)(66556008)(15974865002)(2906002)(478600001)(6436002)(97736004)(5640700003)(305945005)(25786009)(71190400001)(71200400001)(8936002)(6916009)(64756008)(68736007)(26005)(93886005)(316002)(54906003)(86362001)(229853002)(66066001)(76176011)(81166006)(5660300002)(99286004)(3846002)(81156014)(1730700003)(6116002)(4326008)(21314003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2285;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: BaUe3jToAS/ZLl7ei649F5OcGZptq4X1Mx1xbyflJb4evNl8ikcgQTieetK581qAdKVS4XiTstFhBmKLu3MXMdlv676Xn1JO7gWmKwoNs3biVAXObgB4pzGGIMyU4tnOb1du32EiJQ20MRxUl43VlBn/fi5f8eBv4cntphIoDfAe58IdxOWskFposEOmkDIlkxUeZFQ+6tH945GQI5XkN51DFbCJ98cTbd7PfsHblvFAq+l1nky6kzKQikKdxV2WtJvlulwzEYOUMiXYoIH771RiQlkI3/8vn/1oZs35LXe0RyuBsxsyJyA0U8P1JF/peE0DhougCHXJPXdN9DAAVsv0F5Gsu2HH9deFVwC12lwYGlJ2GfdeQkrjttaG17VFoDRlDVgRGIa8m+jZq56Sz6UlFhDw+653BFkWMt+xNyM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <C329617BA8F42C4E8919A7F277805572@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: db354a76-b5ae-4709-11c8-08d6c99cb408
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Apr 2019 16:40:19.0303
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2285
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTA0LTI1IGF0IDExOjMzIC0wNDAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3
cm90ZToNCj4gT24gVGh1LCBBcHIgMjUsIDIwMTkgYXQgMDM6MDA6MjJQTSArMDAwMCwgVHJvbmQg
TXlrbGVidXN0IHdyb3RlOg0KPiA+IFRoZSBhc3N1bXB0aW9uIGlzIHRoYXQgaWYgeW91IGhhdmUg
ZW5vdWdoIHByaXZpbGVnZXMgdG8gbW91bnQgYQ0KPiA+IGZpbGVzeXN0ZW0gdXNpbmcgdGhlIE5G
UyBjbGllbnQsIHRoZW4geW91IHdvdWxkIGFsc28gaGF2ZSBlbm91Z2gNCj4gPiBwcml2aWxlZ2Vz
IHRvIHJ1biBhIHVzZXJzcGFjZSBjbGllbnQsIHNvIHRoZXJlIGlzIGxpdHRsZSBwb2ludCBpbg0K
PiA+IHJlc3RyaWN0aW5nIHRoZSBORlMgY2xpZW50Lg0KPiA+IA0KPiA+IFNvIHRoZSBndWlkaW5n
IHByaW5jaXBsZSBpcyB0aGF0IGEgTkZTIGNsaWVudCBtb3VudCB0aGF0IGlzIHN0YXJ0ZWQNCj4g
PiBpbg0KPiA+IGEgY29udGFpbmVyIHNob3VsZCBiZWhhdmUgYXMgaWYgaXQgd2VyZSBzdGFydGVk
IGJ5IGEgcHJvY2VzcyBpbiBhDQo+ID4gInJlYWwNCj4gPiBWTSIuIFRoYXQgbWVhbnMgdGhhdCB0
aGUgcm9vdCB1aWQvZ2lkIGluIHRoZSBjb250YWluZXIgbWFwcyB0byBhDQo+ID4gcm9vdA0KPiA+
IHVpZC9naWQgb24gdGhlIHdpcmUuDQo+ID4gRGl0dG8sIGlmIHRoZXJlIGlzIGEgbmVlZCB0byBy
dW4gdGhlIGlkbWFwcGVyIGluIHRoZSBjb250YWluZXIsDQo+ID4gdGhlbg0KPiA+IHRoZSBleHBl
Y3RhdGlvbiBpcyB0aGF0IHByb2Nlc3NlcyBydW5uaW5nIGFzICd1c2VyJyB3aXRoIHVpZCAndScs
DQo+ID4gd2lsbA0KPiA+IHNlZSB0aGVpciBjcmVkcyBtYXBwZWQgY29ycmVjdGx5IGJ5IHRoZSBp
ZG1hcHBlci4gQWdhaW4sIHRoYXQncw0KPiA+IHdoYXQNCj4gPiB5b3Ugd291bGQgc2VlIGlmIHRo
ZSBwcm9jZXNzIHdlcmUgcnVubmluZyBpbiBhIFZNIGluc3RlYWQgb2YgYQ0KPiA+IGNvbnRhaW5l
ci4NCj4gPiANCj4gPiBEb2VzIHRoYXQgYWxsIG1ha2Ugc2Vuc2U/DQo+IA0KPiBZZXMsIHRoYW5r
cyENCj4gDQo+IEkgdGhvdWdodCB0aGVyZSB3YXMgYSBwcm9ibGVtIHRoYXQgdGhlIGlkbWFwcGVy
IGRlcGVuZGVkIG9uDQo+IGtleXJpbmcgdXNlcm1vZGVoZWxwZXIgY2FsbHMgdGhhdCBpdCB3YXMg
aGFyZCB0byBwYXNzIG5hbWVzcGFjZQ0KPiBpbmZvcm1hdGlvbiB0by4gIERpZCB0aGF0IGdldCBm
aXhlZCBhbmQgSSBtaXNzZWQgaXQgb3Igb3IgZm9yZ290Pw0KDQpObywgeW91IGFyZSBjb3JyZWN0
LCBhbmQgc28gd2UgYXNzdW1lIHRoZSBjb250YWluZXIgaXMgdXNpbmcgcnBjLmlkbWFwZA0KKGFu
ZCBycGMuZ3NzZCkgaWYgaXQgaXMgcnVubmluZyBORlN2NCB3aXRoIFJQQ1NFQ19HU1MuDQoNCklm
IHRoZSBrZXlyaW5nIHVwY2FsbCBnZXRzIGZpeGVkLCB0aGVuIHdlIG1heSBhbGxvdyBpdCB0byBi
ZSB1c2VkIGluDQpmdXR1cmUga2VybmVscy4NCg0KPiA+IFNvIHRoaXMgbWVhbnMgdGhhdCBhbnkg
b3JjaGVzdHJhdG9yIHNvZnR3YXJlIHdoaWNoIG1heSBiZSBzZXR0aW5nDQo+ID4gdXANCj4gPiBO
RlMgbW91bnRzIGFzIHBhcnQgb2Ygc2V0dGluZyB1cCB0aGUgY29udGFpbmVyIGhhcyAyIG9wdGlv
bnM6DQo+ID4gDQo+ID4gICAgMS4gRWl0aGVyIHBlcmZvcm0gdGhlIG1vdW50IG91dHNpZGUgdGhl
IGNvbnRhaW5lciBuYW1lc3BhY2VzLCBpbg0KPiA+IHdoaWNoDQo+ID4gICAgICAgY2FzZSB0aGUg
Y29udGFpbmVyIHByb2Nlc3MgdWlkcy9naWRzIGFyZSBtYXBwZWQgZnJvbSB0aGVpcg0KPiA+ICAg
ICAgIHVzZXJfbmFtZXNwYWNlIGludG8gdGhlIHVzZXJfbmFtZXNwYWNlIG9mIHRoZSBvcmNoZXN0
cmF0b3IsDQo+ID4gYW5kIHRoZQ0KPiA+ICAgICAgIHVpZHMvZ2lkcyBvbiB0aGUgd2lyZSB3aWxs
IHJlZmxlY3QgdGhvc2UgbWFwcGVkIHVpZHMvZ2lkcyAoc28NCj4gPiB1aWQgMA0KPiA+ICAgICAg
IGluIHRoZSBjb250YWluZXIgd2lsbCBiZSBtYXBwZWQgdG8gdWlkIHh4eCB3aGVyZSB4eHggaXMN
Cj4gPiBkZWNpZGVkIGJ5DQo+ID4gICAgICAgdGhlIG9yY2hlc3RyYXRvcikuDQo+ID4gICAgMi4g
UGVyZm9ybSB0aGUgbW91bnQgaW5zaWRlIHRoZSBjb250YWluZXIgbmFtZXNwYWNlcywgaW4gd2hp
Y2gNCj4gPiBjYXNlIHRoZQ0KPiA+ICAgICAgIGNvbnRhaW5lciBwcm9jZXNzIHVpZHMvZ2lkcyBn
byBvbiB0aGUgd2lyZSBhcy1pcy4NCj4gDQo+IE9LLCBncmVhdCwgdGhhdCBzb3VuZHMgcGVyZmVj
dC4NCj4gDQo+IC0tYi4NCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpDVE8sIEhhbW1lcnNwYWNlIElu
Yw0KNDMwMCBFbCBDYW1pbm8gUmVhbCwgU3VpdGUgMTA1DQpMb3MgQWx0b3MsIENBIDk0MDIyDQp3
d3cuaGFtbWVyLnNwYWNlDQoNCg0K
