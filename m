Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B97C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 14:26:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 28C1520815
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 14:26:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="BnKCj01a"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727670AbfACO0l (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 09:26:41 -0500
Received: from mail-eopbgr770107.outbound.protection.outlook.com ([40.107.77.107]:58784
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727147AbfACO0l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 09:26:41 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=CPBdjZMSM0cjlOSbKY6UEb8ZeEgeTeHV0i/b4QKb9YI=;
 b=BnKCj01ahiMWzfHdr/eDKsRKMGeahe+/Esd8cXBCWz3mDvS4gwDenOSDYJpB3O00CS8EECRYTjOTJGgt/47BwcPRSakPKpZeAuWJLcENbZGgqoNW79Q4bWWC8cCUegMZKy/zFhlfQ3Pm9+XUAWT/pNkJg20TkPfrm/gNLo56D5U=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2478.namprd13.prod.outlook.com (52.135.95.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.6; Thu, 3 Jan 2019 14:26:37 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Thu, 3 Jan 2019
 14:26:37 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "geert@linux-m68k.org" <geert@linux-m68k.org>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>
Subject: Re: [PATCH v2] SUNRPC: Fix TCP receive code on archs with
 flush_dcache_page()
Thread-Topic: [PATCH v2] SUNRPC: Fix TCP receive code on archs with
 flush_dcache_page()
Thread-Index: AQHUoyua7l5ZKHM4hESBaVcRAYnWxaWdVHGAgABAooCAAAU+gA==
Date:   Thu, 3 Jan 2019 14:26:37 +0000
Message-ID: <51911b9147bd4ceef0e24f440067f6e61cb63103.camel@hammerspace.com>
References: <20190103061324.16607-1-trond.myklebust@hammerspace.com>
         <CAMuHMdXpHLjJBMQWDaWKYQFfY4_3yVi9NdBYnWr6Xfzttrb5iA@mail.gmail.com>
         <3f4ee085ffde4c9823719e6607f521836c4158cf.camel@hammerspace.com>
In-Reply-To: <3f4ee085ffde4c9823719e6607f521836c4158cf.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2478;6:Jcf44OPX/LLU2mpLEvBFmSVkUe4knPhwj8pZSUQywOzNqnssTdyYfxMFrMqwZH8SdXFPXABSzW+tOhfhKLwbRFD4ob7FvXn0cJPntmSW3Licy8xBlUzLeSkB0Wp2ArWtfWWbQl2IYMU8JFpgYlvrdQIrH0rVxUyYkG2G4T/V9maTgXg4saR+N8QkuVglFH84WQPNPbK/oulUxiiP9BXNf2cEfKvxiKoN6UNNjGdgvBuBKF+GpRt4nY5+Tpv3anT+8CSsiYiQ0nQAjCJgMhsYZ5bIy0grCsx/a/2LWaLaQE8SiKBeVjUQAkzQvNbHMnTp4JJiNA6dvvCGd1sw8krEtHenXRWRL0jOF3myd98V0FiYXIBk1ecnlert9xbqPwcNHzjri7onuMS3lT/DjwP7luHQGeoufZwp6oNBvBTEu2EWPFweMNJkTv5Z6JvmQdjoZVjbLksX9y9db6R4mMvMJQ==;5:CQazmlym17VgusOjotc+8qga5Ljco+R04KAVkmISKXCO8Ha/Cb3ds905C8Y3DFUh3p1AeAuOtj9Zgm2JTIX+UIGUCGnLmwHPtzquQ3UwzrqvmKw8ynit82BayeqmxMdS6FZAmcJyu1zxs2UPxjBOV94SmBmA4bgnmpTe/QMqaWVl7oMuz8tBedu9i5lVgFLLFaxghi5cwjOVBuxAL4avWQ==;7:lcEr5yvGOUrAsaTgLPQgCeRF1+ZwepqmFqik5Z5nJmeW1sni1GjN6+/oHxEaisd8C/BaY/gDKM/I1A/tdgM2VyZo7xZ/dR9SsAX57kOJvibVXveUd2zUcgbZ5PvFIdGP/Gov+0zddam0LtRk/FCYAQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: ea3d6783-cf0c-4229-bd0b-08d671877874
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2478;
x-ms-traffictypediagnostic: SN6PR13MB2478:
x-microsoft-antispam-prvs: <SN6PR13MB2478ECEB263BA655E7BBB874B88D0@SN6PR13MB2478.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220060)(2401047)(8121501046)(93006095)(93001095)(10201501046)(3231475)(944501520)(52105112)(3002001)(6041310)(20161123564045)(20161123558120)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2478;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2478;
x-forefront-prvs: 0906E83A25
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(376002)(366004)(39830400003)(136003)(346002)(199004)(189003)(81166006)(76176011)(5660300001)(6916009)(6512007)(53936002)(36756003)(81156014)(486006)(86362001)(305945005)(8676002)(8936002)(14454004)(7736002)(256004)(1730700003)(3846002)(6116002)(478600001)(54906003)(2906002)(106356001)(2351001)(71200400001)(6246003)(6506007)(68736007)(99286004)(25786009)(316002)(11346002)(97736004)(186003)(476003)(66066001)(2616005)(118296001)(446003)(105586002)(71190400001)(102836004)(5640700003)(6436002)(6486002)(26005)(2501003)(4326008)(229853002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2478;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: MyHTo9Cf1M1ORtOK8e7E1hOOwd6H5cMtnfLcFU+Df6ovdl7Hmn7ALOBAWznTQBRrFFJDsPPHW1gNqITPIbL3eHtYuB/mbokkXdprvfaMe0/8TZeFrj0ccrajQNtNbKUNa5GpOnOQ8v0t6EO+U4BV6qUelha5DrrpSqAMgMwUVliZtOLfBqbrYz2iPfjcg3WddjpZmbaCp+ItPNvNRh/CSrhYXT9kUnA3r6cw9kjli9KDMvItrLbkpE0P3noBk9GNrBciF0nP2Itdbifbh0Bw7xMzgxp14EtbuCuXCeLiDLc+DQFktuGpbYO0vwKb+CYm
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <554F077F3B2D194AAEC14B097BCB85FD@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ea3d6783-cf0c-4229-bd0b-08d671877874
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jan 2019 14:26:37.4006
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2478
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAxLTAzIGF0IDE0OjA3ICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IE9uIFRodSwgMjAxOS0wMS0wMyBhdCAxMToxNiArMDEwMCwgR2VlcnQgVXl0dGVyaG9ldmVu
IHdyb3RlOg0KPiA+IA0KPiA+IEkgZG9uJ3QgdW5kZXJzdGFuZCB0aGUgY29kZSB3ZWxsIGVub3Vn
aCB0byBzZWUgd2h5IHRoZSBjYWxsIHRvDQo+ID4geHNfZmx1c2hfYnZlYygpIGlzIG5lZWRlZCBp
biB0aGlzIGJyYW5jaCBvbmx5LCBidXQgaXQgZG9lcyBmaXggVENQDQo+ID4gTkZTIG9uIFJCVFg0
OTI3LCBzbw0KPiA+IFRlc3RlZC1ieTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1t
NjhrLm9yZz4NCg0KU29ycnkuIEkgZm9yZ290IHRvIGFuc3dlciB0aGUgaW1wbGljaXQgcXVlc3Rp
b24gdGhlcmUuIFRoaXMgaXMgdGhlIG9ubHkNCnBsYWNlIHdoZXJlIHdlIG1heSBmaW5kIG91cnNl
bHZlcyByZWFkaW5nIGRpcmVjdGx5IGZyb20gYSBzb2NrZXQgaW50bw0KdGhlIHBhZ2UgY2FjaGUs
IHNvIHRoYXQncyB3aHkgd2UgZG9uJ3QgbmVlZCB4c19mbHVzaF9idmVjKCkgaW4gdGhlDQpvdGhl
ciBicmFuY2hlcy4gVGhlIGt2ZWMgZW50cmllcyBpbiBzdHJ1Y3QgeGRyX2J1ZiBzaG91bGQgYWx3
YXlzIHBvaW50DQp0byBwcml2YXRlIG1lbW9yeSBidWZmZXJzIHRoYXQgY2FuJ3QgYmUgbWFwcGVk
IGludG8gdXNlciBzcGFjZS4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGll
bnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5j
b20NCg0KDQo=
