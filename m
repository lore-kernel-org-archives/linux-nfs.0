Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56EA4C43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 16:03:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 24DA221873
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 16:03:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="AjudmlOa"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727011AbeLRQDD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 11:03:03 -0500
Received: from mail-eopbgr790113.outbound.protection.outlook.com ([40.107.79.113]:30368
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726958AbeLRQDD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 11:03:03 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jhzbJ2x/wlW6a8Q16hsCGlkjPyUCGtnSPyxO/5e8k6Y=;
 b=AjudmlOapjHKtG6UbdxdGLDvaJDs4sTu1wkkna4rkeaOnZoovw/Zxi/Uc2N5dNlcv8UArhFE8526SuLZ8oD1T5syYSGNa7FKrKmvpfINkX9HTNRGmmsWl9UeCEpI0gIGf9SdsodNBDMGreWQO6BeYIAnt/6ZSI7p4sveabqH4TQ=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2271.namprd13.prod.outlook.com (52.135.93.160) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1446.13; Tue, 18 Dec 2018 16:02:58 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1446.015; Tue, 18 Dec 2018
 16:02:58 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "smayhew@redhat.com" <smayhew@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dwysocha@redhat.com" <dwysocha@redhat.com>
Subject: Re: [PATCH v2 1/3] SUNRPC: Fix disconnection races
Thread-Topic: [PATCH v2 1/3] SUNRPC: Fix disconnection races
Thread-Index: AQHUlltg9GdqrvxUuUm55vOL4EPwwqWEjQ+AgAAai4CAAAEhgIAAANSA
Date:   Tue, 18 Dec 2018 16:02:58 +0000
Message-ID: <b4b3eeb9ed30437998c9cc7766012ff0fd316b8e.camel@hammerspace.com>
References: <20181217225235.124448-1-trond.myklebust@hammerspace.com>
         <20181218142055.GK27213@coeurl.usersys.redhat.com>
         <2acfb506b55380b3c46ef62cd597d724a517fd75.camel@hammerspace.com>
         <5499D539-B24A-4E54-B9A7-11A91ADE9C0B@oracle.com>
In-Reply-To: <5499D539-B24A-4E54-B9A7-11A91ADE9C0B@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2271;6:99Z55nKEDJOgFsLFYgkOJzPWpsib+sim3A8+cInWaH/Jx6m0qUZu0LmM7qc0LnLZPtjTFQAx/yKCtG0FZ8Smq8ZDZv70RVtmkQN45lUtFM0K+kwxp5YsUVLL8vqf41A/ZH5xY0gv1UH1hmp0qW+8c+f6KjQUBivjq5mFTcqe/L586ImYSeG7c1kAPaQrHWDC6Tov5EOMQTCT22maVmNgMogagyqaEPTGQWmYdjHCt5gKw63NWrPnBMhqpo0QlMfkBzYtcloJqUBZmPx6b3IG9PNBivNo/2eDPc8JLahgNdsF/tZrOKvO2hoq8D2XUBAFE5idB9j/UpeMgRvi6GXY50OYJf9WueTwjcnWLJ/VsguqlS1qWHMsLDFhCbJD/AsWLjZTXXVGQyGBK9K0gslpOr2wo4lfwj9bM0tI419iAewgl3OVGKnqzZBB/nwwEuy/Xo55S4Z2caBX97/pJUvp2A==;5:OStgPtFGDsquYhpCE64WRyaT+Xm1BU1t9HLxFt0VncbU3iX/pheqNvDj0CB4favcXqEJxPVlp4MNBghRHqTKXxKInCeCk7GYbBLNqxcEWnsa0Bq9z+aEWC+H8ZI7ZIJssMmkQAVNeneUEuNHDe3FW9HOET8+1VtWpXFzQoXBZWY=;7:7xgWlWaDKpA9dDacZUh3jvqBJzQbG/5egC8NtMFXn5Hx2KsfCw61FZoFrvaCDwVpiGX2w0HvkeQ5HUqXjBVsny7kaPI2s5G2uj7RtNqOv8aIkw1+YwH38DO/e50cVyk5hNkg0yeKjknDQu9Et9w8tg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 993846cf-ef71-438e-53c9-08d6650247dd
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2271;
x-ms-traffictypediagnostic: SN6PR13MB2271:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB2271A028A00F416BED52591FB8BD0@SN6PR13MB2271.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(5005020)(6040522)(2401047)(8121501046)(3002001)(10201501046)(3231475)(944501520)(52105112)(93006095)(93001095)(148016)(149066)(150057)(6041310)(20161123558120)(20161123564045)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2271;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2271;
x-forefront-prvs: 08902E536D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(346002)(136003)(376002)(396003)(39830400003)(189003)(199004)(106356001)(76176011)(105586002)(6506007)(53546011)(6246003)(99286004)(2616005)(2351001)(11346002)(446003)(26005)(102836004)(186003)(66066001)(256004)(478600001)(118296001)(54906003)(93886005)(316002)(6116002)(3846002)(36756003)(97736004)(4001150100001)(2906002)(5660300001)(68736007)(4326008)(14454004)(5640700003)(71200400001)(71190400001)(6436002)(6486002)(6512007)(229853002)(8936002)(81166006)(8676002)(81156014)(476003)(53936002)(486006)(7736002)(2501003)(6916009)(25786009)(86362001)(305945005);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2271;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: nCBdz31cdVEQo3vE9cMrWmxk/bpU66iAv3mlSq5ymnJKNQeIcxGRDPxtDV9THBu+4caQ9+3gXmrRnL90r8qSoPT0CI4MgyuvF9yJZJ1O8zMhJZAbLz9FZ71pL9LH5tWtpTu+dJ4lKIj2/SEzY90L4Xn6RjYhfz17u1ddRLfdZ/wMRCIaGv9oe3vIpclJOSJqTAxP4ujkYOe3N9jCbz+nMJKI6EsLv3mwki2zPZcqao41OrTg/P7HtboeZvwngGq7myaGrATqqMle+RNmK01s7Tln1Juzo51WvdrRF6+fg9ArANqpvyJ6UTQG5fKhxEi2
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <DEC46B13E26C924A9367161EBA40780F@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 993846cf-ef71-438e-53c9-08d6650247dd
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Dec 2018 16:02:58.7449
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2271
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE4LTEyLTE4IGF0IDEwOjU5IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBEZWMgMTgsIDIwMTgsIGF0IDEwOjU1IEFNLCBUcm9uZCBNeWtsZWJ1c3QgPA0KPiA+IHRy
b25kbXlAaGFtbWVyc3BhY2UuY29tPiB3cm90ZToNCj4gPiANCj4gPiBPbiBUdWUsIDIwMTgtMTIt
MTggYXQgMDk6MjAgLTA1MDAsIFNjb3R0IE1heWhldyB3cm90ZToNCj4gPiA+IEkgcmFuIERhdmUn
cyB0ZXN0IGluIGEgbG9vcCBvdmVyIG5pZ2h0IHdpdGggdGhlc2UgMyBwYXRjaGVzIG9uDQo+ID4g
PiB0b3Agb2YNCj4gPiA+IHY0LjIwLXJjNyBhbmQgZGlkbid0IHNlZSBhbnkgbW9yZSBvZiB0aGUg
WFBSVF9XUklURV9TUEFDRSBoYW5ncy4NCj4gPiA+IA0KPiA+IA0KPiA+IFRoYW5rcyBmb3IgdmVy
aWZ5aW5nIHRoYXQhDQo+IA0KPiBXaXRoIHRoZXNlIHRocmVlIHBhdGNoZXMgYW5kIG15IFJETUEt
cmVsYXRlZCBkaXNjb25uZWN0IGZpeGVzLCBmaW84DQo+IG9uIGtyYjVpDQo+IG5vdyB3b3JrcyBm
aW5lLCBldmVuIHRob3VnaCB0aGUgY29ubmVjdCBjb3VudCB3YXMgNTA4LiBObyBzdGFsbHMgb3IN
Cj4gZGVhZGxvY2tzLg0KPiANCj4gVGVzdGVkLWJ5OiBDaHVjayBMZXZlciA8Y2h1Y2subGV2ZXJA
b3JhY2xlLmNvbT4NCg0KWWF5ISBUaGFua3MgQ2h1Y2suDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0
DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1
c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
