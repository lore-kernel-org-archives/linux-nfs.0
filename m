Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE402ECDE44
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:21:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 846A52064A
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:21:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Iwypzchz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 846A52064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727764AbeJ0E7Y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 00:59:24 -0400
Received: from mail-sn1nam02on0096.outbound.protection.outlook.com ([104.47.36.96]:30688
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727636AbeJ0E7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 27 Oct 2018 00:59:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cRecLh1r7RdUDuEBCYpbl8WJrJ/4WgIGqbmlJbnYXZI=;
 b=IwypzchzrxOjGbRFRUVdq1CkOoej1kLwoJbwNwzhzliiEScab4Pg9u4Z/qIFGgHS67gzbsxr2tpM3QnGnnKL4wpOCSlVTf0E8gjhv09+Jmn6DATg8WkCpbtKHXadYoN6Z1+P9Si8X77X4hdm4qQ4qo6d/B2fAeX+hRrVP7ofEyY=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2238.namprd13.prod.outlook.com (52.135.93.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.12; Fri, 26 Oct 2018 20:20:55 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1294.014; Fri, 26 Oct 2018
 20:20:55 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.20.
Thread-Topic: [GIT PULL] Please pull NFS client changes for Linux 4.20.
Thread-Index: AQHUbULmNFtCgrNwxU+PaaX/lXso7aUx9UwAgAAC8oA=
Date:   Fri, 26 Oct 2018 20:20:54 +0000
Message-ID: <bafa9f6ca7da84e710bc9e1af8fa7428a8331bb6.camel@hammerspace.com>
References: <6bbed95d83465dde644c6f66acc73e3cd94f123e.camel@hammerspace.com>
         <CAHk-=wheW3hFQ8Jy5YYnNL1V+ZqA_qQoA63q2uK9ngz4=pXCqw@mail.gmail.com>
In-Reply-To: <CAHk-=wheW3hFQ8Jy5YYnNL1V+ZqA_qQoA63q2uK9ngz4=pXCqw@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2238;6:S7JZx3LSfBReWWuFdab2ke9h1jOZjP+SCAQj5COSgy/UyYvSvbQ0LGA5iHu+5puCIykqGq0gXBwtx3H/Hn1Xt3faq9/rFuXBROG87v9espxH4m750FUM/sPYwFnU8LW4+SpKRtSwkbSA+H6eQCp3396jpskx8W1/vfTi30j/NujWcZK74fBIzZCVzjE+JEYoZKE28GvfMAOthAN2f2+pYOEqb3lx8RgeuMci59M6DEQNWlqhdTONrUQCFjoRaLHcVA2tD5DjBj1518fXiKgZihgcBEmBeMfOv4iu1aCbF9egnXdvIB8Oj8rW2ovHFose1H7l6kFLDB5izTjjavvKMQ185MrYHrz/kxpj7AgUwIPiLYeylufXoqLDD4RKVQAijgoU0XpQmWCHRneob7DJ3wnFX8KAFEZskAHjuV7mbSBG1scFtk8AMNLMVmkM4L6Be3K9yN4egNCuPgJEqsaDuQ==;5:NFdO1XXDCQS+SQr6OV5mO8+8x4i53xlqOHnFVYvrAmMZz79yHSRBv+sBP33Ynyea6jgg0DDSEN0HftcXrGvpRtKlNFnsFYDAKNpdnCDveR8RcLIXVoA4srbWm0czTgveH/9g44UM5zsE1HkcQHSIkKSl/ztxfz3jOWdIt6A1JyM=;7:pRDVIJmX8FFes6RTlZtkBKnUNkT4QAHB65/xzdJdhsHfsrDJp4cIL7ZeV1k1/HkX14idsuYuWzj2FOj2kqf3QsuRDUOr+XvPrQmscyeX/t1UJ0L2rzKuq3Z3O7zm+ERokvNCWnRHIn7H/UhT4Y4B8g==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: a926e4e1-1e42-4a9c-4850-08d63b80887e
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2238;
x-ms-traffictypediagnostic: SN6PR13MB2238:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB2238F001056908427959987FB8F00@SN6PR13MB2238.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:;
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(10201501046)(3002001)(3231371)(944501410)(52105095)(93006095)(93001095)(148016)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123558120)(20161123560045)(20161123564045)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2238;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2238;
x-forefront-prvs: 083751FCA6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(39830400003)(396003)(136003)(366004)(376002)(199004)(189003)(97736004)(478600001)(68736007)(6246003)(4001150100001)(36756003)(105586002)(102836004)(6486002)(53546011)(6506007)(6436002)(2351001)(53936002)(6512007)(76176011)(99286004)(106356001)(5640700003)(26005)(4326008)(86362001)(6916009)(8676002)(476003)(2616005)(446003)(11346002)(486006)(25786009)(186003)(81156014)(81166006)(1730700003)(229853002)(54906003)(316002)(5660300001)(8936002)(66066001)(256004)(2501003)(2906002)(6116002)(118296001)(5250100002)(3846002)(71190400001)(7736002)(305945005)(71200400001)(2900100001)(14454004);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2238;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: AgmLZuwRu2BZ9+WFvIlwDrQgPPkpDcmqvPu7Um6p2BJUiWRNvF4980+fFxxETtghduabbiRYNKmPSxeF7plENxl3UQgSwAyz5C+Ab5c/gq3gdKzv2Z5gOceHw5FqHjAFIeZzH2v+0itxsjzgsyikJ4NZvU0OekN4tbQcKPm7j+RdEMcdsBKTn/hvtr1incnrnV0S5OuJSozmwFv7KGAAo+qx0z0tfmKB9YxulhbsAE6+2+xPJOJa8fgOL4p4+AFpfe2NoC2XaZf9k0h8uYIUPU8ZneTY/qPdUf/JR2QUK1Sy+RMejIxnEyL9wSXh45jmK8pvebW1Z56aL6Lb//JnwWto2EoD+luw4tAqf7qxfKk=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <79EFFBE6D3D25847A3FC2D448492D6D9@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a926e4e1-1e42-4a9c-4850-08d63b80887e
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Oct 2018 20:20:54.9672
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2238
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTEwLTI2IGF0IDEzOjEwIC0wNzAwLCBMaW51cyBUb3J2YWxkcyB3cm90ZToN
Cj4gT24gRnJpLCBPY3QgMjYsIDIwMTggYXQgODo0NSBBTSBUcm9uZCBNeWtsZWJ1c3QgPA0KPiB0
cm9uZG15QGhhbW1lcnNwYWNlLmNvbT4gd3JvdGU6DQo+ID4gDQo+ID4gTkZTIGNsaWVudCB1cGRh
dGVzIGZvciBMaW51eCA0LjIwDQo+IA0KPiBQdWxsZWQuDQoNClRoYW5rIHlvdSENCg0KPiBCdHcs
IGp1c3Qgb3V0IG9mIGN1cmlvc2l0eSAtIGlzIHRoZXJlIHNvbWUgcGF0dGVybiB0byB3aGVuIEkg
Z2V0IHRoZQ0KPiBwdWxsIHJlcXVlc3RzIGZyb20geW91IHZzIEFubmE/IE9yIGlzIGl0IGp1c3Qg
Indob2V2ZXIgaGFwcGVucyB0bw0KPiBoYXZlDQo+IHRoZSBiYXRvbiI/IE5vdCB0aGF0IGl0IG1h
dHRlcnMsIGJ1dCBJIHdhcyB3b25kZXJpbmcgaWYgdGhlcmUgd2FzDQo+IHNvbWUNCj4gbG9naWMg
dG8gaXQgdGhhdCBJJ3ZlIG1pc3NlZC4uDQoNCldlIGFncmVlZCBhYm91dCBhIHllYXIgb3Igc28g
YWdvIHRvIHRha2UgdHVybnMgbWFpbnRhaW5pbmcgdGhlIGxpbnV4LQ0KbmV4dCBicmFuY2hlcy4g
U28gaW4gcHJhY3RpY2UgdGhhdCBtZWFucyBBbm5hIGhhcyBiZWVuIHNlbmRpbmcgeW91IHRoZQ0K
cHVsbCByZXF1ZXN0cyBmb3IgdGhlIG9kZCBrZXJuZWwgbWlub3IgbnVtYmVycywgYW5kIEkndmUg
YmVlbiBzZW5kaW5nDQp5b3UgdGhlIG9uZXMgZm9yIHRoZSBldmVuIG51bWJlcnMuDQpXZSBzdGls
bCBzaGFyZSB0aGUgYnVyZGVuIG9mIHJldmlld2luZyB0aGUgY29kZSwgdGhvdWdoLCBzbyBpZg0K
c29tZXRoaW5nIHNsaXBzIHRocm91Z2ggdGhlIGNyYWNrcywgd2UgZ2V0IHRvIHNoYXJlIHRoZSBi
bGFtZS4uLiDimLoNCg0KQ2hlZXJzDQogIFRyb25kDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpM
aW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RA
aGFtbWVyc3BhY2UuY29tDQoNCg0K
