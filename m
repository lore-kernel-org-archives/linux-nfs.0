Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C764C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 15:53:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C15C0206B8
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 15:53:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="T+cc30mN"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727100AbfCDPxB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 10:53:01 -0500
Received: from mail-eopbgr680122.outbound.protection.outlook.com ([40.107.68.122]:39181
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726552AbfCDPxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Mar 2019 10:53:00 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=vUBAI4tI3znj5gexztOM1rkc2LKXftDWa6JiryZZiCE=;
 b=T+cc30mNYj9QZHa+UsP+QmwLfZbfDBTtils7j0OO5M8hDT+b7Pp3tKJwQsmu777OYb+syd3WBQXpomV0r6LE1wVgxmzoLXSuJ4zMJnVEiuAhUUwVOmnimKvt0UkglO+5NMMMYaa8lpp7bw+tUQ3v2AseLo2preFiVjKoJK6DVLk=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2446.namprd13.prod.outlook.com (52.135.95.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.6; Mon, 4 Mar 2019 15:52:57 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1686.016; Mon, 4 Mar 2019
 15:52:57 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] SUNRPC: Allow dynamic allocation of back channel
 slots
Thread-Topic: [PATCH 3/3] SUNRPC: Allow dynamic allocation of back channel
 slots
Thread-Index: AQHU0iAaVmJgTvheBU2T2niUJo1+VaX7mPwAgAAHbYA=
Date:   Mon, 4 Mar 2019 15:52:57 +0000
Message-ID: <67ab9b9ab0d45f5fb30ef3e8c3f32b5c3e83b981.camel@hammerspace.com>
References: <20190304001928.4397-1-trond.myklebust@hammerspace.com>
         <20190304001928.4397-2-trond.myklebust@hammerspace.com>
         <20190304001928.4397-3-trond.myklebust@hammerspace.com>
         <D12A8479-F573-4B7C-84D0-EC0FE0F87520@oracle.com>
In-Reply-To: <D12A8479-F573-4B7C-84D0-EC0FE0F87520@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6685f4b4-d7c0-4045-18d7-08d6a0b978eb
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2446;
x-ms-traffictypediagnostic: SN6PR13MB2446:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNDQ2OzIzOmp4SlV5K1ROYldNSTNadEY2aS9xS1huRmVE?=
 =?utf-8?B?Uk9Dd2s1azc0Y1k3MlZpYmhlZUtDbWNOekU4ZXpJMitsQittMlFTcVdmTjB5?=
 =?utf-8?B?Y1VPL1F5VUZBV3YyQzNEUXZPdjc3NlAwY0l6WG0zU21waFo1MnpZVzlQeEtW?=
 =?utf-8?B?M0lEVklHeVJBTkpsVXliZSszblZZVmJ1K3dKRW1ZaHBaNUg5eVpvQlRmRUVV?=
 =?utf-8?B?S2VlNDNpTm9VTWJsK2txNkxYdncwSXBjQ3FLNW9iNEdDY0hwaW5RVXFOUjRk?=
 =?utf-8?B?QVFNOW4rNkNoNEN1VCtPRFREMi9YY0JJNjYrWlQ5Y0E3TDNIbGExOHRMU3Zi?=
 =?utf-8?B?YjR6djNxNjlNdFVaVTlrQ1BnZXlnbWZtRlRRS1R4SHNDZHAvMGZrNWV2djJX?=
 =?utf-8?B?enIwVzhmQXZ3aDc1NllycTYwYnd0dFpVVW1Wazl5bjE3YVlGcVRyMVBHSU9p?=
 =?utf-8?B?OVhvcUNIS2VGUnVxeHY4K0lucFRybHBwUE1PTzFLR3dPVXNSY096Q0QzWE9y?=
 =?utf-8?B?MFcrUEg0Wmxna2JPUEU0L1hQbFgwRUpMbmtXcndyMk8rV1VMMGFBQ09Zcysx?=
 =?utf-8?B?VFhBY3FqZkNIQlNuZGo0TktmaXYrSHRraUhyaTBUcWRaVFk5QkFTdXZFM1JI?=
 =?utf-8?B?bDl1MUhlQVV3Z0FSYjk5Nm90Qkp3VXJDejZHbyt1WW1icmg3VnJ2MmV2VUpZ?=
 =?utf-8?B?cTZ4QjU5djd5bDZYTXJiSWpDZURoNmU1dElRVVdZa3FTM1JUaXVqTnIyN0ll?=
 =?utf-8?B?TE9leGZTQXRNZFowaFNsTmNSQnpXZzE4UnBnLzhRK3kzQTE2bXpSQmF6S2tQ?=
 =?utf-8?B?aFEwVzRqcnRiVnkrcmVLNkQ5NDl4dVZpSy9OcDNOM01zb01zYklENmE2TEVu?=
 =?utf-8?B?cDRDbU5yeGhUUXF5OStYSkdQNlpDMUxoVWl3OERrQ25aKzhQaHlEcE4wSlRa?=
 =?utf-8?B?NzY3VUZOaXkzMGdjZDZVb2Q3ZmpRU1FXZ1JiWlRTRUpSOFYxRG9HeDBZRHgv?=
 =?utf-8?B?clF5ckNjckk0c3ZqOVYzUzF5QmtFSWh5Tkg4VUdORVIxWnhERjlQd0xkeEM0?=
 =?utf-8?B?dXZZa1E4UXFJOFVWRTRldmlFZ21ScjZWeTMvTzJKZlIyVWphM3Fqdzdxdzdr?=
 =?utf-8?B?QkMvd2FFT1J3RVJPWGRrbXJDS1ZKYWxnOXM2azlSUXRaQkcvRXNKVC9aMDI3?=
 =?utf-8?B?djVkdWRIOWxJUWpIejRVK2V4Mm5KR1JMbWVLZDFGMUhvd3h3YUU4T1RZa0lY?=
 =?utf-8?B?WHhqUHZ4RHRrcVVFN09OMFpOMVZUWWRuZ05vb2dnWHozM2w2UFBQbnIxbElv?=
 =?utf-8?B?MUhFY29pWXZQcXRsRkIvUStqenpSNTBFRjRUeStBVmJadkFJc1BMYjhXenpl?=
 =?utf-8?B?VTluVElzRzdpeFU3aUZHZlM2dURzUklodlk4STRrRzd4TWRvMTMwaE96K2Nj?=
 =?utf-8?B?M2tmVHdYUzlNQ1VnWlZXdFZHQlJnZjBTOS9CSnlDRFMzQ3VCNDBRNmkrQUdo?=
 =?utf-8?B?TTNzWkFKNjROd2VVbVJUS29GVmNocy9HcTRGcUp4TnZJN1ROc1NPS2JQMHhw?=
 =?utf-8?B?YklQaXEzQnJ5Z3l3Z0d0elhvUmhHK1prMjJXMlplWWlNdm5TQVZLUHZGL3Ex?=
 =?utf-8?B?eE1vTmk2b29TTHA2L3I2UElEdW9sTXd6ZFU1OGJiYVZUZTVRNEd4TS90UEVw?=
 =?utf-8?B?QTc5eTFtQzZPOGZUNVVKby83MHFVa3kwNXlMNkpDUjczeUI4Tlg2RW8rdFNP?=
 =?utf-8?B?Ly9DbE1OU1BEWTJ6VDViQT09?=
x-microsoft-antispam-prvs: <SN6PR13MB244630078E8250DC464564C3B8710@SN6PR13MB2446.namprd13.prod.outlook.com>
x-forefront-prvs: 09669DB681
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(376002)(346002)(39830400003)(136003)(396003)(189003)(199004)(76176011)(86362001)(2616005)(11346002)(118296001)(446003)(97736004)(2351001)(305945005)(102836004)(14454004)(5660300002)(476003)(8936002)(26005)(81156014)(81166006)(316002)(186003)(68736007)(6916009)(93886005)(53546011)(7736002)(4744005)(6506007)(8676002)(53936002)(6512007)(6246003)(105586002)(256004)(3846002)(6116002)(2501003)(36756003)(106356001)(6486002)(5640700003)(71190400001)(6436002)(66066001)(478600001)(99286004)(71200400001)(25786009)(229853002)(4326008)(486006)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2446;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: pyu4D5TNlaIgkidaRLtr0OIoZX4vUKc8NAFSZhUjlXBMs7kRuKzt+/GI/8K57YeNa7gEpTCFl1ImPaKbJvqcSXWLmngDTQXLjGTCNBIVlUbafAVz7eRecmDUwnuSjlCyPV8NbKbw3/yrQFfX0l+d3cYUxDVQK8fOLqKFIxNMIz2aJTPHdyIVE9wwYaG8IWXFqpp8G2jSBQPf/MvtfDcZ9T/DRNG/v4J3d+OIODKJWdhvQ2T6A4EvgKLNo9YLQiL4LYR+GaKyCdBmqxvflOPPZI+odlJflWOkohAD3zLObIeXWmBKgFUMy1/Gk2+++K9BMv7GBq4pX5s2OdghO5Rhr+UpXS4GZPiqydL+qSdj3ycFCPZi3+oAIOyk4UNsf9dYIW01C/EglJ2j+7HE8obl6Fu1fmjw4U9ETdAryZ+Fo2A=
Content-Type: text/plain; charset="utf-8"
Content-ID: <3724350F6AC01C46AFF78A6F6EB485B8@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6685f4b4-d7c0-4045-18d7-08d6a0b978eb
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Mar 2019 15:52:57.6110
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2446
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAzLTA0IGF0IDEwOjI2IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
SGkgVHJvbmQtDQo+IA0KPiANCj4gPiBPbiBNYXIgMywgMjAxOSwgYXQgNzoxOSBQTSwgVHJvbmQg
TXlrbGVidXN0IDx0cm9uZG15QGdtYWlsLmNvbT4NCj4gPiB3cm90ZToNCj4gPiANCj4gPiBOb3cg
dGhhdCB0aGUgcmVhZHMgaGFwcGVuIGluIGEgcHJvY2VzcyBjb250ZXh0IHJhdGhlciB0aGFuIGEN
Cj4gPiBzb2Z0aXJxLA0KPiA+IGl0IGlzIHNhZmUgdG8gYWxsb2NhdGUgYmFjayBjaGFubmVsIHNs
b3RzIHVzaW5nIGEgcmVjbGFpbWluZw0KPiA+IGFsbG9jYXRpb24uDQo+IA0KPiBJcyB0aGlzIGEg
cmVxdWlyZWQgY2hhbmdlIGZvciB0cmFuc3BvcnRzLCBvciBzaW1wbHkgYW4gb3B0aW1pemF0aW9u
Pw0KPiBXb25kZXJpbmcgaWYgYSBzaW1pbGFyIGNoYW5nZSBpcyBuZWVkZWQgZm9yIFJQQy1vdmVy
LVJETUEuDQoNCk5vdyB0aGF0IHdlIG5vIGxvbmdlciBuZWVkIHRvIGJlIGF0b21pYyBmb3IgdGhl
IHNvY2tldCByZWNlaXZlIGNvZGUsIEkNCmZpZ3VyZSB3ZSBjYW4gYWZmb3JkIHRoZSBjYWxsLiBU
aGUgYWx0ZXJuYXRpdmUgaXMgdGhhdCB3ZSBoYXZlIHRvIGRyb3ANCnRoZSBjb25uZWN0aW9uLCB3
aGljaCBpcyBhbHNvIHZlcnkgY29zdGx5Lg0KDQpDaGVlcnMNCiAgVHJvbmQNCg0KLS0gDQpUcm9u
ZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRy
b25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
