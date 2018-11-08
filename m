Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1A5AC0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 03:13:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 98CFF20827
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 03:13:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="E7AtkLMR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98CFF20827
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728562AbeKHMqt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 07:46:49 -0500
Received: from mail-co1nam03on0106.outbound.protection.outlook.com ([104.47.40.106]:64487
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726726AbeKHMqt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Nov 2018 07:46:49 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=On2FGbePuAJs+3DZ0dgOfd9a4OkZM8w13JK8M+J7AlA=;
 b=E7AtkLMRN2kcJ9siFccqbY3sfroVBcuB3qNfQuhe+lvU9/f69KMqK1MNHlUhKdjOSwOnmEIY1FA6AwyHCTNzPyYEBb6rHZzvHRE1vbTwM/ZFszpqPJW1PN5UB3oW4v5lHqpDluS0xs5RXrOY9occG3qoJV9n7A/nsLHT4OtgYbE=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2239.namprd13.prod.outlook.com (52.135.93.152) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.14; Thu, 8 Nov 2018 03:13:26 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1339.009; Thu, 8 Nov 2018
 03:13:25 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "yuehaibing@huawei.com" <yuehaibing@huawei.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
CC:     "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
Subject: Re: [PATCH net-next] SUNRPC: drop pointless static qualifier in
 xdr_get_next_encode_buffer()
Thread-Topic: [PATCH net-next] SUNRPC: drop pointless static qualifier in
 xdr_get_next_encode_buffer()
Thread-Index: AQHUdwYiBtkJ/7ND9EiehStPlNwUCaVFM/eA
Date:   Thu, 8 Nov 2018 03:13:25 +0000
Message-ID: <d23105929adb66c626d382525adef77265585404.camel@hammerspace.com>
References: <1541642697-33860-1-git-send-email-yuehaibing@huawei.com>
In-Reply-To: <1541642697-33860-1-git-send-email-yuehaibing@huawei.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2239;6:SsWtSfSW99lKtDk8xlyvf1p1g30f+9Xo/HeJ73wrlx4kf/f99Tpf2K45nisYdm1m+ktr8TNNfXlwUkrxgGc+ta3k/BQ7o+1kG4ZJITGd4BcnLPUP8+pWe2hWIqDJ6yn5e7GfP8foTASBLyJxAnD85JxK5aEem6ZVeq9iHteLxaRiXdvMWiW+g233Mvohl9Mb9dFdFBZ3oOIIuSKuMdZMbWndF+tcUs3yxdzz5fHKkvwEINf1kxgcHuHDu4NHyWRwOXePFy1nL08xPHxk9lsRg+UGDNbvmmxxfoewKOOrtDjv3Ubs4Ets/Hsnxb5tYp6358QkhTx9u8sa/MCVR7gf+Pk+K0V26s5iX04PpQgwQPQ8U0Nia06BGZ/8oQYkowWx7rdcrkid5+pTEX1QC0Xlm7bCDZI7SLYTt9gBorbiwK7+m8pkz0wOrppICSUANVoQDvvA8qOIxSRRYgrEtttBBA==;5:VFUgd2zzxGJDPT1Yi3Cn5Z2jH+jwbzWvYeH9/reO9U4pX6U0OR/0nvEOj4v1u2VrcqQjElPtWSJ0edLpopocGJgi+z+1q90JnCZSYWrxRqHEoy+e+zHnhZCRLJqwpW28aGmvaYThCEIq1z4AfNmn7OUPmrMYahrCjMq+M+kRdJY=;7:x+U1RXF0/r28QQAsCEozlIh5yCmA0KtKXsExj7MDkqKiqF8h/VLfZuuntu9Xlwa1Zu7D+cUvJA6XkrUEQPEjxnJ476JXWx89gvqUoUmQwcfnuvxKQxAwPz7mwlQYROBJX3sbWH2+377jmCHO5MgxlQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 03c5beea-6e96-49ee-5fb8-08d64528260e
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2239;
x-ms-traffictypediagnostic: SN6PR13MB2239:
x-microsoft-antispam-prvs: <SN6PR13MB2239FB151F9180F2A2C1DC3FB8C50@SN6PR13MB2239.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:(50582790962513);
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(10201501046)(3002001)(3231382)(944501410)(52105095)(148016)(149066)(150057)(6041310)(20161123558120)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2239;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2239;
x-forefront-prvs: 0850800A29
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(136003)(39830400003)(396003)(346002)(366004)(189003)(199004)(229853002)(68736007)(25786009)(118296001)(14454004)(7736002)(305945005)(8936002)(99286004)(8676002)(81156014)(81166006)(4326008)(5660300001)(36756003)(2906002)(186003)(6116002)(105586002)(106356001)(71200400001)(71190400001)(54906003)(110136005)(3846002)(316002)(478600001)(486006)(102836004)(11346002)(446003)(476003)(2616005)(26005)(2900100001)(97736004)(6486002)(2501003)(53936002)(6246003)(6436002)(6512007)(256004)(14444005)(2201001)(76176011)(86362001)(66066001)(6506007)(473944003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2239;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 2r6cgCaW3okDceiRMacM0taBG5+wOadQV0qZfXKh/Izvb4HAlk9Aa3ng8WzYSGTJiZsuRC8VY6nXj3/U8LwCW4G+2kk7g2V9NbrFejeEcMS2Ys3186FHR9FYVI+qYhvp8KcszeE/9pbMn9hrzqL25UKPkPF7y+dsVusQSZ0xuvUA77K3ONW4ikxOlymLq9+r9TmPu3zHwgg5fF8qS3W41xO9itpf6I2d88thc3f6OJ1VidVU3oOEEUr/X6T55sMXD0dLg8cPt7KECa5ZiOtyosKwhU/3sy8e+QM0pIYTuq0aRYXebniJczHSwC+xQAdY1nwR6MibwZQzevjWZEI9uJZA2GWc1S9CKy28cxkBJUI=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <0612A155791BF24AB602023E6CD8F6A4@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 03c5beea-6e96-49ee-5fb8-08d64528260e
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Nov 2018 03:13:25.7737
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2239
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE4LTExLTA4IGF0IDAyOjA0ICswMDAwLCBZdWVIYWliaW5nIHdyb3RlOg0KPiBU
aGVyZSBpcyBubyBuZWVkIHRvIGhhdmUgdGhlICdfX2JlMzIgKnAnIHZhcmlhYmxlIHN0YXRpYyBz
aW5jZSBuZXcNCj4gdmFsdWUNCj4gYWx3YXlzIGJlIGFzc2lnbmVkIGJlZm9yZSB1c2UgaXQuDQo+
IA0KPiBTaWduZWQtb2ZmLWJ5OiBZdWVIYWliaW5nIDx5dWVoYWliaW5nQGh1YXdlaS5jb20+DQo+
IC0tLQ0KPiAgbmV0L3N1bnJwYy94ZHIuYyB8IDIgKy0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAxIGlu
c2VydGlvbigrKSwgMSBkZWxldGlvbigtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMv
eGRyLmMgYi9uZXQvc3VucnBjL3hkci5jDQo+IGluZGV4IDJiYmI4ZDMuLmQ4MGIxNTYgMTAwNjQ0
DQo+IC0tLSBhL25ldC9zdW5ycGMveGRyLmMNCj4gKysrIGIvbmV0L3N1bnJwYy94ZHIuYw0KPiBA
QCAtNTQ2LDcgKzU0Niw3IEBAIHZvaWQgeGRyX2NvbW1pdF9lbmNvZGUoc3RydWN0IHhkcl9zdHJl
YW0gKnhkcikNCj4gIHN0YXRpYyBfX2JlMzIgKnhkcl9nZXRfbmV4dF9lbmNvZGVfYnVmZmVyKHN0
cnVjdCB4ZHJfc3RyZWFtICp4ZHIsDQo+ICAJCXNpemVfdCBuYnl0ZXMpDQo+ICB7DQo+IC0Jc3Rh
dGljIF9fYmUzMiAqcDsNCj4gKwlfX2JlMzIgKnA7DQo+ICAJaW50IHNwYWNlX2xlZnQ7DQo+ICAJ
aW50IGZyYWcxYnl0ZXMsIGZyYWcyYnl0ZXM7DQo+IA0KDQpPdWNoLCB0aGF0J3MgYSByZWFsbHkg
bmFzdHkgYnVnIHRoYXQgY291bGQgZGVmaW5pdGVseSBjYXVzZSBjb3JydXB0aW9uDQppZiB5b3Ug
aGF2ZSAyIHRocmVhZHMgc2ltdWx0YW5lb3VzbHkgY2FsbGluZyB0aGlzIGZ1bmN0aW9uISBUaGlz
IHJlYWxseQ0KZGVzZXJ2ZXMgdG8gYmUgYSBzdGFibGUgcGF0Y2guDQoNClRoYW5rIHlvdSwgWXVl
SGFpYmluZyENCg0KQnJ1Y2UsIGRvIHlvdSB3YW50IHRvIHNoZXBoZXJkIHRoaXMgb25lIGluPw0K
DQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1t
ZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
