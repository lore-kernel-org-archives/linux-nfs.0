Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37BCBC04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:37:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E029B20663
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:37:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="fkeMXJfk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E029B20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725867AbeLAIsQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 03:48:16 -0500
Received: from mail-eopbgr750125.outbound.protection.outlook.com ([40.107.75.125]:36502
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725749AbeLAIsQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 1 Dec 2018 03:48:16 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lRIrv5VMAVvEhF4/KslFP7mKRNp57fWPnZ2WW06M+3I=;
 b=fkeMXJfkHkbvguDiWrmYH2VPFlOeX4xwVZ4h1eNjFwsqR4+uHaB1XNwx1K5G2G3GP/4tnCFJ1p2Qipz72JHBKD/Fx7IAwxK9PPohJJKNRd00jKIqhXt/+hHtDQl2KqH8Rmr4kXCt5+oWsFFiXPkHOSQ/Hipqnxb50AvH4xGbSC4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2319.namprd13.prod.outlook.com (52.135.94.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1404.8; Fri, 30 Nov 2018 21:37:34 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.011; Fri, 30 Nov 2018
 21:37:34 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
Thread-Topic: [PATCH v2 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
Thread-Index: AQHUiPJ0QlMh2p4wzUyZToZg/uHITqVo0+EAgAAA34CAAAGxAIAAAXWA
Date:   Fri, 30 Nov 2018 21:37:33 +0000
Message-ID: <14e5c2ae4982304c17df6903e9829289d0f44c93.camel@hammerspace.com>
References: <20181130211846.89000-1-trond.myklebust@hammerspace.com>
         <20181130211846.89000-2-trond.myklebust@hammerspace.com>
         <20181130211846.89000-3-trond.myklebust@hammerspace.com>
         <9D04832A-FC88-409C-8742-CBF742B6CB4A@oracle.com>
         <eaa3259a1aa12e29b8bd824f7cd417d6346239f9.camel@gmail.com>
         <93C4273C-DBBD-4B75-9F1F-EB103F2F430A@oracle.com>
In-Reply-To: <93C4273C-DBBD-4B75-9F1F-EB103F2F430A@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2319;6:eg8uyTzLWhzxdd8tVoqgbbBneIAjC6Fsn7ATtfAblNAoE0/S2fn52OI1Rp9FrPOYDD9ntMntGISLAoWmpZ3sgXz6ux5TVj9+0thcw7nn45lQVMk+15Ij4onYa6+yznH1Prbo+X6qBAtRq3lY0qtql826a2OgQhfZHN5eJxLPpNTIhXuvPfGoUu+cU2RoeW/Ds5qS5XZd95KqYMyxMDlizhN3/512Oq/3BISH2n6KYqycSv/mJK9N5zNjuPVXB5tIDveJNeoht9i4CT0qUssdWryaw//X8IF+2fyg2y+qEFs3OT1663yCEk3x324dbseFjahe2F7hWmNJTrR5EWMI+wzPcx3qAjve4kno9DWjTKzr6sdzKrvWNCAhTpVvDa68nFkT0s5I4CicmFNOeVugZBC6IMsKULgE7n9h7qdEzFwQObFTeXsr/NTzsjkw7rSPlQ8rFDDvfY025goTUsLVig==;5:o0zttRkTKZhYU1IGV1kwjbZtPts7IhkKRiCw6RtoMZVkWXVnIkBrRLvedolFFbQBhz9DYwhgPXKUJwCIbSBJbLvl1Ux61FjXjOQ3mxRGLzsj3UpfyLEB+xGIrUnBD8s8CqvW/WOkhqfCGAqaDACRVtwfxpYtAqBacK38TuZmQIk=;7:k74VKASbDpW2QE9efV6o+Bv012aKrsdszZperjLYEaK8hgHvT0/OhOdL/vaEiOC8dWY4+N9xlXri04KtNMiRdei+2L271kjkCp7pjQxH16Vb29NoEej4CRUOI2nbwWZDTv6w7V61e2uR3Bleq5FQMw==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: ccb3b85b-22c0-46ec-116b-08d6570c0a19
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2319;
x-ms-traffictypediagnostic: SN6PR13MB2319:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB2319D62C464359892913C749B8D30@SN6PR13MB2319.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(3002001)(10201501046)(3231453)(999002)(944501469)(52105112)(93006095)(93001095)(148016)(149066)(150057)(6041310)(20161123562045)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(20161123558120)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2319;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2319;
x-forefront-prvs: 087223B4DA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(396003)(39830400003)(366004)(376002)(199004)(189003)(99286004)(6916009)(2501003)(5660300001)(8936002)(106356001)(256004)(6512007)(105586002)(53936002)(5640700003)(36756003)(305945005)(66066001)(6436002)(6246003)(76176011)(2351001)(97736004)(102836004)(86362001)(6506007)(68736007)(7736002)(4001150100001)(93886005)(71200400001)(71190400001)(316002)(446003)(486006)(26005)(81166006)(118296001)(6486002)(478600001)(14454004)(81156014)(25786009)(2906002)(11346002)(186003)(476003)(2616005)(6116002)(3846002)(4326008)(8676002)(229853002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2319;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: O7q7BkEJwkZP4nB86lnHgF0JkssIJ5dZ5LjcqXjGiKM7zoTM4YKiRc08oCD9YliE3bTovuyFbO2f7HhQUMzrtqw0S2L3HN5l0CSV+pv+N7Y0UFvz34FYRNIDBb4DD86x0cpxI550sCbXcCSYuyJ9fQ3+scEzAC2emfG9K6UHHTymrPWGUyDw2J/InffOqcYzvCoux9zq3sPJoDkEj7AQGaoFBrQgOGLs7SAkp5amG/HLHBul6bPG+hE4XRR69b6JAzmnIS/nxdJDt9hninC5ev/TYevbIUAROCz2IKitKlxRBBaGZDUbLFgLP2K/ZMCm8U7F9byoS8zCsLY0yEUbkFSqQA9MwxnQQeDqHL3DJDA=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <8231B8A42866334BBF85D5B0CD878DE1@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ccb3b85b-22c0-46ec-116b-08d6570c0a19
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Nov 2018 21:37:33.9192
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2319
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTExLTMwIGF0IDE2OjMyIC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiANCj4gSSBhY3R1YWxseSBoYWQgYSBwYXRjaCB0aGF0IGxvb2tlZCBleGFjdGx5IGxpa2UgeW91
cnMgKGV4Y2VwdCBmb3IgdGhlDQo+IGRlc2NyaXB0aW9uIHRleHQpLiBJdCBkaWRuJ3Qgc2VlbSB0
byBkbyBhbnl0aGluZy4gU28gdGhlcmUgbWF5IGJlIGFuDQo+IGlzc3VlIGhlcmUsIGJ1dCBJIGRv
bid0IGJlbGlldmUgSSdtIHNlZWluZyBpdCB3aXRoIG15IHJlcHJvZHVjZXIuDQo+IA0KDQpBcmdo
Li4uIFllcywgSSB3YXMgdG9vIHF1aWNrIG9mZiB0aGUgdHJpZ2dlci4gVGhlIGNhbGwgdG8NCnhk
cl9idWZfaW5pdCgpIGluIHJwY194ZHJfZW5jb2RlKCkgd2lsbCBhY3R1YWxseSBjbG9iYmVyIHRo
ZSAtPmJ2ZWMNCmFycmF5Li4uDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xp
ZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2Uu
Y29tDQoNCg0K
