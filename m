Return-Path: <SRS0=Y3U+=SW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE990C282DD
	for <linux-nfs@archiver.kernel.org>; Sat, 20 Apr 2019 19:28:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 87EC2208C0
	for <linux-nfs@archiver.kernel.org>; Sat, 20 Apr 2019 19:28:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Vtk1BtFZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726596AbfDTT23 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 20 Apr 2019 15:28:29 -0400
Received: from mail-eopbgr790100.outbound.protection.outlook.com ([40.107.79.100]:25280
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726309AbfDTT23 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Apr 2019 15:28:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=NptcuhOsa1dY36fxPi5miAHlhMHLJprO9JvfeoGkIfA=;
 b=Vtk1BtFZAsEaPcCQ8d0MSsqsYEXNwvi4lmAf3RRpr2QUkhzz64GiK6XarOudPmKlfM3mLNIHTVbtrKWv/fyWODMNo0Sqz2HDxj0g7eTRM8oh3HOYEf1XL7v05C3b1KPsR27dq0GwLDJ930suIFqmkitIwkkPCRWfSCe8K3asKdY=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2576.namprd13.prod.outlook.com (52.135.96.24) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1835.7; Sat, 20 Apr 2019 19:28:25 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::48d2:c5de:2651:4c30]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::48d2:c5de:2651:4c30%2]) with mapi id 15.20.1835.003; Sat, 20 Apr 2019
 19:28:25 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull 1 NFS client bugfix
Thread-Topic: [GIT PULL] Please pull 1 NFS client bugfix
Thread-Index: AQHU9685McGBL3YIb0GmIuF5ZemXpw==
Date:   Sat, 20 Apr 2019 19:28:24 +0000
Message-ID: <bb6e36bd32eb85f32b15edacc9753341641f43fc.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 21936fc3-f197-4fc9-202b-08d6c5c65b9d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600141)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:SN6PR13MB2576;
x-ms-traffictypediagnostic: SN6PR13MB2576:
x-microsoft-antispam-prvs: <SN6PR13MB2576DD7703D329D8EB0781E1B8200@SN6PR13MB2576.namprd13.prod.outlook.com>
x-forefront-prvs: 0013079544
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(39830400003)(136003)(346002)(396003)(366004)(199004)(189003)(91956017)(76116006)(73956011)(316002)(64756008)(2906002)(6506007)(4326008)(2351001)(7736002)(102836004)(54906003)(118296001)(305945005)(26005)(66946007)(256004)(6116002)(66446008)(8676002)(8936002)(6486002)(81156014)(53936002)(6512007)(81166006)(1730700003)(6436002)(25786009)(97736004)(68736007)(5640700003)(186003)(66556008)(86362001)(6916009)(3846002)(4744005)(2616005)(486006)(476003)(71200400001)(478600001)(99286004)(14454004)(5660300002)(36756003)(71190400001)(2501003)(66066001)(66476007);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2576;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: /9T2jqmbCfhl76zHUI/+KniqS6j9UMhnYhgnUEDbUHk4oVouKiqmedAzxPZvN9UpewUrH+fYxYx3P8BxNFdJwPFxM3tKLBLmlf0fS7Mjlq5cgznoKFHTn3x4R6lEbR8RxgypFEGDhqtuA8SjuSWMTTyByiNR7TmpNbvwfWIzi74BIYtP2WM1dp5B+KUxieDsW9kkH3O3+WcAKwdoDtKgn/c2SUT7phx3lv1xeyTTX97NTPymJwtKjILg4edqizi9Z54wdOO0brnSZ9phnfxYcHh7ALKnO+JuTwt9+9qnembWJY3UaZQ/UMTqSlJ3gA3cLzaMXqyMNPf5EMgkiVujBZToW6W5FSAJ8rTLfAVR8t8vdJimIE3Qc7TQUdBlX27QtpPCWAZD5TKPSANCoSW1X10WMVijX6YyzFfUnmvfpyg=
Content-Type: text/plain; charset="utf-8"
Content-ID: <DEB2AE7035EB204B8FA85CCAC394C2D8@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 21936fc3-f197-4fc9-202b-08d6c5c65b9d
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Apr 2019 19:28:24.8682
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2576
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTGludXMsDQoNClRoZSBmb2xsb3dpbmcgY2hhbmdlcyBzaW5jZSBjb21taXQgZGM0MDYwYTVk
YzI1NTdlNmI1YWE4MTNiZjViNzM2NzcyOTlkNjJkMjoNCg0KICBMaW51eCA1LjEtcmM1ICgyMDE5
LTA0LTE0IDE1OjE3OjQxIC0wNzAwKQ0KDQphcmUgYXZhaWxhYmxlIGluIHRoZSBHaXQgcmVwb3Np
dG9yeSBhdDoNCg0KICBnaXQ6Ly9naXQubGludXgtbmZzLm9yZy9wcm9qZWN0cy90cm9uZG15L2xp
bnV4LW5mcy5naXQgdGFncy9uZnMtZm9yLTUuMS01DQoNCmZvciB5b3UgdG8gZmV0Y2ggY2hhbmdl
cyB1cCB0byBhN2IxYTQ4MzlmZjk3OWI0ZGQ0ZmI2YzFjY2QzMWFmMTFkZTljYTg3Og0KDQogIFNV
TlJQQzogSWdub3JlIHF1ZXVlIHRyYW5zbWlzc2lvbiBlcnJvcnMgb24gc3VjY2Vzc2Z1bCB0cmFu
c21pc3Npb24gKDIwMTktMDQtMTcgMTY6MDc6MjggLTA0MDApDQoNCkNoZWVycw0KICBUcm9uZA0K
DQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tDQpORlMgY2xpZW50IGJ1Z2ZpeGVzIGZvciBMaW51eCA1LjENCg0KSGlnaGxpZ2h0
cyBpbmNsdWRlOg0KDQpCdWdmaXhlczoNCi0gRml4IGEgcmVncmVzc2lvbiBpbiB3aGljaCBhbiBS
UEMgY2FsbCBjYW4gYmUgdGFnZ2VkIHdpdGggYW4gZXJyb3IgZGVzcGl0ZQ0KICB0aGUgdHJhbnNt
aXNzaW9uIGJlaW5nIHN1Y2Nlc3NmdWwNCg0KLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KVHJvbmQgTXlrbGVidXN0ICgxKToN
CiAgICAgIFNVTlJQQzogSWdub3JlIHF1ZXVlIHRyYW5zbWlzc2lvbiBlcnJvcnMgb24gc3VjY2Vz
c2Z1bCB0cmFuc21pc3Npb24NCg0KIG5ldC9zdW5ycGMvY2xudC5jIHwgNyArKysrKy0tDQogMSBm
aWxlIGNoYW5nZWQsIDUgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCi0tIA0KVHJvbmQg
TXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9u
ZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
