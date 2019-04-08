Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4D47C10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 20:38:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C00B720857
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 20:38:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="lygfKnuy"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726509AbfDHUiv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 16:38:51 -0400
Received: from mail-eopbgr790113.outbound.protection.outlook.com ([40.107.79.113]:6213
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726805AbfDHUiu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Apr 2019 16:38:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZWOR98TcCI4jCXqvHgcy/wcCzp9nXiIvrX5WKy+j/90=;
 b=lygfKnuysFb/1R7xG2EeL71BIVDYeVvLyBX9QZ8McQ4o3uByZF+2jt6Q0hTvN/VkdMhros4JISHId2/kyRFtEDC/RxJoff5Qug8OnlmEee2b93hVZO+m1TlpWSFqQkeyxWTBHBtt4QCgE0uF/K7zUzkZIrqi5CquL001Vwc+0Zo=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2560.namprd13.prod.outlook.com (52.135.96.20) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.11; Mon, 8 Apr 2019 20:38:47 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Mon, 8 Apr 2019
 20:38:47 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "kolga@netapp.com" <kolga@netapp.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1] NFS: Fix handling of reply page vector
Thread-Topic: [PATCH v1] NFS: Fix handling of reply page vector
Thread-Index: AQHU7kW8ipWQk7MB5UOoW6Ab09Puv6YyuYYA
Date:   Mon, 8 Apr 2019 20:38:47 +0000
Message-ID: <bede7559be11f283e9f37db2da0b47ddf869a468.camel@hammerspace.com>
References: <20190408200030.16366.22026.stgit@manet.1015granger.net>
In-Reply-To: <20190408200030.16366.22026.stgit@manet.1015granger.net>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c3e048fe-5c40-46d3-faec-08d6bc623332
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2560;
x-ms-traffictypediagnostic: SN6PR13MB2560:
x-microsoft-antispam-prvs: <SN6PR13MB256008A5A418491DB8E0C958B82C0@SN6PR13MB2560.namprd13.prod.outlook.com>
x-forefront-prvs: 0001227049
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(346002)(376002)(136003)(366004)(396003)(199004)(189003)(2906002)(76176011)(68736007)(81156014)(8936002)(486006)(5660300002)(6246003)(305945005)(26005)(99286004)(71200400001)(8676002)(476003)(66066001)(6512007)(6116002)(3846002)(71190400001)(86362001)(7736002)(2616005)(11346002)(25786009)(53936002)(81166006)(110136005)(14454004)(446003)(478600001)(6506007)(105586002)(106356001)(6436002)(14444005)(256004)(118296001)(36756003)(2501003)(97736004)(186003)(6486002)(4326008)(102836004)(229853002)(316002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2560;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: YJVStD67Tmnp1HYUc293xPTQG4qvDsNJFC0homvrEbBBJZhrnBEhdR7xwyiZxovhnEm8OiP+pgP8b4b5+6J/GGj1Opf2cFRtbYRYmxsItQVjCHxe8BkP3OHu39Qstzr/jueK/jiAaYLDFjfYjOZKlsx/UkIL3CyLxgAY4xltqEu/kXBfd5m2qnVJLRePYJBPMk5K7z8xYkZWX58iDjTP+az3XeKx9zO4DLPRtiFK51DUUdmWsy1E1AE+maOmPrSqnqI4qjEgnUSsnLb6O7kldUiS4smmbUqLWs3GJQgnuCDhJ64kE2+TQUZ9EN1OI8/+1GGcqVR1SK0gGANIenTfbErF3VP1mhIEf9xgyZj37FJhYefGBQEN2PvhQsc64RFUKGo4uuyBUgq5hdYSGposLrJe4OUIdPuWvinhiIC+wq8=
Content-Type: text/plain; charset="utf-8"
Content-ID: <FDEB3F1FB7C84E48A8C7A3ECF2273D0E@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c3e048fe-5c40-46d3-faec-08d6bc623332
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Apr 2019 20:38:47.0329
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2560
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTA0LTA4IGF0IDE2OjAwIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
TkZTdjQgR0VUQUNMIGFuZCBGU19MT0NBVElPTlMgcmVxdWVzdHMgc3RvcHBlZCB3b3JraW5nIGlu
IHY1LjEtcmMuDQo+IA0KPiBUaGVzZSB0d28gbmVlZCB0aGUgZXh0cmEgcGFkZGluZyB0byBiZSBh
ZGRlZCBkaXJlY3RseSB0byB0aGUgcmVwbHkNCj4gbGVuZ3RoLg0KPiANCj4gUmVwb3J0ZWQtYnk6
IE9sZ2EgS29ybmlldnNrYWlhIDxhZ2xvQHVtaWNoLmVkdT4NCj4gRml4ZXM6IDAyZWYwNGU0MzJi
YSAoIk5GUzogQWNjb3VudCBmb3IgWERSIHBhZCBvZiBidWYtPnBhZ2VzIikNCj4gU2lnbmVkLW9m
Zi1ieTogQ2h1Y2sgTGV2ZXIgPGNodWNrLmxldmVyQG9yYWNsZS5jb20+DQo+IC0tLQ0KPiAgZnMv
bmZzL25mczR4ZHIuYyB8ICAgIDQgKystLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9u
cygrKSwgMiBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9mcy9uZnMvbmZzNHhkci5j
IGIvZnMvbmZzL25mczR4ZHIuYw0KPiBpbmRleCBjZmNhYmMzLi42MDI0NDYxIDEwMDY0NA0KPiAt
LS0gYS9mcy9uZnMvbmZzNHhkci5jDQo+ICsrKyBiL2ZzL25mcy9uZnM0eGRyLmMNCj4gQEAgLTI1
ODksNyArMjU4OSw3IEBAIHN0YXRpYyB2b2lkIG5mczRfeGRyX2VuY19nZXRhY2woc3RydWN0IHJw
Y19ycXN0DQo+ICpyZXEsIHN0cnVjdCB4ZHJfc3RyZWFtICp4ZHIsDQo+ICAJCQlBUlJBWV9TSVpF
KG5mczRfYWNsX2JpdG1hcCksICZoZHIpOw0KPiAgDQo+ICAJcnBjX3ByZXBhcmVfcmVwbHlfcGFn
ZXMocmVxLCBhcmdzLT5hY2xfcGFnZXMsIDAsDQo+IC0JCQkJYXJncy0+YWNsX2xlbiwgcmVwbGVu
KTsNCj4gKwkJCQlhcmdzLT5hY2xfbGVuLCByZXBsZW4gKyAxKTsNCj4gIAllbmNvZGVfbm9wcygm
aGRyKTsNCj4gIH0NCj4gIA0KPiBAQCAtMjgxMSw3ICsyODExLDcgQEAgc3RhdGljIHZvaWQgbmZz
NF94ZHJfZW5jX2ZzX2xvY2F0aW9ucyhzdHJ1Y3QNCj4gcnBjX3Jxc3QgKnJlcSwNCj4gIAl9DQo+
ICANCj4gIAlycGNfcHJlcGFyZV9yZXBseV9wYWdlcyhyZXEsIChzdHJ1Y3QgcGFnZSAqKikmYXJn
cy0+cGFnZSwgMCwNCj4gLQkJCQlQQUdFX1NJWkUsIHJlcGxlbik7DQo+ICsJCQkJUEFHRV9TSVpF
LCByZXBsZW4gKyAxKTsNCj4gIAllbmNvZGVfbm9wcygmaGRyKTsNCj4gIH0NCj4gIA0KDQpJJ20g
aGF2aW5nIHRyb3VibGUgd2l0aCB0aGUgbWF0aCBoZXJlLiBXaHkgYXJlIHdlIHByZS1lbXB0aXZl
bHkNCnN1YnRyYWN0aW5nIGEgd29yZCBmcm9tIHRoZSB0YWlsPyBUaGUgaGVhZGVyIGNvbnN0YW50
cyBhcmUgYWx3YXlzIDQtYml0IA0KYWxpZ25lZCBiZWNhdXNlIHRoZXkgYXJlIGNhbGN1bGF0ZWQg
YXMgYSB3b3JkIGNvdW50LCBzbyBJJ20gbm90DQp1bmRlcnN0YW5kaW5nIHdoeSB3ZSBuZWVkIGNv
bW1pdCAwMmVmMDRlNDMyYmEgYXQgYWxsLg0KDQpDYW4geW91IHBsZWFzZSBleHBsYWluLCBDaHVj
az8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwg
SGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
