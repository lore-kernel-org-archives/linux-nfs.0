Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5FD6C10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 18:13:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6A99C2084C
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 18:13:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="fd1r4Yif"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727044AbfDHSN5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 14:13:57 -0400
Received: from mail-eopbgr730111.outbound.protection.outlook.com ([40.107.73.111]:4224
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726415AbfDHSN5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Apr 2019 14:13:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=eB2rDg26L+zl87YxwNQhF4tb3FNxuy5lU1kxooxp8cw=;
 b=fd1r4YifZVUq2wK84wOU7BTVm4S2+nCIqzmsAh1NWO5pUENcNDbeN3vCvY4HhQ2sgq929Grx8OvCKDcDpnydWOlcJnEjcH3b0c6/NAhFBdJ+3pFPXJj++VvRftUCgTjCcpf1FgJxgHL0QWl/FHX5r2Imww00S6idA2KlqqoiaKM=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2512.namprd13.prod.outlook.com (52.135.95.154) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.8; Mon, 8 Apr 2019 18:13:53 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Mon, 8 Apr 2019
 18:13:53 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>
Subject: Re: [PATCH v2 28/28] NFS: Remove redundant open context from nfs_page
Thread-Topic: [PATCH v2 28/28] NFS: Remove redundant open context from
 nfs_page
Thread-Index: AQHU5nsWqA/xigu8WUiGoN8r6re6H6YuAmGAgAE2uACAA1YpgIAAEWkA
Date:   Mon, 8 Apr 2019 18:13:53 +0000
Message-ID: <745990f6eedb24b4c59cb653d70b6b7da81aca9e.camel@hammerspace.com>
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
         <9498d534b8e59f903bf750183a08d22a6ae7ba9a.camel@hammerspace.com>
         <89770990a66eb25000248daaf2b0b8fcf105c8d7.camel@gmail.com>
In-Reply-To: <89770990a66eb25000248daaf2b0b8fcf105c8d7.camel@gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2590abcf-59ca-4701-2b55-08d6bc4df57f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2512;
x-ms-traffictypediagnostic: SN6PR13MB2512:
x-microsoft-antispam-prvs: <SN6PR13MB2512E813D0FCF6CB677D16F4B82C0@SN6PR13MB2512.namprd13.prod.outlook.com>
x-forefront-prvs: 0001227049
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(396003)(39830400003)(376002)(366004)(346002)(199004)(189003)(51234002)(14444005)(256004)(68736007)(106356001)(105586002)(97736004)(305945005)(7736002)(66066001)(36756003)(8676002)(86362001)(81166006)(81156014)(8936002)(2501003)(71190400001)(6506007)(99286004)(110136005)(11346002)(6436002)(5660300002)(476003)(2616005)(316002)(229853002)(6486002)(2906002)(118296001)(486006)(478600001)(186003)(93886005)(14454004)(26005)(102836004)(53936002)(6512007)(6246003)(6116002)(25786009)(3846002)(45080400002)(446003)(76176011)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2512;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: u02bUZSMLhVU2DROjbca/WmTf3s3oa75P4ObBWah1yQscbC32voAtzyTEitH5Skmi2EyjxEtzFx8N0J0VxvF0nBFjlpixphuUqB1mYYqWLTcKCvlutBpoaouoW5MCvA0zQICqt88sQumRgioX2Fiwera1wODG2C+KRYUVpUGFW/S52Txt4ptDCA/Q7diHV4jthU4Y8j90WaBKcpMLNrfQkM4ggsmZhr63bNAZQz0le0jJ29TUE0ZSAZkVKs7CMre5n+rixUWzwqTt3KKKl7dL3mW76TXxeC+OAfQaFkKvqkIZYMglbzizs1F+6nhofCtkuI9Q0OPPtRM1Mq81bOwkcrzaMVmoy3QHBELSM0FgIAuedtaA3+Iz8iAlLlAoz7v5jyxWV4Eg5RoyebpiN3etmAhSVl9QSxV6W+AXCER2ek=
Content-Type: text/plain; charset="utf-8"
Content-ID: <576219AFB0AEF24380312A2183C63593@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2590abcf-59ca-4701-2b55-08d6bc4df57f
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Apr 2019 18:13:53.4628
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2512
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTA0LTA4IGF0IDEzOjExIC0wNDAwLCBBbm5hIFNjaHVtYWtlciB3cm90ZToN
Cj4gT24gU2F0LCAyMDE5LTA0LTA2IGF0IDE0OjE0ICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3Jv
dGU6DQo+ID4gSGkgQW5uYQ0KPiA+IA0KPiA+IE9uIEZyaSwgMjAxOS0wNC0wNSBhdCAxNTo0MiAt
MDQwMCwgQW5uYSBTY2h1bWFrZXIgd3JvdGU6DQo+ID4gPiBIaSBUcm9uZCwNCj4gPiA+IA0KPiA+
ID4gSSdtIGhhdmluZyBzb21lIHRyb3VibGUgd2l0aCB4ZnN0ZXN0cyBnZW5lcmljLzQ2NCBhZnRl
ciBhcHBseWluZw0KPiA+ID4gdGhpcw0KPiA+ID4gcGF0Y2guDQo+ID4gPiBIZXJlIGlzIHRoZSBv
b3BzIEknbSBnZXR0aW5nLCBJJ20gYWJsZSB0byByZXByb2R1Y2UgaXQgZmFpcmx5DQo+ID4gPiBl
YXNpbHkNCj4gPiA+IGFnYWluc3QgYWxsDQo+ID4gPiBORlMgdmVyc2lvbnM6IA0KPiA+ID4gDQo+
ID4gPiBbICAgNDEuMTgyMDE1XSBCVUc6IHVuYWJsZSB0byBoYW5kbGUga2VybmVsIE5VTEwgcG9p
bnRlcg0KPiA+ID4gZGVyZWZlcmVuY2UNCj4gPiA+IGF0DQo+ID4gPiAwMDAwMDAwMDAwMDAwMDQ4
DQo+ID4gPiBbICAgNDEuMTgyMDUxXSAjUEYgZXJyb3I6IFtub3JtYWwga2VybmVsIHJlYWQgZmF1
bHRdDQo+ID4gPiBbICAgNDEuMTgyMDcxXSBQR0QgMCBQNEQgMCANCj4gPiA+IFsgICA0MS4xODIw
ODZdIE9vcHM6IDAwMDAgWyMxXSBQUkVFTVBUIFNNUCBQVEkNCj4gPiA+IFsgICA0MS4xODIxMDRd
IENQVTogMSBQSUQ6IDE0NTE1IENvbW06IGt3b3JrZXIvMTo2IE5vdCB0YWludGVkDQo+ID4gPiA1
LjEuMC0NCj4gPiA+IHJjMy1BTk5BKw0KPiA+ID4gIzUyOTINCj4gPiA+IFsgICA0MS4xODIxMzFd
IEhhcmR3YXJlIG5hbWU6IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAxLzAxLzIwMTENCj4gPiA+
IFsgICA0MS4xODIxNzRdIFdvcmtxdWV1ZTogbmZzaW9kIHJwY19hc3luY19yZWxlYXNlIFtzdW5y
cGNdDQo+ID4gPiBbICAgNDEuMTgyMjA5XSBSSVA6IDAwMTA6X19wdXRfbmZzX29wZW5fY29udGV4
dCsweGQvMHgxMTAgW25mc10NCj4gPiA+IFsgICA0MS4xODIyMjddIENvZGU6IGY4IGJhIGE4IDAw
IDAwIDAwIGJlIGMwIDBjIDAwIDAwIGU4IDVkIGMwIDU4DQo+ID4gPiBmNw0KPiA+ID4gNDggODkg
YzMgNDgNCj4gPiA+IDg1IGMwIDc0IGM1IGU5IDE1IGZmIGZmIGZmIDBmIDFmIDQ0IDAwIDAwIDQx
IDU2IDQxIDU1IDQxIDU0IDU1IDUzDQo+ID4gPiA8NDg+IDhiIDQ3IDQ4DQo+ID4gPiA0OCA4YiA2
OCAzMCA0YyA4YiA2MCA2OCBmMCBmZiAwZiAwZiA4OCAxNCA1MyAwMSAwMCA3NA0KPiA+ID4gWyAg
IDQxLjE4MjI2N10gUlNQOiAwMDE4OmZmZmZhZTVmMDRiNmJlMzAgRUZMQUdTOiAwMDAxMDI0Ng0K
PiA+ID4gWyAgIDQxLjE4MjI3OV0gUkFYOiAwMDAwMDAwMDAwMDAwMDAwIFJCWDogZmZmZmEyMmFh
ZTcxYTY4MCBSQ1g6DQo+ID4gPiAwMDAwMDAwMDAwMDAwMDAwDQo+ID4gPiBbICAgNDEuMTgyMjk1
XSBSRFg6IGZmZmZmZmZmYjkyMDVkYzggUlNJOiAwMDAwMDAwMDAwMDAwMDAwIFJESToNCj4gPiA+
IDAwMDAwMDAwMDAwMDAwMDANCj4gPiA+IFsgICA0MS4xODIzMTFdIFJCUDogMDAwMDAwMDAwMDAw
MDgwMSBSMDg6IGZmZmZhMjJhYTVjYTAwMDAgUjA5Og0KPiA+ID4gZmZmZmEyMmFiYTI2NzgwMA0K
PiA+ID4gWyAgIDQxLjE4MjMyN10gUjEwOiAwMDAwMDAwMDAwMDAwMDAwIFIxMTogMDAwMDAwMDAw
MDAwMDAwMCBSMTI6DQo+ID4gPiBmZmZmY2U1ZWZmZDFjMjAwDQo+ID4gPiBbICAgNDEuMTgyMzUx
XSBSMTM6IDAwMDAwMDAwMDAwMDAwMDAgUjE0OiBmZmZmYTIyYWFkMmFhNmMwIFIxNToNCj4gPiA+
IDBmZmZmY2U1ZWZmZDFjMjANCj4gPiA+IFsgICA0MS4xODIzNzhdIEZTOiAgMDAwMDAwMDAwMDAw
MDAwMCgwMDAwKQ0KPiA+ID4gR1M6ZmZmZmEyMmFiY2IwMDAwMCgwMDAwKQ0KPiA+ID4ga25sR1M6
MDAwMDAwMDAwMDAwMDAwMA0KPiA+ID4gWyAgIDQxLjE4MjQxMV0gQ1M6ICAwMDEwIERTOiAwMDAw
IEVTOiAwMDAwIENSMDogMDAwMDAwMDA4MDA1MDAzMw0KPiA+ID4gWyAgIDQxLjE4MjQzNV0gQ1Iy
OiAwMDAwMDAwMDAwMDAwMDQ4IENSMzogMDAwMDAwMDBhZjk3MjAwNSBDUjQ6DQo+ID4gPiAwMDAw
MDAwMDAwMTYwZWUwDQo+ID4gPiBbICAgNDEuMTgyNDY4XSBDYWxsIFRyYWNlOg0KPiA+ID4gWyAg
IDQxLjE4MjQ5NV0gIG5mc19jb21taXRkYXRhX3JlbGVhc2UrMHgxNS8weDMwIFtuZnNdDQo+ID4g
PiBbICAgNDEuMTgyNTM2XSAgcnBjX2ZyZWVfdGFzaysweDM5LzB4NzAgW3N1bnJwY10NCj4gPiA+
IFsgICA0MS4xODI1NzFdICBycGNfYXN5bmNfcmVsZWFzZSsweDI5LzB4NDAgW3N1bnJwY10NCj4g
PiA+IFsgICA0MS4xODI1OTRdICBwcm9jZXNzX29uZV93b3JrKzB4MWViLzB4NDEwDQo+ID4gPiBb
ICAgNDEuMTgyNjExXSAgd29ya2VyX3RocmVhZCsweDJkLzB4M2QwDQo+ID4gPiBbICAgNDEuMTgy
NjIxXSAgPyBwcm9jZXNzX29uZV93b3JrKzB4NDEwLzB4NDEwDQo+ID4gPiBbICAgNDEuMTgyNjMy
XSAga3RocmVhZCsweDExMi8weDEzMA0KPiA+ID4gWyAgIDQxLjE4MjY0MV0gID8ga3RocmVhZF9w
YXJrKzB4ODAvMHg4MA0KPiA+ID4gWyAgIDQxLjE4MjY1Ml0gIHJldF9mcm9tX2ZvcmsrMHgzNS8w
eDQwDQo+ID4gPiBbICAgNDEuMTgyNjYyXSBNb2R1bGVzIGxpbmtlZCBpbjogbmZzdjMgbmZzIGZz
Y2FjaGUgcnBjcmRtYQ0KPiA+ID4gaWJfaXNlcnQNCj4gPiA+IA0KPiA+IA0KPiA+IERvZXMgdGhl
IGZvbGxvd2luZyBwYXRjaCBoZWxwIHRvIGZpeCB0aGlzPw0KPiANCj4gVGhpcyBwYXRjaCBkb2Vz
IGZpeCB0aGUgcHJvYmxlbS4gVGhhbmtzIQ0KPiANCg0KQ29vbCEgSSBzZW50IGEgdjMgcGF0Y2hz
ZXQgdXBkYXRlIGxhc3QgbmlnaHQgd2l0aCB0aGlzIHBhdGNoIGNvcnJlY3RseQ0KcG9zaXRpb25l
ZCBzbyBpdCB3b24ndCBjYXVzZSBiaXNlY3Rpb24gaXNzdWVzLCBhbmQgd2l0aCAyIG90aGVyDQpi
dWdmaXhlcy4gSG9wZWZ1bGx5LCB0aGF0IGlzIHRoZSBmaW5hbCBpdGVyYXRpb24gb2YgdGhlIHBh
dGNoc2V0Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFp
bmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
