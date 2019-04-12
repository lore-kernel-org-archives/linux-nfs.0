Return-Path: <SRS0=G8Mt=SO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 990AFC10F0E
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Apr 2019 13:35:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6442D2084D
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Apr 2019 13:35:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="AWjWEQN3"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726874AbfDLNfC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 12 Apr 2019 09:35:02 -0400
Received: from mail-eopbgr820117.outbound.protection.outlook.com ([40.107.82.117]:2880
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726727AbfDLNfC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 Apr 2019 09:35:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ev9idIM8MZQPUmOTYa3CCzyibRHlabnDQ2brK8g9mhA=;
 b=AWjWEQN35dxwOO8h0/jTr2eqW8sngV6cwIquyO6qvJYrZV1y376tQs+kIHgoy5hJJk7ZOVCU3uKHxlSC5vLDfjUH7Zf7Bc9MChN9zBZR2tuT33ebPLOBU+ULkjj+2PLEDzqxRXWFZDD0nQ7PHGqPQxXgRniMBnKFaHa71B6TA50=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2399.namprd13.prod.outlook.com (52.135.94.155) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.3; Fri, 12 Apr 2019 13:34:58 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1813.006; Fri, 12 Apr 2019
 13:34:58 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "daniel@zonque.org" <daniel@zonque.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: 5.1.0-rc4: Oops in __rpc_execute() when trying to boot from NFS
Thread-Topic: 5.1.0-rc4: Oops in __rpc_execute() when trying to boot from NFS
Thread-Index: AQHU7i3XWMBYs7+7DEGG17GL2cVEYaYym9UAgAFpbICAAAiIgIAAEFmAgANFEICAAKmVgIAAf+UA
Date:   Fri, 12 Apr 2019 13:34:58 +0000
Message-ID: <2e5c705f27f7aceae3972bd58e6ebc5ebf569a52.camel@hammerspace.com>
References: <0412f79c-61a8-bfa4-26ce-1083a59d31e8@zonque.org>
         <ce6d2388a9214f95cc38de5ec225cba26cf63b0d.camel@hammerspace.com>
         <4f4bb4a9-f752-f9f4-41cd-5c41d6191308@zonque.org>
         <7bdd83d7c2442d8096612ad3f821af556dd96015.camel@hammerspace.com>
         <78dbd13a-9a91-9a67-eaa6-ea7f0190898b@zonque.org>
         <be1368dce21d38bb1e90d2c84671ed51498d77ea.camel@hammerspace.com>
         <d08ea2a9-080e-f039-35f3-ba6d388b1878@zonque.org>
In-Reply-To: <d08ea2a9-080e-f039-35f3-ba6d388b1878@zonque.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f727a0fe-7023-4080-84fc-08d6bf4ba86b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2399;
x-ms-traffictypediagnostic: SN6PR13MB2399:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <SN6PR13MB23992D3F8234C764651D3CCCB8280@SN6PR13MB2399.namprd13.prod.outlook.com>
x-forefront-prvs: 0005B05917
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(376002)(39830400003)(346002)(396003)(189003)(199004)(71200400001)(8676002)(6512007)(118296001)(2201001)(106356001)(66066001)(476003)(229853002)(14454004)(93886005)(102836004)(2616005)(105586002)(7736002)(446003)(11346002)(6246003)(2501003)(486006)(4744005)(53546011)(186003)(2906002)(97736004)(3846002)(99286004)(25786009)(81156014)(76176011)(6116002)(6506007)(305945005)(26005)(86362001)(53936002)(81166006)(4326008)(5660300002)(478600001)(256004)(6306002)(110136005)(8936002)(966005)(36756003)(316002)(68736007)(6486002)(6436002)(71190400001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2399;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: pBjLn+lIAwAU7WMyaDFEsqI3Gx2YH6nmAN32qNv+S8ZbZ+s8WJH0/Y/8WBOuo4Gk9lechiCHR92sDDwft4KauOCKBUNKzDiD/F5tirvUGqlCS8gPBb+oT7hIWDsiUTDJ0uYv9Em2/wdxuPxmT6pnMhafQ6c5nhenB1JtfEjEgaVfm0ZsMVppZF64d0IwgagEjA6prjVbuKGGmnCmDbaiIkc2ImC/oT2aUciBlWnbJOZ1TfZXoQ1/sN0v0ZoD2W7+8ICt9mBDsvOPqhH2uVb8dcd3WT/oBYhVDdnPUEID1ckn6BwLSyil4TTs3OIU+FJ2DnbAT0ouvfZ3UtD5cB9zkaIA1YZFE1xyXhdw3a0vdtPklHhXSfbtLknZpuK996W2fScDMll4191wBR1SOhdj4qUbTjof+QULfylvF9OJB5Q=
Content-Type: text/plain; charset="utf-8"
Content-ID: <83DE1F6E3C0B114A866745EF1DB6A0C6@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f727a0fe-7023-4080-84fc-08d6bf4ba86b
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Apr 2019 13:34:58.6813
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2399
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE5LTA0LTEyIGF0IDA3OjU3ICswMjAwLCBEYW5pZWwgTWFjayB3cm90ZToNCj4g
SGkgVHJvbmQsDQo+IA0KPiBPbiAxMS80LzIwMTkgOTo1MCBQTSwgVHJvbmQgTXlrbGVidXN0IHdy
b3RlOg0KPiA+IENvdWxkIHlvdSBwbGVhc2UgdHJ5IHB1bGxpbmcgdGhlICd0ZXN0aW5nJyBicmFu
Y2ggZnJvbSANCj4gPiBodHRwOi8vZ2l0LmxpbnV4LW5mcy5vcmcvP3A9dHJvbmRteS9saW51eC1u
ZnMuZ2l0O2E9c2hvcnRsb2c7aD1yZWZzL2hlYWRzL3Rlc3RpbmcNCj4gPiANCj4gPiBpLmUuICdn
aXQgcHVsbCBnaXQ6Ly9naXQubGludXgtbmZzLm9yZy9wcm9qZWN0cy90cm9uZG15L2xpbnV4LQ0K
PiA+IG5mcy5naXQNCj4gPiB0ZXN0aW5nJw0KPiA+IA0KPiA+IHRvIHNlZSBpZiB0aGF0IHN1ZmZp
Y2VzIHRvIGZpeCB0aGUgaXNzdWUgeW91J3JlIHJlcG9ydGluZz8NCj4gDQo+IFllcywgdGhhdCBy
ZXZlcnQgaW4geW91ciBicmFuY2ggZml4ZXMgdGhlIHByb2JsZW0uIEFsbCBmaW5lIGFnYWluIQ0K
DQpPSy4gVGhhbmtzIGZvciB0ZXN0aW5nIQ0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1l
cnNwYWNlLmNvbQ0KDQoNCg==
