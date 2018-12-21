Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 947DCC43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 06:37:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0AFA1218FD
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 06:37:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="iDpOKFOd"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729871AbeLUGhb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Dec 2018 01:37:31 -0500
Received: from mail-eopbgr780103.outbound.protection.outlook.com ([40.107.78.103]:30144
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727920AbeLUGha (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Dec 2018 01:37:30 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=q87oNq2lHUIhpz8CdkV8KgNzqjJmu9nnUtLe+hGgEVA=;
 b=iDpOKFOdzG8T2VQ3lTv243JEwLeL8hIwbBcHrNCfUCtt90teYWwhxE7q+p+qKI6+9LcSVJ8KyfMq2Z/ZDPsklPrI+StOfg6zAem3UP/IRQqBAooNO1rUgEjgKv1luUeC9iVaVMrydzF395YAHuE+Hkk086C83mMC4dhMgLWTlkA=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2463.namprd13.prod.outlook.com (52.135.95.31) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1471.13; Fri, 21 Dec 2018 06:37:27 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1471.011; Fri, 21 Dec 2018
 06:37:27 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "schumakeranna@gmail.com" <schumakeranna@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: convert unnecessary GFP_ATOMIC to GFP_NOFS
Thread-Topic: [PATCH] sunrpc: convert unnecessary GFP_ATOMIC to GFP_NOFS
Thread-Index: AQHUmHqi5oMzT3f4BE+KH/GgqdGXKKWHxaWAgAABX4CAAPdKAA==
Date:   Fri, 21 Dec 2018 06:37:27 +0000
Message-ID: <367f28cedc86e955be2206ed31f8da5dff6533bf.camel@hammerspace.com>
References: <20181220153511.GB6063@fieldses.org>
         <20181220154236.GC6063@fieldses.org>
         <09BE8CC3-B528-45BA-B10E-01D7F9FD264D@oracle.com>
         <20181220155219.GD6063@fieldses.org>
In-Reply-To: <20181220155219.GD6063@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [84.202.42.9]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2463;6:zyNW07fw363QZ95UxpRa8ynImn4FkKO1IgmB2g7nElslNCD5k8ZUa0kQ/fwuiQ8zeEYusDVO4iMCOR6xB3C36JjlEKMqTCNSTFN7TkYy0MzacKA/fSIbSdQkYng8f/2/oXRG4ZGGD2W0Hs3fK+40vcXMm1B7BcJUa7dQFeysnJl6kT7DGSy3PRgxaBYM2/nJ30KaE6ejNfJubBXunpcfLGZx/bzWZVBU789gjYckVRpMu1uXHx65QIO/29OW6L8O+5RgPbnqS/UaJH3iOxB6WvadfE2xBns5u17nkg3SgQAAE+7vn7oXIkfeAzeTL8OamXs1a7K4CbyYI8aJqeweQ60udRUtKqUmyY3YtABTmAU60ftYC1SASoxxswjA1MS+rPU6S6+BM+xiKZLMfi1Jv8fuVrMmIGncnPk2g+rrobT3oOed1b5ty4mNe3RFPyicI1HnpIbh/sKmJ46jZC/HLw==;5:OVuWAMP+R9HSXRdQUdSuQZxEfn+N4N8gdxsOvnt+jalDhoxyTSV2LBWnaJ7tWbLkVy6tvc+vTqvt++Wk2/9u4J5qiq+9kZOs/mmm55zFTecnmOa8POHf/Qg341egE0Yy6W/e7oziffkTm3hhlb4rI/gUZuM6uIdwVa4wmajldaI=;7:jd92CKwva5es/yq7r4qqlNGTyHakWOXl4s7yNxdsrV+Oph0sGarRt0VsAqK6dy3zGq1LzGxkd0lCt7waoIkAGnNOvIjKfc4gFbQ9SFNYs+31kDQvDZayH5+L2ulv0WQQRAjpVqmzn+ccB7jYFLR35A==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 5c63549b-40e2-4eeb-38bb-08d6670ec657
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2463;
x-ms-traffictypediagnostic: SN6PR13MB2463:
x-microsoft-antispam-prvs: <SN6PR13MB2463C2F43336277F7D98ECD7B8B80@SN6PR13MB2463.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(5005026)(6040522)(2401047)(8121501046)(10201501046)(3231475)(944501520)(52105112)(3002001)(93006095)(93001095)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(20161123562045)(20161123558120)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2463;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2463;
x-forefront-prvs: 0893636978
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(366004)(376002)(346002)(136003)(396003)(199004)(189003)(76176011)(6116002)(3846002)(53936002)(118296001)(316002)(86362001)(36756003)(68736007)(6246003)(229853002)(25786009)(305945005)(7736002)(6486002)(39060400002)(6506007)(53546011)(54906003)(26005)(6512007)(102836004)(4326008)(105586002)(106356001)(93886005)(5660300001)(14444005)(256004)(14454004)(110136005)(6436002)(186003)(2501003)(446003)(2616005)(99286004)(486006)(11346002)(8936002)(81156014)(81166006)(478600001)(2906002)(8676002)(97736004)(66066001)(476003)(4001150100001)(71200400001)(71190400001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2463;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 39GTw/pgNMpOOF0NupfI2ig36bLIIzV0zu4hCftILtdlbitl291ZMXHXgNMMFNBPuKtHVQ3pkZFqEe8W4eEBOddQK/r1zFJwy4BdwNrGhLALLi38a+yeg01z+vWXFnViXZMNPqg2xh17Cjh+4hDF8TXvKtSYNL+n1jCnGW111juiB7nQ7aNdXu++O90nRwvlJJLBvD9Lc4jb8Fd2mwoHZRwx8Z6uck54UMdvFno3aLhkQt1yGM/ZokRiqFzHgMDqRlWwIBCYK0cMYmqjLGeYzCdxJq8t/xZwvj6qH6JKy7a6zy7n32GZOySSpbM8y8Vc
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <DC8533FA04CD0E4CAABB4396431B7AC3@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5c63549b-40e2-4eeb-38bb-08d6670ec657
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Dec 2018 06:37:27.2660
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2463
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE4LTEyLTIwIGF0IDEwOjUyIC0wNTAwLCBCcnVjZSBGaWVsZHMgd3JvdGU6DQo+
IE9uIFRodSwgRGVjIDIwLCAyMDE4IGF0IDEwOjQ3OjI1QU0gLTA1MDAsIENodWNrIExldmVyIHdy
b3RlOg0KPiA+IA0KPiA+ID4gT24gRGVjIDIwLCAyMDE4LCBhdCAxMDo0MiBBTSwgSi4gQnJ1Y2Ug
RmllbGRzIDwNCj4gPiA+IGJmaWVsZHNAZmllbGRzZXMub3JnPiB3cm90ZToNCj4gPiA+IA0KPiA+
ID4gRnJvbTogIkouIEJydWNlIEZpZWxkcyIgPGJmaWVsZHNAcmVkaGF0LmNvbT4NCj4gPiA+IA0K
PiA+ID4gSXQncyBPSyB0byBzbGVlcCBoZXJlLCB3ZSBqdXN0IGRvbid0IHdhbnQgdG8gcmVjdXJz
ZSBpbnRvIHRoZQ0KPiA+ID4gZmlsZXN5c3RlbQ0KPiA+ID4gYXMgdGhpcyB3cml0ZW91dCBjb3Vs
ZCBiZSB3YWl0aW5nIG9uIHRoaXMuDQo+ID4gDQo+ID4gImFzIGEgd3JpdGVvdXQiDQo+IA0KPiBP
b3BzLCB0aGFua3MuDQo+IA0KPiA+ID4gRnV0dXJlIHdvcms6IHRoZSBkb2N1bWVudGF0aW9uIGZv
ciBHRlBfTk9GUyBzYXlzICJQbGVhc2UgdHJ5IHRvDQo+ID4gPiBhdm9pZA0KPiA+ID4gdXNpbmcg
dGhpcyBmbGFnIGRpcmVjdGx5IGFuZCBpbnN0ZWFkIHVzZQ0KPiA+ID4gbWVtYWxsb2Nfbm9mc197
c2F2ZSxyZXN0b3JlfSB0bw0KPiA+ID4gbWFyayB0aGUgd2hvbGUgc2NvcGUgd2hpY2ggY2Fubm90
L3Nob3VsZG4ndCByZWN1cnNlIGludG8gdGhlIEZTDQo+ID4gPiBsYXllcg0KPiA+ID4gd2l0aCBh
IHNob3J0IGV4cGxhbmF0aW9uIHdoeS4gQWxsIGFsbG9jYXRpb24gcmVxdWVzdHMgd2lsbA0KPiA+
ID4gaW5oZXJpdA0KPiA+ID4gR0ZQX05PRlMgaW1wbGljaXRseS4iDQo+ID4gPiANCj4gPiA+IEJ1
dCBJJ20gbm90IHN1cmUgd2hlcmUgdG8gZG8gdGhpcy4gIFNob3VsZCB0aGUgd29ya3F1ZXVlIGJl
DQo+ID4gPiBhcnJhbmdpbmcNCj4gPiA+IHRoYXQgZm9yIHVzIGluIHRoZSBjYXNlIG9mIHdvcmtx
dWV1ZXMgY3JlYXRlZCB3aXRoDQo+ID4gPiBXUV9NRU1fUkVDTEFJTT8NCj4gPiANCj4gPiBUaGVy
ZSBzZWVtIHRvIGJlIHBsZW50eSBvZiB1c2VzIG9mIEdGUF9OT0ZTIGluIE5GUyBhbmQgc3VucnBj
Lg0KPiA+IFRoYXQgc291bmRzIGxpa2UgYSBiaWcgcHJvamVjdC4NCj4gDQo+IFllYWgsIGp1c3Qg
bm90aW5nIGl0IGZvciBmdXR1cmUgcmVmZXJlbmNlLg0KPiANCg0KSSdkIHN1Z2dlc3QgdGhhdCB3
ZSBjYW4gcHJvYmFibHkganVzdCBjYWxsIG1lbWFsbG9jX25vZnNfc2F2ZSgpIGluDQpycGNfZXhl
Y3V0ZSgpLCBhbmQgb3RoZXJ3aXNlIGluIHRob3NlIHdvcmtxdWV1ZSBjYWxsYmFjayBmdW5jdGlv
bnMgdGhhdA0KYXJlIGV4ZWN1dGVkIGRpcmVjdGx5IGJ5IHJwY2lvZCBhbmQgeHBydGlvZC4gVGhh
dCBkb2Vzbid0IG1ha2UgZm9yIHRvbw0KbWFueSBjYWxsc2l0ZXMuDQoNCg0KLS0gDQpUcm9uZCBN
eWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25k
Lm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
