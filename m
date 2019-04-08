Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B075AC10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 18:51:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7A1112083E
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 18:51:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="tIcFCfAG"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726615AbfDHSvr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 14:51:47 -0400
Received: from mail-eopbgr820107.outbound.protection.outlook.com ([40.107.82.107]:13269
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726373AbfDHSvr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Apr 2019 14:51:47 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=b3eH/CEEuMUmFdYKkdxQI4O3w6wb+Xag9mBH/oc93L4=;
 b=tIcFCfAGFSQGIt0zTqQAmv5We62fmLWWtqebrZzHkwZr2Xp8RyW1tG45HJDPGYjKavlhhQeuevao/hD0YqmMUyxnYSGg1o6r2W5txg4bDeud+H8rLH62EZYifcWcWiOWLPW8sxlny4mnWR++syORSav+QXbBUItaNm6cnUPCtkE=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2560.namprd13.prod.outlook.com (52.135.96.20) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.11; Mon, 8 Apr 2019 18:51:44 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Mon, 8 Apr 2019
 18:51:44 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "daniel@zonque.org" <daniel@zonque.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: 5.1.0-rc4: Oops in __rpc_execute() when trying to boot from NFS
Thread-Topic: 5.1.0-rc4: Oops in __rpc_execute() when trying to boot from NFS
Thread-Index: AQHU7i3XWMBYs7+7DEGG17GL2cVEYaYym9UA
Date:   Mon, 8 Apr 2019 18:51:43 +0000
Message-ID: <ce6d2388a9214f95cc38de5ec225cba26cf63b0d.camel@hammerspace.com>
References: <0412f79c-61a8-bfa4-26ce-1083a59d31e8@zonque.org>
In-Reply-To: <0412f79c-61a8-bfa4-26ce-1083a59d31e8@zonque.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ac19ccd4-1eca-4b1a-1c1f-08d6bc533eca
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2560;
x-ms-traffictypediagnostic: SN6PR13MB2560:
x-microsoft-antispam-prvs: <SN6PR13MB256021EF703D35952CAAB742B82C0@SN6PR13MB2560.namprd13.prod.outlook.com>
x-forefront-prvs: 0001227049
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(346002)(366004)(136003)(376002)(396003)(199004)(189003)(6506007)(478600001)(256004)(106356001)(105586002)(6436002)(14454004)(446003)(110136005)(4326008)(102836004)(316002)(229853002)(118296001)(6486002)(36756003)(2501003)(97736004)(186003)(99286004)(26005)(305945005)(71200400001)(8676002)(2201001)(68736007)(2906002)(76176011)(4744005)(6246003)(81156014)(5660300002)(8936002)(486006)(53936002)(25786009)(81166006)(66066001)(3846002)(6512007)(6116002)(476003)(2616005)(11346002)(7736002)(71190400001)(86362001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2560;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 1USVAKoMJb0ZiRZlmF9EAANfCD8TeBMRl5NX8TjKUcDyqXN1g77YdTQ0pdFjqm0Z9mJcNCtYbY1XmDEQS3PY2Cylx35WrRM/mKNCrcmJxQpLwma660MscLktEJSQVqaAIpV2aRnok4H6NkjQTGC5m6459PjzXT2gsmlhHTvKAX+nbDdP14g47qlsfFbHH7HLY9dMTzVOGsyz3LcZtiBlCF715ikzZ8KU8y2kfWeQiVpbG+Bp2HExam8NxjIIQH2JbkPXYHubBaguZ5wayMVFMCdq8ksjn4X0RnBIFlvmvSbcp5o6+Q55MORRmog3IUm8yeL3lyMsJm8pJvGvXTThnsZ3OI9OzWHDaaOpjOYgNmXaZMQlm+kduA7tMEjbH5/iOlFtNFcZ+7krp2Fgzq725TgaoyzlxAJGmeW6rpBwvq4=
Content-Type: text/plain; charset="utf-8"
Content-ID: <50A9D1076D58E645BDEE029947E3DAFB@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ac19ccd4-1eca-4b1a-1c1f-08d6bc533eca
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Apr 2019 18:51:43.9823
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2560
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTA0LTA4IGF0IDE5OjAxICswMjAwLCBEYW5pZWwgTWFjayB3cm90ZToNCj4g
SGksDQo+IA0KPiBJJ20gc2VlaW5nIHRoZSBPb3BzIGJlbG93IHdoZW4gdHJ5aW5nIHRvIGJvb3Qg
NS4xLjAtcmM0IG9uIGFuIEFSTQ0KPiBQWEEzeHgNCj4gcGxhdGZvcm0uIHY1LjAgZGlkIG5vdCBz
aG93IHRoaXMgZWZmZWN0IHdpdGggdGhlIHNhbWUgY21kbGluZS4NCj4gDQo+IFJlbGV2YW50IGJp
dHMgZnJvbSB0aGUgY29uZmlnIGFyZToNCj4gDQo+IENPTkZJR19ORlNfRlM9eQ0KPiBDT05GSUdf
TkZTX1YyPXkNCj4gQ09ORklHX05GU19WMz15DQo+ICMgQ09ORklHX05GU19WM19BQ0wgaXMgbm90
IHNldA0KPiAjIENPTkZJR19ORlNfVjQgaXMgbm90IHNldA0KPiAjIENPTkZJR19ORlNfU1dBUCBp
cyBub3Qgc2V0DQo+IENPTkZJR19ST09UX05GUz15DQo+IENPTkZJR19ORlNfRlNDQUNIRT15DQo+
ICMgQ09ORklHX05GU0QgaXMgbm90IHNldA0KPiBDT05GSUdfTkZTX0NPTU1PTj15DQo+IA0KPiBB
bnl0aGluZyBlbHNlIEkgY2FuIHByb3ZpZGU/IEkgY291bGQgYmlzZWN0IHRoZSBpc3N1ZSBpZiB0
aGF0IGhlbHBzLg0KPiANCg0KUGxlYXNlIGRvIGJpc2VjdCBpZiB0aGF0IGlzIGF0IGFsbCBwcmFj
dGljYWwuIEknbSBoYXZpbmcgdHJvdWJsZQ0KaW50ZXJwcmV0aW5nIHRoaXMgT29wcy4NCg0KVGhh
bmtzIQ0KICBUcm9uZA0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFp
bnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0K
DQo=
