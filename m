Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30D2EC0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 15:53:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DFCCD2064C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 15:53:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="DY89vRrP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFCCD2064C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729582AbeKAAvy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 20:51:54 -0400
Received: from mail-co1nam03on0134.outbound.protection.outlook.com ([104.47.40.134]:50220
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729440AbeKAAvy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Oct 2018 20:51:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cH2w95Is/jfSLatEyNLoIRRZaoTxDqKzqV5dRvpDgVg=;
 b=DY89vRrP5CW6fkZcMaQdRMIDXP5TC3+/3nHyfyrbpaA6cOj4xohlO8iNe522NlPyOMpY5HELXObqjGULPvpzLoVE3T6ADqrCiKKzyUfjpDI4rJeoZ5H5BhRnXG1K2owDYoBrZgUTzn/2Vq2vcEq0e3I8s/ADALlsiILknrxbl1E=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2464.namprd13.prod.outlook.com (52.135.95.32) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.7; Wed, 31 Oct 2018 15:53:16 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1294.021; Wed, 31 Oct 2018
 15:53:16 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] nfsd changes for 4.20
Thread-Topic: [GIT PULL] nfsd changes for 4.20
Thread-Index: AQHUcIUrE3uFY7hHRkGPGmMMSz2oPKU4M+UAgAADSgCAAUjxAIAAAn6A
Date:   Wed, 31 Oct 2018 15:53:16 +0000
Message-ID: <953cca652ccb0bf1c69a099a1e64ad37ee1d972c.camel@hammerspace.com>
References: <20181030191710.GA23042@fieldses.org>
         <CAHk-=wi+-POnmS41x9SKR+CB9va3ZnmRmCF8S7wNEw0QVATHXA@mail.gmail.com>
         <CAHk-=wgeJzBWjCafB3nKP0QMJCyh3rAjN+s6Z+T+5hfAT81YMw@mail.gmail.com>
         <20181031154418.GB2451@fieldses.org>
