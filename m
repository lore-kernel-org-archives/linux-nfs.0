Return-Path: <SRS0=GLKr=PR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB1D8C43387
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 20:38:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6AFE2206B6
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 20:38:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ckLWi6D4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726477AbfAIUiz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 9 Jan 2019 15:38:55 -0500
Received: from mail-eopbgr760131.outbound.protection.outlook.com ([40.107.76.131]:10656
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726181AbfAIUiz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 Jan 2019 15:38:55 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3CNrlYesBVUHxnwoby3FcBYezx0dR+3x2vaQA/TuzFs=;
 b=ckLWi6D4gAtgww2ubgJnkUzQ0qz9NEjInuXW55iNt9GWTnAG3peFAH7WBjSGHtYs2apzxHuXy4V8J5xSW5pj8slbWCuJY/7VZv8BL1Zn7PfZhouCtUHCiVtwnJZrN0YYKHGoCbY0CD4rDwiLSe5ldiPumE/ntjWtpVbIrQePBRo=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2368.namprd13.prod.outlook.com (52.135.94.148) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1516.3; Wed, 9 Jan 2019 20:38:51 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%4]) with mapi id 15.20.1516.010; Wed, 9 Jan 2019
 20:38:51 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "aglo@umich.edu" <aglo@umich.edu>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH 0/5] Fun with the multipathing code
Thread-Topic: [RFC PATCH 0/5] Fun with the multipathing code
Thread-Index: AQHUqFMBQpl0cjz7OUaNV1iNSYXWIqWnZf4A
Date:   Wed, 9 Jan 2019 20:38:51 +0000
Message-ID: <27c2a121e83a6546d3a35aeb07ae6b1f9b372fe0.camel@hammerspace.com>
References: <20170428172535.7945-1-trond.myklebust@primarydata.com>
         <CAN-5tyEp5=bF2mFjTCs2K2NdKWLY=msqN-5c94hwuXSm3QTDAw@mail.gmail.com>
