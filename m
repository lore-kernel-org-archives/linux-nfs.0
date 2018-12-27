Return-Path: <SRS0=fblw=PE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11CBDC43387
	for <linux-nfs@archiver.kernel.org>; Thu, 27 Dec 2018 22:14:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9E697218FE
	for <linux-nfs@archiver.kernel.org>; Thu, 27 Dec 2018 22:14:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="XSo0JdLf"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731900AbeL0WOU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 27 Dec 2018 17:14:20 -0500
Received: from mail-eopbgr720115.outbound.protection.outlook.com ([40.107.72.115]:2560
        "EHLO NAM05-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1732874AbeL0WOU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 27 Dec 2018 17:14:20 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=8J1D8zA/k1nj6rwWMuKJ/shX+Qd+758Z8LcM4Zbk1u4=;
 b=XSo0JdLfyZOI4ZpjNh5NRGfGxgt1zgxGfliorIu4U0rnw8PIxPNyLzLkCdDYnEUXxJJ0qR1POZ8Uo6F98dDF0sExTjd/okGrtz84JNBwwTj108TJ2fn919uPHwBYSawZKLpsrtgZksWknREXvEREbpbhZY6AIcEE+AC2PwVk6b8=
Received: from BYAPR13MB2486.namprd13.prod.outlook.com (52.135.230.12) by
 BYAPR13MB2486.namprd13.prod.outlook.com (52.135.230.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1471.17; Thu, 27 Dec 2018 22:14:16 +0000
Received: from BYAPR13MB2486.namprd13.prod.outlook.com
 ([fe80::bdfe:ef96:323:59a3]) by BYAPR13MB2486.namprd13.prod.outlook.com
 ([fe80::bdfe:ef96:323:59a3%2]) with mapi id 15.20.1471.019; Thu, 27 Dec 2018
 22:14:16 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     Charles Edward Lever <chuck.lever@oracle.com>
CC:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Thread-Topic: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Thread-Index: AQHUTob5qK09WaTXZkeMo/gY+CHqD6WTldAAgAAwIgA=
Date:   Thu, 27 Dec 2018 22:14:16 +0000
Message-ID: <BC34B04D-4AD5-46FB-8DC6-310BF3FBEBD3@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
 <4D3465FB-041C-4BB1-AB75-03511FA5AAF1@oracle.com>
In-Reply-To: <4D3465FB-041C-4BB1-AB75-03511FA5AAF1@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [46.9.229.60]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BYAPR13MB2486;6:0HnULp2N+kp64jV9tmvsO0GwmwzbksEg/HAbVUdtAR/ESZaGPrPpiHabzjomG9H3CeUsLMeyMG4gclM0vU6sCBo5S5nNIsVuJ8QXQSujtreHdqW4xeDvcWBBoqwBHB2SeUZLv3YvUBluxXU0juwF6U3W+AviBhpo/d9firrkzhmuvS5iw1DYqSOOSd3LwGI4j3c/kivyPCpyTL9LtPHMz0cBbcKTcOy0IU2oNPcK9ELpGjgT1yVpgWswdTwm/nO96oa5SWDcHkP42+ycxZcrpi8G2pMqlaKB/kJ6MnYucHYz8BTezuxWhV5NDm2l6dooIroU6FuAtcxkPf1Uk4sv3r8a5srvIUvwlNXUkV3QaEbadPa8IDq+YXNGs/+IAGFkYeJumvSGfvKr6KSxjB8gBg888WflGdLdz+TAa4vkG5pzrHije8h9CR+Hw6rsI5OjHpWo9YXiuiaPsl/uaB6dYA==;5:bofYUoYxMJySLJ3npTTdZYsLaKxgVr2sKQkUmllm0yHYBNKOdEXK1ZUZ7sVXQ6lDIM26pM3NldsZfkFkG28XKsLdFC5oXrV6xQlkB1E98BjLBovKMHJAKbyaUjtvVR8EywWIfIVbrWZjw166f2ZtJndoRaVoxin6ThTAXYkc8QU=;7:4W/FeBUA0BK3b6L1+pH0mlHctWAtcMUjh1K7v2bYctCjKhlTDBtknTPtsC98fcgrbqEG2z5lfuMOf9uLqc/fy9UuXDXJWzwQ4pSTFSZkMIc80VXP1fLr6lBVGIrltFdjeG0sDXV4LU0oVFxqT4v6BQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 395d5638-3e32-415e-1a9b-08d66c48a409
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:BYAPR13MB2486;
x-ms-traffictypediagnostic: BYAPR13MB2486:
x-microsoft-antispam-prvs: <BYAPR13MB2486985C3F5914C7D69D1872B8B60@BYAPR13MB2486.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(2401047)(8121501046)(3231475)(944501520)(52105112)(10201501046)(3002001)(93006095)(93001095)(6041310)(20161123558120)(20161123560045)(20161123562045)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:BYAPR13MB2486;BCL:0;PCL:0;RULEID:;SRVR:BYAPR13MB2486;
x-forefront-prvs: 0899B47777
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(396003)(346002)(366004)(39830400003)(136003)(189003)(199004)(99286004)(186003)(3846002)(102836004)(71190400001)(8936002)(71200400001)(26005)(105586002)(2906002)(6116002)(6506007)(53546011)(76176011)(106356001)(11346002)(2616005)(446003)(86362001)(486006)(6486002)(305945005)(256004)(25786009)(14444005)(33656002)(68736007)(36756003)(5660300001)(6246003)(97736004)(229853002)(4326008)(6512007)(6916009)(8676002)(478600001)(476003)(316002)(7736002)(53936002)(14454004)(6436002)(82746002)(66066001)(81166006)(83716004)(81156014)(93886005);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR13MB2486;H:BYAPR13MB2486.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: GnNqqY+2nuAbJunlmcYjf0LCNHrpi4V9FjA4LhOOrmyNWtcZqE24wFKtZGwtdIUl9N3o+rzMQkZSF74xnuLDN1Zpdky1yEjV3/yRs+GGxa71OM+c01VlFXEkqCbpwFByZZVEOAJqIT7dNNBrnzzMA5+eqFBKlzdTiy+knUf/c2kQrKqF5r21B91Uwe9PC9I5Nx7/F/AbCgk9+YxdQPv4ZCj1Mu23ugwrWMQT+PkjB/0QWwFUhAeer6/PFKNTju4tIGCeHrLDgicfZt5gqlXxcMPv7XiAdfJQPQxQ5rXU+pHG4/YKuOBaIfbpGJ7gAbK3
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <61D9BF661C506D4285FA966A1271E457@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 395d5638-3e32-415e-1a9b-08d66c48a409
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Dec 2018 22:14:16.2817
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR13MB2486
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

DQoNCj4gT24gRGVjIDI3LCAyMDE4LCBhdCAyMDoyMSwgQ2h1Y2sgTGV2ZXIgPGNodWNrLmxldmVy
QG9yYWNsZS5jb20+IHdyb3RlOg0KPiANCj4gSGkgVHJvbmQtDQo+IA0KPiBJJ3ZlIGNoYXNlZCBk
b3duIGEgY291cGxlIG9mIHJlbWFpbmluZyByZWdyZXNzaW9ucyB3aXRoIHRoZSB2NC4yMCBORlMg
Y2xpZW50LA0KPiBhbmQgdGhleSBzZWVtIHRvIGJlIHJvb3RlZCBpbiB0aGlzIGNvbW1pdC4NCj4g
DQo+IFdoZW4gdXNpbmcgc2VjPWtyYjUsIGtyYjVpLCBvciBrcmI1cCBJIGZvdW5kIHRoYXQgbXVs
dGktdGhyZWFkZWQgd29ya2xvYWRzDQo+IHRyaWdnZXIgYSBsb3Qgb2Ygc2VydmVyLXNpZGUgZGlz
Y29ubmVjdHMuIFRoaXMgaXMgd2l0aCBUQ1AgYW5kIFJETUEgdHJhbnNwb3J0cy4NCj4gQW4gaW5z
dHJ1bWVudGVkIHNlcnZlciBzaG93cyB0aGF0IHRoZSBjbGllbnQgaXMgdW5kZXItcnVubmluZyB0
aGUgR1NTIHNlcXVlbmNlDQo+IG51bWJlciB3aW5kb3cuIEkgbW9uaXRvcmVkIHRoZSBvcmRlciBp
biB3aGljaCBHU1Mgc2VxdWVuY2UgbnVtYmVycyBhcHBlYXIgb24NCj4gdGhlIHdpcmUsIGFuZCBh
ZnRlciB0aGlzIGNvbW1pdCwgdGhlIHNlcXVlbmNlIG51bWJlcnMgYXJlIHdpbGRseSBtaXNvcmRl
cmVkLg0KPiBJZiBJIHJldmVydCB0aGUgaHVuayBpbiB4cHJ0X3JlcXVlc3RfZW5xdWV1ZV90cmFu
c21pdCwgdGhlIHByb2JsZW0gZ29lcyBhd2F5Lg0KPiANCj4gSSBhbHNvIGZvdW5kIHRoYXQgcmV2
ZXJ0aW5nIHRoYXQgaHVuayByZXN1bHRzIGluIGEgMy00JSBpbXByb3ZlbWVudCBpbiBmaW8NCj4g
SU9QUyByYXRlcywgYXMgd2VsbCBhcyBpbXByb3ZlbWVudCBpbiBhdmVyYWdlIGFuZCBtYXhpbXVt
IGxhdGVuY3kgYXMgcmVwb3J0ZWQNCj4gYnkgZmlvLg0KPiANCg0KSG1t4oCmIFByb3ZpZGVkIHRo
ZSBzZXF1ZW5jZSBudW1iZXJzIHN0aWxsIGxpZSB3aXRoaW4gdGhlIHdpbmRvdywgdGhlbiB3aHkg
d291bGQgdGhlIG9yZGVyIG1hdHRlcj8NCg0KQ2hlZXJzDQogIFRyb25kDQoNCg0KX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGll
bnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5j
b20NCg0K
