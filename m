Return-Path: <SRS0=vwJo=SI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73497C10F06
	for <linux-nfs@archiver.kernel.org>; Sat,  6 Apr 2019 14:14:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F16A3213A2
	for <linux-nfs@archiver.kernel.org>; Sat,  6 Apr 2019 14:14:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="qjVg0Rtr"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726424AbfDFOOj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 6 Apr 2019 10:14:39 -0400
Received: from mail-eopbgr810098.outbound.protection.outlook.com ([40.107.81.98]:45140
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726419AbfDFOOj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 6 Apr 2019 10:14:39 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=p4YjTaL3aZBeYjVV1mZ9EtSqGr26o8chQaFpstQXTwQ=;
 b=qjVg0Rtrgg6jSleY0LG0/ldCM1niBqV9MGuuY3+NWbk/I/Tpt/WV58HINBTCeV5P7v2y0XRnY8oLBBiEVf+tVxOmcRG0/ENj5qdlSEsapf+ScrWCMyLuJ4xEEEb9XbdXpQwIuDpGXCnjkAXBhiVx3j7TaDfZh49rAZrZpU/7hY4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2445.namprd13.prod.outlook.com (52.135.95.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.7; Sat, 6 Apr 2019 14:14:34 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Sat, 6 Apr 2019
 14:14:34 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>
Subject: Re: [PATCH v2 28/28] NFS: Remove redundant open context from nfs_page
Thread-Topic: [PATCH v2 28/28] NFS: Remove redundant open context from
 nfs_page
Thread-Index: AQHU5nsWqA/xigu8WUiGoN8r6re6H6YuAmGAgAE2uAA=
Date:   Sat, 6 Apr 2019 14:14:34 +0000
Message-ID: <9498d534b8e59f903bf750183a08d22a6ae7ba9a.camel@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
         <20190329215948.107328-2-trond.myklebust@hammerspace.com>
         <20190329215948.107328-3-trond.myklebust@hammerspace.com>
         <20190329215948.107328-4-trond.myklebust@hammerspace.com>
         <20190329215948.107328-5-trond.myklebust@hammerspace.com>
         <20190329215948.107328-6-trond.myklebust@hammerspace.com>
         <20190329215948.107328-7-trond.myklebust@hammerspace.com>
         <20190329215948.107328-8-trond.myklebust@hammerspace.com>
         <20190329215948.107328-9-trond.myklebust@hammerspace.com>
         <20190329215948.107328-10-trond.myklebust@hammerspace.com>
         <20190329215948.107328-11-trond.myklebust@hammerspace.com>
         <20190329215948.107328-12-trond.myklebust@hammerspace.com>
         <20190329215948.107328-13-trond.myklebust@hammerspace.com>
         <20190329215948.107328-14-trond.myklebust@hammerspace.com>
         <20190329215948.107328-15-trond.myklebust@hammerspace.com>
         <20190329215948.107328-16-trond.myklebust@hammerspace.com>
         <20190329215948.107328-17-trond.myklebust@hammerspace.com>
         <20190329215948.107328-18-trond.myklebust@hammerspace.com>
         <20190329215948.107328-19-trond.myklebust@hammerspace.com>
         <20190329215948.107328-20-trond.myklebust@hammerspace.com>
         <20190329215948.107328-21-trond.myklebust@hammerspace.com>
         <20190329215948.107328-22-trond.myklebust@hammerspace.com>
         <20190329215948.107328-23-trond.myklebust@hammerspace.com>
         <20190329215948.107328-24-trond.myklebust@hammerspace.com>
         <20190329215948.107328-25-trond.myklebust@hammerspace.com>
         <20190329215948.107328-26-trond.myklebust@hammerspace.com>
         <20190329215948.107328-27-trond.myklebust@hammerspace.com>
         <20190329215948.107328-28-trond.myklebust@hammerspace.com>
         <20190329215948.107328-29-trond.myklebust@hammerspace.com>
         <c92a3c3d629636a0ce88a04098565345ce5ed5d8.camel@gmail.com>
In-Reply-To: <c92a3c3d629636a0ce88a04098565345ce5ed5d8.camel@gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f37e7982-2534-43c8-09e9-08d6ba9a31fe
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2445;
x-ms-traffictypediagnostic: SN6PR13MB2445:
x-microsoft-antispam-prvs: <SN6PR13MB2445D4732FCE079F12A023B4B8520@SN6PR13MB2445.namprd13.prod.outlook.com>
x-forefront-prvs: 0999136621
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(136003)(376002)(366004)(39830400003)(189003)(199004)(51234002)(8936002)(5660300002)(45080400002)(478600001)(14454004)(2501003)(36756003)(305945005)(86362001)(71190400001)(8676002)(81156014)(2906002)(81166006)(106356001)(7736002)(105586002)(110136005)(71200400001)(2616005)(14444005)(26005)(186003)(6506007)(102836004)(11346002)(446003)(256004)(3846002)(476003)(25786009)(53936002)(6246003)(316002)(66066001)(68736007)(6512007)(6116002)(97736004)(229853002)(6486002)(76176011)(99286004)(93886005)(118296001)(486006)(53546011)(6436002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2445;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: JpM4idHQMp4PrR19o7x/wz/erWaVjJ8dqmgPGZjP0INC17+LUZ9t8x/N8pwZONbvz9YH+XvtyirO4ddvNG45Hi5YzYXpZ62s3WLUEY2RzebA5lrHmsxbUQWEdrz4+RYPjGFSKeLWP5G71GWKvrl3tKISJ/uy30CoKJy0ZkoUVm7muP0/daVMdk+iiSIQAftfjeKJiFsAYk79DZ/RiYq82zM57AAAtXhvm76/IPD57+LRHLzG7JmY5+p3CuHc9+n2nzMCOt3ei7G+WYpvTTMBV3Qb/uXYZn4loASkNcc0HxBagXP0Xegea7cYHCvVWe9xtaAs+ADLG1ARc3EmYs4QauryXtnfomH1ZWSXyS7UG+x74N73n0mE+TRDOef8apWEf+74RIH+lTzC/eDpz1ZFQJyW3AHtMI2mzzEcSZCvP4g=
Content-Type: text/plain; charset="utf-8"
Content-ID: <2A59527A890FD54086BACC278A6B6E2D@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f37e7982-2534-43c8-09e9-08d6ba9a31fe
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Apr 2019 14:14:34.4454
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2445
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgQW5uYQ0KDQpPbiBGcmksIDIwMTktMDQtMDUgYXQgMTU6NDIgLTA0MDAsIEFubmEgU2NodW1h
a2VyIHdyb3RlOg0KPiBIaSBUcm9uZCwNCj4gDQo+IEknbSBoYXZpbmcgc29tZSB0cm91YmxlIHdp
dGggeGZzdGVzdHMgZ2VuZXJpYy80NjQgYWZ0ZXIgYXBwbHlpbmcgdGhpcw0KPiBwYXRjaC4NCj4g
SGVyZSBpcyB0aGUgb29wcyBJJ20gZ2V0dGluZywgSSdtIGFibGUgdG8gcmVwcm9kdWNlIGl0IGZh
aXJseSBlYXNpbHkNCj4gYWdhaW5zdCBhbGwNCj4gTkZTIHZlcnNpb25zOiANCj4gDQo+IFsgICA0
MS4xODIwMTVdIEJVRzogdW5hYmxlIHRvIGhhbmRsZSBrZXJuZWwgTlVMTCBwb2ludGVyIGRlcmVm
ZXJlbmNlDQo+IGF0DQo+IDAwMDAwMDAwMDAwMDAwNDgNCj4gWyAgIDQxLjE4MjA1MV0gI1BGIGVy
cm9yOiBbbm9ybWFsIGtlcm5lbCByZWFkIGZhdWx0XQ0KPiBbICAgNDEuMTgyMDcxXSBQR0QgMCBQ
NEQgMCANCj4gWyAgIDQxLjE4MjA4Nl0gT29wczogMDAwMCBbIzFdIFBSRUVNUFQgU01QIFBUSQ0K
PiBbICAgNDEuMTgyMTA0XSBDUFU6IDEgUElEOiAxNDUxNSBDb21tOiBrd29ya2VyLzE6NiBOb3Qg
dGFpbnRlZCA1LjEuMC0NCj4gcmMzLUFOTkErDQo+ICM1MjkyDQo+IFsgICA0MS4xODIxMzFdIEhh
cmR3YXJlIG5hbWU6IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAxLzAxLzIwMTENCj4gWyAgIDQx
LjE4MjE3NF0gV29ya3F1ZXVlOiBuZnNpb2QgcnBjX2FzeW5jX3JlbGVhc2UgW3N1bnJwY10NCj4g
WyAgIDQxLjE4MjIwOV0gUklQOiAwMDEwOl9fcHV0X25mc19vcGVuX2NvbnRleHQrMHhkLzB4MTEw
IFtuZnNdDQo+IFsgICA0MS4xODIyMjddIENvZGU6IGY4IGJhIGE4IDAwIDAwIDAwIGJlIGMwIDBj
IDAwIDAwIGU4IDVkIGMwIDU4IGY3DQo+IDQ4IDg5IGMzIDQ4DQo+IDg1IGMwIDc0IGM1IGU5IDE1
IGZmIGZmIGZmIDBmIDFmIDQ0IDAwIDAwIDQxIDU2IDQxIDU1IDQxIDU0IDU1IDUzDQo+IDw0OD4g
OGIgNDcgNDgNCj4gNDggOGIgNjggMzAgNGMgOGIgNjAgNjggZjAgZmYgMGYgMGYgODggMTQgNTMg
MDEgMDAgNzQNCj4gWyAgIDQxLjE4MjI2N10gUlNQOiAwMDE4OmZmZmZhZTVmMDRiNmJlMzAgRUZM
QUdTOiAwMDAxMDI0Ng0KPiBbICAgNDEuMTgyMjc5XSBSQVg6IDAwMDAwMDAwMDAwMDAwMDAgUkJY
OiBmZmZmYTIyYWFlNzFhNjgwIFJDWDoNCj4gMDAwMDAwMDAwMDAwMDAwMA0KPiBbICAgNDEuMTgy
Mjk1XSBSRFg6IGZmZmZmZmZmYjkyMDVkYzggUlNJOiAwMDAwMDAwMDAwMDAwMDAwIFJESToNCj4g
MDAwMDAwMDAwMDAwMDAwMA0KPiBbICAgNDEuMTgyMzExXSBSQlA6IDAwMDAwMDAwMDAwMDA4MDEg
UjA4OiBmZmZmYTIyYWE1Y2EwMDAwIFIwOToNCj4gZmZmZmEyMmFiYTI2NzgwMA0KPiBbICAgNDEu
MTgyMzI3XSBSMTA6IDAwMDAwMDAwMDAwMDAwMDAgUjExOiAwMDAwMDAwMDAwMDAwMDAwIFIxMjoN
Cj4gZmZmZmNlNWVmZmQxYzIwMA0KPiBbICAgNDEuMTgyMzUxXSBSMTM6IDAwMDAwMDAwMDAwMDAw
MDAgUjE0OiBmZmZmYTIyYWFkMmFhNmMwIFIxNToNCj4gMGZmZmZjZTVlZmZkMWMyMA0KPiBbICAg
NDEuMTgyMzc4XSBGUzogIDAwMDAwMDAwMDAwMDAwMDAoMDAwMCkgR1M6ZmZmZmEyMmFiY2IwMDAw
MCgwMDAwKQ0KPiBrbmxHUzowMDAwMDAwMDAwMDAwMDAwDQo+IFsgICA0MS4xODI0MTFdIENTOiAg
MDAxMCBEUzogMDAwMCBFUzogMDAwMCBDUjA6IDAwMDAwMDAwODAwNTAwMzMNCj4gWyAgIDQxLjE4
MjQzNV0gQ1IyOiAwMDAwMDAwMDAwMDAwMDQ4IENSMzogMDAwMDAwMDBhZjk3MjAwNSBDUjQ6DQo+
IDAwMDAwMDAwMDAxNjBlZTANCj4gWyAgIDQxLjE4MjQ2OF0gQ2FsbCBUcmFjZToNCj4gWyAgIDQx
LjE4MjQ5NV0gIG5mc19jb21taXRkYXRhX3JlbGVhc2UrMHgxNS8weDMwIFtuZnNdDQo+IFsgICA0
MS4xODI1MzZdICBycGNfZnJlZV90YXNrKzB4MzkvMHg3MCBbc3VucnBjXQ0KPiBbICAgNDEuMTgy
NTcxXSAgcnBjX2FzeW5jX3JlbGVhc2UrMHgyOS8weDQwIFtzdW5ycGNdDQo+IFsgICA0MS4xODI1
OTRdICBwcm9jZXNzX29uZV93b3JrKzB4MWViLzB4NDEwDQo+IFsgICA0MS4xODI2MTFdICB3b3Jr
ZXJfdGhyZWFkKzB4MmQvMHgzZDANCj4gWyAgIDQxLjE4MjYyMV0gID8gcHJvY2Vzc19vbmVfd29y
aysweDQxMC8weDQxMA0KPiBbICAgNDEuMTgyNjMyXSAga3RocmVhZCsweDExMi8weDEzMA0KPiBb
ICAgNDEuMTgyNjQxXSAgPyBrdGhyZWFkX3BhcmsrMHg4MC8weDgwDQo+IFsgICA0MS4xODI2NTJd
ICByZXRfZnJvbV9mb3JrKzB4MzUvMHg0MA0KPiBbICAgNDEuMTgyNjYyXSBNb2R1bGVzIGxpbmtl
ZCBpbjogbmZzdjMgbmZzIGZzY2FjaGUgcnBjcmRtYSBpYl9pc2VydA0KPiANCg0KRG9lcyB0aGUg
Zm9sbG93aW5nIHBhdGNoIGhlbHAgdG8gZml4IHRoaXM/DQoNCkNoZWVycw0KICBUcm9uZA0KDQo4
PC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KRnJvbSBkODRjNjk5YmJh
NzhkNjZkM2NjZDNmNzZhNmFhZTU3M2JkZmRkYzA1IE1vbiBTZXAgMTcgMDA6MDA6MDAgMjAwMQ0K
RnJvbTogVHJvbmQgTXlrbGVidXN0IDx0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tPg0K
RGF0ZTogU2F0LCA2IEFwciAyMDE5IDEwOjA1OjU1IC0wNDAwDQpTdWJqZWN0OiBbUEFUQ0hdIE5G
UzogRW5zdXJlIHRoYXQgYWxsIG5mcyBsb2NrIGNvbnRleHRzIGhhdmUgYSB2YWxpZCBvcGVuDQog
Y29udGV4dA0KDQpGb3JjZSB0aGUgbG9jayBjb250ZXh0IHRvIGtlZXAgYSByZWZlcmVuY2UgdG8g
dGhlIHBhcmVudCBvcGVuDQpjb250ZXh0IHNvIHRoYXQgd2UgY2FuIGd1YXJhbnRlZSB0aGUgdmFs
aWRpdHkgb2YgdGhlIGxhdHRlci4NCg0KU2lnbmVkLW9mZi1ieTogVHJvbmQgTXlrbGVidXN0IDx0
cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tPg0KLS0tDQogZnMvbmZzL2lub2RlLmMgfCAx
MyArKysrKysrKystLS0tDQogMSBmaWxlIGNoYW5nZWQsIDkgaW5zZXJ0aW9ucygrKSwgNCBkZWxl
dGlvbnMoLSkNCg0KZGlmZiAtLWdpdCBhL2ZzL25mcy9pbm9kZS5jIGIvZnMvbmZzL2lub2RlLmMN
CmluZGV4IDQxNGE5MGQ0ODQ5My4uZWZjNDVmMjJjNTgxIDEwMDY0NA0KLS0tIGEvZnMvbmZzL2lu
b2RlLmMNCisrKyBiL2ZzL25mcy9pbm9kZS5jDQpAQCAtODg1LDEwICs4ODUsMTQgQEAgc3RydWN0
IG5mc19sb2NrX2NvbnRleHQgKm5mc19nZXRfbG9ja19jb250ZXh0KHN0cnVjdCBuZnNfb3Blbl9j
b250ZXh0ICpjdHgpDQogCQlzcGluX2xvY2soJmlub2RlLT5pX2xvY2spOw0KIAkJcmVzID0gX19u
ZnNfZmluZF9sb2NrX2NvbnRleHQoY3R4KTsNCiAJCWlmIChyZXMgPT0gTlVMTCkgew0KLQkJCWxp
c3RfYWRkX3RhaWxfcmN1KCZuZXctPmxpc3QsICZjdHgtPmxvY2tfY29udGV4dC5saXN0KTsNCi0J
CQluZXctPm9wZW5fY29udGV4dCA9IGN0eDsNCi0JCQlyZXMgPSBuZXc7DQotCQkJbmV3ID0gTlVM
TDsNCisJCQluZXctPm9wZW5fY29udGV4dCA9IGdldF9uZnNfb3Blbl9jb250ZXh0KGN0eCk7DQor
CQkJaWYgKG5ldy0+b3Blbl9jb250ZXh0KSB7DQorCQkJCWxpc3RfYWRkX3RhaWxfcmN1KCZuZXct
Pmxpc3QsDQorCQkJCQkJJmN0eC0+bG9ja19jb250ZXh0Lmxpc3QpOw0KKwkJCQlyZXMgPSBuZXc7
DQorCQkJCW5ldyA9IE5VTEw7DQorCQkJfSBlbHNlDQorCQkJCXJlcyA9IEVSUl9QVFIoLUVCQURG
KTsNCiAJCX0NCiAJCXNwaW5fdW5sb2NrKCZpbm9kZS0+aV9sb2NrKTsNCiAJCWtmcmVlKG5ldyk7
DQpAQCAtOTA2LDYgKzkxMCw3IEBAIHZvaWQgbmZzX3B1dF9sb2NrX2NvbnRleHQoc3RydWN0IG5m
c19sb2NrX2NvbnRleHQgKmxfY3R4KQ0KIAkJcmV0dXJuOw0KIAlsaXN0X2RlbF9yY3UoJmxfY3R4
LT5saXN0KTsNCiAJc3Bpbl91bmxvY2soJmlub2RlLT5pX2xvY2spOw0KKwlwdXRfbmZzX29wZW5f
Y29udGV4dChjdHgpOw0KIAlrZnJlZV9yY3UobF9jdHgsIHJjdV9oZWFkKTsNCiB9DQogRVhQT1JU
X1NZTUJPTF9HUEwobmZzX3B1dF9sb2NrX2NvbnRleHQpOw0KLS0gDQoyLjIwLjENCg0KDQotLSAN
ClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFj
ZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