In-Reply-To: <20181031154418.GB2451@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2464;6:As+j/zYUSzxyFv8U1K+dTeS11HGVTQZk3Wr80ZID+XLjIivNmHpCcISnnrTLpC1a9nJVgh8zWyF+q+GAD/G1FgqeuxBxquPcTLnS+uXOQUl3VR2S4hMUL52dUJ4fo37KMxIesQvf3QmkWht0jpXg635h3F6Z/74MBZNZ6bUA0yhVcWjCTOtL1YzwJPvuRWWoloGvpIsZQD8c41Nl6fMTUGr46uXhZagBeGkGPcQLDFXzl8DBtuzAxbaLNuCP9iOy88XsmQ4DqtW1eB3qLuOZKtxbMYfCuwZw/xug9CZNZyhh71aGhbb8H/5BzoHBDbmFJ1paIZZAP+nAkGv/6R1QtzcTHd5vGIyTmzcSoME/xGSsYB0n+LcMdHq7JbaajoNVXywY+WOrEJaMl/yrASgvGc7gGnwNVoHDKGDBfFEX1Vlpe3BLugcV8Ij9zivthESQlYmtfPLxXM2o+7ROkpZkPg==;5:vZCJmFIxjNvuv2SgD7/nwZPOkbLvpKlxAfy4dNjb581CNUz2FLngnUEdfMYJbSukfIUoUr8QoQ4HcEHz1qvazK/Th/HOgfJf53oKGndXn0QCe/rN6QTSmRo17ldCmqoXO8zBNpji7pvST5pA0/sGVo+1SRFIH8Wyq7LGfZbPEJc=;7:vMpZD6wKaG2FKVGEgqRfQ4A9VXux60Elq4pUQgbRXGRBzEXCiXKo6dxNsOhhxUkVB1YFK0bD2qo95lbBuVc0HfgOGoj6FSyS9WK1uxcsxXn7suhJ4T1X46K4nDHy/+eeoL6UkcYsgTD4zn4Ve31YdQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 07c96016-bce2-40b6-5ec9-08d63f48f8a5
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2464;
x-ms-traffictypediagnostic: SN6PR13MB2464:
x-microsoft-antispam-prvs: <SN6PR13MB246421559B44FAC518AC45AAB8CD0@SN6PR13MB2464.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:(42068640409301);
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(93006095)(93001095)(10201501046)(3002001)(3231382)(944501410)(4982022)(52105095)(148016)(149066)(150057)(6041310)(20161123564045)(20161123560045)(20161123562045)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2464;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2464;
x-forefront-prvs: 084285FC5C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(396003)(366004)(136003)(346002)(376002)(199004)(189003)(6116002)(110136005)(106356001)(105586002)(2906002)(71190400001)(6246003)(966005)(71200400001)(3846002)(316002)(305945005)(7736002)(54906003)(118296001)(4001150100001)(81166006)(81156014)(8676002)(97736004)(8936002)(229853002)(478600001)(2900100001)(14444005)(36756003)(66066001)(26005)(6436002)(476003)(6512007)(2616005)(76176011)(446003)(5660300001)(11346002)(256004)(25786009)(102836004)(186003)(4326008)(5250100002)(486006)(86362001)(6506007)(6306002)(68736007)(14454004)(93886005)(2501003)(99286004)(6486002)(53936002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2464;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 43o0oufmrrPX+/1wJTRyGDRk/3gHhhoKHzmNVSdiwYt1+1QM+E1hhwF8sVMc3332SI1XuMBvtfrjqXjm64p+3DBHTFq463HEl74Bc2TTdR/aKrfPCgZohvMTOTmT+0R7C5WT2oxC4c5NseuHpckHgfxAhWoTgpNMFyGPfddqG9DfqzvLO96owbNDSQXqoPuDs/XLj6dpWMuE+YfyuKL7NNNqoC0/G3rsL9lFnYzLlJ3WLoMr3TrQhOnuzlDPgOVQ70kijQVW2AsiP8EkQWzqgjPnpWfUebmKUlNuITMoEPeq1e09bCpDALoMjeS7wdxfe9g3qEh89P7HkZSrwpivYGtF/Xr/xjcvRpwvyTOloT0=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <E7901667AE31884D98658BD140CD3CE6@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 07c96016-bce2-40b6-5ec9-08d63f48f8a5
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Oct 2018 15:53:16.0385
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2464
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE4LTEwLTMxIGF0IDExOjQ0IC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQoNCj4gU3RlcGhlbiBhbHNvIHNlbnQgYSB3YXJuaW5nIGFib3V0IGEgbWVyZ2UgY29uZmxpY3Qg
d2l0aCB0aGUgdmZzIHRyZWUNCj4gKG5vdCBtZXJnZWQgeWV0LCBJIHRoaW5rKSBidXQgSSBhc3N1
bWUgdGhhdCdzIG5vdCBhcyBiaWcgYSBkZWFsIHNpbmNlDQo+IGl0DQo+IHNob3VsZCBhY3R1YWxs
eSBzaG93IHVwIGF0IG1lcmdlIHRpbWUsIG5vdCBidWlsZCB0aW1lOg0KPiANCj4gCQ0KPiBodHRw
Oi8vbGttbC5rZXJuZWwub3JnL3IvMjAxODEwMjkxMjIxMjEuNzc1OGZlZDRAY2FuYi5hdXVnLm9y
Zy5hdQ0KPiANCj4gLS1iLg0KDQpGb3IgdGhlIHJlY29yZCwgdGhlIHNhbWUgaXNzdWUgc2hvd3Mg
dXAgaW4gdGhlIGNsaWVudCBjb2RlIGluDQpuZXQvc3VucnBjL3hwcnRzb2NrLmMsIGFuZCB2YXJp
b3VzIHBlb3BsZSBoYXZlIENjZWQgdXMgd2l0aCBwYXRjaGVzLg0KSSd2ZSBmb3J3YXJkZWQgYXQg
bGVhc3Qgb25lIHN1Y2ggcGF0Y2ggb24gdG8gQWwsIHNvIEknbSBhc3N1bWluZyBoZQ0Kd2lsbCBm
aXggdGhpbmdzIHVwIGJlZm9yZSBzZW5kaW5nIGEgcHVsbCByZXF1ZXN0Lg0KDQotLSANClRyb25k
IE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJv
bmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