In-Reply-To: <CAN-5tyEp5=bF2mFjTCs2K2NdKWLY=msqN-5c94hwuXSm3QTDAw@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2368;6:5KF22tvG8v6lMjgwciJUhTu63VY/wBWuK6mRB6PkQgAItnq/f4JYrcKXgXxxfYbmeJ3QMcT9a2seioaS5HyAc1p9acvBwgaLcEJ7ymmSuXN/rvQ2E0GWjrGECDuCBONsmxiNKTQRvvuvpjsBDYtH6kv6cEevH+IAlG8El/NMhLvYPEfvZsOO9nyVTOmLCeLynmuQSOtBh3ovKWfXiC2TAEGLZB4u+9hmHucgpSpu0F6nDYfzF8tnVnieyFFvsbt2gEAS2hlg1ReTuM2jwcZG6tetvtWMVXzKOzqCqK0XU/HBgOfn0fP7SGoZ/G/hXTBgMXanPWY20SiKxTOYzQNjhEy+W+6ggjoCzZpPmidb/c0tGANOpoysF/oV9Rfq+ZQaZ4vhmXYiZTjFz490lrzy+jnHrfNTh15f/3Kyz4QWkYUlA2jOBcnYPQj6rsAdZEALmamIWBrWA78ykJfjegK9vg==;5:8VCmv/v8OHR+Z9yXrVMYfVL83FBGRmPOG1t0DMugWvNrB9iC85aYTCoC6rgl5rqlLqnEf/nxndDmcIXIQx+uQ3vZfqAUO+/PJT7GTxNdJsontHaCSoPk1P1E+tl8ppvoh0LaNMCbm0JlWpmVLLeWUV3n2VlrVv65d91UalyocB86LBmtWNlwc9FMZ7bzeLsrSUXj4vB3CwvTiBBSPEQ4Ig==;7:alzd2imy1VmyARw1lfAd5ESXHbQt8p9Nbq5/sFPjs6qvd2dWRh4Ssfm+pN1sWoee/QBXpd9aGMXAK1CuGhV0CiGApAy0x9Q0u83d5Ya/v0t/VX4Xrv+0d7o61Ci4plp/rnOdYeL83urO60HKuKFQgw==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: a89ffa8f-5a59-4eb4-1cee-08d676727706
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2368;
x-ms-traffictypediagnostic: SN6PR13MB2368:
x-microsoft-antispam-prvs: <SN6PR13MB2368AD720CED7352B45635A5B88B0@SN6PR13MB2368.namprd13.prod.outlook.com>
x-forefront-prvs: 0912297777
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39830400003)(376002)(346002)(396003)(366004)(199004)(189003)(68736007)(6486002)(118296001)(7736002)(305945005)(5660300001)(6306002)(105586002)(2171002)(53936002)(5640700003)(4326008)(6512007)(14454004)(6246003)(2501003)(966005)(3846002)(11346002)(476003)(446003)(36756003)(478600001)(2616005)(99286004)(2351001)(316002)(229853002)(106356001)(76176011)(6506007)(71190400001)(256004)(71200400001)(2906002)(6116002)(217873002)(86362001)(8936002)(6436002)(6916009)(25786009)(8676002)(1730700003)(81156014)(81166006)(66066001)(102836004)(6346003)(97736004)(486006)(26005)(186003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2368;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: U5JLrgYgOhxL9+7C06wemYGBcjPQMPpTbIaxRA9oYpGfdii1EK1vFgcqIA3/782kPuOVgetHiBWaURjqhHoran6quBxD02CXgfiFCOKJIykMYjhvOSCB3HTMNAEDe42KxdlxUQVEbb6ErSn+8R8g5eDqwX1qBxzqARPiSGDf7E6Qi5BiQpxDFODdwTGoPpGvYIXgxNFPe7pKjdDE2uU0bBIfg1xfjrVATB3PHQP5yD6hkIEmw6zQC0XF1GExZgeFEPHkP+3/IFA+n5bh5711KOY8xiliNhjYkeNfxWZiU8PzsyG2pV0XGZcxtxdP1fzv
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <CE05002252F95C4695138B1AD79AA643@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a89ffa8f-5a59-4eb4-1cee-08d676727706
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Jan 2019 20:38:51.3141
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2368
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgT2xnYQ0KDQpPbiBXZWQsIDIwMTktMDEtMDkgYXQgMTQ6MzkgLTA1MDAsIE9sZ2EgS29ybmll
dnNrYWlhIHdyb3RlOg0KPiBIaSBUcm9uZCwNCj4gDQo+IERvIHlvdSBoYXZlIGFueSBwbGFucyBm
b3IgdGhpcyBwYXRjaCBzZXQ/DQo+IA0KPiBJIGFwcGxpZWQgdGhlIHBhdGNoZXMgb24gdG9wIG9m
IDQuMjAtcmM3IGtlcm5lbCBJIGhhZCBhbmQgdGVzdGVkIGl0DQo+IChsaW51eCB0byBsaW51eCkg
d2l0aCBpb3pvbmUgb24gdGhlIGhhcmR3YXJlICg0MEcgbGluayB3aXRoIE1lbGxhbm94DQo+IENY
LTUgY2FyZCkuDQo+IA0KPiBSZXN1bHRzIHNlZW0gdG8gc2hvdyByZWFkIElPIGltcHJvdmVtZW50
IGZyb20gMS45R0IgdG8gMy45R0IuIFdyaXRlDQo+IElPDQo+IHNwZWVkIHNlZW1zIHRvIGJlIHRo
ZSBzYW1lIChkaXNrIGJvdW5kIEknbSBndWVzc2luZykuIEkgYWxzbyB0cmllZA0KPiBtb3VudGlu
ZyB0bXBmcy4gU2FtZSB0aGluZy4NCj4gDQo+IFNlZW1zIGxpa2UgYSB1c2VmdWwgZmVhdHVyZSB0
byBpbmNsdWRlPw0KDQpUaGFua3MgZm9yIHRlc3RpbmcgdGhpcy4NCg0KV2FzIHRoaXMgeW91ciBv
d24gcG9ydCBvZiB0aGUgb3JpZ2luYWwgcGF0Y2hlcywgb3IgaGF2ZSB5b3UgdGFrZW4gbXkNCmJy
YW5jaCBmcm9tIA0KaHR0cDovL2dpdC5saW51eC1uZnMub3JnLz9wPXRyb25kbXkvbGludXgtbmZz
LmdpdDthPXNob3J0bG9nO2g9cmVmcy9oZWFkcy9tdWx0aXBhdGhfdGNwDQo/DQoNCkVpdGhlciB3
YXkgSSBhcHByZWNpYXRlIHRoZSBkYXRhIHBvaW50LiBJIGhhdmVuJ3Qgc2VlbiB0b28gbWFueSBv
dGhlcg0KcmVwb3J0cyBvZiBwZXJmb3JtYW5jZSBpbXByb3ZlbWVudHMsIGFuZCB0aGF0J3MgdGhl
IG1haW4gcmVhc29uIHdoeQ0KdGhpcyBwYXRjaHNldCBoYXMgbGFuZ3Vpc2hlZC4NCg0KMy45R0Iv
cyB3b3VsZCBiZSBhYm91dCAzMUdicHMsIHNvIHRoYXQgaXMgbm90IHF1aXRlIHdpcmUgc3BlZWQs
IGJ1dA0KY2VydGFpbmx5IGEgYmlnIGltcHJvdmVtZW50IG9uIDEuOUdCL3MuIEknbSBhIGxpdHRs
ZSBzdXJwcmlzZWQsIHRib3VnaCwNCnRoYXQgdGhlIHdyaXRlIHBlcmZvcm1hbmNlIGRpZCBub3Qg
aW1wcm92ZSB3aXRoIHRoZSB0bXBmcy4gV2FzIGFsbCB0aGlzDQp1c2luZyBhaW8rZGlvIG9uIHRo
ZSBjbGllbnQ/DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50
YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
