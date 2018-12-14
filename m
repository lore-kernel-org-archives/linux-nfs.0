Return-Path: <SRS0=hAdq=OX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 578A4C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 21:33:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 84254206DD
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 21:33:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Tbmu4jcC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730854AbeLNVdU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Dec 2018 16:33:20 -0500
Received: from mail-eopbgr710097.outbound.protection.outlook.com ([40.107.71.97]:53737
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730846AbeLNVdU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Dec 2018 16:33:20 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=7XYB9/k0bwkfBdVJMXrN2EzuARWBUMhxaGVBHXQm2T4=;
 b=Tbmu4jcCZAr5ugcW8ha7AdJa+Aj0lDdgSoqKtuG52p94eQ0e4LXB+Qz79k6cOvQi31fQcSiYKyfoVnGqs2zZaPx40OiNNQL++YyRp1iGX4iqRwoUbVppHkoGLuPx7ajAymbzEg/38FIYeD3LcRLVGCHq0m7TeMCtkRA92/7EvlA=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2528.namprd13.prod.outlook.com (52.135.95.158) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1425.10; Fri, 14 Dec 2018 21:33:15 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1425.021; Fri, 14 Dec 2018
 21:33:15 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "smayhew@redhat.com" <smayhew@redhat.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: Be sure to clear XPRT_WRITE_SPACE when resetting
 the transport
Thread-Topic: [PATCH] sunrpc: Be sure to clear XPRT_WRITE_SPACE when resetting
 the transport
Thread-Index: AQHUk9sFH3HgprfhW0a1FuM6yMRWpqV+wYWA
Date:   Fri, 14 Dec 2018 21:33:15 +0000
Message-ID: <a7b8fb5de0a1b6623c0450577e225421ad731790.camel@hammerspace.com>
References: <20181214182956.14643-1-smayhew@redhat.com>
In-Reply-To: <20181214182956.14643-1-smayhew@redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2528;6:qf6UIrgyW/YPqfEQulveXYu2cI6j869xLmQ4fYbnqzyzlnH2OsabgUHjc9P9O9vKPDYDxF8WMRvrT7LelMGHapotNrXmUeI384VhPsY16vI29s1JOTJaap7nd7F80xF6jnrPPgpXsIVI+pkYnNgQlZsNzxPYEyHHe4VyfWDHJT8q3qtgnKouM+1uZGpN7I5zkUPWRd8P9cAAFZCUV3SKNSPh0sr2clEz3k3xpT68awGXmd2SILyseqHK3f3a/H3AQFSvMO3JT8Y4pTDNTh11JEz0pfDlwUi9oR+acDDsO+3PiwbHLd52li+LIfAiYyOed/WtyCoW5Uw0uRjvPRGXNtv2en+RGV28+C7hTmOkSx+rTr0LuHdn7+73qHIgzuaT9hCZXTio0Vrg67zuIrh6pwJzajatatfkbvEEmxg1PtK6q668R539oIBIiuKc9bFI1x1bWfNymzd6hcuaIuEaSw==;5:oKNryRAnnsd8OouwfF+UEFrkijok9W9daHFq7YvGyul4JQsbJfe+JwyHpqH/uddi3scAkuOKpONwVbeO6tXM42JLsQmj3ploOIs3Ap4YTm/VhArnz+D055vcnkZH1f37uRNL80pKbxRSd6Q3rqlkdw1uXcb0oXgPpDUsbjqVgLM=;7:Cycj4Sw4tljLDOID5mt+mxo/13F2eQfJzzve/ibQEKS+fJMHweLIFq3qCf0OZhX/gJyrC6FIp6B9RKBnACN8GbcGpKCtWrnQ1Q+v+N3jZSXtaj3W1M8XaatLXP5rJpgJGr4viSwMfO8fcnw3q1R8hA==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: cb0c6484-14c8-4de6-78bf-08d6620bc1ed
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2528;
x-ms-traffictypediagnostic: SN6PR13MB2528:
x-microsoft-antispam-prvs: <SN6PR13MB2528693EDFB358EC3228C975B8A10@SN6PR13MB2528.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(3002001)(3231475)(944501520)(52105112)(10201501046)(148016)(149066)(150057)(6041310)(20161123560045)(20161123562045)(20161123564045)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2528;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2528;
x-forefront-prvs: 08864C38AC
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(346002)(39830400003)(396003)(136003)(376002)(199004)(189003)(6486002)(6506007)(106356001)(110136005)(316002)(102836004)(66066001)(99286004)(6116002)(2906002)(3846002)(6246003)(76176011)(81166006)(5660300001)(4001150100001)(71190400001)(71200400001)(97736004)(36756003)(2501003)(25786009)(8936002)(2616005)(256004)(14444005)(6512007)(53936002)(486006)(81156014)(8676002)(476003)(11346002)(446003)(4326008)(118296001)(229853002)(7736002)(186003)(305945005)(575784001)(86362001)(478600001)(68736007)(14454004)(6436002)(105586002)(26005);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2528;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: nshx8t2DOuT0W/hmmd4gbUgHwJUOH6v571+5fEt9DAdMEXxqPjFsoxZg0QGGGOvtO6W8bRI3LJOS1YF2b8Fr5WnOLnhuZlxYH4HjZ6Dd7Bh/nZSiMe7oN7BbVQf4MlVP9cJsAnL36Zu837E6BgP8UPqStnEPmpy3OOH6wI7WjZYMkRjrxG2rIrFPgWvshPx4QgQalymCAoBXkO/dNSdsX++YC2wppkmtR1YfbcW+YGSXzTj7m4C4Y4Gjq8VJCmrlLQ/KMW0hphEocEGl+/hKpNj6cbKFePCmAYVhOXNxQoDBC/s1zQRJ5CYSlchdyipd
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <3B245F59213AA648BB0B303AE27A6F2F@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: cb0c6484-14c8-4de6-78bf-08d6620bc1ed
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 Dec 2018 21:33:15.6311
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2528
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTEyLTE0IGF0IDEzOjI5IC0wNTAwLCBTY290dCBNYXloZXcgd3JvdGU6DQo+
IE90aGVyd2lzZSBubyBSUEMgdGFza3Mgd2lsbCBiZSBhYmxlIHRvIGxvY2sgdGhlIHRyYW5zcG9y
dCBhbmQgd2lsbA0KPiB0aGVyZWZvcmUgYmUgdW5hYmxlIHRvIGNvbm5lY3QgaXQgZWl0aGVyLg0K
PiANCj4gU2lnbmVkLW9mZi1ieTogU2NvdHQgTWF5aGV3IDxzbWF5aGV3QHJlZGhhdC5jb20+DQo+
IC0tLQ0KPiAgbmV0L3N1bnJwYy94cHJ0c29jay5jIHwgMSArDQo+ICAxIGZpbGUgY2hhbmdlZCwg
MSBpbnNlcnRpb24oKykNCj4gDQo+IGRpZmYgLS1naXQgYS9uZXQvc3VucnBjL3hwcnRzb2NrLmMg
Yi9uZXQvc3VucnBjL3hwcnRzb2NrLmMNCj4gaW5kZXggOGE1ZTgyM2UwYjMzLi5iYmUwNmUzY2M4
NTMgMTAwNjQ0DQo+IC0tLSBhL25ldC9zdW5ycGMveHBydHNvY2suYw0KPiArKysgYi9uZXQvc3Vu
cnBjL3hwcnRzb2NrLmMNCj4gQEAgLTExNTcsNiArMTE1Nyw3IEBAIHN0YXRpYyB2b2lkDQo+IHhz
X3NvY2tfcmVzZXRfY29ubmVjdGlvbl9mbGFncyhzdHJ1Y3QgcnBjX3hwcnQgKnhwcnQpDQo+ICAJ
c21wX21iX19iZWZvcmVfYXRvbWljKCk7DQo+ICAJY2xlYXJfYml0KFhQUlRfQ0xPU0VfV0FJVCwg
JnhwcnQtPnN0YXRlKTsNCj4gIAljbGVhcl9iaXQoWFBSVF9DTE9TSU5HLCAmeHBydC0+c3RhdGUp
Ow0KPiArCWNsZWFyX2JpdChYUFJUX1dSSVRFX1NQQUNFLCAmeHBydC0+c3RhdGUpOw0KPiAgCXhz
X3NvY2tfcmVzZXRfc3RhdGVfZmxhZ3MoeHBydCk7DQo+ICAJc21wX21iX19hZnRlcl9hdG9taWMo
KTsNCj4gIH0NCg0KWWVwLCB0aGlzIG1ha2Ugc2Vuc2UuIFRoYW5rcyENCg0KLS0gDQpUcm9uZCBN
eWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25k
Lm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
