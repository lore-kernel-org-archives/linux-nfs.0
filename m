Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B99A2C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 20:56:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 37051218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 20:56:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="IkEtZg+A"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726556AbfCOU41 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 16:56:27 -0400
Received: from mail-eopbgr740124.outbound.protection.outlook.com ([40.107.74.124]:17379
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726097AbfCOU41 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Mar 2019 16:56:27 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=mUaydzOUirL7uTclWPgwNnQBCQ0fFzRiIU/TLRk4Tg4=;
 b=IkEtZg+AS1XmzBvSnT2od5p5ArWUjBDJGxm0TVecA+Vw76OKqpZKrquqqxRsom6jAdOAoFm6clJYFpI9q6S2KiqtRx8g6xJL+T3n+Rjw6Il6hOQUyVnFIju+M4XtuF4x+/6wpLUlWks5nGDNp2EdFmUo9tnEvrSzQeVczoIyNq4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2349.namprd13.prod.outlook.com (52.135.94.32) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.13; Fri, 15 Mar 2019 20:55:43 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1730.003; Fri, 15 Mar 2019
 20:55:43 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "jiufei.xue@linux.alibaba.com" <jiufei.xue@linux.alibaba.com>,
        "aglo@umich.edu" <aglo@umich.edu>
CC:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "joseph.qi@linux.alibaba.com" <joseph.qi@linux.alibaba.com>
Subject: Re: [bug report] task hang while testing xfstests generic/323
Thread-Topic: [bug report] task hang while testing xfstests generic/323
Thread-Index: AQHUz03JX9HUIwfLV060fPzVrzJvGKX1yrYAgABwXICAAD3OgIAASFUAgATbqoCAAAhnAIAA30IAgAChFQCAAUJngIAAZ1oAgAaw2YCAAQ8rAIAACkKAgAABlACABbdyAIAA646AgAAGEQA=
Date:   Fri, 15 Mar 2019 20:55:43 +0000
Message-ID: <a9c8905d999187f24e702d19eb9622ec8aa3d3d3.camel@hammerspace.com>
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
         <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
         <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com>
         <57796366-0f08-2cfb-6f85-27d5485c07af@linux.alibaba.com>
         <ce839197cb70f3bc75413ed2e54f8baafafc01dd.camel@hammerspace.com>
         <365504c3-d785-7e4b-1dd2-c75f30c85c65@linux.alibaba.com>
         <740c1ad6c5b2afad196af34f48dda7097b5102b7.camel@hammerspace.com>
         <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com>
         <b729878b38f32053890a592a91f0645f15caa96f.camel@hammerspace.com>
         <46f5c870-f4fd-b29a-f5eb-eab39c4c1e89@linux.alibaba.com>
         <20190306160934.GB3066@fieldses.org>
         <CAN-5tyEPSDKao=83sW+voU9SPbcszZyR+XfZzcsD2-ozVa22Xg@mail.gmail.com>
         <ace3659edd3efb70d3d978e108ecf1fc22ee3966.camel@hammerspace.com>
         <CAN-5tyH8hFmEsAKDMDL4uey0MXh9+kY43=LEpgjj711eVUubAA@mail.gmail.com>
         <CAN-5tyEAfV_WA3Vyf8LQ-EN4yn99p1sk7fuu7n43t8H8+un2Yw@mail.gmail.com>
         <37b3d7db-0bdf-014a-adff-ea401ea92fc7@linux.alibaba.com>
         <CAN-5tyFHD5ZCqZ59GJzf_CAaJQZ7OXEhaxtYaSDAdXMLSA-xDA@mail.gmail.com>
In-Reply-To: <CAN-5tyFHD5ZCqZ59GJzf_CAaJQZ7OXEhaxtYaSDAdXMLSA-xDA@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5782a693-6cd4-42a3-f1cb-08d6a98896f1
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2349;
x-ms-traffictypediagnostic: SN6PR13MB2349:
x-microsoft-antispam-prvs: <SN6PR13MB2349047043BD26A0274ED2DCB8440@SN6PR13MB2349.namprd13.prod.outlook.com>
x-forefront-prvs: 09778E995A
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(136003)(396003)(39830400003)(346002)(189003)(199004)(316002)(6512007)(446003)(53546011)(2616005)(6486002)(256004)(6436002)(14444005)(118296001)(478600001)(6116002)(26005)(476003)(66066001)(3846002)(186003)(105586002)(6506007)(25786009)(2501003)(7736002)(305945005)(106356001)(76176011)(14454004)(5660300002)(102836004)(71200400001)(2906002)(54906003)(71190400001)(97736004)(486006)(99286004)(8676002)(229853002)(53936002)(81166006)(11346002)(93886005)(8936002)(81156014)(2171002)(4326008)(110136005)(86362001)(6246003)(36756003)(68736007)(41533002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2349;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 3o5Vcep4u+DtYt8d5HMC1AQZv1YgkXUW0oc0HBMIjh0JZoX/0ZQAtV6Xlqja8KuEYbmWTtKdns/79nNepDRfr5pkHI9T32/sM7BTGGYu9tNuk+Tk0htNBOwuyXXS+KGZN06RcET6htMoTRfZYtXhyScYuRRJF0+2pvJppNbK5tOzOtWu67O810sF4LvnwdN7F3lhZDm825hP7VgZOw4irrNVv9tpmFg0/mDtkDXd3NSZfvmKSNo5clvUvPwGiOtteskTwPztH2tBPrS2sYa0UwkQifqlP30ROj0X874IgcJE6PXHW10RxjCcNtR4YeghdZbmw+XlAxiW4gYso4fxirpl3S63/Pe/QG8z9akN6UOzEhwI985RftNKYl8LdZY2o7P92HQUpcxN8GIk+d8CxUOs+43FeSFfTNsIkOTVsAU=
Content-Type: text/plain; charset="utf-8"
Content-ID: <FEBF804977A76747B58762F0B3BE4938@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5782a693-6cd4-42a3-f1cb-08d6a98896f1
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Mar 2019 20:55:43.1437
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2349
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgT2xnYSwNCg0KT24gRnJpLCAyMDE5LTAzLTE1IGF0IDE2OjMzIC0wNDAwLCBPbGdhIEtvcm5p
ZXZza2FpYSB3cm90ZToNCj4gT24gRnJpLCBNYXIgMTUsIDIwMTkgYXQgMjozMSBBTSBKaXVmZWkg
WHVlIDwNCj4gaml1ZmVpLnh1ZUBsaW51eC5hbGliYWJhLmNvbT4gd3JvdGU6DQo+ID4gSGkgT2xn
YSwNCj4gPiANCj4gPiBPbiAyMDE5LzMvMTEg5LiL5Y2IMTE6MTMsIE9sZ2EgS29ybmlldnNrYWlh
IHdyb3RlOg0KPiA+ID4gTGV0IG1lIGRvdWJsZSBjaGVjayB0aGF0LiBJIGhhdmUgcmVwcm9kdWNl
ZCB0aGUgImluZmluaXRlIGxvb3AiDQo+ID4gPiBvcg0KPiA+ID4gQ0xPU0Ugb24gdGhlIHVwc3Ry
ZWFtIChJJ20gbG9va2luZyB0aHJ1IHRoZSB0cmFjZSBwb2ludHMgZnJvbQ0KPiA+ID4gZnJpZGF5
KS4NCj4gPiANCj4gPiBEbyB5b3UgdHJ5IHRvIGNhcHR1cmUgdGhlIHBhY2thZ2VzIHdoZW4gcmVw
cm9kdWNlZCB0aGlzIGlzc3VlIG9uDQo+ID4gdGhlDQo+ID4gdXBzdHJlYW0uIEkgc3RpbGwgbG9z
dCBrZXJuZWwgcGFja2FnZXMgYWZ0ZXIgc29tZSBhZGp1c3RtZW50DQo+ID4gYWNjb3JkaW5nDQo+
ID4gdG8gYmZpZWxkJ3Mgc3VnZ2VzdGlvbiA6KA0KPiANCj4gSGkgSml1ZmVpLA0KPiANCj4gWWVz
IEkgaGF2ZSBuZXR3b3JrIHRyYWNlIGNhcHR1cmVzIGJ1dCB0aGV5IGFyZSB0b28gYmlnIHRvIHBv
c3QgdG8gdGhlDQo+IG1haWxpbmcgbGlzdC4gSSBoYXZlIHJlcHJvZHVjZWQgdGhlIHByb2JsZW0g
b24gdGhlIGxhdGVzdCB1cHN0cmVhbQ0KPiBvcmlnaW4vdGVzdGluZyBicmFuY2ggY29tbWl0ICJT
VU5SUEM6IFRha2UgdGhlIHRyYW5zcG9ydCBzZW5kIGxvY2sNCj4gYmVmb3JlIGJpbmRpbmcrY29u
bmVjdGluZyIuIEFzIHlvdSBoYXZlIG5vdGVkIGJlZm9yZSBpbmZpbml0ZSBsb29wcw0KPiBpcw0K
PiBkdWUgdG8gY2xpZW50ICJsb3NpbmciIGFuIHVwZGF0ZSB0byB0aGUgc2VxaWQuDQo+IA0KPiBv
bmUgcGFja2V0IHdvdWxkIHNlbmQgb3V0IGFuIChyZWNvdmVyeSkgT1BFTiB3aXRoIHNsb3Q9MCBz
ZXFpZD1ZLg0KPiB0cmFjZXBvaW50IChuZnM0X29wZW5fZmlsZSkgd291bGQgbG9nIHRoYXQgc3Rh
dHVzPUVSRVNUQVJUU1lTLiBUaGUNCj4gcnBjDQo+IHRhc2sgd291bGQgYmUgc2VudCBhbmQgdGhl
IHJwYyB0YXNrIHdvdWxkIHJlY2VpdmUgYSByZXBseSBidXQgdGhlcmUNCj4gaXMNCj4gbm9ib2R5
IHRoZXJlIHRvIHJlY2VpdmUgaXQuLi4gVGhpcyBvcGVuIHRoYXQgZ290IGEgcmVwbHkgaGFzIGFu
DQo+IHVwZGF0ZWQgc3RhdGVpZCBzZXFpZCB3aGljaCBjbGllbnQgbmV2ZXIgdXBkYXRlcy4gV2hl
biBDTE9TRSBpcyBzZW50LA0KPiBpdCdzIHNlbnQgd2l0aCB0aGUgIm9sZCIgc3RhdGVpZCBhbmQg
cHV0cyB0aGUgY2xpZW50IGluIGFuIGluZmluaXRlDQo+IGxvb3AuIEJ0dywgQ0xPU0UgaXMgc2Vu
dCBvbiB0aGUgaW50ZXJydXB0ZWQgc2xvdCB3aGljaCBzaG91bGQgZ2V0DQo+IEZBTFNFX1JFVFJZ
IHdoaWNoIGNhdXNlcyB0aGUgY2xpZW50IHRvIHRlcm1pbmF0ZSB0aGUgc2Vzc2lvbi4gQnV0IGl0
DQo+IHdvdWxkIHN0aWxsIGtlZXAgc2VuZGluZyB0aGUgQ0xPU0Ugd2l0aCB0aGUgb2xkIHN0YXRl
aWQuDQo+IA0KPiBTb21lIHRoaW5ncyBJJ3ZlIG5vdGljZWQgaXMgdGhhdCBURVNUX1NUQVRFIG9w
IChhcyBhIHBhcnQgb2YgdGhlDQo+IG5mczQxX3Rlc3RfYW5kIF9mcmVlX2V4cGlyZWRfc3RhdGVp
ZCgpKSBmb3Igc29tZSByZWFzb24gYWx3YXlzIGhhcyBhDQo+IHNpZ25hbCBzZXQgZXZlbiBiZWZv
cmUgaXNzdWluZyBhbmQgUlBDIHRhc2sgc28gdGhlIHRhc2sgbmV2ZXINCj4gY29tcGxldGVzIChl
dmVyKS4NCj4gDQo+IEkgYWx3YXlzIHRob3VnaHQgdGhhdCBPUEVOJ3MgY2FuJ3QgYmUgaW50ZXJy
dXB0ZWQgYnV0IEkgZ3Vlc3MgdGhleQ0KPiBhcmUNCj4gc2luY2UgdGhleSBjYWxsIHJwY193YWl0
X2Zvcl9jb21wbGV0aW9uX3Rhc2soKSBhbmQgdGhhdCdzIGEga2lsbGFibGUNCj4gZXZlbnQuIEJ1
dCBJIGRvbid0IGtub3cgaG93IHRvIGZpbmQgb3V0IHdoYXQncyBzZW5kaW5nIGEgc2lnbmFsIHRv
DQo+IHRoZQ0KPiBwcm9jZXNzLiBJJ20gcmF0aGVyIHN0dWNrIGhlcmUgdHJ5aW5nIHRvIGZpZ3Vy
ZSBvdXQgd2hlcmUgdG8gZ28gZnJvbQ0KPiB0aGVyZS4gU28gSSdtIHN0aWxsIHRyeWluZyB0byBm
aWd1cmUgb3V0IHdoYXQncyBjYXVzaW5nIHRoZSBzaWduYWwgb3INCj4gYWxzbyBob3cgdG8gcmVj
b3ZlciBmcm9tIGl0IHRoYXQgdGhlIGNsaWVudCBkb2Vzbid0IGxvc2UgdGhhdCBzZXFpZC4NCj4g
DQoNClNlbmRpbmcgYSBmYXRhbCBzaWduYWwgdG8gYSBwcm9jZXNzIHdhaXRpbmcgaW4NCnJwY193
YWl0X2Zvcl9jb21wbGV0aW9uX3Rhc2soKSB3aWxsIGludGVycnVwdCB0aGF0IHdhaXQsIGJ1dCBp
dCB3aWxsDQpub3QgaW50ZXJydXB0IHRoZSBydW5uaW5nIGFzeW5jaHJvbm91cyBSUEMgY2FsbC4g
QWxsIGl0IHNob3VsZCBkbyBpcw0Kc3dpdGNoIHRoZSBjYWxsIHRvIHRha2luZyB0aGUgJ2RhdGEt
PmNhbmNlbGxlZCA9PSB0cnVlJyBwYXRoIGluIHRoZSBSUEMNCmNhbGwgY2xlYW4gdXAuDQoNCkNo
ZWVycw0KICBUcm9uZA0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBt
YWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0K
DQoNCg==
