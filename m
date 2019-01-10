Return-Path: <SRS0=3Jq2=PS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C89CC43387
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Jan 2019 15:53:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 02B87206B7
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Jan 2019 15:53:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netapp.onmicrosoft.com header.i=@netapp.onmicrosoft.com header.b="qW+sip81"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728795AbfAJPxd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 10 Jan 2019 10:53:33 -0500
Received: from mail-eopbgr700045.outbound.protection.outlook.com ([40.107.70.45]:57152
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729561AbfAJPxd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Jan 2019 10:53:33 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=netapp.onmicrosoft.com; s=selector1-netapp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZET1B15oS+fPcugDOpOJfDW0TiUtqcPBHF+AW41lvSw=;
 b=qW+sip81IIE3IUoPJW8FX8MAqwlTe35aO2Hb7aaFCJvBQ7ST55ZlYexpznSgrij1wWPPoP4TZtjZdnl1QP5cfYyTcLfVk4Aqw1RRd3dinrLyQo8Hn/LWcja7AWIbuRfrrS1+ltO0w6Ln6AEgdOmAR1G/rPiOGTBAAsN97lsGQv8=
Received: from DM5PR06MB3161.namprd06.prod.outlook.com (10.174.240.148) by
 DM5PR06MB3049.namprd06.prod.outlook.com (10.168.196.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1516.14; Thu, 10 Jan 2019 15:53:30 +0000
Received: from DM5PR06MB3161.namprd06.prod.outlook.com
 ([fe80::e942:888d:b5bb:44fb]) by DM5PR06MB3161.namprd06.prod.outlook.com
 ([fe80::e942:888d:b5bb:44fb%5]) with mapi id 15.20.1495.011; Thu, 10 Jan 2019
 15:53:30 +0000
From:   "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To:     "trond.myklebust@hammerspace.com" <trond.myklebust@hammerspace.com>,
        "santoshkumar.pradhan@wdc.com" <santoshkumar.pradhan@wdc.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "davej@codemonkey.org.uk" <davej@codemonkey.org.uk>
Subject: Re: [PATCH] sunrpc: kernel BUG at kernel/cred.c:825!
Thread-Topic: [PATCH] sunrpc: kernel BUG at kernel/cred.c:825!
Thread-Index: AQHUqDnEnNpCrEgCbkSvaaZ+iB8kNqWoqM0A
Date:   Thu, 10 Jan 2019 15:53:30 +0000
Message-ID: <e9fb95ddac73ce50483405ab76c8da13b48146e8.camel@netapp.com>
References: <20190109163826.2851-1-santoshkumar.pradhan@wdc.com>
In-Reply-To: <20190109163826.2851-1-santoshkumar.pradhan@wdc.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Evolution 3.30.4 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Anna.Schumaker@netapp.com; 
x-originating-ip: [216.240.30.11]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;DM5PR06MB3049;6:ySpTZif7iYCA1Eod0euVeq4YW5V4sAlrDYUFEwgyTpLGLx9zmc+FevPqNJTfYni9hP2Uy/JbkPn1jxGafnKDZwHdYPK4Pr2t7ltqafBsZWOVvxjDVPjcVP2iWYfkuKYVH8nNIq1HwbM70blkRVcYXO1WlaeLgZH51qE5Ud+T3iqSkVrzvZSwIZtcLzcoPZGGBdQ44bScZKDkHEmBP9mJ07i6/LoLl/1bRfoHM93cmep73vEFN/B3ALR9ZGAJg7DCtsC9NNg8leMuaMfI23n4zRWyk6lSWSkQCrKxhT4rT2L29NSRfxSHDY5gXsyMbJhCV60YpSmbDgQQq0LlhXR5/KU20cUBn20xftgRmgL1QswvTJvrozHJF7qlE7koVno7DRGP+LxCtyUVSf6+Kvw4zyzOuEyw/F0OxybrNs91LUz7sYI92ondocDo2hzvXiAh3gbId/MsAlyq6iGxvRh93A==;5:A4YZs73/Suw/n3a7nAMCQpt5uYdrNQqJsvqZKzoQYYU1VYiFT8MuW6eJVEDmfHie4G6TyDmieostt5Q7sy7x+K8R+L2NrsNFwvTLL8nMp7+vxuWUqlYTbtEahwCTz/dMREONbGQ7jxGKcz/+x/jUYKru+w0zIntQipDv1MqQRa775PbVKpuC1OPk6qspbORQhWqX6x2gssbq3zQW/N88bw==;7:jpo28Qfm0x+Crm5B08K1LvnVIVIAUgBwrd4zcb7vBu60nXCZHPwD+zU8tcB8+hkkPPhgQvMtuUnXziip22YLSles8eIvSvgOqUWvdH2F1McJZYanVzESb8lhTf47ZutcPu9BRB0BEmfY8YDdojG1wA==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: ee78001b-8ab1-4d56-7755-08d67713c46b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7193020);SRVR:DM5PR06MB3049;
x-ms-traffictypediagnostic: DM5PR06MB3049:
x-microsoft-antispam-prvs: <DM5PR06MB30490F1E2FB5691E741DEB8FF8840@DM5PR06MB3049.namprd06.prod.outlook.com>
x-forefront-prvs: 0913EA1D60
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(376002)(346002)(39860400002)(396003)(136003)(366004)(189003)(199004)(2906002)(446003)(11346002)(575784001)(97736004)(476003)(2616005)(4326008)(72206003)(86362001)(6512007)(229853002)(25786009)(6486002)(6116002)(5660300001)(53936002)(4744005)(3846002)(14454004)(68736007)(478600001)(6246003)(118296001)(8936002)(6436002)(76176011)(106356001)(105586002)(55236004)(6506007)(54906003)(110136005)(58126008)(102836004)(26005)(81156014)(316002)(256004)(186003)(99286004)(36756003)(71190400001)(71200400001)(81166006)(66066001)(2501003)(226693001)(305945005)(486006)(7736002)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR06MB3049;H:DM5PR06MB3161.namprd06.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: netapp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: v0yBhdZM1e3gk2V7d/tY+BiJmvVWwqbgwVh+dcQ/r5EmXED75G/A1wOcW1HX57Z6C1CR4W0lJRVPM383T+BWHVNt302FsC3x3MOK2VOqGPtPqty71L8XpvWMxu8JSWYrQ6HEBIZTYLNVjNHeoED0QU9Y/XNy/OvXV0qKR/a8oDCv/DpHNMWS5P/jjWQhKMMCw0QyWT0ybl6OqylOyFXUVqcrgdzJHYoIPk+k7kOFGtxIUAPyvy3wUSlL4TmcAeCPpTIj9klhqqzukWeh8Y1nYHFBtsP6pGfuGOyjztLo/hHWA6P45iy1UjAHV6b06ADL
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <31034E057E26D243B1FF2B0333E91DF8@namprd06.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ee78001b-8ab1-4d56-7755-08d67713c46b
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 Jan 2019 15:53:30.1834
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR06MB3049
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE5LTAxLTA5IGF0IDIyOjA4ICswNTMwLCBTYW50b3NoIGt1bWFyIHByYWRoYW4g
d3JvdGU6DQo+IEluaXQgbWlzc2luZyBkZWJ1ZyBtZW1iZXIgbWFnaWMgd2l0aCBDUkVEX01BR0lD
Lg0KPiANCj4gU2lnbmVkLW9mZi1ieTogU2FudG9zaCBrdW1hciBwcmFkaGFuIDxzYW50b3Noa3Vt
YXIucHJhZGhhbkB3ZGMuY29tPg0KPiBSZXBvcnRlZC1ieTogRGF2ZSBKb25lcyA8ZGF2ZWpAY29k
ZW1vbmtleS5vcmcudWs+DQoNClRoaXMgcGF0Y2ggbG9va3MgZ29vZCB0byBtZSwgdGhhbmtzIQ0K
DQpBbm5hDQoNCj4gLS0tDQo+ICBuZXQvc3VucnBjL2F1dGguYyB8IDMgKysrDQo+ICAxIGZpbGUg
Y2hhbmdlZCwgMyBpbnNlcnRpb25zKCspDQo+IA0KPiBkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy9h
dXRoLmMgYi9uZXQvc3VucnBjL2F1dGguYw0KPiBpbmRleCAxZmY5NzY4ZjU0NTYuLmYzMDIzYmJj
MGI3ZiAxMDA2NDQNCj4gLS0tIGEvbmV0L3N1bnJwYy9hdXRoLmMNCj4gKysrIGIvbmV0L3N1bnJw
Yy9hdXRoLmMNCj4gQEAgLTQxLDYgKzQxLDkgQEAgc3RhdGljIHVuc2lnbmVkIGxvbmcgbnVtYmVy
X2NyZWRfdW51c2VkOw0KPiANCj4gIHN0YXRpYyBzdHJ1Y3QgY3JlZCBtYWNoaW5lX2NyZWQgPSB7
DQo+ICAgICAgICAgLnVzYWdlID0gQVRPTUlDX0lOSVQoMSksDQo+ICsjaWZkZWYgQ09ORklHX0RF
QlVHX0NSRURFTlRJQUxTDQo+ICsgICAgICAgLm1hZ2ljID0gQ1JFRF9NQUdJQywNCj4gKyNlbmRp
Zg0KPiAgfTsNCj4gDQo+ICAvKg0KPiAtLQ0KPiAyLjIwLjENCj4gDQo=
