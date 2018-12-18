Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F295C43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 15:56:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5C3FE21871
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 15:56:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="pKSyCJ21"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727047AbeLRP4B (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 10:56:01 -0500
Received: from mail-eopbgr730122.outbound.protection.outlook.com ([40.107.73.122]:33998
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727002AbeLRP4B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 10:56:01 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pjewZ6104CRxMDWF5aCvmE0JSz+DO+8im8O9C+l6WHw=;
 b=pKSyCJ213r31YipAweiBMm1L1yiJ+KIlHbBMdhtwlEmewUYUkOj/e8sCkwxZTcSbrCtLHFCLlaWZR7x2MqC7Tb8HN5tN24G49hlFQXx9vHSHnE996dF7JCUuq6RZL+FtKdCtMMAm383lCQN5+ItF96dtCBw2qfp+BKdmHm/rqKE=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2416.namprd13.prod.outlook.com (52.135.94.160) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1446.15; Tue, 18 Dec 2018 15:55:57 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1446.015; Tue, 18 Dec 2018
 15:55:57 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "smayhew@redhat.com" <smayhew@redhat.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dwysocha@redhat.com" <dwysocha@redhat.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 1/3] SUNRPC: Fix disconnection races
Thread-Topic: [PATCH v2 1/3] SUNRPC: Fix disconnection races
Thread-Index: AQHUlltg9GdqrvxUuUm55vOL4EPwwqWEjQ+AgAAai4A=
Date:   Tue, 18 Dec 2018 15:55:57 +0000
Message-ID: <2acfb506b55380b3c46ef62cd597d724a517fd75.camel@hammerspace.com>
References: <20181217225235.124448-1-trond.myklebust@hammerspace.com>
         <20181218142055.GK27213@coeurl.usersys.redhat.com>
In-Reply-To: <20181218142055.GK27213@coeurl.usersys.redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2416;6:83iINIp5cJ1kKHQqtSNpR7xajPFLvOpxqY4gt2ZcJIxtBDlZYsNMGatNfDiQLHAuWDdbL7nPC+1d7yDaYDWDhPRiNTGb/0MPxSD49Ts3KpFFPTTL93kacS3biw9drfhHkRaxUpXudppgzL12ff7Hn4WflrWQh2kZfcn23mRYVLVVAsxB53WeROR8f1z+hUdzpP62vkuee0d/17e2fMrdfmAqvI5fJ9rpYfOjT+HKB1QkVcclwbtOywM0tCu+y2YPCU339EL9rzGo09V7KhiRUWKnz6BEv1CFOExuWFST3+ksMSUQUoYqu7Uor3cA6HoSgVMTPlhp2iHtf8oEPamGJtyBRBgrgL/St5LkcIB9BjlkxZPZB6SdzoHOsNVKpllpi+fnawtSg2LQ/b0yBVAmi+wB9rg3UOgImqyALUKGPb7U/2GNrGJJ90LTeKaKDBfr7gKGwuJKt0vZ3wmwE0UMjA==;5:w26alLO+WS2ioPwwAJ054KA7tYoMPbtLKYMLeJMQSIaJ05jf5MCZOXSNc7QZnpKcC3ThKiqY0+JnQM6gaQsRtBUP01RzGIAaD41Kz8p6/U8v645+sNPj/uqLeQhh0OoQ2zVP77ur/QwZTju//N3kqgeHyddP80PaUhv/gMEPTtE=;7:k1WeJyDt7NDrg4LB0Z2Ixeu1i0MHKLPfFKFNtk0chUBMtEbOzQJ7i9w2kIXG8ayJxCJIEqzpDvoesn+O0QsC+cimyJ5AmGgW9m3ypQjYaLoG2RYI0MTRErKczo22RIcT6UF+YdApL+rqTfTY0Aqlzw==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: dad2316b-a33e-414c-0017-08d665014c7a
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2416;
x-ms-traffictypediagnostic: SN6PR13MB2416:
x-microsoft-antispam-prvs: <SN6PR13MB2416BDB029F94CAFF3EFF30EB8BD0@SN6PR13MB2416.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(6040522)(2401047)(8121501046)(5005006)(93006095)(93001095)(3231475)(944501520)(52105112)(3002001)(10201501046)(148016)(149066)(150057)(6041310)(20161123560045)(20161123558120)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2416;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2416;
x-forefront-prvs: 08902E536D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(396003)(39830400003)(346002)(366004)(136003)(189003)(199004)(7736002)(118296001)(36756003)(8936002)(81166006)(81156014)(256004)(1730700003)(8676002)(86362001)(6512007)(99286004)(229853002)(446003)(11346002)(2616005)(71190400001)(71200400001)(305945005)(486006)(478600001)(476003)(14454004)(316002)(3846002)(186003)(6116002)(2501003)(6916009)(4001150100001)(68736007)(2906002)(5660300001)(97736004)(66066001)(102836004)(4326008)(6246003)(5640700003)(26005)(25786009)(105586002)(2351001)(53936002)(6486002)(6436002)(106356001)(54906003)(76176011)(6506007);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2416;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: pbBTQc3W0CJ1TnszKEIOwJefEh2nudNoT4QJ7jils3n96omTvKv8/BWT0koK/k+4pCpLxzIDMoEKkbicBK/eLUG+l5tnlQsbL7sKA+NhJN4O8JaynlCgp11VtI4Bttsx9svLvcM9BXxMzYiONBIKfH71OG7/YihbI0Xz93Bh72BwDdndFihziOQCqZSzNOeD8TQTU+ge08ezDf54VeJQ2Nqn9pAwWzJncW5MBnmH0sNV4/g/VDf78YYvklliAl7u2XuE9cVzb8M/nymK7QqKk5K0ZYcs9morOq/0Bjm7GXtntoIg7YExZtc8kG/aPs4C
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <CF225DFD3A63B646A090E4600E90BF3D@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: dad2316b-a33e-414c-0017-08d665014c7a
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Dec 2018 15:55:57.0229
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2416
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE4LTEyLTE4IGF0IDA5OjIwIC0wNTAwLCBTY290dCBNYXloZXcgd3JvdGU6DQo+
IEkgcmFuIERhdmUncyB0ZXN0IGluIGEgbG9vcCBvdmVyIG5pZ2h0IHdpdGggdGhlc2UgMyBwYXRj
aGVzIG9uIHRvcCBvZg0KPiB2NC4yMC1yYzcgYW5kIGRpZG4ndCBzZWUgYW55IG1vcmUgb2YgdGhl
IFhQUlRfV1JJVEVfU1BBQ0UgaGFuZ3MuDQo+IA0KDQpUaGFua3MgZm9yIHZlcmlmeWluZyB0aGF0
IQ0KDQpDaGVlcnMNCiAgVHJvbmQNCg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZT
IGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNw
YWNlLmNvbQ0KDQoNCg==
